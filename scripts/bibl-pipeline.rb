require 'csv'
require 'fileutils'
require_relative 'bibl-parser'
require_relative 'bibl-counter'
require_relative 'bibl-deidemizer'

def transformxml(xml)
  tagged = tag(xml)
  biblcounter(tagged)

  # create the folder that will contain the new xmls if it does not yet exist
  FileUtils.mkdir("tagged_xmls-copy") unless Dir.exists?("tagged_xmls-copy")
  outfile = File.new(File.join(Dir.pwd, "tagged_xmls-copy", xml), "w")
  outfile.write(tagged)
  outfile.close
end

def transformfolder(folder)
  # create the folder that will contain the new xmls if it does not yet exist
  FileUtils.mkdir("tagged_xmls-copy") unless Dir.exists?("tagged_xmls-copy")


  # list all the xml files in the folder
  xmls = Dir.glob('*.xml')

  csvname = folder.to_s + "_biblcounts.csv"
  # puts csvname
  countfile = CSV.open(csvname, 'w')
  countfile << ["file", "total bibls", "m-level", "j-level", "a-level", "s-level", "u-level"]

  # for each xml file in the folder, perform the transformation and save the result
  xmls.each do |xml|
    tagged = tag(xml)

    # count the number of m and j level bibls
    totalbibls, totalm, totalj, totala, totals, totalu = biblcounter(tagged)
    countfile << [xml.to_s, totalbibls, totalm, totalj, totala, totals, totalu]

    # make new file to write the tagged xml into
    outfile = File.new(File.join(Dir.pwd, "tagged_xmls-copy", xml), "w")
    outfile.write(tagged)
    outfile.close
  end
  # close the csv file
  countfile.close
end

def transformall

  rootpath = Dir.pwd

  countfile = CSV.open("total_biblcounts.csv", 'w')
  countfile << ["file", "total bibls", "m-level", "j-level", "a-level", "s-level", "u-level"]

  totalbibls = 0
  totalm = 0
  totalj = 0
  totala = 0
  totals = 0
  totalu = 0

  # select all the xml folders in the current directory
  # !!NOTE!! this assumes the only folders in the current directory are folders with xml files that
  # need to be converted!
  xmlfolders = Dir.glob('*').select {|f| File.directory? f}

  xmlfolders.each do |folder|
    # go to the folder with the xml files
    Dir.chdir folder

    transformfolder(folder)
    Dir.chdir rootpath
  end

  xmlfolders.each do |folder|
    Dir.chdir folder
    csvname = folder.to_s + "_biblcounts.csv"

    CSV.foreach(csvname, headers: true, converters: :numeric) do |row|
      totalbibls += row[1]
      totalm += row[2]
      totalj += row[3]
      totala += row[4]
      totals += row[5]
      totalu += row[6]
    end
    countfile << [folder, totalbibls, totalm, totalj, totala, totals, totalu]
    Dir.chdir rootpath
  end
  countfile.close
end


if ARGV.length == 0
  deidemizeall
  transformall
  # if you have supplied an xml file as a command line argument, this part of the script will be run
else
  xml = ARGV[0]
  deidemize(xml)
  transformxml(xml)
end


