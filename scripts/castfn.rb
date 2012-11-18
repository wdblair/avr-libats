#!/usr/bin/env ruby

#Generate cast functions for fixed size integers.

types = ["uint8", "int8", "uint16", "int16", 
         "uint32", "int32", "uint64", "int64"]

targets = ["char","uchar", "int", "int1", "uint","uint1"]

types.each do |from|

  static = from =~ /^u/ ? "nat" : "int"
  
  puts "(* **** #{from} **** *)\n\n"

  puts "symintr #{from}\n\n"

  targets.each do |to|
    name = "#{from}_#{to}"
    other_name = "#{to}_#{from}"

    argument = case to
               when "int1"
                 "{n:#{static}} (n: int n)"
               when "uint1"
                 "{n:#{static}} (n: uint n)"
               else
                 "(n: #{to})"
               end

    res = case to
          when "int1", "uint1"
            "#{from} n"
          else
            "[n:#{static}] #{from} n"
          end

    template =<<FUN
castfn #{name} 
   #{argument} : #{res}

overload #{from} with #{name}

FUN
    
    puts template

    argument =  "{n:#{static}} (n: #{from} n)"

    res = case to
          when "int1"
            "int n"
          when "uint1"
            "uint n"
          else
            to
          end
    #Going the other way
    template =<<FUN
castfn #{other_name}
  #{argument} : #{res}

overload #{to} with #{other_name}

FUN

    puts template

  end

  #Addition, subtraction, multiplication, division
  operators = [["+","add"], ["-","sub"], ["*","mul"], ["/","div"],
               ["<<","lsl"], [">>", "lsr"], ["lor", "lor"],
               ["land", "land"], ["~", "lnot"], ["lxor", "lxor"],
               ["abs", "abs"], ["mod", "mod"], ["<", "lt"], [">", "gt"],
               ["<=", "lte"], [">=", "gte"], ["=", "eq"], ["!=", "eq"]]

  #Define the typical operators
  operators.each do |op|
    if op[0] == "<<" || op[0] == ">>"
      template =<<FUN
fun #{op[1]}_#{from}_int1 {n:#{static}}
  (i: #{from}, shift: Nat) :<> #{from} = "atspre_#{op[1]}_#{from}_int1"

overload #{op[0]} with #{op[1]}_#{from}_int1

FUN
    else
      static_conds = []
      res = case op[0]
            when "+"
              "#{from} (i1 + i2)"
            when "-"
              "#{from} (i1 - i2)"
            when "*"
              "#{from} (i1 * i2)"
            when "/"
              "#{from} (i1 / i2)"
            when "abs"
              "[i3:nat] #{from} i3"
            when "mod"
              static_conds.push "i1 >= 0; i2 > 0"
              "[i3:nat | i3 < i2] #{from} i3"
            when "<"
              "bool (i1 < i2)"
            when "<="
              "bool (i1 <= i2)"
            when ">"
              "bool (i1 > i2)"
            when ">="
              "bool (i1 >= i2)"
            when "!="
              "bool (i1 != i2)"
            else
              "[i3:#{static}] #{from} i3"
            end
      if static_conds.length > 0 
        static_conds.unshift " |" 
      end

      name = [op[1], from, from].join("_")
      template =<<FUN
fun #{name} {i1,i2:#{static}#{static_conds.join(" ")}}
  (i1: #{from} i1, i2: #{from} i2) : #{res} = "atspre_#{name}"

overload #{op[0]} with #{name}


FUN
      puts template
    end
  end
  puts "(* **** [end of #{from}] **** *)\n\n"

end
