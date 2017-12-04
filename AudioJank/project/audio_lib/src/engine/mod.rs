mod all_pass;
mod comb;
mod freeverb;
mod helpers;
mod state_variable_filter;

use audrey::read::Reader;

use ring_buffer::*;

use self::freeverb::*;
use self::helpers::*;
use self::state_variable_filter::*;

use std::borrow::Cow;
use std::collections::HashMap;
use std::io::Cursor;

pub type Error = Cow<'static, str>;

struct Sample {
    frames: Box<[[f32; 2]]>,
}

impl Sample {
    fn from_bytes(data: &[u8]) -> Result<Sample, Error> {
        let cursor = Cursor::new(data);
        let mut reader = Reader::new(cursor)
            .map_err(|e| format!("Couldn't load sample: {}", e))?;
        let frames = reader.frames().map(|x| x.unwrap_or([0, 0])).collect::<Vec<_>>();
        Ok(Sample::from_frames(frames))
    }

    fn from_frames(frames: Vec<[i16; 2]>) -> Sample {
        Sample {
            frames: frames.into_iter().map(|x| [((x[0] as f64) / 32768.0) as f32, ((x[1] as f64) / 32768.0) as f32]).collect::<Vec<_>>().into_boxed_slice(),
        }
    }
}

type SampleId = u32;

pub enum Volume {
    Static(f32),
    Bgm,
}

enum Voice {
    OneShotSample { sample_id: SampleId, volume: Volume, frame_index: u32 },
    SpaceSample {
        sample_id: SampleId,
        filter_left: StateVariableFilter,
        filter_right: StateVariableFilter,
        volume_left: f32,
        volume_right: f32,
        frame_index: u32,
    },
}

type VoiceId = u32;

pub struct Engine {
    samples: HashMap<SampleId, Sample>,
    voices: HashMap<VoiceId, Voice>,

    small_room: Freeverb,
    large_room: Freeverb,

    bgm_events: [(u32, SampleId); 3],
    pub bgm_volume: f32,

    pub boot_sample_id: SampleId,

    pub enemy_dialog_high_ids: [SampleId; 6],
    pub enemy_dialog_low_ids: [SampleId; 6],
    pub explosion_ids: [SampleId; 3],
    pub sonar_id: SampleId,
    pub sonar_echo_id: SampleId,
    pub turret_fire_id: SampleId,
}

