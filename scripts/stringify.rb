#!/usr/bin/ruby

require_relative 'worldcat_api_interaction'

def stringify_author(tagdict_author, bibl)
  if tagdict_author.contains? " / "
    authors = tagdict_author.split(' / ')
  elsif tagdict_author.include? ' and ' # case: multiple authors
    authors = tagdict_author.split(' and ')
  else # case: one author
    authors = [tagdict_author]
  end

  authors.each {|potential_author|

    puts "PAUTHOR: " + potential_author.to_s

    potential_author.strip!
    if includes_nums_punct?(potential_author)
      bibl.add_child "<author><name type=\"misparsed\">" + potential_author + "</name></author>"
      next # return
    end

    if single_word?(potential_author) # case: author name is a single word (ie. Homerus)
      viaflink = find_single_author(potential_author)
      unless viaflink.to_s.empty?
        bibl.add_child "<author ref=\"" + viaflink + "\"><name type=\"mononym\">" + potential_author + "</name></author>"
        next # return
      end
      bibl.add_child "<author><name type=\"misparsed\">" + potential_author + "</name></author>"
      next # return

    elsif potential_author.include? ',' # case: first and last name
      author = potential_author.split(', ')
      surname = author[0]
      forename = author[1]

      if letter_and_name_forename?(forename)
        bibl.add_child "<author><name type =\"polynym\"><surname>"+surname+"</surname><forename>"+forename+"</forename></name></author>"
        next # return
      else
        viaflink = find_author(forename, surname)
        unless viaflink.to_s.empty?
          bibl.add_child "<author ref=\"" + viaflink + "\"><name type=\"polynym\"><surname>"+surname+"</surname><forename>"+forename+"</forename></name></author>"
          next # return
        end
        bibl.add_child "<author><name type=\"misparsed\">" + potential_author + "</name></author>"
        next # return
      end
    else
      bibl.add_child "<author><name type=\"misparsed\">" + potential_author + "</name></author>"
    end
  }
end

def stringify_editor(tagdict_editor, bibl)
  if tagdict_editor.contains? " / "
    editors = tagdict_editor.split(' / ')
  elsif tagdict_editor.include? ' and ' # case: multiple editors
    editors = tagdict_editor.split(' and ')
  else
    editors = [tagdict_editor]
  end

  editors.each {|potential_editor|

    potential_editor.strip!
    if includes_nums_punct?(potential_editor)
      bibl.add_child "<editor><name type=\"misparsed\">" + potential_editor + "</name></editor>"
      next # return
    end

    if single_word?(potential_editor) # case: author name is a single word (ie. Homerus)
      bibl.add_child "<author ref=\"" + viaflink + "\"><name type=\"mononym\">" + potential_editor + "</name></author>"
      next # return

    elsif potential_editor.include? ',' # case: first and last name
      author = potential_editor.split(', ')
      surname = author[0]
      forename = author[1]

      bibl.add_child "<editor><name type =\"polynym\"><surname>"+surname+"</surname><forename>"+forename+"</forename></name></editor>"

    else
      bibl.add_child "<editor><name type=\"misparsed\">" + potential_editor + "</name></editor>"
    end
  }
end


def single_word?(string)
  !string.strip.include? " "
end

def letter_forename?(forename)
  /^([-]?[A-Z]\. ?)+$/ =~ forename
end

def letter_and_name_forename?(forename)
  /([-]?[A-Z]\.)+/ =~ forename
end

def includes_nums_punct?(name)
  /[\W*\d*&&[^-'., ]]/ =~ name.strip
end