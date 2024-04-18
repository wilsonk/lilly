module buffer

pub struct GapBuffer {
mut:
	data      []rune
	gap_size  int
	gap_left  int
	gap_right int
	size      int
}

pub fn new_gap_buffer() &GapBuffer {
	return &GapBuffer{ data: []rune{ len: 50 } }
}

fn (mut gap_buffer GapBuffer) grow(size int, position int) {
	mut a := []rune{ len: size }
	for i := position; i < size; i++ {
		a[i - position] = gap_buffer.data[i]
	}

	for i := 0; i < size; i++ {
		gap_buffer.data[i + position] = "_".runes()[0]
	}

	for i := 0; i < position + size; i++ {
		gap_buffer.data[position + size + i] = a[i]
	}

	gap_buffer.size += size
	gap_buffer.gap_right += size
}

fn (mut gap_buffer GapBuffer) left(position int) {
	for position < gap_buffer.gap_left {
		gap_buffer.gap_left -= 1
		gap_buffer.gap_right -= 1
		gap_buffer.data[gap_buffer.gap_right + 1] = gap_buffer.data[gap_buffer.gap_left]
		gap_buffer.data[gap_buffer.gap_left] = "_".runes()[0]
	}
}

fn (mut gap_buffer GapBuffer) right(position int) {
	for position > gap_buffer.gap_right {
		gap_buffer.gap_left += 1
		gap_buffer.gap_right += 1
		gap_buffer.data[gap_buffer.gap_left - 1] = gap_buffer.data[gap_buffer.gap_right]
		gap_buffer.data[gap_buffer.gap_right] = "_".runes()[0]
	}
}

pub fn (mut gap_buffer GapBuffer) move_cursor(position int) {
	if position < gap_buffer.gap_left { gap_buffer.left(position); return }
	gap_buffer.right(position)
}

pub fn (mut gap_buffer GapBuffer) insert(s string, position int) {
	if position != gap_buffer.gap_left {
		gap_buffer.move_cursor(position)
	}

	mut ppos := position
	for r in s.runes() {
		if gap_buffer.gap_right == gap_buffer.gap_left {
			gap_buffer.grow(10, ppos)
		}
		gap_buffer.data[gap_buffer.gap_left] = r
		gap_buffer.gap_left += 1
		ppos += 1
	}
}
