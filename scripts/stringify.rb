#!/usr/bin/ruby

require_relative 'worldcat_api_interaction'

def stringify_author(tagdict_author, bibl)
  if tagdict_author.include? 'and' # case: multiple authors
    authors = tagdict_author.split(' and ')
  else # case: one author
    authors = [tagdict_author]
  end

  authors.each {|potential_author|
    if includes_nums_punct?(potential_author)
      puts "numpunct: " + potential_author
      bibl.add_child "<author><name type=\"misparsed\">" + potential_author + "</name></author>"
      return
    end

    if single_word?(potential_author) # case: author name is a single word (ie. Homerus)
      puts "single word author: " + potential_author
      viaf = find_single_author(potential_author)
      if viaf
        bibl.add_child "<author><name type=\"mononym\">" + potential_author + "</name></author>"
        return
      end
      bibl.add_child "<author><name type=\"misparsed\">" + potential_author + "</name></author>"
      return

    elsif potential_author.include? ',' # case: first and last name
      puts "GETS HERE"
      author = potential_author.split(', ')
      surname = author[0]
      forename = author[1]

      if letter_forename?(forename)
        puts "letter forename: " + forename
        bibl.add_child "<author><name type =\"polynym\"><surname>"+surname+"</surname><forename>"+forename+"</forename></name></author>"
        return
      else
        puts "word forename: " + forename
        viaf = find_author(forename, surname)
        if viaf
          bibl.add_child "<author><name type=\"polynym\"><surname>"+surname+"</surname><forename>"+forename+"</forename></name></author>"
          return
        end
        bibl.add_child "<author><name type=\"misparsed\">" + potential_author + "</name></author>"
        return
      end
    else
      bibl.add_child "<author><name type=\"misparsed\">" + potential_author + "</name></author>"
    end
  }
end

def single_word?(string)
  !string.strip.include? " "
end

def letter_forename?(forename)
  /^([A-Z]\. ?)+$/ =~ forename
end

def includes_nums_punct?(name)
  /[\W*\d*&&[^-'., ]]/ =~ name.strip
end