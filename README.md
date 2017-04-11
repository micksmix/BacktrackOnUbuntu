# BacktrackOnUbuntu
Script and blog post on how to install BackTrack 4 tools on Ubuntu with the correct menu structure, using BT repo's

I originally wrote this script in 2009 to allow me to install the BackTrack 4 tools in Ubuntu 9.10, and I blogged the [setup instructions here](https://micksmix.wordpress.com/2009/11/20/getting-the-backtrack-menu-structure-and-tools-in-ubuntu/).


So, here's a brief overview of the steps in this lengthy blog post:

1. Prepare the GNOME menu with the appropriate BackTrack menu structure
2. Install BackTrack 4 tools within Ubuntu
3. Run a Perl script to update the newly created menu entries so that they will launch a terminal correctly within Ubuntu



![Finished product](https://micksmix.files.wordpress.com/2009/11/snapshot2.png "Finished product")

NOTE: This involves modifying your current GNOME menu settings, and could cause issues with your menu if done incorrectly. Make a backup first, and note that this worked on my system, but your mileage may vary!

**The first step **before installing any of the tools is to prepare the GNOME menu. Open up a shell:
    
    
    
    sudo cp /etc/xdg/menus/applications.menu /etc/xdg/menus/applications.menu.original
    sudo geany /etc/xdg/menus/applications.menu
    

Note that I am using the application [Geany][7], which is a programmer's editor for Linux, much like Notepad++ for Windows. You can use **gedit** if you'd prefer, but Geany may help you in modifying this XML file because it offers code folding and syntax highlighting.

If you opened it with Geany, click on the _Document_ menu, Select _Set Filetype_, select _Markup Languages_, and then finally select _XML Document_.

![Select file type within Geany][8]

With Geany, I find it easiest to collapse the menu blocks for the other sub-menus within Gnome's _Applications_ menu.

After collapsing the _System Tools_ section, paste the XML from the `BtMenuStructure.xml` file directly after it. This will define the BackTrack menu's and submenu's:

![Adding BackTrack menu structure with Geany][9]

After updating this with the BackTrack XML, you may now save and close the document.

At this point, we can follow the instructions in my previous post to install the BackTrack utilities.

Let's begin by launching a root bash shell by typing:
    
    
`sudo bash`
    

The next step is to add the BackTrack repositories to your apt-get sources.list file:

**1\. Add the Backtrack repository:**
    
`sudo echo deb http://repo.offensive-security.com/dist/bt4 binary/ >> /etc/apt/sources.list`
    

**2\. Import the Backtrack PGP key and update your sources** (and set a proxy server to use if you need it):
```export http_proxy="http://myproxyserver.com:8080"
wget http://repo.offensive-security.com/dist/bt4/binary/public-key && sudo apt-key add public-key && sudo aptitude update
```    

**3\. Build your package list **(NOTE that I am specifying a proxy server — remove this part from the command if you do not use a proxy):
    
`links -http-proxy myproxyserver.com:8080 -dump http://repo.offensive-security.com/dist/bt4/binary/ | awk '{print $3}' | grep -i deb | cut -d . -f 1 > backtrack.txt`
    

**If you do not use a proxy server, then the command will look like this:**
    
`links -dump http://repo.offensive-security.com/dist/bt4/binary/ | awk '{print $3}' | grep -i deb | cut -d . -f 1 > backtrack.txt`
    

**4\. Install packages:**
    
`for i in $(cat backtrack.txt); do sudo aptitude -y install $i; done`
    

Credit for the BackTrack menu settings goes to[ or4n9e at Remote Exploit's forums][11].

Next, we need to run a Perl script to ensure that the newly installed applications can be correctly executed from our GNOME _Applications _menu.


I saved that file to my home folder at _/home/mick_

Next we need to run the script, but first we will backup all menu files in case something goes wrong. Open up a terminal:
    
```
cd ~/
mkdir menu_backup
sudo cp /usr/local/share/applications/* ~/menu_backup
```
    

Now we have made a backup of the menus, so it is safe to run our Perl script now:
    
`sudo perl ./UpdateBTMenu.pl`
    

**That's it! Your BackTrack tools (with menu structure) are ready to use within Ubuntu!**

If for some reason there was a problem with executing the Perl script or your menu isn't working, you can copy the backed up menu items to their original location:
    
`sudo cp ~/menu_backup/* /usr/local/share/applications/`
    
[6]: https://micksmix.files.wordpress.com/2009/11/snapshot2.png?w=595 "BackTrack 4 Menu in Ubuntu!"
[7]: http://www.geany.org/
[8]: https://micksmix.files.wordpress.com/2009/11/geany2.png?w=595 "Select file type within Geany"
[9]: https://micksmix.files.wordpress.com/2009/11/geany3.png?w=595 "Adding BackTrack menu structure with Geany"
[10]: https://micksmix.wordpress.com/2009/11/14/backtrack-xml-menu/
[11]: http://forums.remote-exploit.org/bt4beta-howtos/23327-bt4beta-gnome-edition.html
