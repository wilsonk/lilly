module piece_tree

struct UndoRedoEntry {
}

type LineStart = u8

struct NodePosition {
	// piece index
	node &NodeData
}

type Column       = u8
type BufferIndex  = u8
enum Line        as u8 {
	index_beginning
	beginning
}
type Length    = u8
type LFCount   = u8

struct BufferCursor {
	line   Line
	column u32
}

struct Piece {
	index  u32
	first         BufferCursor
	end           BufferCursor
	length        Length
	newline_count LFCount
}

struct NodeData {
	piece                 Piece
	left_subtree_length   Length
	left_subtree_lf_count LFCount
}

enum Color as u8 {
	red
	black
	double_black
}
