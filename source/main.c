#include <3ds.h>
#include <stdio.h>
#include <citro2d.h>
#include <citro3d.h>

// Placeholder for Epic Duck 3DS
// REPLACE THIS ENTIRE FILE with your real game code!
// Your original main.c goes here.

int main(int argc, char** argv) {
    gfxInitDefault();
    C3D_Init(C3D_DEFAULT_CMDBUF_SIZE);
    C2D_Init(C2D_DEFAULT_MAX_OBJECTS);
    C2D_Prepare();

    consoleInit(GFX_TOP, NULL);
    printf("Epic Duck 3DS\n");
    printf("Placeholder build - replace source/main.c with your code!\n");
    printf("\nControls (from README):\n");
    printf("D-pad / Circle Pad: move\n");
    printf("A: jump\n");
    printf("B: dash / boss attack\n");
    printf("START: pause / exit\n");

    while (aptMainLoop()) {
        hidScanInput();
        u32 kDown = hidKeysDown();
        if (kDown & KEY_START) break;

        C3D_FrameBegin(C3D_FRAME_SYNCDRAW);
        C2D_TargetClear(C2D_CreateScreenTarget(GFX_TOP, GFX_LEFT), C2D_Color32(0x20, 0x40, 0x80, 0xFF));
        C2D_SceneBegin(C2D_CreateScreenTarget(GFX_TOP, GFX_LEFT));
        // Draw stuff here later
        C3D_FrameEnd(0);
    }

    C2D_Fini();
    C3D_Fini();
    gfxExit();
    return 0;
}
