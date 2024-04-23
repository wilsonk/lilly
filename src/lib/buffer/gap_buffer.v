module buffer

import arrays

pub struct GapBuffer {
mut:
	buffer       []rune
	pre_gap_len  int
	post_gap_len int
}

const c_gapsize = 50

pub fn new_gap_buffer(size int) &GapBuffer {
	mut len := size - c_gapsize
	if len < c_gapsize { len = c_gapsize }
	return &GapBuffer{ buffer: []rune{ len: len, cap: len } }
}

pub fn (mut gap_buffer GapBuffer) set_string(s string) {
	gap_buffer.buffer = s.runes()
	gap_buffer.pre_gap_len = 0
	gap_buffer.post_gap_len = gap_buffer.buffer.len
}

pub fn (mut gap_buffer GapBuffer) get_string() string {
	mut text := []rune{}
	text << gap_buffer.buffer[..gap_buffer.pre_gap_len]
	text << gap_buffer.buffer[gap_buffer.post_gap_start()..]
	return text.string()
}

pub fn (mut gap_buffer GapBuffer) move_cursor_left() bool {
	if gap_buffer.pre_gap_len == 0 { return false }
	gap_buffer.buffer[gap_buffer.post_gap_start() - 1] = gap_buffer.buffer[gap_buffer.pre_gap_len - 1]
	gap_buffer.pre_gap_len -= 1
	gap_buffer.post_gap_len += 1
	return true
}

pub fn (mut gap_buffer GapBuffer) move_cursor_right() bool {
	if gap_buffer.post_gap_len == 0 { return false }
	gap_buffer.buffer[gap_buffer.pre_gap_len] = gap_buffer.buffer[gap_buffer.post_gap_start()]
	gap_buffer.pre_gap_len += 1
	gap_buffer.post_gap_len -= 1
	return true
}

pub fn (mut gap_buffer GapBuffer) insert(c rune) {
	if gap_buffer.gap_len() == 0 {
		gap_buffer.grow_gap()
	}
	gap_buffer.buffer[gap_buffer.gap_start()] = c
	gap_buffer.pre_gap_len += 1
}

pub fn (mut gap_buffer GapBuffer) delete() bool {
	if gap_buffer.post_gap_len == 0 { return false }
	gap_buffer.post_gap_len -= 1
	return true
}

pub fn (mut gap_buffer GapBuffer) backspace() bool {
	if gap_buffer.pre_gap_len == 0 { return false }
	gap_buffer.pre_gap_len -= 1
	return true
}

// 0 newlines = 1 line  // previous newline? -> NO,  next newline? -> YES
// 1 newline  = 2 lines // previous newline? -> YES, next newline? -> YES
// 2 newlines = 3 lines // previous newline? -> YES, next newline? -> YES
// 3 newlines = 4 lines // previous newline? -> YES, next newline? -> NO
// 10 newlines = 11 lines, line_num = 4 // previous newline? -> YES, next newline -> YES
// 10 newlines = 11 lines, line_num = 0 // previous newline? -> NO, next newline -> YES
// 10 newlines = 11 lines, line_num = 10 // previous newline? -> YES, next newline -> NO
// 0 newlines = 1 line, line_num = 0 // previous newline? -> NO, next newline -> NO
pub fn (mut gap_buffer GapBuffer) get_line_str(line_num int) !string {
	if line_num < 0 { return error("invalid line index ${line_num} < 0") }
	newline_locations := gap_buffer.locate_newlines()
	if line_num >= newline_locations.len { return error("invalid line index ${line_num} >= ${newline_locations.len}") }

	return ""
	// return gap_buffer.buffer[newline_locations[line_num - 1]..newline_locations[line_num]].string()
}

pub fn (mut gap_buffer GapBuffer) get_string_lines(from int, to int) []string {
	mut lines := []string{}

	newline_locations := gap_buffer.locate_newlines()
	// if newline_locations.len == 0 { return [gap_buffer.string()] }

	lines << gap_buffer.buffer[..newline_locations[0]].string()

	return lines
}

pub fn (mut gap_buffer GapBuffer) locate_newlines() []int {
	mut found := []int{}
	for i, r in gap_buffer.buffer[..gap_buffer.pre_gap_len] { if r == `\n` { found << i } }
	for i, r in gap_buffer.buffer[gap_buffer.post_gap_start()..] { if r == `\n` { found << i + gap_buffer.gap_len() } }
	return found
}

fn (mut gap_buffer GapBuffer) gap_start() int {
	return gap_buffer.pre_gap_len
}

fn (mut gap_buffer GapBuffer) gap_len() int {
	return gap_buffer.post_gap_start() - gap_buffer.pre_gap_len
}

fn (mut gap_buffer GapBuffer) post_gap_start() int {
	return gap_buffer.buffer.len - gap_buffer.post_gap_len
}

fn (mut gap_buffer GapBuffer) grow_gap() {
	mut new_buffer := []rune{ len: gap_buffer.buffer.len * 2, cap: gap_buffer.buffer.len * 2 }
	arrays.copy(mut &new_buffer, gap_buffer.buffer[..gap_buffer.pre_gap_len])
	new_buffer.insert(gap_buffer.post_gap_start(), gap_buffer.buffer[gap_buffer.post_gap_start()..])
	gap_buffer.buffer = new_buffer
}

