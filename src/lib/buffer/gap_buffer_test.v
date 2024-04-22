module buffer

fn test_gap_buffer_storing_str() {
	mut buff := new_gap_buffer(0)
	buff.set_string("Hello Test!")
	assert buff.get_string() == "Hello Test!"
}

fn test_gap_buffer_inserting_sentence_per_rune() {
	mut buff := new_gap_buffer(0)
	for c in "Hello Test!".runes() {
		buff.insert(c)
	}
	assert buff.get_string() == "Hello Test!"
}

fn test_gap_buffer_locating_newlines() {
	mut buff := new_gap_buffer(0)
	for c in "Hello Test!\nThis is a second line".runes() {
		buff.insert(c)
	}
	assert buff.get_string() == "Hello Test!\nThis is a second line"

	newline_positions := buff.locate_newlines()
	assert newline_positions == [11]
}

fn test_gap_buffer_reading_lines() {
	mut buff := new_gap_buffer(0)
	for c in "Hello Test!\nThis is a second line.\nThis is a third line!".runes() {
		buff.insert(c)
	}
	assert buff.get_string() == "Hello Test!\nThis is a second line.\nThis is a third line!"

	newline_positions := buff.locate_newlines()
	assert newline_positions == [11, 34]

	assert buff.get_line_str(0)! == "Hello Test!"
	assert buff.get_line_str(1)! == "This is a second line."
	assert buff.get_line_str(2)! == "This is a third line!"
}

fn test_gap_buffer_deleting_chars() {
	mut buff := new_gap_buffer(0)
	buff.set_string("This is a test sentence.")
	assert buff.get_string() == "This is a test sentence."

	assert buff.delete()
	assert buff.get_string() == "his is a test sentence."

    assert buff.backspace() == false
	assert buff.get_string() == "his is a test sentence."

	assert buff.move_cursor_right()
	assert buff.backspace()
	assert buff.get_string() == "is is a test sentence."
}

fn test_gap_buffer_inserting_lots_of_text() {
	mut buff := new_gap_buffer(0)

	for i := 0; i < 100; i++ {
		buff.insert("${i}".runes()[0])
	}
	assert buff.get_string() == "0123456789111111111122222222223333333333444444444455555555556666666666777777777788888888889999999999"
}
