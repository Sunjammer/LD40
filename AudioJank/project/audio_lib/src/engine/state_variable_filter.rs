use super::helpers::*;

use std::f32::consts::PI;

#[derive(Clone)]
pub enum StateVariableFilterType {
    Lowpass,
    Highpass,
    Bandpass,
    Notch,
}

#[derive(Clone)]
pub struct StateVariableFilter {
    pub filter_type: StateVariableFilterType,
    pub freq: f32,
    pub resonance: f32,

    last_input: f32,
    low: f32,
    band: f32,
}

impl StateVariableFilter {
    pub fn new() -> StateVariableFilter {
        StateVariableFilter {
            filter_type: StateVariableFilterType::Lowpass,
            freq: 20.0,
            resonance: 0.99,

            last_input: 0.0,
            low: 0.0,
            band: 0.0,
        }
    }

    pub fn next(&mut self, input: f32) -> f32 {
        let f = 1.5 * (PI * self.freq / 2.0 / 44100.0).sin();
        let q = self.resonance;

        let last_input = self.last_input;
        let a = self.run((last_input + input) * 0.5, f, q);
        let b = self.run(input, f, q);
        let ret = fix_denormal((a + b) * 0.5);

        self.last_input = input;

        ret
    }

    fn run(&mut self, input: f32, f: f32, q: f32) -> f32 {
        self.low = fix_denormal(self.low + f * self.band);
        let high = fix_denormal(q * (input - self.band) - self.low);
        self.band = fix_denormal(self.band + f * high);

        match self.filter_type {
            StateVariableFilterType::Lowpass => self.low,
            StateVariableFilterType::Highpass => high,
            StateVariableFilterType::Bandpass => self.band,
            StateVariableFilterType::Notch => self.low + high,
        }
    }
}
