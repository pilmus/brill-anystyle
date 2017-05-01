#!/usr/bin/ruby

require 'nokogiri'

def biblcounter(xml)
  bibls = xml.css("listBibl bibl title")

  totalbibls = bibls.length
  mbibls = 0
  jbibls = 0

  bibls.each do |bibl|
    # get the level of the title node
    level = bibl.attribute("level").text

    # increment the counters
    if level == "m"
      mbibls += 1
    end
    if level == "j"
      jbibls += 1
    end
  end

  puts "number of bibls: " + totalbibls.to_s
  puts "title level=\"m\": " + mbibls.to_s
  puts "title level=\"j\": " +jbibls.to_s
end