#include <3ds.h>
#include <stdio.h>
int main(int argc, char **argv) {
    // Initialize 3DS graphics and console services
    gfxInitDefault();
    consoleInit(GFX_TOP, NULL);
    // Initial game variables
    float px = 40.0f;
    float py = 140.0f;
    float vy = 0.0f;
    bool on_ground = true;
    int score = 0;
    int bread = 0;
    // Print title screen instructions on top screen
    printf("\x1b[1;10H=== EPIC DUCK 3DS ===");
    printf("\x1b[4;2HControls:");
    printf("\x1b[5;2H- Circle Pad / D-Pad: Move");
    printf("\x1b[6;2H- A Button: Jump");
    printf("\x1b[7;2H- Y Button: Shoot");
    printf("\x1b[9;2H- START: Exit to Homebrew");
    // Main 3DS execution loop
    while (aptMainLoop()) {
        // Scan hardware inputs each frame
        hidScanInput();
        u32 kDown = hidKeysDown();
        u32 kHeld = hidKeysHeld();
        // Exit application when START is pressed
        if (kDown & KEY_START) break;
        // Player Movement (supports D-pad and Circle Pad directions)
        if (kHeld & (KEY_DLEFT | KEY_CPAD_LEFT))  px -= 2.5f;
        if (kHeld & (KEY_DRIGHT | KEY_CPAD_RIGHT)) px += 2.5f;
        // Jump Handling (A Button or D-Pad Up)
        if ((kDown & (KEY_A | KEY_DUP)) && on_ground) {
            vy = -7.5f;
            on_ground = false;
        }
        // Apply gravity and ground physics
        vy += 0.38f;
        py += vy;
        if (py >= 150.0f) {
            py = 150.0f;
            vy = 0.0f;
            on_ground = true;
        }
        // Real-time HUD refresh on the top screen console
        printf("\x1b[13;2H[X: %.1f | Y: %.1f]  ", px, py);
        printf("\x1b[14;2HScore: %d   Bread: %d   ", score, bread);
        // Swap buffers and wait for vertical blank to maintain smooth frame rate
        gfxFlushBuffers();
        gfxSwapBuffers();
        gspWaitForVBlank();
    }
    // Clean up graphics services before exit
    gfxExit();
    return 0;
}
