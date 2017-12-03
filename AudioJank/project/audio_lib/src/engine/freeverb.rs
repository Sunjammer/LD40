use super::all_pass::*;
use super::comb::*;
use super::helpers::*;

pub struct Freeverb {
    left_combs: [Comb; 8],
    right_combs: [Comb; 8],
    left_all_passes: [AllPass; 4],
    right_all_passes: [AllPass; 4],
    width: f32,
    dry_wet: f32,
}

impl Freeverb {
    pub fn new(room_size: f32, damp: f32, width: f32, dry_wet: f32) -> Freeverb {
        Freeverb {
            left_combs: [
                Comb::new(1116, damp, room_size),
                Comb::new(1188, damp, room_size),
                Comb::new(1277, damp, room_size),
                Comb::new(1356, damp, room_size),
                Comb::new(1422, damp, room_size),
                Comb::new(1491, damp, room_size),
                Comb::new(1557, damp, room_size),
                Comb::new(1617, damp, room_size),
            ],
            right_combs: [
                Comb::new(1116 + 23, damp, room_size),
                Comb::new(1188 + 23, damp, room_size),
                Comb::new(1277 + 23, damp, room_size),
                Comb::new(1356 + 23, damp, room_size),
                Comb::new(1422 + 23, damp, room_size),
                Comb::new(1491 + 23, damp, room_size),
                Comb::new(1557 + 23, damp, room_size),
                Comb::new(1617 + 23, damp, room_size),
            ],
            left_all_passes: [
                AllPass::new(556, 0.5),
                AllPass::new(441, 0.5),
                AllPass::new(341, 0.5),
                AllPass::new(225, 0.5),
            ],
            right_all_passes: [
                AllPass::new(556 + 23, 0.5),
                AllPass::new(441 + 23, 0.5),
                AllPass::new(341 + 23, 0.5),
                AllPass::new(225 + 23, 0.5),
            ],
            width: width,
            dry_wet: dry_wet,
        }
    }

    pub fn next(&mut self, input: [f32; 2]) -> [f32; 2] {
        let gain = 0.015;

        let wet1 = self.width * 0.5 + 0.5;
        let wet2 = (1.0 - self.width) * 0.5;

        let summed_input = (input[0] + input[1]) * gain;

        let mut out_left = 0.0;
        let mut out_right = 0.0;

        // Accumulate combs in parallel
        for i in 0..8 {
            out_left += self.left_combs[i].next(summed_input);
            out_right += self.right_combs[i].next(summed_input);
        }

        // Feed allpasses in series
        for i in 0..4 {
            out_left = self.left_all_passes[i].next(out_left);
            out_right = self.right_all_passes[i].next(out_right);
        }

        out_left = out_left * wet1 + out_right * wet2;
        out_right = out_right * wet1 + out_left * wet2;

        out_left = fix_denormal(input[0] * (1.0 - self.dry_wet) + out_left * self.dry_wet);
        out_right = fix_denormal(input[1] * (1.0 - self.dry_wet) + out_right * self.dry_wet);

        [out_left, out_right]
    }
}
