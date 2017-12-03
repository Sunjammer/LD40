pub fn fix_denormal(f: f32) -> f32 {
    f + 1e-20
}

pub fn param_to_freq(param: f32) -> f32 {
    20.0 + (20000.0 - 20.0) * param * param
}

pub fn freq_to_param(freq: f32) -> f32 {
    ((freq - 20.0) / (20000.0 - 20.0)).sqrt()
}

pub fn param_to_resonance(param: f32) -> f32 {
    param * 0.99 + 0.01
}

pub fn resonance_to_param(resonance: f32) -> f32 {
    (resonance - 0.01) / 0.99
}
