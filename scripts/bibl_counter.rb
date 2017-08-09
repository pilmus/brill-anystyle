#!/usr/bin/ruby

require 'nokogiri'

def bibl_counter(xml)
  bibls = xml.css("listBibl bibl")
  bibl_titles = xml.css("listBibl bibl title")
  bibl_names = xml.css("listBibl bibl name")

  totalbibls = bibls.length
  mbibls = 0
  jbibls = 0
  abibls = 0
  sbibls = 0
  ubibls = 0
  mpbibls = 0
  monobibls = 0
  polybibls = 0

  bibl_titles.each do |bibl|
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

  bibl_names.each do |bibl|
    type = bibl.attribute("type").to_s

    if type == "misparsed"
      mpbibls += 1
    end
    if type == "mononym"
      monobibls += 1
    end
    if type == "polynym"
      polybibls += 1
    end
  end
  return totalbibls, mbibls, jbibls, abibls, sbibls, ubibls, mpbibls, monobibls, polybibls
end

def count_one(file)
  xml = Nokogiri::XML(File.open(file))
  totalbibls, mbibls, jbibls, abibls, sbibls, ubibls, mpbibls, monobibls, polybibls = bibl_counter(xml)
  puts "total bibls: " + totalbibls.to_s
  puts "m-level bibls: " + mbibls.to_s
  puts "j-level bibls: " + jbibls.to_s
  puts "a-level bibls: " + abibls.to_s
  puts "s-level bibls: " + sbibls.to_s
  puts "u-level bibls: " + ubibls.to_s
  puts "misparsed bibls: " + mpbibls.to_s
  puts "mononym bibls: " + monobibls.to_s
  puts "polynym bibls: " + polybibls.to_s
 end