use cpal::{default_endpoint, EventLoop, Voice, UnknownTypeBuffer};

use futures::stream::Stream;
use futures::task::{self, Executor, Run};

use engine::*;
use ring_buffer::*;

use std::borrow::Cow;
use std::sync::{Arc, Mutex};
use std::iter::Iterator;
use std::thread::{self, JoinHandle};

pub type Error = Cow<'static, str>;

type Frame = [i16; 2];

struct DriverExecutor;

impl Executor for DriverExecutor {
    fn execute(&self, r: Run) {
        r.run();
    }
}

pub struct Driver {
    pub state: Arc<Mutex<(RingBuffer, Engine)>>,

    _voice: Voice,
    _render_thread_join_handle: JoinHandle<()>,
}

impl Driver {
    pub fn new(sample_rate: u32, desired_latency_ms: u32) -> Result<Driver, Error> {
        if desired_latency_ms == 0 {
            return Err(format!("desired_latency_ms must be greater than 0").into());
        }

        let endpoint = default_endpoint().ok_or(format!("Failed to get audio endpoint"))?;

        let format = endpoint.supported_formats()
            .map_err(|e| format!("Failed to get supported format list for endpoint: {}", e))?
            .find(|format| format.channels.len() == 2)
            .ok_or("Failed to find format with 2 channels")?;

        let buffer_frames = sample_rate * desired_latency_ms / 1000 * 2;
        let ring_buffer = RingBuffer {
            inner: vec![0; buffer_frames as usize].into_boxed_slice(),

            write_pos: 0,
            read_pos: 0,

            samples_written: 0,
            samples_read: 0,
        };

        let engine = Engine::new()?;

        let state = Arc::new(Mutex::new((ring_buffer, engine)));

        let event_loop = EventLoop::new();

        let (mut voice, stream) = Voice::new(&endpoint, &format, &event_loop).map_err(|e| format!("Failed to create voice: {}", e))?;
        voice.play();

        let mut resampler = LinearResampler::new(sample_rate as _, format.samples_rate.0 as _);

        let render_thread_state = state.clone();
        task::spawn(stream.for_each(move |output_buffer| {
            let mut render_thread_state = render_thread_state.lock().unwrap();
            let (ref mut ring_buffer, ref mut engine) = *render_thread_state;

            if ring_buffer.samples_read > ring_buffer.samples_written {
                let samples_to_render = ring_buffer.samples_read - ring_buffer.samples_written;
                let frames_to_render = samples_to_render / 2;

                engine.render(ring_buffer, frames_to_render as _);
            }

            match output_buffer {
                UnknownTypeBuffer::I16(mut buffer) => {
                    for sample in buffer.chunks_mut(format.channels.len()) {
                        for out in sample.iter_mut() {
                            *out = resampler.next(ring_buffer);
                        }
                    }
                }
                UnknownTypeBuffer::U16(mut buffer) => {
                    for sample in buffer.chunks_mut(format.channels.len()) {
                        for out in sample.iter_mut() {
                            *out = ((resampler.next(ring_buffer) as i32) + 32768) as u16;
                        }
                    }
                }
                UnknownTypeBuffer::F32(mut buffer) => {
                    for sample in buffer.chunks_mut(format.channels.len()) {
                        for out in sample.iter_mut() {
                            *out = (resampler.next(ring_buffer) as f32) / 32768.0;
                        }
                    }
                }
            }

            Ok(())
        })).execute(Arc::new(DriverExecutor));

        let render_thread_join_handle = thread::spawn(move || {
            event_loop.run();
        });

        Ok(Driver {
            state: state,

            _voice: voice,
            _render_thread_join_handle: render_thread_join_handle,
        })
    }
}

struct LinearResampler {
    from_sample_rate: u32,
    to_sample_rate: u32,

    current_from_frame: Frame,
    next_from_frame: Frame,
    from_fract_pos: u32,

    current_frame_channel_offset: u32,
}

impl LinearResampler {
    fn new(from_sample_rate: u32, to_sample_rate: u32) -> LinearResampler {
        let sample_rate_gcd = {
            fn gcd(a: u32, b: u32) -> u32 {
                if b == 0 {
                    a
                } else {
                    gcd(b, a % b)
                }
            }

            gcd(from_sample_rate, to_sample_rate)
        };

        LinearResampler {
            from_sample_rate: from_sample_rate / sample_rate_gcd,
            to_sample_rate: to_sample_rate / sample_rate_gcd,

            current_from_frame: [0, 0],
            next_from_frame: [0, 0],
            from_fract_pos: 0,

            current_frame_channel_offset: 0,
        }
    }

    fn next(&mut self, input: &mut Iterator<Item = i16>) -> i16 {
        fn interpolate(a: i16, b: i16, num: u32, denom: u32) -> i16 {
            (((a as i32) * ((denom - num) as i32) + (b as i32) * (num as i32)) / (denom as i32)) as _
        }

        let ret = match self.current_frame_channel_offset {
            0 => interpolate(self.current_from_frame[0], self.next_from_frame[0], self.from_fract_pos, self.to_sample_rate),
            _ => interpolate(self.current_from_frame[1], self.next_from_frame[1], self.from_fract_pos, self.to_sample_rate)
        };

        self.current_frame_channel_offset += 1;
        if self.current_frame_channel_offset >= 2 {
            self.current_frame_channel_offset = 0;

            self.from_fract_pos += self.from_sample_rate;
            while self.from_fract_pos > self.to_sample_rate {
                self.from_fract_pos -= self.to_sample_rate;

                self.current_from_frame = self.next_from_frame;

                let left = input.next().unwrap_or(0);
                let right = input.next().unwrap_or(0);
                self.next_from_frame = [left, right];
            }
        }

        ret
    }
}
