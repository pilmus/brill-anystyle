require 'anystyle/parser'
require 'nokogiri'

def deidemizeall
  # puts "De-idemizing all the things..."
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
  # puts "De-idemizing " + folder.to_s + "..."
  # create the folder that will contain the new xmls if it does not yet exist
  # FileUtils.mkdir("deidemized_xmls-copy") unless Dir.exists?("deidemized_xmls-copy")


  # list all the xml files in the folder
  xmls = Dir.glob('*.xml')

  # for each xml file in the folder, perform the transformation and save the result
  xmls.each do |xml|
    # deidemized =
    deidemize(xml)

    # outfile = File.new(File.join(Dir.pwd, "deidemized_xmls-copy", xml), "w")
    # outfile.write(deidemized)
    # outfile.close
  end
end

def deidemize(filename)
  xml = File.read(filename)
  doc = Nokogiri::XML(xml) #File.open(filename, 'r'))

  # find the tag named listBibl and every bibl under it
  bibls = doc.css("listBibl bibl")

  prevauthor = ""

  bibls.each do |bibl|
    # puts prevauthor
    bt = bibl.text
    # skips certain tags we wish to leave unchanged
    if bt.to_s.empty? || bt == " "
      bibl.remove
    end
    next if (bt.include? ("Primary sources" || "Secondary sources")) || bt.to_s.empty? || bt == " "

    bt.gsub!(/\s+/, ' ')

    # strip leading and trailing whitespaces
    bt.strip!

    # replaces numbers within brackets
    bt.sub!(/^\[\d{1,2}\]\s?/, '')
    bt.sub!(/^\(\d{1,2}\)\s?/, '')
    bt.sub!(/^\d{1,2}\s?/, '')



    btsplitcomma = bt.split(',')[0]
    btsplitdot = bt.split('.')[0]

    if !prevauthor.to_s.empty?
      if bt.include? "——"
        bt.sub! "——", prevauthor.to_s
      end
      if btsplitcomma.include?("idem")|| btsplitdot.include?("idem")
        bt.sub! "idem", prevauthor.to_s
      end
      if btsplitcomma.include?("Idem") || btsplitdot.include?("Idem")
        bt.sub! "Idem", prevauthor.to_s
      end
      if btsplitcomma.include?("id.") || btsplitdot.include?("id.")
        bt.sub! "id.", prevauthor.to_s
      end
      if btsplitcomma.include?("[id.]") || btsplitdot.include?("[id.]")
        bt.sub! "[id.]", prevauthor.to_s
      end
      if bt.include? "â€”â€”"
        bt.sub! "â€”â€”", prevauthor.to_s
      end
    end

    # puts "bt: " + bt
    bibl.content = bt
    tagged = Anystyle.parse bt

    # puts "tagged: " + tagged.to_s

    prevauthor = tagged[0][:author]

  end
  File.write(filename, doc.to_xml)
  # return doc
end

if ARGV.length == 0
  deidemizeall
elsif ARGV.length != 0
  deidemized = deidemize(ARGV[0])

  filename = File.join(Dir.pwd, ARGV[0].to_s + "-deidemized").to_s

  outfile = File.new(filename, "w")
  outfile.write(deidemized)
  outfile.close
end
