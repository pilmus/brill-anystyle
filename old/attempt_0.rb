#!/usr/bin/ruby

require 'anystyle/parser'
require 'nokogiri'

def transform(file)
    xml = Nokogiri::XML(File.open(file))
    xml.css("bibl").each do |bibl|
	bt = bibl.text
	next if bt.include? ("Primary sources" || "Secondary sources")
	bibl.content = ""
	tagged = Anystyle.parse bt 
        stringify(tagged,bibl)
    end
    
    return xml
end

def stringify(tags,bibl)
    tagdict = tags[0]

    if tagdict.key?(:author)
	bibl.add_child "<author><name>#{tagdict[:author]}</name></author>"
    end

    if tagdict.key?(:journal)
	bibl.add_child "<title level=\"a\">#{tagdict[:title]}</title>"
    else
	bibl.add_child "<title level=\"m\">#{tagdict[:title]}</title>"
    end
    
    if tagdict.key?(:journal)
	bibl.add_child "<title level="j">#{tagdict[:journal]}</title>"
    end

    if tagdict.key?(:volume)
        bibl.add_child "<volume>#{tagdict[:volume]}</volume>"
    end
 
    if tagdict.key?(:pages)
        bibl.add_child "<pages>#{tagdict[:pages]}</pages>"
    end

    if tagdict.key?(:editor)
        bibl.add_child "<editor><name>#{tagdict[:editor]}</name></editor>"
    end

    if tagdict.key?(:date)
        bibl.add_child "<date>#{tagdict[:date]}</date>"
    end

    if tagdict.key?(:location)
        bibl.add_child "<pubPlace>#{tagdict[:location]}</pubPlace>"
    end

    if tagdict.key?(:publisher)
        bibl.add_child "<publisher>#{tagdict[:publisher]}</publisher>"
    end

    if tagdict.key?(:unknown)
	bibl.add_child "<unclear>#{tagdict[:unknown]}</unclear>"
    end

    if tagdict.key?(:url)
	bibl.add_child "<ref target=\"#{tagdict[:url]}\">#{tagdict[:url]}</ref>"
    end
end

Anystyle.parser.model.path = "." #put your model in the same folder as your script

# list all the xml files in the folder
xmls = Dir.glob('*.xml')

# name of the folder that will contain the transformed xmls
dirname = "new_xmls"

# create the folder that will contain the new xmls if it does not yet exist
FileUtils.mkdir(dirname) unless Dir.exists?(dirname)

xmls.each do |item|
    transformed = transform(item)
    # make new file to write the transformed xml into
    outfile = File.new(File.join(Dir.pwd, dirname, item), "w")
    outfile.write(transformed)
    outfile.close
end

