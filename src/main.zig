const std = @import("std");
const c = @cImport({
    @cInclude("SDL2/SDL.h");
});

const FPS = 60;
const DELTA_TIME_SEC: f32 = 1.0 / @intToFloat(f32, FPS);
const WINDOW_WIDTH = 800;
const WINDOW_HEIGHT = 600;
const BACKGROUND_COLOR = 0xFF000000;
const ROPE_COLOR = 0xFFFFFFFF;
const NB_ROPE_SEG: i32 = 50;
const ROPE_SPEED_X: f32 = 100;
const ROPE_SPEED_Y: f32 = -50;

var pause = false;

const Point = struct {
    x: f32,
    y: f32,
};
const Segment = struct {
    pt1: Point,
    pt2: Point,
};

var rope: [NB_ROPE_SEG]Segment = undefined;

fn make_point_from_int(x: usize, y: usize) Point {
    return Point{ .x = @intToFloat(f32, x), .y = @intToFloat(f32, y) };
}

fn init_rope() void {
    for (rope) |*item, i| {
        item.* = Segment{
            .pt1 = make_point_from_int(100 + 10 * i, 200 + i * i),
            .pt2 = make_point_from_int(100 + 10 * (i + 1), 200 + (i + 1) * (i + 1)),
        };
    }
}

fn set_color(renderer: *c.SDL_Renderer, color: u32) void {
    const r = @truncate(u8, color);
    const g = @truncate(u8, (color >> 8));
    const b = @truncate(u8, (color >> (2 * 8)));
    const a = @truncate(u8, (color >> (3 * 8)));
    _ = c.SDL_SetRenderDrawColor(renderer, r, g, b, a);
}

// TODO always inline
fn translate_point(dx: f32, dy: f32, pt: Point) Point {
    return Point{ .x = pt.x + dx, .y = pt.y + dy };
}

// TODO always inline
fn translate_segment(dx: f32, dy: f32, seg: Segment) Segment {
    return Segment{ .pt1 = translate_point(dx, dy, seg.pt1), .pt2 = translate_point(dx, dy, seg.pt2) };
}

fn translate_rope(dx: f32, dy: f32) void {
    for (rope) |*item| {
        item.* = translate_segment(dx, dy, item.*);
    }
}

fn update(dt: f32) void {
    if (!pause) {
        translate_rope(dt * ROPE_SPEED_X, dt * ROPE_SPEED_Y);
    }
}

// TODO always inline
fn draw_segment(renderer: *c.SDL_Renderer, seg: Segment) void {
    _ = c.SDL_RenderDrawLine(renderer, @floatToInt(i32, seg.pt1.x), @floatToInt(i32, seg.pt1.y), @floatToInt(i31, seg.pt2.x), @floatToInt(i32, seg.pt2.y));
}

fn render(renderer: *c.SDL_Renderer) void {
    set_color(renderer, ROPE_COLOR);
    for (rope) |*item| {
        draw_segment(renderer, item.*);
    }
}

pub fn main() !void {
    init_rope();

    if (c.SDL_Init(c.SDL_INIT_VIDEO) < 0) {
        c.SDL_Log("Unable to initialize SDL: %s", c.SDL_GetError());
        return error.SDLInitializationFailed;
    }
    defer c.SDL_Quit();

    const window = c.SDL_CreateWindow("Cut the rope", 0, 0, WINDOW_WIDTH, WINDOW_HEIGHT, 0) orelse {
        c.SDL_Log("Unable to initialize SDL: %s", c.SDL_GetError());
        return error.SDLInitializationFailed;
    };
    defer c.SDL_DestroyWindow(window);

    const renderer = c.SDL_CreateRenderer(window, -1, c.SDL_RENDERER_ACCELERATED) orelse {
        c.SDL_Log("Unable to initialize SDL: %s", c.SDL_GetError());
        return error.SDLInitializationFailed;
    };
    defer c.SDL_DestroyRenderer(renderer);

    while (true) {
        var event: c.SDL_Event = undefined;
        while (c.SDL_PollEvent(&event) != 0) {
            switch (event.@"type") {
                c.SDL_QUIT => {
                    return;
                },
                c.SDL_KEYDOWN => {
                    switch (event.key.keysym.sym) {
                        'q' => return,
                        ' ' => pause = !pause,
                        else => {},
                    }
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
