module luajit

import term.ui as tui

struct Test{
	value int
	name  string
	extra int
}

fn test_parse() {
	c := parse[Test]("config = { value = 43384, name = 'thing' }") or { panic(err) }
	assert c == Test{ value: 43384, name: "thing" }
}

struct Config {
	leader_key                string
	relative_line_numbers     int
	insert_tabs_not_spaces    int
	selection_highlight_color tui.Color
}

fn test_parse_config_replacement() {
	config_in_lua := "config = { leader_key = ';', insert_tabs_not_spaces = 1, relative_line_numbers = 1, selection_highlight_color = { r = 22, g = 235, b = 225 } }"
	parsed_config := parse[Config](config_in_lua) or { panic(err) }
	assert parsed_config == Config {
		leader_key: ";", relative_line_numbers: 1, insert_tabs_not_spaces: 1, selection_highlight_color: tui.Color{ r: 22, g: 235, b: 225 }
	}

}
