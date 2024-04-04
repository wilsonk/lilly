module luajit

#flag -I/usr/local/include/luajit-2.1
#flag -L/usr/local/lib
#flag -lluajit-5.1
#flag -lm
#include "lua.h"
#include "lauxlib.h"

pub struct C.lua_State {}

fn C.luaL_newstate() &C.lua_State
fn C.lua_getglobal(&C.lua_State, &char)
fn C.lua_istable(&C.lua_State, int) int
fn C.lua_gettable(&C.lua_State, int)
fn C.lua_isnoneornil(&C.lua_State, int) int
fn C.lua_pushstring(&C.lua_State, &char)
fn C.lua_tointeger(&C.lua_State, int) int
fn C.lua_tostring(&C.lua_State, int) &char
fn C.luaL_dostring(&C.lua_State, &char) int
fn C.lua_pop(&C.lua_State, int)
fn C.lua_close(&C.lua_State)

pub fn parse[T](code string) !T {
	mut typ := T{}
	lua_state := C.luaL_newstate()
	defer { C.lua_close(lua_state) }
	status := C.luaL_dostring(lua_state, &char(code.str))
	C.lua_getglobal(lua_state, c"config")
	if C.lua_istable(lua_state, -1) == 1 {
		$if T is $struct {
			$for field in T.fields {
				C.lua_pushstring(lua_state, &char(field.name.str))
				if C.lua_isnoneornil(lua_state, -2) == 0 {
					C.lua_gettable(lua_state, -2)
					$if field.typ is int {
						typ.$(field.name) = C.lua_tointeger(lua_state, -1)
						C.lua_pop(lua_state, 1)
					} $else $if field.typ is string {
						typ.$(field.name) = unsafe { cstring_to_vstring(C.lua_tostring(lua_state, -1)) }
						C.lua_pop(lua_state, 1)
					}
				}
			}
		}
	}
	return typ
}
