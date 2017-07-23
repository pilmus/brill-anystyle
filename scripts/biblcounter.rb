#!/usr/bin/ruby

require 'nokogiri'

def biblcounter(xml)
  bibls = xml.css("listBibl bibl title")

  totalbibls = bibls.length
  mbibls = 0
  jbibls = 0
  abibls = 0
  sbibls = 0
  ubibls = 0

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
    if level == "a"
      abibls += 1
    end
    if level == "s"
      sbibls += 1
    end
    if level == "u"
      ubibls += 1
    end
  end

  return totalbibls, mbibls, jbibls, abibls, sbibls, ubibls
end

def count_one(file)
  xml = Nokogiri::XML(File.open(file))
  totalbibls, mbibls, jbibls, abibls, sbibls, ubibls = biblcounter(xml)
  puts "total bibls: " + totalbibls.to_s
  puts "m-level bibls: " + mbibls.to_s
  puts "j-level bibls: " + jbibls.to_s
  puts "a-level bibls: " + abibls.to_s
  puts "s-level bibls: " + sbibls.to_s
  puts "u-level bibls: " + ubibls.to_s
end