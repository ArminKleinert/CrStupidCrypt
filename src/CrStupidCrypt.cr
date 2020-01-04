module CrStupidCrypt
  VERSION = "0.1.0"

class Cryptor
  private def self.xorshift64star(seed : UInt64) : UInt64
    seed ^= seed >> 12
    seed ^= seed << 25
    seed ^= seed >> 27
    seed ^ 0x2545F4914F6CDD1D_u64
  end

  MASK = (0x7FFFFFFF_u64 << 8).to_u64
  
  def self.crypt_write_s(string : String, io : IO, seed : UInt64)
    string.each_char do |c|
      seed = seed.to_u64
      seed = xorshift64star(seed)
      off = ((seed & MASK) >> 8).to_u32
      new_c = off + c.ord
      io.write_bytes(new_c, IO::ByteFormat::LittleEndian)
    end
  end

  def self.each_32(io, &block)
    buff = [] of UInt32
    until io.peek.empty?
      i = io.read_bytes(UInt32, IO::ByteFormat::LittleEndian)
      buff << yield(i)
    end
    buff
  end

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

  f_from  = ARGV[0]
  f_to    = ARGV[1]
  seedstr = ARGV[2]
  seed    = 0

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
