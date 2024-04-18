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
		println(i)
		buff.insert("${i}".runes()[0])
	}
	assert buff.get_string() == "0123456789111111111122222222223333333333444444444455555555556666666666777777777788888888889999999999"
}
