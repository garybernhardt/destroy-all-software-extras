# This file was used in Destroy All Software production 0102, "Data Compressor
# From Scratch". It wasn't shown in the screencast, so it's not designed to be
# as readable as the main code. All of this code is exactly as used in the
# screencast except for:
#
# - New comments (including this one)
# - The call to `imgcat` was changed to refer to the `imgcat` script in this
#   directory Previously, it relied on the `imgcat` in my ~/bin directory,
#   which is in $PATH.
#
# To see how this file was used to build a data compressor, visit:
#
#   https://www.destroyallsoftware.com/screencasts/catalog/data-compressor-from-scratch

require "open3"

# Render a Huffman tree by converting it into Graphviz dot code, then piping
# the dot into the `dot` command line tool, and finally into the `imgcat`
# script. This will only work in recent versions of iTerm 2, or any other
# terminal that supports iTerm 2's PNG rendering escape codes.
def render_tree(nodes)
  nodes = [nodes] unless nodes.is_a? Array
  dot = [
    "digraph {",
    "ordering=out",
    "dpi=120",
    nodes.map do |node|
      tree_to_dot(node)
    end,
    "}"
  ].flatten.join("\n")
  rendered = Open3.popen3("dot -Tpng | ./imgcat") do |stdin, stdout, stderr, wait_thr|
    stdin.write(dot)
    stdin.close
    stdout.read
  end
  $stderr.puts(rendered)
end

def tree_to_dot(node)
  name = "node_#{node.object_id}"
  if node.is_a? Node
    [
      %{#{name}[label="(n=#{node.count})"]},
      %{#{name} -> node_#{node.left.object_id}[label="0"]},
      %{#{name} -> node_#{node.right.object_id}[label="1"]},
      tree_to_dot(node.left),
      tree_to_dot(node.right),
    ].join("\n")
  else
    [
      %{node_#{node.object_id}[label="#{node.byte.chr.gsub(/"/,'\"')}\n(n=#{node.count})"]},
    ].join("\n")
  end
end
