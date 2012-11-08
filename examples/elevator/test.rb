#!/usr/bin/env rubyx

require 'serialport'

sp = SerialPort.new "/dev/tty.usbmodemfd121", 9600

sp.print "u10\r"

puts sp.readline("\r\n")
