require 'csv'
require 'fileutils'
require 'anystyle/parser'
require_relative 'bibl_parser'
require_relative 'bibl_counter'
require_relative 'deidemizer'

def transformxml(xml)
  tagged = tag(xml)
  bibl_counter(tagged)

  outfilename = "transformedfile.xml"
  outfile = File.new(outfilename, "w")
  outfile.write(tagged)
  outfile.close
end

def transformfolder(folder,do_doi,do_viaf)
  # create the folder that will contain the new xmls if it does not yet exist
  FileUtils.mkdir("tagged_xmls") unless Dir.exists?("tagged_xmls")

  # list all the xml files in the folder
  xmls = Dir.glob('*.xml')

  csvname = folder.to_s + "_biblcounts.csv"

  countfile = CSV.open(csvname, 'w')
  countfile << ["file", "total bibls", "m-level", "j-level", "a-level", "s-level", "u-level", "misparsed", "mononym", "polynym"]

  # for each xml file in the folder, perform the transformation and save the result
  xmls.each do |xml|
    tagged = tag(xml,do_doi, do_viaf)

    # count the number of m and j level bibls
    totalbibls, totalm, totalj, totala, totals, totalu, totalmis, totalmono, totalpoly = bibl_counter(tagged)
    countfile << [xml.to_s, totalbibls, totalm, totalj, totala, totals, totalu, totalmis, totalmono, totalpoly]

    # make new file to write the tagged xml into
    outfile = File.new(File.join(Dir.pwd, "tagged_xmls", xml), "w")
    outfile.write(tagged)
    outfile.close
  end
  # close the csv file
  countfile.close
end

def transformall

  rootpath = Dir.pwd
  CSV.foreach(ARGV[0], headers: true) do |row|
    folder = row[0]
    do_doi = row[1]
    do_viaf = row[2]

    Dir.chdir folder

    Anystyle.parser.train "training.txt", true

    start = Time.now
    deidemizefolder(folder)
    transformfolder(folder, do_doi,do_viaf)


    finish = Time.now

    diff = finish - start

    puts "It took " + diff.to_s + " seconds to transform " + folder.to_s


    Dir.chdir rootpath
  end

  # count the bibls
  countfile = CSV.open("total_biblcounts.csv", 'w')
  countfile << ["file", "total bibls", "m-level", "j-level", "a-level", "s-level", "u-level", "misparsed", "mononym", "polynym"]

  totalbibls = 0
  totalm = 0
  totalj = 0
  totala = 0
  totals = 0
  totalu = 0
  totalmis = 0
  totalmono = 0
  totalpoly = 0
  CSV.foreach(ARGV[0], headers: true) do |row|
    folder = row[0]
    Dir.chdir folder
    csvname = folder.to_s + "_biblcounts.csv"

    CSV.foreach(csvname, headers: true, converters: :numeric) do |row|
      totalbibls += row[1]
      totalm += row[2]
      totalj += row[3]
      totala += row[4]
      totals += row[5]
      totalu += row[6]
      totalmis += row[7]
      totalmono += row[8]
      totalpoly += row[9]
    end

    countfile << [folder, totalbibls, totalm, totalj, totala, totals, totalu, totalmis, totalmono, totalpoly]
    Dir.chdir rootpath
  end
  countfile.close
end

transformall



