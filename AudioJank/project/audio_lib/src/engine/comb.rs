use super::helpers::*;

pub struct Comb {
    buffer: Vec<f32>,
    buffer_index: u32,
    damp: f32,
    feedback: f32,

    filter_store: f32,
}

impl Comb {
    pub fn new(buffer_size: u32, damp: f32, feedback: f32) -> Comb {
        Comb {
            buffer: vec![0.0; buffer_size as usize],
            buffer_index: 0,
            damp: damp,
            feedback: feedback,

            filter_store: 0.0,
        }
    }

    pub fn next(&mut self, input: f32) -> f32 {
        let output = self.buffer[self.buffer_index as usize];

        self.filter_store = output * (1.0 - self.damp) + self.filter_store * self.damp;
        self.buffer[self.buffer_index as usize] = fix_denormal(input + (self.filter_store * self.feedback));

        self.buffer_index += 1;
        if self.buffer_index >= self.buffer.len() as u32 {
            self.buffer_index = 0;
        }

        output
    }
}
