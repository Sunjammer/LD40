#ifndef STATIC_LINK
#define IMPLEMENT_API
#endif

#if defined(HX_WINDOWS) || defined(HX_MACOS) || defined(HX_LINUX)
#define NEKO_COMPATIBLE
#endif


#include <hx/CFFI.h>
#include "Utils.h"

#pragma comment(lib, "../audio_lib/target/release/audio_lib.lib")
#include "../audio_lib/audio_lib.h"

using namespace audiojank;

static context_t *context;

extern "C" {

    static void audiojank_create_context()
    {
        context = context_create();
    }
	

    static void audiojank_play_sample_in_space(value sampleId, value relativeX, value relativeY) {
        context_play_sample_in_space(context, val_int(sampleId), val_float(relativeX), val_float(relativeY));
    }
	
	static void audiojank_context_set_bgm_volume(value vol){
		context_set_bgm_volume(context, val_float(vol));
	}
	
	static void audiojank_context_play_boot_sequence_sample(value vol){
		context_play_boot_sequence_sample(context, val_float(vol));
	}


    void audiojank_main () {
        val_int(0); // Fix Neko init
    }
	
	int audiojank_register_prims () { return 0; }
}

DEFINE_ENTRY_POINT (audiojank_main);
DEFINE_PRIM (audiojank_create_context, 0);
DEFINE_PRIM (audiojank_play_sample_in_space, 3);
DEFINE_PRIM (audiojank_context_set_bgm_volume, 1);
DEFINE_PRIM (audiojank_context_play_boot_sequence_sample, 1);
