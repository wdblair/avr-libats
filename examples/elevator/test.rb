#!/usr/bin/env ruby

#A discrete event simulator to test the elevator controller.

require 'rubygems'
require 'serialport'
require 'json'

require 'securerandom'

FLOORS = 10

def char_of_direction(d)
  d == 0 ? 'u' : 'd'
end

class Elevator
  def initialize()
    @semaphore = Mutex.new
    @sp = SerialPort.new "/dev/tty.usbmodemfd121", 9600
    @curr = 1
    @direction = 'u'
    #Opening the Serial Port resets the MCU, give it a
    #second.
    sleep 1.0
    @origin = Time.now.to_f * 1000.0
    @onboard = []
    @events = []
  end

  #Send a service request from someone
  #waiting for the elevator.
  def service(id, direction, flr)
    out = "#{direction}#{flr}\r"
    send_message(out)
    js = {:id=> id, :dir => direction, :flr => flr}
    publish_event("service", js)
  end
  
  #Send a request from a passenger
  #inside the elevator to the controller
  def request(id, floor)
    send_message("r#{floor}\r")
    js = {:id => id, :flr => floor}
    publish_event("request", js)
  end

  def exit(id, floor)
    js = {:id => id, :flr => floor}
    publish_event("exit", js)
    sleep 1.0
  end
  
  #Record doors opening
  def open(dir)
    @direction = char_of_direction(dir)
    js = {:direction=>@direction}
    publish_event("open", js)
    
    @onboard.delete_if { |u|
      u.leave(self)
    }
  end
  
  def board(users)
    return if users.nil?

    users.delete_if { |u|
      res = u.board(self)
      @onboard.push(u) if res
      res
    }
  end
  
  #Close the doors
  def close()
    send_message("c\r")
    publish_event("close", {})
  end
  
  #Move to a specific floor.
  def move(to)
    js = {:from => @curr}
    publish_event("move", js)

    #Actually move to the floor
    diff = (@curr - to).abs
    sleep diff
    send_message("a#{to}\r")
    @curr = to
    js = {:flr => @curr}
    publish_event("arrive", js)
  end

  #Wait for a message from the device
  def wait()
    resp = @sp.readline("\n")
    
    if m = /^(f|o)([0-9]+).*/.match(resp)
      return m
    end
    
    puts resp
    raise
  end
 
  def floor()
    @curr
  end
  
  def direction()
    @direction
  end

  #Send a string to the device
  def send_message(msg)
    @semaphore.synchronize {
      @sp.print(msg)
      @sp.flush()
    }
  end

  #Log a message to the simulator
  def publish_event(tag, msg)
    msg[:tag] = tag
    msg[:time] = snapshot()
    puts msg.to_json()
    @events.push msg
  end

  #Output a nice history in JSON to file
  def output_events(filename)
    File.open(filename, "w+") { |out|
      out.write @events.to_json()
    }
  end

  def snapshot()
    Time.now.to_f * 1000.0 - @origin
  end
end

class Passenger
  attr_accessor :start
  
  @@nextid = 0

  def initialize()
    #Fetch a random direction and floor.
    direction = char_of_direction(SecureRandom.random_number(2))
    floor = SecureRandom.random_number(FLOORS) + 1
    
    @id = @@nextid
    @@nextid += 1
    @start = floor
    @direction = direction
    
    @direction = case @start
                   when 10 then 'd'
                   when 1 then 'u'
                   else @direction
                 end

    #Not set until boarding the elevator.
    @destination = 0
  end
  
  def arrive(elevator)
    elevator.service(@id, @direction, @start)
  end
  
  def board(elevator)
    if @destination == 0 && @start == elevator.floor() \
      && @direction == elevator.direction()
     
      make_destination()
      elevator.request(@id, @destination)
      sleep 1.0
      return true
    end
    false
  end
  
  def leave(elevator)
    res = @destination == elevator.floor()
    if res
      elevator.exit(@id, @destination)
    end
    res
  end

  def make_destination()
    max_floor = @direction == 'u' ? FLOORS : @start
    lowest_floor = @direction == 'u' ? @start : 1
    dist = max_floor - lowest_floor
    flr = @start

    #Shouldn't request the current floor
    while flr == @start
      flr = SecureRandom.random_number(dist+1)+lowest_floor
    end
    @destination = flr
  end
end

#Users waiting to board the elevator by floor
waiting = {}

elevator = Elevator.new()

if ARGV.length == 0
  puts "Need an output file."
  exit 1
end

Signal.trap("USR1") {
  elevator.output_events(ARGV[0])
  puts "File Written..."
}

a = Thread.new {
  10.times do
    #Go to a random floor
    pass = Passenger.new()
    pass.arrive(elevator)
    waiting[pass.start] ||= []
    waiting[pass.start].push(pass)
    sleep (SecureRandom.random_number(5)+1)
  end
}

while true
  cmd = elevator.wait()
  case cmd[1]
  when 'f' then
    target = cmd[2].to_i
    elevator.move(target)
  when 'o' then
    elevator.open(cmd[2].to_i)
    elevator.board(waiting[elevator.floor()])
    elevator.close()
  end
  STDOUT.flush()
end
