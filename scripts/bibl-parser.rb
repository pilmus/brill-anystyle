#!/usr/bin/ruby

require 'anystyle/parser'
require 'nokogiri'
require_relative 'bibl-counter'

def tag(file)

  # puts "\nCurrently transforming " + file.to_s + "\n"

  xml = Nokogiri::XML(File.open(file))

  # find the tag named listBibl and every bibl under it
  bibls = xml.css("listBibl bibl")

  bibls.each do |bibl|
    bt = bibl.text

    # skips tags that include the words w/in the brackets, because we want to leave them unchanged
    next if (bt.include? ("Primary sources" || "Secondary sources")) || bt == ""

    # strip leading and trailing whitespaces
    bt.strip!

    # replaces numbers within brackets that may be at the beginning of a bibl
    bt.gsub(/^\[\d{1,2}\]/, '')
    bt.gsub(/^\d{1,2}/, '')

    bibl.content = ""
    tagged = Anystyle.parse bt

    # puts "Here is the tagdict: " + tagged.to_s

    stringify(tagged, bibl, bt)

  end

  return xml
end

def stringify(tags, bibl, unknown)
  tagdict = tags[0]

  if tagdict.key?(:author)
    bibl.add_child "<author><name>#{tagdict[:author]}</name></author>"
    unknown.sub! "#{tagdict[:author]}", ""
  end

  if tagdict.key?(:journal)
    bibl.add_child "<title level=\"a\">#{tagdict[:title]}</title>"
    unknown.sub! "#{tagdict[:title]}", ""
  else
    bibl.add_child "<title level=\"m\">#{tagdict[:title]}</title>"
    unknown.sub! "#{tagdict[:title]}", ""
  end

  if tagdict.key?(:journal)
    bibl.add_child "<title level=\"j\">#{tagdict[:journal]}</title>"
    unknown.sub! "#{tagdict[:journal]}", ""
  end

  if tagdict.key?(:volume)
    bibl.add_child "<biblScope unit=\"volume\">#{tagdict[:volume]}</biblScope>"
    unknown.sub! "#{tagdict[:volume]}", ""
  end

  if tagdict.key?(:pages)
    bibl.add_child "<biblScope unit=\"page\">#{tagdict[:pages]}</biblScope>"
    unknown.sub! "#{tagdict[:pages]}", ""
  end

  if tagdict.key?(:editor)
    bibl.add_child "<editor><name>#{tagdict[:editor]}</name></editor>"
    unknown.sub! "#{tagdict[:editor]}", ""
  end

  if tagdict.key?(:date)
    bibl.add_child "<date>#{tagdict[:date]}</date>"
    unknown.sub! "#{tagdict[:date]}", ""
  end

  if tagdict.key?(:location)
    bibl.add_child "<pubPlace>#{tagdict[:location]}</pubPlace>"
    unknown.sub! "#{tagdict[:location]}", ""
  end

  if tagdict.key?(:publisher)
    bibl.add_child "<publisher>#{tagdict[:publisher]}</publisher>"
    unknown.sub! "#{tagdict[:publisher]}", ""
  end

  if tagdict.key?(:unknown) && unknown != ""
    bibl.add_child "<unclear>#{tagdict[:unknown]}</unclear>"
  elsif tagdict.key?(:unknown) && unknown == ""
    bibl.add_child "<unclear>#{tagdict[:unknown]}</unclear>"
  else
    bibl.add_child "<unclear>#{unknown}</unclear>"
  end

  if tagdict.key?(:url)
    bibl.add_child "<ref target=\"#{tagdict[:url]}\">#{tagdict[:url]}</ref>"
  end
end

Anystyle.parser.model.path = "." #put your model in the same folder as your script