impl Engine {
    pub fn new() -> Result<Engine, Error> {
        let mut ret = Engine {
            samples: HashMap::new(),
            voices: HashMap::new(),

            small_room: Freeverb::new(0.5, 0.5, 0.7, 1.0),
            large_room: Freeverb::new(0.99, 0.3, 1.0, 1.0),

            bgm_events: [(0, 0); 3],
            bgm_volume: 0.02,

            boot_sample_id: 0,
            enemy_dialog_high_ids: [0; 6],
            enemy_dialog_low_ids: [0; 6],
            explosion_ids: [0; 3],
            sonar_id: 0,
            sonar_echo_id: 0,
            turret_fire_id: 0,
        };

        // TODO: Look into streaming these!!
        let bgm_ringy_shit_id = ret.load_sample(include_bytes!("assets/bgm/ringy_shit.flac"))?;
        let bgm_right_in_the_earholes_id = ret.load_sample(include_bytes!("assets/bgm/right_in_the_earholes.flac"))?;
        let bgm_hyper_light_shitter_id = ret.load_sample(include_bytes!("assets/bgm/hyper_light_shitter.flac"))?;
        //let bgm_slappy_bass_id = ret.load_sample(include_bytes!("assets/bgm/slappy_bass.flac"))?;
        ret.bgm_events = [
            (0, bgm_ringy_shit_id),
            (0, bgm_right_in_the_earholes_id),
            ((48.0 * 4.0 * 60.0 / 140.0 * 44100.0) as u32, bgm_hyper_light_shitter_id),
            //(0, bgm_slappy_bass_id),
        ];

        ret.boot_sample_id = ret.load_sample(include_bytes!("assets/boot_sequence.flac"))?;

        ret.enemy_dialog_high_ids = [
            ret.load_sample(include_bytes!("assets/enemy_dialogue_high_1.flac"))?,
            ret.load_sample(include_bytes!("assets/enemy_dialogue_high_2.flac"))?,
            ret.load_sample(include_bytes!("assets/enemy_dialogue_high_3.flac"))?,
            ret.load_sample(include_bytes!("assets/enemy_dialogue_high_4.flac"))?,
            ret.load_sample(include_bytes!("assets/enemy_dialogue_high_5.flac"))?,
            ret.load_sample(include_bytes!("assets/enemy_dialogue_high_6.flac"))?,
        ];
        ret.enemy_dialog_low_ids = [
            ret.load_sample(include_bytes!("assets/enemy_dialogue_low_1.flac"))?,
            ret.load_sample(include_bytes!("assets/enemy_dialogue_low_2.flac"))?,
            ret.load_sample(include_bytes!("assets/enemy_dialogue_low_3.flac"))?,
            ret.load_sample(include_bytes!("assets/enemy_dialogue_low_4.flac"))?,
            ret.load_sample(include_bytes!("assets/enemy_dialogue_low_5.flac"))?,
            ret.load_sample(include_bytes!("assets/enemy_dialogue_low_6.flac"))?,
        ];
        ret.explosion_ids = [
            ret.load_sample(include_bytes!("assets/explosion_1.flac"))?,
            ret.load_sample(include_bytes!("assets/explosion_2.flac"))?,
            ret.load_sample(include_bytes!("assets/explosion_3.flac"))?,
        ];
        ret.sonar_id = ret.load_sample(include_bytes!("assets/sonar.flac"))?;
        ret.sonar_echo_id = ret.load_sample(include_bytes!("assets/sonar_echo.flac"))?;
        ret.turret_fire_id = ret.load_sample(include_bytes!("assets/turret_fire.flac"))?;

        Ok(ret)
    }

    pub fn render(&mut self, ring_buffer: &mut RingBuffer, mut frames_to_render: u32) {
        let bgm_events_loop_bars = 80;
        let bgm_events_loop_samples = ((bgm_events_loop_bars as f64) * 4.0 * 60.0 / 140.0 * 44100.0) as u32;

        while frames_to_render > 0 {
            let mut next_event_start = None;
            for &(event_start, _) in self.bgm_events.iter() {
                next_event_start = match next_event_start {
                    Some(current_start) => Some(if event_start < current_start {
                        event_start
                    } else {
                        current_start
                    }),
                    _ => Some(event_start)
                };
            }
            let next_event_start = next_event_start.unwrap();

            let batch_frames_to_render = if next_event_start < frames_to_render {
                next_event_start
            } else {
                frames_to_render
            };

            if batch_frames_to_render > 0 {
                self.render_impl(ring_buffer, batch_frames_to_render);
            }

            let mut event_play_samples = Vec::new();
            for &mut (ref mut event_start, sample_id) in self.bgm_events.iter_mut() {
                if *event_start == 0 {
                    event_play_samples.push(sample_id);
                    *event_start += bgm_events_loop_samples;
                } else {
                    *event_start -= batch_frames_to_render;
                }
            }
            for sample_id in event_play_samples {
                self.play_sample(sample_id, Volume::Bgm);
            }

            frames_to_render -= batch_frames_to_render;
        }
    }

