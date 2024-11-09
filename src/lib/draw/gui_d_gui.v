module draw

import gg
import gx
import os
import term.ui as tui

enum Mode {
    normal
    insert
}

struct Context {
	user_data voidptr
	frame_cb  fn (v voidptr) @[required]
mut:
	gg                         &gg.Context = unsafe { nil }
	txt_cfg                    gx.TextCfg
	foreground_color           Color
	background_color           Color
	text_draws_since_last_pass int
	mode                       Mode
}

pub fn new_context(cfg Config) (&Contextable, Runner) {
    println('Creating context')
	mut ctx := &Context{
		user_data: cfg.user_data
		frame_cb:  cfg.frame_fn
	}
    println('Setting up context')
	ctx.gg = gg.new_context(
		width:         1200
		height:        1000
		create_window: true
		window_title:  'Lilly Editor'
		user_data:     ctx
		bg_color:      gx.white
		font_path:     os.resource_abs_path('./experiment/DejaVuSansMono.ttf')
		frame_fn: 	   frame
		event_fn: fn [cfg] (e &gg.Event, ptr voidptr) {
		    if e.typ != .key_down {
		        return
		    }

		    mut con := unsafe { &Context(ptr) }
			cfg.event_fn(gg_to_tui_event(e, mut con), con.user_data)
		}
		)
	return ctx, unsafe { ctx.run_wrapper }
}

fn gg_to_tui_event(e &gg.Event, mut ctx Context) Event {
    println('Raw gg modifiers: ${e.modifiers}')

    mut code := match e.key_code {
		.space { tui.KeyCode.space }
        .left_shift, .right_shift { tui.KeyCode.null }
        .a { tui.KeyCode.a }
        .b { tui.KeyCode.b }
        .c { tui.KeyCode.c }
        .d { tui.KeyCode.d }
        .e { tui.KeyCode.e }
        .f { tui.KeyCode.f }
        .g { tui.KeyCode.g }
        .h { tui.KeyCode.h }
        .i {
			ctx.mode = .insert
			tui.KeyCode.i
		 }
        .j { tui.KeyCode.j }
        .k { tui.KeyCode.k }
        .l { tui.KeyCode.l }
        .m { tui.KeyCode.m }
        .n { tui.KeyCode.n }
        .o { tui.KeyCode.o }
        .p { tui.KeyCode.p }
        .q { tui.KeyCode.q }
        .r { tui.KeyCode.r }
        .s { tui.KeyCode.s }
        .t { tui.KeyCode.t }
        .u { tui.KeyCode.u }
        .v { tui.KeyCode.v }
        .w { tui.KeyCode.w }
        .x { tui.KeyCode.x }
        .y { tui.KeyCode.y }
        .z { tui.KeyCode.z }
        .right { tui.KeyCode.right }
        .left { tui.KeyCode.left }
        .up { tui.KeyCode.up }
        .down { tui.KeyCode.down }
        .period { tui.KeyCode.period }
        .comma { tui.KeyCode.comma }
        .semicolon { tui.KeyCode.semicolon }
        .enter { tui.KeyCode.enter }
        .tab { tui.KeyCode.tab }
        .backspace { tui.KeyCode.backspace }
        .delete { tui.KeyCode.delete }
        .caps_lock {
			ctx.mode = .normal
			tui.KeyCode.escape 
		}
        .home { tui.KeyCode.home }
        .end { tui.KeyCode.end }
        .page_up { tui.KeyCode.page_up }
        .page_down { tui.KeyCode.page_down }
        else { tui.KeyCode.null }
    }

    mut utf8 := match e.key_code {
        .space { " " }
        .left_shift, .right_shift { "" }
        else { e.key_code.str() }
    }

    mut tui_mods := u32(0)
    if int(e.modifiers) & int(gg.Modifier.shift) != 0 {
        tui_mods |= 2
    }
    if int(e.modifiers) & int(gg.Modifier.ctrl) != 0 {
        tui_mods |= 1
    }
    if int(e.modifiers) & int(gg.Modifier.alt) != 0 {
        tui_mods |= 4
    }

    mut evt :=  Event{
        Event: tui.Event{
            typ: .key_down
            code: code
            ascii: u8(e.char_code)
            utf8: utf8
			modifiers: unsafe {
				tui.Modifiers(tui_mods)
				}
        }
        gg_event: e
    }
    println('Converted to tui modifiers: ${evt.modifiers}')

	return evt
}


