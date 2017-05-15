require 'csv'
require 'fileutils'
require_relative 'bibl-parser'
require_relative 'bibl-counter'

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
  countfile << ["file", "total", "m-level", "j-level", "a-level"]

  # for each xml file in the folder, perform the transformation and save the result
  xmls.each do |xml|
    tagged = tag(xml)

    # count the number of m and j level bibls
    total, m, j, a = biblcounter(tagged)
    countfile << [xml.to_s, total, m, j, a]

    # make new file to write the tagged xml into
    outfile = File.new(File.join(Dir.pwd, "tagged_xmls-copy", xml), "w")
    outfile.write(tagged)
    outfile.close
  end
  # close the csv file
  countfile.close()
end

def transformall
  rootpath = Dir.pwd

  countfile = CSV.open("total_biblcounts.csv", 'w')
  countfile << ["file", "total", "m-level", "j-level", "a-level"]

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

    CSV.foreach(csvname, headers: true) do |row|
      puts row.to_s
    end
    Dir.chdir rootpath
  end
end


if ARGV.length == 0
  transformall
  # if you have supplied an xml file as a command line argument, this part of the script will be run
else
  xml = ARGV[0]
  transformxml(xml)
end


