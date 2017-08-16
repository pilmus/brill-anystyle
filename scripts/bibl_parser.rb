#!/usr/bin/ruby

require 'anystyle/parser'
require 'nokogiri'
require_relative 'bibl_counter'
require_relative 'crossreffing'
require_relative 'stringify'


def tag(file, do_doi, do_viaf)
  xml = Nokogiri::XML(File.open(file))

  # find the tag named listBibl and every bibl under it
  bibls = xml.css("listBibl bibl")

  wrongfiles = CSV.open("transformation_error.csv", 'w')

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

    begin
      stringify(tagged[0], bibl, bt, do_doi, do_viaf)
    rescue => e
      puts "Something went wrong when transforming " + file.to_s
      puts e.to_s
      wrongfiles << [file.to_s]
      #raise #TODO: comment this out when done
    end

  end

  wrongfiles.close

  return xml
end

def stringify(tagdict, bibl, unclear, do_doi, do_viaf)

  if tagdict.key?(:author)
    stringify_author(tagdict[:author], bibl, do_viaf)
  end

  # check if journal, if so title level article, otherwise book
  if tagdict.key?(:journal)
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

  if do_doi == "yes"
    if tagdict.key?(:title)
      begin
        doi = finddoi(tagdict[:title])
        bibl.add_child "<idno type=\"DOI\">" + doi.to_s + "</idno>"
      rescue
        bibl.add_child "<idno type=\"DOI\"></idno>"
        raise
      end
    end
  end
end