require 'anystyle/parser'
require 'nokogiri'

def deidemizeall
  rootpath = Dir.pwd

  # select all the xml folders in the current directory
  # !!NOTE!! this assumes the only folders in the current directory are folders with xml files that
  # need to be converted!
  xmlfolders = Dir.glob('*').select {|f| File.directory? f}

  xmlfolders.each do |folder|
    # go to the folder with the xml files
    Dir.chdir folder

    deidemizefolder(folder)
    Dir.chdir rootpath
  end
end

def deidemizefolder(folder)
  # create the folder that will contain the new xmls if it does not yet exist
  FileUtils.mkdir("deidemized_xmls-copy") unless Dir.exists?("deidemized_xmls-copy")


  # list all the xml files in the folder
  xmls = Dir.glob('*.xml')

  # for each xml file in the folder, perform the transformation and save the result
  xmls.each do |xml|
    deidemized = deidemize(xml)

    outfile = File.new(File.join(Dir.pwd, "deidemized_xmls-copy", xml), "w")
    outfile.write(deidemized)
    outfile.close
  end
end

def deidemize(file)
  xml = Nokogiri::XML(File.open(file, 'r'))

  # find the tag named listBibl and every bibl under it
  bibls = xml.css("listBibl bibl")

  prevauthor = ""

  bibls.each do |bibl|
    bt = bibl.text

    # skips certain tags we wish to leave unchanged
    next if (bt.include? ("Primary sources" || "Secondary sources")) || bt == ""

    bt.gsub!(/\s+/, ' ')

    puts "bt: " + bt

    # strip leading and trailing whitespaces
    bt.strip!

    # replaces numbers within brackets that may be at the beginning of a bibl
    bt.gsub!(/^\[\d{1,2}\]/, '')
    bt.gsub!(/^\d{1,2}/, '')

    if bt.include? "idem"
      bt.sub! "idem", prevauthor.to_s
    end
    if bt.include? "id."
      bt.sub! "id.", prevauthor.to_s
    end
    if bt.include? "â€”â€”"
      bt.sub! "â€”â€”", prevauthor.to_s
    end

    # puts "bt: " + bt
    bibl.content = bt
    tagged = Anystyle.parse bt

    prevauthor = tagged[0][:author]
  end
  return xml
end

if ARGV.length == 0
  deidemizeall
elsif ARGV.length != 0
  deidemized = deidemize(ARGV[0])
  outfile = File.new(File.join(Dir.pwd, "deidemized_xmls-copy", xml), "w")
  outfile.write(deidemized)
  outfile.close
end
