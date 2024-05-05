module piece_tree

type BufferIndex = u8

enum Line as u8 {
	index_beginning
	beginning
}

type LFCount = u8

enum Column as u8 {
	beginning
}

type Length = int

struct BufferCursor {
	line   Line
	column Column
}

struct Piece {
	index         BufferIndex
	first         BufferCursor
	last          BufferCursor
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

type Offset = int

@[heap]
struct Node {
	color Color
	left  &Node
	data  NodeData
	right &Node
}

fn new_node(c Color, lft &Node, data &NodeData, rgt &Node) Node {
	return Node {
		color: c,
		left: lft,
		data: data,
		right: rgt
	}
}

struct RedBlackTree {
	root_node &Node
}

fn new_rb_tree(c Color, lft &RedBlackTree, val &NodeData, rgt &RedBlackTree) RedBlackTree {
	return RedBlackTree{
	}
}

fn new_rb_tree_from_node(root_node &Node) RedBlackTree {
	return RedBlackTree{ root_node: root_node }
}

fn (mut rbt RedBlackTree) root_ptr() &Node {
	return rbt.root_node
}

fn (mut rbt RedBlackTree) is_empty() bool {
	return unsafe { rbt.root_node != nil }
}

fn (mut rbt RedBlackTree) root() &NodeData {
	assert !rbt.is_empty()
	return &rbt.root_node.data
}

fn (mut rbt RedBlackTree) left() RedBlackTree {
	assert !rbt.is_empty()
	return new_rb_tree(rbt.root_node.left)
}

fn (mut rbt RedBlackTree) right() RedBlackTree {
	assert !rbt.is_empty()
	return new_rb_tree(rbt.root_node.right)
}

fn (mut rbt RedBlackTree) root_color() Color {
	assert !rbt.is_empty()
	return rbt.root_node.color
}

fn (mut rbt RedBlackTree) insert(x &NodeData, at Offset) RedBlackTree {
}

fn (mut rbt RedBlackTree) ins(x &NodeData, at Offset, total_offset Offset) RedBlackTree {
	if rbt.is_empty() { return new_rb_tree(Color.red, ) }
}
