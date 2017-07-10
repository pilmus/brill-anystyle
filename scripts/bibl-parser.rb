#!/usr/bin/ruby

require 'anystyle/parser'
require 'nokogiri'
require_relative 'bibl-counter'
# require_relative 'crossreffing'


def tag(file)
  puts file.to_s
  xml = Nokogiri::XML(File.open(file))

  # find the tag named listBibl and every bibl under it
  bibls = xml.css("listBibl bibl")

  bibls.each do |bibl|
    bt = bibl.text

    # skips certain tags we wish to leave unchanged
    next if (bt.include? ("Primary sources" || "Secondary sources")) || bt == ""

    # strip leading and trailing whitespaces
    bt.strip!

    # replaces numbers within brackets that may be at the beginning of a bibl
    bt.gsub!(/^\[\d{1,2}\]/, '')
    bt.gsub!(/^\d{1,2}/, '')

    # empty the tag so we can fill it with tagged information
    bibl.content = ""
    tagged = Anystyle.parse bt

    stringify(tagged, bibl, bt)
  end

  return xml
end

def stringify(tags, bibl, unclear)
  puts bibl
  tagdict = tags[0]

  # puts "tagdict: " + tagdict.to_s

  if tagdict.key?(:author)
    bibl.add_child "<author><name>#{tagdict[:author]}</name></author>"
    unclear.sub! "#{tagdict[:author]}", ""
  end

  if tagdict.key?(:title)
    bibl.add_child "<title level=\"a\">#{tagdict[:title]}</title>"
    unclear.sub! "#{tagdict[:title]}", ""
  else
    bibl.add_child "<title level=\"m\">#{tagdict[:title]}</title>"
    unclear.sub! "#{tagdict[:title]}", ""
  end

  if tagdict.key?(:journal)
    bibl.add_child "<title level=\"j\">#{tagdict[:journal]}</title>"
    unclear.sub! "#{tagdict[:journal]}", ""
  end

  if tagdict.key?(:volume)
    bibl.add_child "<biblScope unit=\"volume\">#{tagdict[:volume]}</biblScope>"
    unclear.sub! "#{tagdict[:volume]}", ""
  end

  if tagdict.key?(:pages)
    bibl.add_child "<biblScope unit=\"page\">#{tagdict[:pages]}</biblScope>"
    unclear.sub! "#{tagdict[:pages]}", ""
  end

  if tagdict.key?(:editor)
    bibl.add_child "<editor><name>#{tagdict[:editor]}</name></editor>"
    unclear.sub! "#{tagdict[:editor]}", ""
  end

  if tagdict.key?(:date)
    bibl.add_child "<date>#{tagdict[:date]}</date>"
    unclear.sub! "#{tagdict[:date]}", ""
  end

  if tagdict.key?(:location)
    bibl.add_child "<pubPlace>#{tagdict[:location]}</pubPlace>"
    unclear.sub! "#{tagdict[:location]}", ""
  end

  if tagdict.key?(:publisher)
    bibl.add_child "<publisher>#{tagdict[:publisher]}</publisher>"
    unclear.sub! "#{tagdict[:publisher]}", ""
  end

  if tagdict.key?(:url)
    bibl.add_child "<ref target=\"#{tagdict[:url]}\">#{tagdict[:url]}</ref>"
    unclear.sub! "#{tagdict[:url]}", ""
  end

  if tagdict.key?(:unknown)
    bibl.add_child "<unclear>#{tagdict[:unknown]}#{unclear}</unclear>"
  else
    unclear.to_s.each_char {|c|
      if c =~ /[[:punct:]]/ || c == ' '
      else
        bibl.add_child "<unclear>#{unclear}</unclear>"
        break
      end
    }
  end

  # puts tagdict
  #
  # if tagdict.key?(:title)
  #   doi = finddoi(tagdict[:title])
  #   bibl.add_child "<idno type=\"DOI\">" + doi.to_s + "</idno>"
  # end


end

# Anystyle.parser.model.path = "." #put your model in the same folder as your script

if ARGV.length != 0
  tagged = tag(ARGV[0])
  FileUtils.mkdir("tagged_xmls-copy") unless Dir.exists?("tagged_xmls-copy")
  outfile = File.new(File.join(Dir.pwd, "tagged_xmls-copy", ARGV[0]), "w")
  outfile.write(tagged)
  outfile.close
end
