const std = @import("std");
const c = @cImport({
    @cInclude("SDL2/SDL.h");
});

const FPS = 60;
const DELTA_TIME_SEC: f32 = 1.0 / @intToFloat(f32, FPS);
const WINDOW_WIDTH = 800;
const WINDOW_HEIGHT = 600;
const BACKGROUND_COLOR = 0;
const RECT_SIZE: f32 = 25;
const RECT_SPEED: f32 = 350;
const RECT_COLOR = 0xFFFFFFFF;

var rect_x: f32 = WINDOW_WIDTH / 2 - RECT_SIZE / 2;
var rect_y: f32 = 30;
var quit = false;

fn make_rect(x: f32, y: f32, w: f32, h: f32) c.SDL_Rect {
    return c.SDL_Rect{ .x = @floatToInt(i32, x), .y = @floatToInt(i32, y), .w = @floatToInt(i32, w), .h = @floatToInt(i32, h) };
}

fn set_color(renderer: *c.SDL_Renderer, color: u32) void {
    const r = @truncate(u8, color);
    const g = @truncate(u8, (color >> 8));
    const b = @truncate(u8, (color >> (2 * 8)));
    const a = @truncate(u8, (color >> (3 * 8)));
    _ = c.SDL_SetRenderDrawColor(renderer, r, g, b, a);
}

fn rect(x: f32, y: f32) c.SDL_Rect {
    return make_rect(x, y, RECT_SIZE, RECT_SIZE);
}

fn update(_: f32) void {}

fn render(renderer: *c.SDL_Renderer) void {
    set_color(renderer, RECT_COLOR);
    _ = c.SDL_RenderFillRect(renderer, &rect(rect_x, rect_y));
}

pub fn main() !void {
    if (c.SDL_Init(c.SDL_INIT_VIDEO) < 0) {
        c.SDL_Log("Unable to initialize SDL: %s", c.SDL_GetError());
        return error.SDLInitializationFailed;
    }
    defer c.SDL_Quit();

    const window = c.SDL_CreateWindow("Zigout", 0, 0, WINDOW_WIDTH, WINDOW_HEIGHT, 0) orelse {
        c.SDL_Log("Unable to initialize SDL: %s", c.SDL_GetError());
        return error.SDLInitializationFailed;
    };
    defer c.SDL_DestroyWindow(window);

    const renderer = c.SDL_CreateRenderer(window, -1, c.SDL_RENDERER_ACCELERATED) orelse {
        c.SDL_Log("Unable to initialize SDL: %s", c.SDL_GetError());
        return error.SDLInitializationFailed;
    };
    defer c.SDL_DestroyRenderer(renderer);

    while (!quit) {
        var event: c.SDL_Event = undefined;
        while (c.SDL_PollEvent(&event) != 0) {
            switch (event.@"type") {
                c.SDL_QUIT => {
                    quit = true;
                },
                else => {},
            }
        }

        update(DELTA_TIME_SEC);

        set_color(renderer, BACKGROUND_COLOR);
        _ = c.SDL_RenderClear(renderer);

        render(renderer);

        c.SDL_RenderPresent(renderer);

        c.SDL_Delay(1000 / FPS);
    }
}
