use super::helpers::*;

pub struct AllPass {
    buffer: Vec<f32>,
    buffer_index: u32,
    feedback: f32,
}

impl AllPass {
    pub fn new(buffer_size: u32, feedback: f32) -> AllPass {
        AllPass {
            buffer: vec![0.0; buffer_size as usize],
            buffer_index: 0,
            feedback: feedback,
        }
    }

    pub fn next(&mut self, input: f32) -> f32 {
        let buffer_out = self.buffer[self.buffer_index as usize];

        let output = -input + buffer_out;
        self.buffer[self.buffer_index as usize] = fix_denormal(input + buffer_out * self.feedback);

        self.buffer_index += 1;
        if self.buffer_index >= self.buffer.len() as u32 {
            self.buffer_index = 0;
        }

        output
    }
}
