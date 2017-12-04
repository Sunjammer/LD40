extern crate audrey;
extern crate cpal;
extern crate futures;
extern crate libc;

mod driver;
mod engine;
mod ring_buffer;

use driver::*;

struct Context {
    driver: Driver,
}

impl Context {
    fn new() -> Result<Context, Error> {
        let driver = Driver::new(44100, 100)?;

        Ok(Context {
            driver: driver,
        })
    }

    fn get_bgm_volume(&mut self) -> f32 {
        let mut driver_state = self.driver.state.lock().unwrap();
        let engine = &mut driver_state.1;

        engine.bgm_volume
    }

    fn set_bgm_volume(&mut self, value: f32) {
        let mut driver_state = self.driver.state.lock().unwrap();
        let engine = &mut driver_state.1;

        engine.bgm_volume = value;
    }

    fn play_boot_sequence_sample(&mut self, volume: f32) {
        let mut driver_state = self.driver.state.lock().unwrap();
        let engine = &mut driver_state.1;

        let sample_id = engine.boot_sample_id;
        engine.play_sample(sample_id, engine::Volume::Static(volume));
    }

    fn play_sample_in_space(&mut self, sample_id: u32, relative_x: f32, relative_y: f32) {
        let mut driver_state = self.driver.state.lock().unwrap();
        let engine = &mut driver_state.1;

        let sample_id = match sample_id {
            0 => engine.enemy_dialog_high_ids[0],
            1 => engine.enemy_dialog_high_ids[1],
            2 => engine.enemy_dialog_high_ids[2],
            3 => engine.enemy_dialog_high_ids[3],
            4 => engine.enemy_dialog_high_ids[4],
            5 => engine.enemy_dialog_high_ids[5],
            6 => engine.enemy_dialog_low_ids[0],
            7 => engine.enemy_dialog_low_ids[1],
            8 => engine.enemy_dialog_low_ids[2],
            9 => engine.enemy_dialog_low_ids[3],
            10 => engine.enemy_dialog_low_ids[4],
            11 => engine.enemy_dialog_low_ids[5],

            12 => engine.explosion_ids[0],
            13 => engine.explosion_ids[1],
            14 => engine.explosion_ids[2],

            15 => engine.sonar_id,
            16 => engine.sonar_echo_id,
            _ => engine.turret_fire_id,
        };

        engine.play_sample_in_space(sample_id, relative_x, relative_y);
    }
}

pub mod c_api {
    use super::*;

    use libc::c_void;

    use std::ptr;

    #[no_mangle]
    pub extern fn context_create() -> *mut c_void {
        match Context::new() {
            Ok(context) => Box::into_raw(Box::new(context)) as *mut c_void,
            Err(e) => {
                println!("Error creating context: {}", e);
                ptr::null_mut()
            }
        }
    }

    #[no_mangle]
    pub unsafe extern fn context_free(context: *mut c_void) {
        Box::from_raw(context as *mut Context);
    }

    fn deref_context<'a>(context: *mut c_void) -> &'a mut Context {
        unsafe { &mut *(context as *mut Context) }
    }

    #[no_mangle]
    pub extern fn context_get_bgm_volume(context: &mut c_void) -> f32 {
        let context = deref_context(context);
        context.get_bgm_volume()
    }

    #[no_mangle]
    pub extern fn context_set_bgm_volume(context: &mut c_void, volume: f32) {
        let context = deref_context(context);
        context.set_bgm_volume(volume);
    }

    #[no_mangle]
    pub extern fn context_play_boot_sequence_sample(context: &mut c_void, volume: f32) {
        let context = deref_context(context);
        context.play_boot_sequence_sample(volume);
    }

    #[no_mangle]
    pub extern fn context_play_sample_in_space(context: &mut c_void, sample_id: u32, relative_x: f32, relative_y: f32) {
        let context = deref_context(context);
        context.play_sample_in_space(sample_id, relative_x, relative_y);
    }
}

pub use c_api::*;
