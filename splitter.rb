#!/usr/bin/env ruby

require 'rubygems'
require 'fileutils'
require 'sax-machine'

fname = ARGV[0]
fname_parts = fname.split('.')
points_per_file = ARGV[1].to_i || 50
@dir = 'split'

raise "File #{fname} not found" unless File.exists?(fname)

FileUtils.mkpath(@dir) unless File.directory?(@dir)

def write_split_file filename, xml
  file = File.open(File.join(@dir, filename), 'w')
  file.write(xml)
  file.close
end

file = File.open(fname, 'r')
xml = Nokogiri::XML(file)
file.close

split_coords = {}
file_num = 1
last_coord = nil

title = xml.css('Document name').first
name  = xml.css('Placemark name').first
coords = xml.css('coordinates').first

coords.content.strip.split(' ').compact.each_with_index do |coord,i|
  arr = split_coords[file_num] ||= []
  arr << last_coord if arr.empty? && last_coord
  arr << coord

  file_num += 1 if (i+1) % points_per_file == 0
  last_coord = coord
end

split_coords.each do |i,coord|
  title.content = "#{title.content} #{i}"
  name.content  = "#{name.content} #{i}"
  coords.content = coord.join(' ')
  write_split_file "#{fname_parts[0]}-#{i}.#{fname_parts[1]}", xml
end

