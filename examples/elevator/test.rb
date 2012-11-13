#!/usr/bin/env ruby

#A discrete event simulator to test the elevator controller.

require 'rubygems'
require 'serialport'
require 'json'

$semaphore = Mutex.new
$FLOORS = 10

$origin = Time.now.to_f * 1000.0

def snapshot()
  Time.now.to_f * 1000.0 - $origin
end

def char_of_direction(d)
  d == 0 ? 'u' : 'd'
end

class Passenger
  @@nextid = 0
  
  def initialize(floor, direction)
    @id = @@nextid
    @@nextid += 1
    @start = floor
    @direction = direction

    #Not set until boarding the elevator.
    @destination = 0

    #Has exited the system
    @arrived = false
  end

  def arrive
    $semaphore.synchronize {
      json.puts({:tag => "service", :id=> @id, :dir => direction, :flr => floor, :time => snapshot()}.to_json)
      sp.print "#{out}\r"
      sp.flush
    }
  end
  

  def board?(floor, direction)
    @destination == 0 && @start == floor \
      && @direction == direction
  end

  def board!
    max_floor = @direction == 'u' ? $FLOORS : @start
    lowest_floor = @direction == 'u' ? @start : 1
    flr = rand(max_floor)+lowest_floor
    json.puts({:tag => "request", :id => id, :flr => flr, :time => snapshot()}.to_json)
    $semaphore.synchronize {
      sp.print "r#{flr}\r"
      sp.flush
    }
    sleep 1.0
  end
  
  def leave?(floor)
    @destination == floor
  end
  
  def leave!
    json.puts({:tag=>"exit", :id=>@id, :floor=>@destination}.to_json)
  end
end

curr = 1

sp = SerialPort.new "/dev/tty.usbmodemfd121", 9600

#Opening the Serial Port resets
#the MCU, give it a second...
sleep 1.0

users = []

json = File.open("output.json", "w+")

a = Thread.new {
  10.times do
    #Go to a random floor
    direction = char_of_direction(rand(2))
    floor = rand($FLOORS) + 1
    out = "#{direction}#{floor}"
    $semaphore.synchronize {
      pass = Passenger.new(floor, direction)
      pass.arrive()
      users.push(pass)
    }
    sleep (rand(5)+1)
  end
  stderr.puts "done"
}

while true
  resp = ""
  resp = sp.readline("\n")

  if m = /^(f|o)([0-9]+).*/.match(resp)
    if m[1] == 'f'
      target = m[2].to_i
      diff = (curr - target).abs
      json.puts({:tag => "move", :from => curr, :time => snapshot()}.to_json)
      sleep diff
      $semaphore.synchronize {
        curr = target
        json.puts({:tag => "arrive", :flr => curr, :time => snapshot()}.to_json)
        sp.print "a#{m[2]}\r"
        sp.flush
      }
    elsif m[1] == 'o'
      json.puts({:tag => "open", :time => snapshot()}.to_json)
      users.delete_if { |u|
        res = u.leave?
        u.leave! if res
        res
      }
      users.each { |u|
        u.board! if u.board?
      }
      $semaphore.synchronize {
        json.puts({:tag => "close", :time => snapshot()}.to_json)
        sp.print "c\r"
        sp.flush
      }
    end
  else
    puts resp
    raise
  end
  json.flush
end
