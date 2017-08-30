# Brill Anystyle

# Prerequisites
Before you can use the Brill Anystyle scripts, there are a number of prerequisites that have to be fulfilled:
* You must have a basic knowledge of the **Linux Terminal**. If you do not, I recommend having a look at [this](http://linuxcommand.org/) tutorial.
* You must be using a **Linux Machine**. If you are working on a computer with a different operating system, you must [create a virtual machine](#creating-a-virtual-machine-vm).
* Ruby 2.3 or higher must be [installed](#installing-ruby) on your computer. 
* Although not necessary for this project, it is convenient to have a basic knowledge of GIT. If you do not, I recommend having a look at this website, as well as the Brill Freelancer’s Introduction to Git.

**NOTE**: In this guide, whenever the instruction “type xyz” is given, you should type this in the terminal.

# Creating a Virtual Machine (VM)
## Creating the Client Machine
Install VirtualBox or another VM manager of your choice. (This guide will assume you have downloaded VirtualBox.) Select the version appropriate for your operating system.
NOTE: From here on, your regular system will be known as the host (system). The Virtual Machine will be known as the guest (system) or the VM.
Create a new VM by clicking the “New” button.

A window appears prompting you to name the VM and choose an operating system. You can name your VM whatever you like. You must select Linux as the Type of your VM, and Other Linux (64-bit) as the Version. When you’re done, click “Next”.

You can now allocate a certain amount of RAM to your VM. This is somewhat analogous to the amount of thinking power. Set the memory size to 1024MB and click next.

In the next screen, you can create a virtual hard disk. This is a certain amount of memory that is reserved on the hard disk of the host system for use by the client system. Select “Create a virtual hard disk now” and click “Create”.

You are prompted to select a hard disk file type. Select “VDI (VirtualBox Disk Image)” and click “Next”.

Now, you can choose whether the space necessary for your virtual hard disk should be reserved at once, or allocated whenever necessary. Select “Fixed size” and click “Next”.

Give your new virtual hard disk a name and location, as well as a maximum size. If you are planning on making more VMs, it is a good idea to create a separate folder for the hard disks, for example in your Documents folder or on your C-Drive. Set the size of the hard disk to 8,00GB. Click “Create”.
Done!

## Installing an Operating System
Download an installation CD. You need this to install an operating system (OS) on your VM. I recommend installing Lubuntu, as it is a lightweight OS, so most laptops can handle it. Since our VM is a 64-bit system, choose the 64-bit version.
Note: the creators of Lubuntu recommend downloading the CD through a torrent. If you go with this option, you will need a torrent client such as qBittorrent.
If you haven’t already, start VirtualBox. Then, start your VM by double clicking its name in the list of VMs. You will be prompted to select a start-up disk. Click the folder icon and navigate to the folder where you saved the installation and select it. Click Start.
Choose a language and then select Install Lubuntu.


Make your way through the installation procedure. There are a number of prompts that warrant extra attention:


When prompted about third-party software, leave the box unchecked.

Select Erase disk and install Lubuntu. This action will not erase your host system; it wipes the memory you have allocated to your VM only. (In other words: it is perfectly safe.)

Select continue.

Fill in your user details. Since the VM lives inside of your computer, it is not necessary to have a complicated password or require a password to log in.

Restart your VM.

Once your VM has restarted, press Enter. You do not have to remove the installation medium yourself; VirtualBox does this for you.


## Connecting the VM to the Host System
When working on the VM, it is not automatically possible to access files on the host system. This is because for all intents and purposes, the VM and the host machine are two different computers. Therefore, in order to access files on the host system from the VM, you need to create a connection between the two. The following steps are taken from this guide.
### Installing Guest Additions
Add a terminal to your desktop by going to Start → System Tools, right-clicking the LXTerminal icon and selecting Add to desktop. Open the terminal.

From Virtual Box’ menu (so the window containing your VM), go to Devices → Insert Guest Additions CD image… When prompted, you can open the file in the file explorer, but this is not necessary.
 
Go to your terminal and type:

        cd /media/<user-name>/VBOXADDITIONS

Then press tab to autocomplete your command; the text in your terminal should look something like:

cd /media/<user-name>/VBOXADDITIONS_5.1.26_1177224

Press Enter.

Type:

    sudo ./VBoxLinuxAdditions.run
    
    Give your password when prompted.
When the program has completed running, reboot your VM.
### Marking shared folders
With the Guest Additions installed, you can mark folders on your host system you want to share with the VM.
From VirtualBox’ menu go to Devices → Shared Folders → Shared Folders Settings… In the dialog that appears, click the icon of a folder with a small plus to add a folder.

In the next dialog screen, select the folder you want to mount and give it a name. You will need this name later so make sure it is something you can remember. Tick the boxes Auto-mount and Make Permanent.

Reboot your VM.
### Mounting shared folders
By mounting the shared folders, you allow the VM to actually access them. It is convenient to create a script that does this for you.
Open a terminal and type:

        sudo mkdir <folder-name>

This will create a new directory in your home directory. If you want to place the mount point elsewhere, change <folder-name> to the corresponding path.
Go to Start → Accessoires → LeafPad. In the editor that opens, type:

sudo mount -t vboxsf <host-folder> <folder-name>

Here <host-folder> is the folder you marked as shared earlier, and <folder-name> is the path or folder you used in the previous step. Save the file in your home folder under a convenient name; this folder has your username as name.
In the terminal, type

    sudo chmod +x ./<save-name>

To make the file executable. Here <save-name> is the name of the file you saved in the previous step. 
Type:

        ./<save-name>

    This creates the actual connection between your VM and the host system. 
Note: Next time you start your VM, this is the only step you have to perform. Make sure you are in your home directory when you execute this command.
Type:

        cd <folder-name>

to access your files.
# Setting up Brill Anystyle
There are a number of software libraries that need to be installed before you can use Brill Anystyle.
## Installing Ruby
Install Ruby by typing:

sudo apt-get install ruby; sudo apt-get install ruby-dev
## Installing the Anystyle Parser
First type:

sudo apt-get install build-essential zlib1g-dev libssl-dev

Then type:

sudo gem install anystyle-parser

to install the Anystyle Parser

## Installing Nokogiri
Nokogiri allows your scripts to traverse xml-documents.
Type:

sudo gem install nokogiri
## Installing Serrano
Serrano is necessary for connecting to the Crossref database and retrieve the DOIs of the different references.
Type:


sudo gem install serrano

# Using Brill Anystyle
The Brill Anystyle scripts take all the xmls in (a) specified folder(s) and find the bibliographic references contained therein. These references are split into for example authors and titles, which are then tagged with the right xml tags. The transformed xmls are placed in a separate folder so that the source material is preserved.

Create a .csv file containing the absolute paths to the folders containing the xmls you wish to transform. Note: an absolute path on Linux looks different than on Windows! Your path should look something like this:

        /home/username/publications/publication_name

You can name this file however you like, for example xmlfolders.csv.

In each folder containing xmls you wish to transform, create a file called training.txt. A different name will not work. In training.txt you add i) a line starting with “#” containing the description of the training file (ie. “# basic training plus publication name), ii) a number of correctly tagged bibliographic references. The allowed tags are:

"author", "booktitle", "container", "date", "doi", "edition", "editor", "institution", "isbn", "journal", "location", "note", "pages", "publisher", "retrieved", "tech", "title", "translator", "unknown", "url", "volume"

A tagged reference should look something like:

<author>Shakespeare, William.</author><title>Othello.</title><publisher>Milwaukee Repertory Theater,</publisher> <location>Milwaukee,</location> <date>April 2012.</date>

    It is advisable to have at least 50-100 references in total.

To run the script, type:

        ruby path/to/pipeline.rb path/to/<list_of_folders>.csv

    Replace <list_of_folders> with the name of the file you created in step 1.

