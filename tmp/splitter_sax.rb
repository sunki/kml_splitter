#!/usr/bin/env ruby

require 'rubygems'
require 'sax-machine'

filename = ARGV[0]

raise "File #{filename} not found" if !File.exists?(filename)

class LineString
  include SAXMachine

  element :coordinates
end

class Placemark
  include SAXMachine

  element :LineString, :class => LineString
end

class Document
  include SAXMachine

  element :Placemark, :class => Placemark
end

kml = File.read(filename)
kml = Document.parse(kml)

kml.Placemark.LineString.coordinates.strip!

p kml.to_s