    fn render_impl(&mut self, ring_buffer: &mut RingBuffer, frames_to_render: u32) {
        let mut mix_buffer = vec![[0.0, 0.0]; frames_to_render as usize];

        let mut finished_voice_ids = Vec::new();

        for (voice_id, voice) in self.voices.iter_mut() {
            match voice {
                &mut Voice::SpaceSample { sample_id, ref mut filter_left, ref mut filter_right, volume_left, volume_right, ref mut frame_index } => {
                    if let Some(ref sample) = self.samples.get(&sample_id) {
                        for i in 0..frames_to_render {
                            let frame = &sample.frames[*frame_index as usize];

                            let mix_frame = &mut mix_buffer[i as usize];
                            mix_frame[0] += filter_left.next(frame[0]) * volume_left;
                            mix_frame[1] += filter_right.next(frame[1]) * volume_right;

                            *frame_index += 1;
                            if *frame_index >= sample.frames.len() as u32 {
                                finished_voice_ids.push(*voice_id);
                                break;
                            }
                        }
                    }
                }
                _ => () // Only SpaceSample voices will go through the reverb chain
            }
        }

        for frame in mix_buffer.iter_mut() {
            let small_reverb_frame = self.small_room.next(*frame);
            frame[0] += small_reverb_frame[0] * 0.3;
            frame[1] += small_reverb_frame[1] * 0.3;
            let large_reverb_frame = self.large_room.next(*frame);
            frame[0] += large_reverb_frame[0] * 0.9;
            frame[1] += large_reverb_frame[1] * 0.9;
        }

        for (voice_id, voice) in self.voices.iter_mut() {
            match voice {
                &mut Voice::OneShotSample { sample_id, ref volume, ref mut frame_index } => {
                    if let Some(ref sample) = self.samples.get(&sample_id) {
                        let volume = match volume {
                            &Volume::Static(volume) => volume,
                            &Volume::Bgm => self.bgm_volume,
                        };
                        for i in 0..frames_to_render {
                            let frame = &sample.frames[*frame_index as usize];

                            let mix_frame = &mut mix_buffer[i as usize];
                            mix_frame[0] += frame[0] * volume;
                            mix_frame[1] += frame[1] * volume;

                            *frame_index += 1;
                            if *frame_index >= sample.frames.len() as u32 {
                                finished_voice_ids.push(*voice_id);
                                break;
                            }
                        }
                    }
                }
                _ => () // SpaceSamples have already been processed
            }
        }

        for id in finished_voice_ids {
            self.voices.remove(&id);
        }

        for frame in mix_buffer.into_iter() {
            let mut left = (frame[0] * 32768.0) as i32;
            let mut right = (frame[1] * 32768.0) as i32;
            if left < -32768 { left = -32768; }
            if left > 32767 { left = 32767; }
            if right < -32768 { right = -32768; }
            if right > 32767 { right = 32767; }

            ring_buffer.push(left as _);
            ring_buffer.push(right as _);
        }
    }

    fn load_sample(&mut self, data: &[u8]) -> Result<SampleId, Error> {
        let sample = Sample::from_bytes(data)?;
        Ok(self.insert_sample(sample))
    }

    fn insert_sample(&mut self, sample: Sample) -> SampleId {
        let mut id = 0;
        while self.samples.contains_key(&id) {
            id += 1;
        }
        self.samples.insert(id, sample);
        id
    }

    pub fn play_sample_in_space(&mut self, sample_id: SampleId, relative_x: f32, relative_y: f32) -> VoiceId {
        let mut distance = (relative_x * relative_x + relative_y * relative_y).sqrt();
        let mut distance_div = distance;
        if distance_div < 1e-20 {
            distance_div = 1e-20;
        }
        let direction_x = relative_x / distance_div;
        let direction_y = relative_y / distance_div;
        if distance > 1.0 {
            distance = 1.0;
        }

        let d = 1.0 - distance;

        let mut filter = StateVariableFilter::new();
        filter.freq = param_to_freq((d * d) * 0.92 + 0.08);
        filter.resonance = param_to_resonance(d * 0.3 + 0.7);

        let volume = (d * d * 0.7 + 0.3) * 0.75;

        let pan = direction_x * 0.5 + 0.5;
        let volume_left = volume * (1.0 - pan).sqrt();
        let volume_right = volume * pan.sqrt();

        let voice = Voice::SpaceSample {
            sample_id: sample_id,
            filter_left: filter.clone(),
            filter_right: filter,
            volume_left: volume_left,
            volume_right: volume_right,
            frame_index: 0,
        };

        self.insert_voice(voice)
    }

    pub fn play_sample(&mut self, sample_id: SampleId, volume: Volume) -> VoiceId {
        let voice = Voice::OneShotSample { sample_id: sample_id, volume: volume, frame_index: 0 };
        self.insert_voice(voice)
    }

    fn insert_voice(&mut self, voice: Voice) -> VoiceId {
        let mut id = 0;
        while self.voices.contains_key(&id) {
            id += 1;
        }
        self.voices.insert(id, voice);
        id
    }
}
