#!/usr/bin/env ruby

#A helper script to generate some repetetive code.

settings = {
  setbits: {
    assign: "|="
  },
  maskbits: {
    assign: "&="
  },
  clearbits: {
    assign: "&=",
    filter: "~"
  }
}

functions = [:setbits,:maskbits,:clearbits]

make_bits_sats = lambda { |file|

  functions.each { |f|
    fn_tmpl =<<FUNCTION
fun __name__ {n:nat} (
    r: !reg(n) >> reg(n'), __bits__
) : #[n':nat; 0 <= n'; n' < 256] void = "mac#avr_libats___name__"
FUNCTION
    
    name = f.to_s
    file.puts("symintr #{name}\n\n")
    8.times { |i|
      bits = (0..i).map { |b|
        "b#{b}: natLt(8)"
      }.join(", ")
      n = name + i.to_s
      file.puts(fn_tmpl.gsub(/__name__/,n).gsub(/__bits__/,bits)+"\n\n")
      file.puts("overload #{name} with #{n}\n\n")
    }
  }
}

make_bits_cats = lambda { |file|
  functions.each { |f|
    mac_tmpl =<<MACRO
#define avr_libats___name__(reg, __labels__) (reg __assign__ __filter__(__bits__))
MACRO
    
    name = f.to_s
    8.times { |i|
      bits = (0..i).map { |b|
        "b#{b}"
      }
      
      labels = bits.join(", ")
      sum = bits.map{ |b|
        "_BV(#{b})"
      }.join(" | ")

      n = name+i.to_s
      file.puts (
                 mac_tmpl.gsub(/__name__/,n).gsub(/__labels__/,labels)
                   .gsub(/__assign__/,settings[f][:assign] || "")
                   .gsub(/__filter__/,settings[f][:filter] || "")
                   .gsub(/__bits__/,sum) + "\n\n"
                 )
    }
  }
}

open("io.sats","w+") { |s|
  make_bits_sats.call(s)
}

open("io.cats","w+") { |c|
  make_bits_cats.call(c)
}
