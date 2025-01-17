const rl = @import("raylib");

const MYBLACK = rl.Color.init(10, 10, 10, 255);

const scr_width = 2200;
const scr_height = 1500;

const FPS: f32 = 60;
const DELTA_TIME_SEC: f32 = 1.0 / FPS;

var started = false;
var paused = false;

const GameState = enum { PLAYING, WIN, LOSE };
var state = GameState.PLAYING;

// Ball
var ball_dx: f32 = 1;
var ball_dy: f32 = 1;
var ball_x: f32 = scr_width / 2 - BALL_SIZE / 2;
var ball_y: f32 = BAR_Y - BAR_THICKNESS / 2 - BALL_SIZE;
const BALL_SIZE = 60;
const BALL_SPEED: f32 = 700;

// Bar
var bar_x: f32 = scr_width / 2 - BAR_LEN / 2;
const BAR_LEN = 300;
const BAR_THICKNESS = 25;
const BAR_Y = scr_height - BAR_THICKNESS - 150;

// Targets
const TARGET_WIDTH = BAR_LEN;
const TARGET_HEIGHT = BAR_THICKNESS * 3;
const TARGET_PADDING = 40;
const TARGET_OFFSET = 40;
const Target = struct { x: f32, y: f32, dead: bool = false };
var target_count: u8 = 36;
var target_pool = [_]Target{
    // First Row
    Target{ .x = 100 + (TARGET_WIDTH + TARGET_PADDING) * 0 - TARGET_OFFSET, .y = 100 + (TARGET_HEIGHT + TARGET_PADDING) * 0 },
    Target{ .x = 100 + (TARGET_WIDTH + TARGET_PADDING) * 1 - TARGET_OFFSET, .y = 100 + (TARGET_HEIGHT + TARGET_PADDING) * 0 },
    Target{ .x = 100 + (TARGET_WIDTH + TARGET_PADDING) * 2 - TARGET_OFFSET, .y = 100 + (TARGET_HEIGHT + TARGET_PADDING) * 0 },
    Target{ .x = 100 + (TARGET_WIDTH + TARGET_PADDING) * 3 - TARGET_OFFSET, .y = 100 + (TARGET_HEIGHT + TARGET_PADDING) * 0 },
    Target{ .x = 100 + (TARGET_WIDTH + TARGET_PADDING) * 4 - TARGET_OFFSET, .y = 100 + (TARGET_HEIGHT + TARGET_PADDING) * 0 },
    Target{ .x = 100 + (TARGET_WIDTH + TARGET_PADDING) * 5 - TARGET_OFFSET, .y = 100 + (TARGET_HEIGHT + TARGET_PADDING) * 0 },
    // Secend Row
    Target{ .x = 100 + (TARGET_WIDTH + TARGET_PADDING) * 0 + TARGET_OFFSET, .y = 100 + (TARGET_HEIGHT + TARGET_PADDING) * 1 },
    Target{ .x = 100 + (TARGET_WIDTH + TARGET_PADDING) * 1 + TARGET_OFFSET, .y = 100 + (TARGET_HEIGHT + TARGET_PADDING) * 1 },
    Target{ .x = 100 + (TARGET_WIDTH + TARGET_PADDING) * 2 + TARGET_OFFSET, .y = 100 + (TARGET_HEIGHT + TARGET_PADDING) * 1 },
    Target{ .x = 100 + (TARGET_WIDTH + TARGET_PADDING) * 3 + TARGET_OFFSET, .y = 100 + (TARGET_HEIGHT + TARGET_PADDING) * 1 },
    Target{ .x = 100 + (TARGET_WIDTH + TARGET_PADDING) * 4 + TARGET_OFFSET, .y = 100 + (TARGET_HEIGHT + TARGET_PADDING) * 1 },
    Target{ .x = 100 + (TARGET_WIDTH + TARGET_PADDING) * 5 + TARGET_OFFSET, .y = 100 + (TARGET_HEIGHT + TARGET_PADDING) * 1 },
    // Third Row
    Target{ .x = 100 + (TARGET_WIDTH + TARGET_PADDING) * 0 - TARGET_OFFSET, .y = 100 + (TARGET_HEIGHT + TARGET_PADDING) * 2 },
    Target{ .x = 100 + (TARGET_WIDTH + TARGET_PADDING) * 1 - TARGET_OFFSET, .y = 100 + (TARGET_HEIGHT + TARGET_PADDING) * 2 },
    Target{ .x = 100 + (TARGET_WIDTH + TARGET_PADDING) * 2 - TARGET_OFFSET, .y = 100 + (TARGET_HEIGHT + TARGET_PADDING) * 2 },
    Target{ .x = 100 + (TARGET_WIDTH + TARGET_PADDING) * 3 - TARGET_OFFSET, .y = 100 + (TARGET_HEIGHT + TARGET_PADDING) * 2 },
    Target{ .x = 100 + (TARGET_WIDTH + TARGET_PADDING) * 4 - TARGET_OFFSET, .y = 100 + (TARGET_HEIGHT + TARGET_PADDING) * 2 },
    Target{ .x = 100 + (TARGET_WIDTH + TARGET_PADDING) * 5 - TARGET_OFFSET, .y = 100 + (TARGET_HEIGHT + TARGET_PADDING) * 2 },
    // Fourth Row
    Target{ .x = 100 + (TARGET_WIDTH + TARGET_PADDING) * 0 + TARGET_OFFSET, .y = 100 + (TARGET_HEIGHT + TARGET_PADDING) * 3 },
    Target{ .x = 100 + (TARGET_WIDTH + TARGET_PADDING) * 1 + TARGET_OFFSET, .y = 100 + (TARGET_HEIGHT + TARGET_PADDING) * 3 },
    Target{ .x = 100 + (TARGET_WIDTH + TARGET_PADDING) * 2 + TARGET_OFFSET, .y = 100 + (TARGET_HEIGHT + TARGET_PADDING) * 3 },
    Target{ .x = 100 + (TARGET_WIDTH + TARGET_PADDING) * 3 + TARGET_OFFSET, .y = 100 + (TARGET_HEIGHT + TARGET_PADDING) * 3 },
    Target{ .x = 100 + (TARGET_WIDTH + TARGET_PADDING) * 4 + TARGET_OFFSET, .y = 100 + (TARGET_HEIGHT + TARGET_PADDING) * 3 },
    Target{ .x = 100 + (TARGET_WIDTH + TARGET_PADDING) * 5 + TARGET_OFFSET, .y = 100 + (TARGET_HEIGHT + TARGET_PADDING) * 3 },
    // Fifth Row
    Target{ .x = 100 + (TARGET_WIDTH + TARGET_PADDING) * 0 - TARGET_OFFSET, .y = 100 + (TARGET_HEIGHT + TARGET_PADDING) * 4 },
    Target{ .x = 100 + (TARGET_WIDTH + TARGET_PADDING) * 1 - TARGET_OFFSET, .y = 100 + (TARGET_HEIGHT + TARGET_PADDING) * 4 },
    Target{ .x = 100 + (TARGET_WIDTH + TARGET_PADDING) * 2 - TARGET_OFFSET, .y = 100 + (TARGET_HEIGHT + TARGET_PADDING) * 4 },
    Target{ .x = 100 + (TARGET_WIDTH + TARGET_PADDING) * 3 - TARGET_OFFSET, .y = 100 + (TARGET_HEIGHT + TARGET_PADDING) * 4 },
    Target{ .x = 100 + (TARGET_WIDTH + TARGET_PADDING) * 4 - TARGET_OFFSET, .y = 100 + (TARGET_HEIGHT + TARGET_PADDING) * 4 },
    Target{ .x = 100 + (TARGET_WIDTH + TARGET_PADDING) * 5 - TARGET_OFFSET, .y = 100 + (TARGET_HEIGHT + TARGET_PADDING) * 4 },
    // Sixth Row
    Target{ .x = 100 + (TARGET_WIDTH + TARGET_PADDING) * 0 + TARGET_OFFSET, .y = 100 + (TARGET_HEIGHT + TARGET_PADDING) * 5 },
    Target{ .x = 100 + (TARGET_WIDTH + TARGET_PADDING) * 1 + TARGET_OFFSET, .y = 100 + (TARGET_HEIGHT + TARGET_PADDING) * 5 },
    Target{ .x = 100 + (TARGET_WIDTH + TARGET_PADDING) * 2 + TARGET_OFFSET, .y = 100 + (TARGET_HEIGHT + TARGET_PADDING) * 5 },
    Target{ .x = 100 + (TARGET_WIDTH + TARGET_PADDING) * 3 + TARGET_OFFSET, .y = 100 + (TARGET_HEIGHT + TARGET_PADDING) * 5 },
    Target{ .x = 100 + (TARGET_WIDTH + TARGET_PADDING) * 4 + TARGET_OFFSET, .y = 100 + (TARGET_HEIGHT + TARGET_PADDING) * 5 },
    Target{ .x = 100 + (TARGET_WIDTH + TARGET_PADDING) * 5 + TARGET_OFFSET, .y = 100 + (TARGET_HEIGHT + TARGET_PADDING) * 5 },
    // I Know it's a Mess and there are better ways to do this, I'm just practicing! :)
};

