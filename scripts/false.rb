#!/usr/bin/ruby

require 'anystyle/parser'
Anystyle.parser.train 'training_copy', false
Anystyle.parser.model.path="./default.mod"
Anystyle.parser.model.save



