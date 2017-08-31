# Brill Anystyle
The Brill Anystyle scripts take all the xmls in (a) specified folder(s) and find the bibliographic references contained therein. These references are split into for example authors and titles, which are then tagged with the right xml tags. The transformed xmls are placed in a separate folder so that the source material is preserved.

**NOTE**: As of yet, Brill Anystyle works on Linux systems only!

# Installation
## Installing the Anystyle Parser
1. First type:

   ```shell
   sudo apt-get install build-essential zlib1g-dev libssl-dev
   ```
   
   This step may not be necessary on all machines.

2. Then type:

   ```shell
   sudo gem install anystyle-parser
   ```
   
   to install the Anystyle Parser

## Installing Nokogiri
Nokogiri allows your scripts to traverse xml-documents.
1. Type:
   ```shell
   sudo gem install nokogiri
   ```
   
## Installing Serrano
Serrano is necessary for connecting to the Crossref database and retrieve the DOIs of the different references.
1. Type:
   
   ```shell
   sudo gem install serrano
   ```

# Using Brill Anystyle
1. Create a .csv file containing the absolute paths to the folders containing the xmls you wish to transform. 
   **Note**: an absolute path on Linux looks different than on Windows! Your path should look something like this:
   
   ```shell
   /home/username/publications/publication_name
   ```

   You can name this file however you like.

2. In each folder containing xmls you wish to transform, create a file called "training.txt". A different name will **not** work. In training.txt you add 
   
   i) a line starting with “#” containing the description of the training file (ie. “# basic training plus publication name)
   
   ii) a number of correctly tagged bibliographic references. The allowed tags are:

      "author", "booktitle", "container", "date", "doi", "edition", "editor", "institution", "isbn", "journal", "location", "note", "pages", "publisher", "retrieved", "tech", "title", "translator", "unknown", "url", "volume"

      A tagged reference should look something like:

      ```xml
      <author>Shakespeare, William.</author><title>Othello.</title><publisher>Milwaukee Repertory Theater,</publisher> <location>Milwaukee,</location> <date>April 2012.</date>
      ```

       It is advisable to have at least 50-100 references in total.

3. To run the script, type:
   
   ```shell
   ruby path/to/pipeline.rb path/to/<list_of_folders>.csv
   ```

    Replace <list_of_folders> with the name of the file you created in step 1.

License
Copyright 2016-2017 Maaike Visser. All rights reserved.

[Anystyle-Parser](https://github.com/inukshuk/anystyle-parser), used in this project, was created by Sylvester Keil, copyright 2011-2014 Sylvester Keil.

Brill Anystyle is distributed under a MIT style license. For more information, see LICENSE.
