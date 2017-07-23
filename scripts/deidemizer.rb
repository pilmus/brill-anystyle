require 'anystyle/parser'
require 'nokogiri'

def deidemizeall
  rootpath = Dir.pwd

  # select all the xml folders in the current directory
  xmlfolders = Dir.glob('*').select {|f| File.directory? f}

  xmlfolders.each do |folder|
    # go to the folder with the xml files
    Dir.chdir folder

    deidemizefolder(folder)
    Dir.chdir rootpath
  end
end

def deidemizefolder(folder)
  # list all the xml files in the folder
  xmls = Dir.glob('*.xml')

  # for each xml file in the folder, perform the transformation and save the result
  xmls.each do |xml|
    # deidemized =
    deidemize(xml)
  end
end

def deidemize(filename)
  xml = File.read(filename)
  doc = Nokogiri::XML(xml)

  # find the tag named listBibl and every bibl under it
  bibls = doc.css("listBibl bibl")

  prevauthor = ""

  bibls.each do |bibl|
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
      if btsplitcomma.include?("Id.") || btsplitdot.include?("id.")
        bt.sub! "Id.", prevauthor.to_s
      end
      if btsplitcomma.include?("[id.]") || btsplitdot.include?("[id.]")
        bt.sub! "[id.]", prevauthor.to_s
      end
      if btsplitcomma.include?("[Id.]") || btsplitdot.include?("[Id.]")
        bt.sub! "[Id.]", prevauthor.to_s
      end
      if btsplitcomma.include?("ders.") || btsplitdot.include?("ders.")
        bt.sub! "ders.", prevauthor.to_s
      end
      if btsplitcomma.include?("Ders.") || btsplitdot.include?("Ders.")
        bt.sub! "Ders.", prevauthor.to_s
      end
      if btsplitcomma.include?("dies.") || btsplitdot.include?("dies.")
        bt.sub! "dies.", prevauthor.to_s
      end
      if btsplitcomma.include?("Dies.") || btsplitdot.include?("Dies.")
        bt.sub! "Dies.", prevauthor.to_s
      end
      if bt.include? "â€”â€”"
        bt.sub! "â€”â€”", prevauthor.to_s
      end
    end

    bibl.content = bt
    tagged = Anystyle.parse bt

    prevauthor = tagged[0][:author]

  end
  File.write(filename, doc.to_xml)
end