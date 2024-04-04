module luajit

struct Test{
	value int
}

fn test_parse() {
	c := parse[Test]("global = { value = 43384 }") or { panic(err) }
	println(c)
	assert 1 == 2
}