const font_size = 16

fn (mut ctx Context) run_wrapper() ! {
    println('Starting run')
    ctx.gg.run()
    println('end run')
}

fn (mut ctx Context) render_debug() bool {
    return true
}

fn frame(mut ctx Context) {
	mut scale_factor := gg.dpi_scale()
	if scale_factor <= 0 {
		scale_factor = 1
	}
	ctx.txt_cfg = gx.TextCfg{
		size: draw.font_size * int(scale_factor)
	}
	ctx.frame_cb(ctx.user_data)
	if ctx.text_draws_since_last_pass < 1000 {
		ctx.text_draws_since_last_pass = 0
		ctx.gg.end()
	}
}

fn (mut ctx Context) rate_limit_draws() bool {
	return false
}

fn (mut ctx Context) window_width() int {
    return ctx.gg.window_size().width / draw.font_size
}

fn (mut ctx Context) window_height() int {
    return (gg.window_size().height / draw.font_size) - 1
}

fn (mut ctx Context) draw_text(x int, y int, text string) {
    if ctx.text_draws_since_last_pass == 0 {
        ctx.gg.begin()
    }

    y_pos := if y == ctx.window_height() - 1 {
        (ctx.window_height() - 1) * draw.font_size
    } else {
        (y - 1) * draw.font_size
    }

    
    // Different x offset calculation for trough vs text content
    x_pos := if x < 4 {
		0
    } else {
        (x - 2) * int(f32(draw.font_size) / 2.23)  // Regular text positioning
    }

    // Use monospace width for all characters including spaces
	ctx.txt_cfg = gx.TextCfg{
	    size: draw.font_size
	    color: gx.rgb(ctx.foreground_color.r, ctx.foreground_color.g, ctx.foreground_color.b)
	    align: .left
	    mono: true
	}


    ctx.gg.draw_text(
        x_pos,
        y_pos,
        text,
        ctx.txt_cfg
    )

    if ctx.text_draws_since_last_pass >= 1000 {
        ctx.gg.end(how: .passthru)
        ctx.text_draws_since_last_pass = 0
        return
    }

    ctx.text_draws_since_last_pass += 1
}

fn (mut ctx Context) set_cursor_position(x int, y int) {
    x_pos := (x - 2) * int(f32(draw.font_size) / 2.23)
    y_pos := (y - 1) * draw.font_size

    if ctx.mode == .insert {
        // Underline cursor for insert mode
        ctx.gg.draw_rect_filled(
            x_pos,
            y_pos + (draw.font_size - 2),
            draw.font_size / 2,
            2,
            gx.rgb(254, 191, 243)
        )
    } else {
        // Vertical line cursor for normal mode
        ctx.gg.draw_rect_filled(
            x_pos,
            y_pos,
            2,
            draw.font_size,
            gx.rgb(254, 191, 243)
        )
    }
}

fn (mut ctx Context) draw_rect(x int, y int, width int, height int) {
    c := ctx.background_color
    lighter_color := gx.rgb(
        if c.r < 128 { c.r + 120 } else { c.r },
        if c.g < 128 { c.g + 120 } else { c.g },
        if c.b < 128 { c.b + 120 } else { c.b }
    )
    x_pos := (x - 2) * (draw.font_size/2)
    y_pos := if y == ctx.window_height() - 1 {
        (ctx.window_height() - 1) * draw.font_size
    } else {
        (y - 1) * draw.font_size
    }
    
    ctx.gg.draw_rect_filled(
        x_pos,
        y_pos,
        width * draw.font_size,
        draw.font_size,
        lighter_color
    )
}

fn (mut ctx Context) write(c string) {}

fn (mut ctx Context) draw_point(x int, y int) {}

fn (mut ctx Context) bold() {}

fn (mut ctx Context) set_color(c Color) {
	ctx.foreground_color = c
}

fn (mut ctx Context) set_bg_color(c Color) {
	ctx.background_color = c
}

fn (mut ctx Context) reset_color() {
	ctx.foreground_color = Color{}
}

fn (mut ctx Context) reset_bg_color() {}

fn (mut ctx Context) reset() {
	ctx.foreground_color = Color{}
	ctx.background_color = Color{}
}

fn (mut ctx Context) run() ! {
	ctx.gg.run()
}

fn (mut ctx Context) clear() {
	ctx.gg.begin()
	ctx.gg.end()
}

fn (mut ctx Context) flush() {}
