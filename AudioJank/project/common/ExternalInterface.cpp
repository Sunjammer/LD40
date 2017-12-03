#ifndef STATIC_LINK
#define IMPLEMENT_API
#endif

#if defined(HX_WINDOWS) || defined(HX_MACOS) || defined(HX_LINUX)
#define NEKO_COMPATIBLE
#endif


#include <hx/CFFI.h>
#include "Utils.h"

#include "../audio_lib/audio_lib.h"

using namespace audiojank;

static context_t *context;

static void audiojank_create_context()
{
    context = context_create();
}
DEFINE_PRIM (audiojank_create_context, 0);


static value audiojank_sample_method (value inputValue) {

	int returnValue = SampleMethod(val_int(inputValue));
	return alloc_int(returnValue);

}
DEFINE_PRIM (audiojank_sample_method, 1);



extern "C" void audiojank_main () {

	val_int(0); // Fix Neko init

}
DEFINE_ENTRY_POINT (audiojank_main);



extern "C" int audiojank_register_prims () { return 0; }
