module CrStupidCrypt
  VERSION = "0.1.0"

class Cryptor
  # Generates random 64-bit numbers.
  private def self.xorshift64star(seed : UInt64) : UInt64
    seed ^= seed >> 12
    seed ^= seed << 25
    seed ^= seed >> 27
    seed ^ 0x2545F4914F6CDD1D_u64
  end

  MASK = (0x7FFFFFFF_u64 << 8).to_u64
  
  # This method pushes the characters of the string to
  # the IO object. Each character is changed into a
  # random 32-bit number individually just before it 
  # is written.
  def self.crypt_write_s(string : String, io : IO, seed : UInt64)
    string.each_char do |c|
      seed = seed.to_u64
      seed = xorshift64star(seed)
      off = ((seed & MASK) >> 8).to_u32
      new_c = off + c.ord
      io.write_bytes(new_c, IO::ByteFormat::LittleEndian)
    end
  end

  # Helper-function for decrypt_read
  # Reads UInt32 objects from the io object until it is 
  # empty and applies the block to it.
  # Outputs an Array of UInt32 objects.
  def self.each_32(io, &block)
    buff = [] of UInt32
    until io.peek.empty?
      i = io.read_bytes(UInt32, IO::ByteFormat::LittleEndian)
      buff << yield(i)
    end
    buff
  end

  # Reads an IO object as a stream of 32-bit unsigned 
  # integers. Then, each number is transformed into a 
  # UTF-8 character.
  # Lastly, the characters are joined into a String and 
  # returned.
  def self.decrypt_read(io, seed)
    res = each_32(io) do |c|
      seed = xorshift64star(seed)
      off = ((seed & MASK) >> 8).to_u32
      (c - off).to_u32
    end
    
    nres = res.map(&.chr)
    String.build do |s|
      until nres.empty?
        s << nres.shift
      end
    end
  end
end

  # Initializing the source- and destination-files.
  f_from  = ARGV[0]
  f_to    = ARGV[1]
  seedstr = ARGV[2]
  seed    = 0

  # Transform the seed-string as read from the arguments
  # into an unsigned 64-bit number.
  if seedstr.starts_with? "0x"
    seed = seedstr[2..-1].to_u64(16)
  elsif seedstr.starts_with? "0b"
    seed = seedstr[2..-1].to_u64(2)
  elsif seedstr.starts_with? "0o"
    seed = seedstr[2..-1].to_u64(8)
  else
    seed = seedstr.to_u64
  end

  str = ""

  if ARGV.includes?("--decrypt") || ARGV.includes? ("decrypt")
    File.open(f_from, "r") do |from|
      str = Cryptor.decrypt_read(from, seed)
    end
    File.write(f_to, str)
  else
    str = File.read(f_from)
    File.open(f_to, "w") do |to|
      Cryptor.crypt_write_s(str, to, seed)
    end
  end
end
