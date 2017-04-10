#!/usr/bin/ruby

require 'anystyle/parser'
require 'nokogiri'

def transform(file)
  xml = Nokogiri::XML(File.open(file))
  xml.css("listBibl bibl").each do |bibl|
    puts "hey!"
  end
end

# list all the xml files in the folder
xmls = Dir.glob('*.xml')

xmls.each do |item|
  transform(item)
end
