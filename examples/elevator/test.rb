#!/usr/bin/env ruby

require 'rubygems'
require 'serialport'
require 'json'

#Really hacky discrete event simulator for the elevator. Each service request
#and passenger request should be an object along with total wait time for service.

semaphore = Mutex.new

FLOORS = 10

curr = 1

sp = SerialPort.new "/dev/tty.usbmodemfd121", 9600, 8 , 1, SerialPort::NONE

#Serial Connection Resets the Chip.
sleep 1.0

$origin = Time.now.to_f * 1000.0

def snapshot()
  Time.now.to_f * 1000.0 - $origin
end

users = []

json = File.open("output.json", "w+")

a = Thread.new {
  10.times do
    #Go to a random floor
    direction = (rand(2) == 0) ? 'u' : 'd'
    floor = rand(FLOORS) + 1
    out = "#{direction}#{floor}"
    semaphore.synchronize {
      users.push({:start => floor, :dest => 0, :direction => direction})
      json.puts({:tag => "service",:dir => direction, :flr => floor, :time => snapshot()}.to_json)
      sp.print "#{out}\r"
      sp.flush
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
      semaphore.synchronize {
        curr = target
        json.puts({:tag => "arrive", :flr => curr, :time => snapshot()}.to_json)
        sp.print "a#{m[2]}\r"
        sp.flush
      }
    elsif m[1] == 'o'
      semaphore.synchronize {
        json.puts({:tag => "open", :time => snapshot()}.to_json)
        users.delete_if { |u|
          u[:dest] == curr
        }
        users.map! { |u|
          random_request = lambda {
            max_floor = u[:direction] == 'u' ? FLOORS : curr
            lowest_floor = u[:direction] == 'u' ? curr : 1
            flr = rand(max_floor)+lowest_floor
            json.puts({:tag => "request", :flr => flr, :time => snapshot()}.to_json)
            sp.print "r#{flr}\r"
            sp.flush
            sleep 1.0
            flr
          }
          if u[:start] == curr && u[:dest] == 0
            u[:dest] = random_request.call()
          end
          u
        }
      }
      json.puts({:tag => "close", :time => snapshot()}.to_json)
      sp.print "c\r"
    end
  else
    puts resp
    raise
  end
  json.flush
end