fn target_rect(target: Target) rl.Rectangle {
    return rl.Rectangle{ .x = target.x, .y = target.y, .width = TARGET_WIDTH, .height = TARGET_HEIGHT };
}

pub fn main() void {

    // Init the Game
    rl.initWindow(scr_width, scr_height, "Breakout");
    defer rl.closeWindow();

    rl.setTargetFPS(FPS);

    // ***** Main game loop *****
    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        defer rl.endDrawing();

        // Objects
        const ball = rl.Rectangle{ .x = ball_x, .y = ball_y, .width = BALL_SIZE, .height = BALL_SIZE };
        const bar = rl.Rectangle{ .x = bar_x, .y = BAR_Y - BAR_THICKNESS / 2, .width = BAR_LEN, .height = BAR_THICKNESS };

        // Check Keyboard Keys
        if (rl.isKeyPressed(rl.KeyboardKey.q))
            break;

        if (rl.isKeyPressed(rl.KeyboardKey.space) and started)
            paused = !paused;

        if ((rl.isKeyDown(rl.KeyboardKey.right) or rl.isKeyDown(rl.KeyboardKey.d)) and bar_x < scr_width - BAR_LEN and !paused) {
            bar_x += 15;
            if (!started) {
                started = true;
                ball_dx = 1;
            }
        }
        if ((rl.isKeyDown(rl.KeyboardKey.left) or rl.isKeyDown(rl.KeyboardKey.a)) and bar_x > 0 and !paused) {
            bar_x -= 15;
            if (!started) {
                started = true;
                ball_dx = -1;
            }
        }

        // Changing Game State
        if (ball_y >= scr_height - BALL_SIZE - 1) {
            paused = true;
            state = GameState.LOSE;
        }

        if (target_count == 0) {
            paused = true;
            state = GameState.WIN;
        }

        // Updating State
        if (started and !paused) {
            var ball_nx = ball_x + ball_dx * BALL_SPEED * DELTA_TIME_SEC;
            var cond_x = ball_nx < 0 or ball_nx + BALL_SIZE > scr_width;
            for (&target_pool) |*target| {
                if (cond_x) break;
                if (!target.dead) {
                    cond_x = cond_x or rl.checkCollisionRecs(ball, target_rect(target.*));
                    if (cond_x) {
                        target.dead = true;
                        target_count -= 1;
                    }
                }
            }
            if (cond_x) {
                ball_dx *= -1;
                ball_nx = ball_x + ball_dx * BALL_SPEED * DELTA_TIME_SEC;
            }
            ball_x = ball_nx;

            var ball_ny = ball_y + ball_dy * BALL_SPEED * DELTA_TIME_SEC;
            var cond_y = ball_ny < 0 or ball_ny + BALL_SIZE > scr_height;
            for (&target_pool) |*target| {
                if (cond_y) break;
                if (!target.dead) {
                    cond_y = cond_y or rl.checkCollisionRecs(ball, target_rect(target.*));
                    if (cond_y) {
                        target.dead = true;
                        target_count -= 1;
                    }
                }
            }
            if (cond_y) {
                ball_dy *= -1;
                ball_ny = ball_y + ball_dy * BALL_SPEED * DELTA_TIME_SEC;
            }

            if (rl.checkCollisionRecs(ball, bar)) {
                ball_dy *= -1;
                ball_ny = ball_y + ball_dy * BALL_SPEED * DELTA_TIME_SEC;
            }
            ball_y = ball_ny;
        }

        // Drawing
        rl.clearBackground(MYBLACK);
        rl.drawRectangleRec(ball, rl.Color.red);
        rl.drawRectangleRec(bar, rl.Color.blue);

        for (target_pool) |target| {
            if (!target.dead)
                rl.drawRectangleRec(target_rect(target), rl.Color.green);
        }

        // Check Game State
        if (state == GameState.LOSE) {
            rl.drawRectangle(0, 0, scr_width, scr_height, rl.fade(rl.Color.white, 0.7));
            rl.drawText("YOU LOSE!", scr_width / 2 - @divTrunc(rl.measureText("YOU LOSE!", 50), 2), scr_height / 2 - 25, 50, rl.Color.red);
        }

        if (state == GameState.WIN) {
            rl.drawRectangle(0, 0, scr_width, scr_height, rl.fade(rl.Color.white, 0.7));
            rl.drawText("YOU WIN!", scr_width / 2 - @divTrunc(rl.measureText("YOU WIN!", 50), 2), scr_height / 2 - 25, 50, rl.Color.green);
        }
    }
}
