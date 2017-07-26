#!/usr/bin/ruby

require 'anystyle/parser'
require 'nokogiri'
require_relative 'biblcounter'
require_relative 'crossreffing'


def tag(file)
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

    begin
      stringify(tagged, bibl, bt)
    rescue => e
      puts e
      puts "Something went wrong when transforming " + file.to_s
      wrongfiles = CSV.open("transformation_error.csv", 'w')
      wrongfiles << [file.to_s]
    end

  end

  return xml
end

def stringify(tags, bibl, unclear)
  tagdict = tags[0]

  if tagdict.key?(:author)

    if tagdict[:author].include? 'and'
      authors = tagdict[:author].split('and')
    else
      bibl.add_child "<author><name>#{tagdict[:author]}</name></author>"
      unclear.sub! "#{tagdict[:author]}", ""
    end

    unless authors.nil?
      authors.each {|potential_author|
        # remove leading and trailing whitespace
        potential_author.strip!

        if potential_author.include? ','
          author = potential_author.split(', ')
          surname = author[0].to_s
          forename = author[1].to_s

          bibl.add_child "<author><name><surname>" + surname + "</surname><forename>" + forename + "</forename></name></author>"

          puts "sur: " + surname.to_s
          puts "for: " + forename.to_s
        end
      }
    end
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
#
# def verify_author(potential_author)
#   wskey = OCLC::Auth::WSKey.new('api-key', 'api-key-secret', :services => ['WorldCatDiscoveryAPI'])
#   WorldCat::Discovery.configure(wskey, 128807, 128807)
#
#   params = Hash.new
#   params[:q] = potential_author
#   params[:facetFields] = ['itemType:10', 'inLanguage:10']
#   params[:startNum] = 0
#   results = WorldCat::Discovery::Bib.search(params)
#
#   puts "snkt: " + results.bibs.class.to_s
#   exit!
# end