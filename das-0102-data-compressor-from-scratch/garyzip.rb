#!/usr/bin/env ruby

# This file was used in Destroy All Software production 0102, "Data Compressor
# From Scratch". It wasn't shown in the screencast, so it's not designed to be
# as readable as the main code. All of this code is exactly as used in the
# screencast except for:
#
# - This comment.
# - Calls to `render_tree` and `packer.debug` in the `compress` function, so
#   you can easily run this file and see the debug output from the screencast.
#
# To see this work, try the command below. Note that the tree printed by
# `render_tree` will only work in iTerm 2, or other terminals that support its
# PNG rendering escape codes. If you're not using iTerm 2, you can comment out
# the call to `render_tree`.
#
#   echo -n "abbcccc" | ./garyzip.rb compress | hexdump
#
# To see how this file was written, visit:
#
#   https://www.destroyallsoftware.com/screencasts/catalog/data-compressor-from-scratch

require "./rendertree"
require "./bin"

def compress(original)
  tree = build_tree(original)
  table = build_table(tree)
  packer = BinPacker.new

  packer.int32(original.length)
  pack_table(table, packer)

  original.bytes.each do |byte|
    bits = look_up_byte(table, byte)
    packer.bits(bits)
  end

  render_tree(tree)
  packer.debug

  packer.pack
end

def decompress(compressed)
  unpacker = BinUnpacker.new(compressed)

  data_length = unpacker.int32
  table = unpack_table(unpacker)

  data_length.times.map do
    look_up_bits(table, unpacker)
  end.map(&:chr).join
end

def build_tree(original)
  bytes = original.bytes
  unique_bytes = bytes.uniq

  nodes = unique_bytes.map do |byte|
    Leaf.new(byte, bytes.count(byte))
  end

  until nodes.length == 1
    node1 = nodes.delete(nodes.min_by(&:count))
    node2 = nodes.delete(nodes.min_by(&:count))
    nodes << Node.new(node1, node2, node1.count + node2.count)
  end

  nodes.fetch(0)
end

def build_table(node, path=[])
  if node.is_a? Node
    build_table(node.left, path + [0]) +
      build_table(node.right, path + [1])
  else
    [TableRow.new(node.byte, path)]
  end
end

def look_up_byte(table, byte)
  table.each do |row|
    if row.byte == byte
      return row.bits
    end
  end

  awoijf
end

# a = 00
# b = 01
# c = 1

def look_up_bits(table, unpacker)
  table.each do |row|
    if row.bits == unpacker.peek(row.bits.length)
      unpacker.bits(row.bits.length)
      return row.byte
    end
  end

  awoijf
end

def pack_table(table, packer)
  packer.int8(table.length - 1)
  table.each do |row|
    packer.int8(row.byte)
    packer.int8(row.bits.length)
    packer.bits(row.bits)
  end
end

def unpack_table(unpacker)
  table_length = unpacker.int8 + 1
  table_length.times.map do
    byte = unpacker.int8
    bit_count = unpacker.int8
    bits = unpacker.bits(bit_count)
    TableRow.new(byte, bits)
  end
end

Node = Struct.new(:left, :right, :count)
Leaf = Struct.new(:byte, :count)

TableRow = Struct.new(:byte, :bits)

if ARGV.fetch(0) == "compress"
  $stdout.write(compress($stdin.read))
else
  $stdout.write(decompress($stdin.read))
end
