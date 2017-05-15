require 'csv'

def test(x)
  puts "hi"
  CSV.foreach("./xmls_biblcounts.csv") do |row|
    puts row.to_s
  end
end
