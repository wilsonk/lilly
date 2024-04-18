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

fn test_gap_buffer_deleting_chars() {
	mut buff := new_gap_buffer(0)
	buff.set_string("This is a test sentence.")
	assert buff.get_string() == "This is a test sentence."

	buff.delete()
	assert buff.get_string() == "his is a test sentence."

	buff.backspace()
	assert buff.get_string() == "his is a test sentence."

	buff.move_cursor_right()
	buff.backspace()
	assert buff.get_string() == "is is a test sentence."
}
