#!/usr/bin/ruby

require 'anystyle/parser'
require 'nokogiri'

def transform(file)
  xml = Nokogiri::XML(File.open(file))

  # find the tag named listBibl and every bibl under it
  xml.css("listBibl bibl").each do |bibl|
    bt = bibl.text

    # skips tags that include the words w/in the brackets, because we want to leave them unchanged
    next if bt.include? ("Primary sources" || "Secondary sources")

    # replaces numbers within brackets that may be at the beginning of a bibl
    bt.sub! "^\[\d{1,2}\]", ""
    bt.sub! "^\d{1,2}", ""

    bibl.content = ""
    tagged = Anystyle.parse bt
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

# select all the xml folders in the current directory
# !!NOTE!! this assumes the only folders in the current directory are folders with xml files that
# need to be converted!
xmlfolders = Dir.glob('*').select {|f| File.directory? f}

# name of the folder that will contain the transformed xmls
dirname = "new_xmls-copy"

xmlfolders.each do |item|
  # go to the folder with the xml files
  Dir.chdir item
  puts Dir.pwd
  # create the folder that will contain the new xmls if it does not yet exist
  FileUtils.mkdir(dirname) unless Dir.exists?(dirname)

  # list all the xml files in the folder
  xmls = Dir.glob('*.xml')

  # for each xml file in the folder, perform the transformation and save the result
  xmls.each do |xml|
    transformed = transform(xml)
    # make new file to write the transformed xml into
    outfile = File.new(File.join(Dir.pwd, dirname, xml), "w")
    outfile.write(transformed)
    outfile.close
  end
  current_path = Dir.pwd
  target_path = File.expand_path("..", current_path)
  Dir.chdir target_path
  puts Dir.pwd
end

