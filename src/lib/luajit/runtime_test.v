module luajit

struct Test{
	value int
	name string
}

fn test_parse() {
	c := parse[Test]("config = { value = 43384, name = 'thing' }") or { panic(err) }
	assert c == Test{ value: 43384, name: "thing" }
}
