# This file was used in Destroy All Software production 0102, "Data Compressor
# From Scratch". It wasn't shown in the screencast, so it's not designed to be
# as readable as the main code. All of this code is exactly as used in the
# screencast except for the addition of comments.
#
# To see how this file was used to build a data compressor, visit:
#
#   https://www.destroyallsoftware.com/screencasts/catalog/data-compressor-from-scratch

class BinPacker
  def initialize
    @bits = []
  end

  def int32(int)
    @bits << [int_to_bits(int, 32), int]
    self
  end

  def int16(int)
    @bits << [int_to_bits(int, 16), int]
    self
  end

  def int8(int)
    @bits << [int_to_bits(int, 8), int]
    self
  end

  def int(int, bit_count)
    @bits << [int_to_bits(int, bit_count), int]
    self
  end

  def bits(bits)
    @bits << [bits, bits]
    self
  end

  def pack
    [flattened_bits.map(&:to_s).join].pack("b*")
  end

  def flattened_bits
    @bits.map { |bits, original| bits }.flatten(1)
  end

  # This function was banged out to be used once during recording, without
  # regard for whether anyone would ever read it. Oh well!
  def debug
    # Some ANSI escape codes that we'll use
    red = "\e[31;49m"
    reset = "\e[0m"

    # Pack up the original packed values into DebugValues containing DebugBits.
    # The DebugValues carry the original data plus the serialized bits; the
    # DebugBits carry the original bits plus the colorized bits.
    debug_values = @bits.each_with_index.map do |(bits, original), index|
      mark_this_group = index % 2 == 0
      debug_bits = bits.map do |bit|
        bit_string = mark_this_group ? red + bit.to_s + reset : bit.to_s
        DebugBit.new(bit_string, bit)
      end
      DebugValue.new(debug_bits, original)
    end

    # Print the original bit groups with their added alternating colors.
    $stderr.puts "Original values (#{debug_values.length}):"
    bit_strings = debug_values.map(&:debug_bits).map do |group|
      # Reverse so the bits are printed in decreasing significance order, as
      # expected by humans.
      group.map(&:colorized_bit).reverse.join
    end
    original_values = debug_values.map(&:original).map(&:to_s)
    max_original_length = original_values.map(&:length).max
    bit_strings.zip(original_values).each do |bit_string, original|
      $stderr.puts "  " + original.rjust(max_original_length) + " | " + bit_string
    end
    $stderr.puts

    # Print the actual bytes in three forms (bits, base-10 number, and ASCII
    # character), maintaining the alternate coloring so we can see how the
    # original bit groups map to the output bytes.
    $stderr.puts "Bytes (#{pack.length}):"
    debug_values.map(&:debug_bits).flatten(1).each_slice(8) do |group|
      padding = "0" * (8 - group.length)
      colorized_bits = padding + group.map(&:colorized_bit).reverse.join
      just_the_bits = group.map(&:bit)

      # Convert this group of bits into a character
      char = [just_the_bits.map(&:to_s).join].pack("b*")

      $stderr.puts "  " + colorized_bits + " | " + char.ord.to_s.ljust(3) + " | " + char.inspect
    end
    $stderr.puts

    # Print the final packed string, which will be the same as the ASCII
    # characters rendered for the packed bits.
    $stderr.puts "Packed string (#{pack.length}): #{pack.inspect}"
    $stderr.puts
  end

  DebugValue = Struct.new(:debug_bits, :original)
  DebugBit = Struct.new(:colorized_bit, :bit)

  private

  def int_to_bits(int, bit_count)
    bits = []
    bit_count.times do
      bits << (int & 0x1)
      int >>= 1
    end
    bits
  end
end

class BinUnpacker
  def initialize(packed)
    @bits = packed.unpack("b*").fetch(0).chars.map(&:to_i)
  end

  def int32
    int(32)
  end

  def int16
    int(16)
  end

  def int8
    int(8)
  end

  def bits(count)
    bits = @bits[0...count]
    @bits = @bits[count..-1]
    bits
  end

  def peek(n)
    @bits[0...n]
  end

  def int(bit_count)
    bits, @bits = @bits[0...bit_count], @bits[bit_count..-1]
    int = 0
    bits.reverse.each do |bit|
      int <<= 1
      int |= bit
    end
    int
  end
end
