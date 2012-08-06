#!/usr/bin/env ruby

format = 'macdef __name__ = $extval(uint8, "__name__")'

out = open("i2c.sats", "w")

section_start = false
open("../CATS/i2c.cats", "r").each_line do |line|
  if m = /^#define ([A-Z_]+)\s+0x[A-F0-9]+/.match(line)
    out.puts format.gsub(/__name__/, m[1])
  elsif m = /^\/\/ .*/.match(line)
    out.puts line
    section_start = true
  elsif section_start
    section_start = false
    out.puts "\n\n"
  end
end
