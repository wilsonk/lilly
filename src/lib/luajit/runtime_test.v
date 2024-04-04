module luajit

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
	leader_key             string
	relative_line_numbers  int
	insert_tabs_not_spaces int
}

fn test_parse_config_replacement() {
	config_in_lua := "config = { leader_key = ';', relative_line_numbers = 1, insert_tabs_not_spaces = 1 }"
	parsed_config := parse[Config](config_in_lua) or { panic(err) }
	assert parsed_config == Config {
		leader_key: ";", relative_line_numbers: 1, insert_tabs_not_spaces: 1
	}

}
