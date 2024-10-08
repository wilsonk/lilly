module workspace

import os
import json

const builtin_v_syntax = $embed_file('../../syntax/v.syntax').to_string()
const builtin_go_syntax = $embed_file('../../syntax/go.syntax').to_string()
const builtin_c_syntax = $embed_file('../../syntax/c.syntax').to_string()
const builtin_rust_syntax = $embed_file('../../syntax/rust.syntax').to_string()

pub struct Syntax {
pub:
	name       string
	extensions []string
	keywords   []string
	literals   []string
}

fn (mut workspace Workspace) load_builtin_syntaxes() {
	vsyntax := json.decode(Syntax, builtin_v_syntax) or {
		panic('builtin V syntax file failed to decode: ${err}')
	}
	workspace.syntaxes << vsyntax
	go_syntax := json.decode(Syntax, builtin_go_syntax) or {
		panic('builtin Go syntax file failed to decode: ${err}')
	}
	workspace.syntaxes << go_syntax
	c_syntax := json.decode(Syntax, builtin_c_syntax) or {
		panic('builtin C syntax file failed to decode: ${err}')
	}
	workspace.syntaxes << c_syntax
	rust_syntax := json.decode(Syntax, builtin_rust_syntax) or {
		panic('builtin Rust syntax file failed to decode: ${err}')
	}
	workspace.syntaxes << rust_syntax
}

fn (mut workspace Workspace) load_syntaxes_from_disk(config_dir fn () !string, dir_walker fn (path string, f fn (string)), read_file fn (path string) !string) ! {
	config_root_dir := config_dir() or {
		return error('unable to resolve local config root directory')
	}
	syntax_dir_full_path := os.join_path(config_root_dir, lilly_config_root_dir_name,
		lilly_syntaxes_dir_name)
	mut syns := &workspace.syntaxes
	dir_walker(syntax_dir_full_path, fn [mut syns, read_file] (file_path string) {
		if !file_path.ends_with('.syntax') {
			return
		}
		contents := read_file(file_path) or {
			panic('${err.msg()}')
			'{}'
		} // TODO(tauraamui): log out to a file here probably
		mut syn := json.decode(Syntax, contents) or { Syntax{} }
		if file_path.ends_with('v.syntax') {
			unsafe {
				syns[0] = syn
			}
			return
		}
		if file_path.ends_with('go.syntax') {
			unsafe {
				syns[1] = syn
			}
			return
		}
		if file_path.ends_with('c.syntax') {
			unsafe {
				syns[2] = syn
			}
			return
		}
		if file_path.ends_with('rust.syntax') {
			unsafe {
				syns[3] = syn
			}
			return
		}
		syns << syn
	})
}
