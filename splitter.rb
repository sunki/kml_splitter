#!/usr/bin/env ruby

require 'rubygems'
require 'fileutils'
require 'sax-machine'

fname = ARGV[0]
fname_parts = fname.split('.')
points_per_file = ARGV[1] || 50
@dir = 'split'

raise "File #{fname} not found" if !File.exists?(fname)

FileUtils.mkpath(@dir) if !File.directory?(@dir)

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

coords = xml.css('coordinates').first
coords.content.strip.split(' ').compact.each_with_index do |coord,i|
  (split_coords[file_num] ||=[]) << coord

  file_num += 1 if (i+1) % points_per_file == 0
end

split_coords.each do |i,coord|
  coords.content = coord.join(' ')
  write_split_file "#{fname_parts[0]}-#{i}.#{fname_parts[1]}", xml
end

