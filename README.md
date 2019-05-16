# object-helper
Helps browsing imported classes for projects in arduino ide and helps getting over the missing code-completion.

    Copyright (C) 2019 Ralph Rathmann

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.
    
    
This Clarion Program scans given paths with header-files of your Arduino IDE (c) (Copyright by Arduino) Installation and imports them in a browse list.
Here you can find the declarations of your imported classes and use them to paste into your code (into your .ino) or c-file.

Everything you need for use is to copy the ObjectHelper.exe and its Manifest and the media subfolder from Release to a new directory on your harddisk (Windows only).
The program creates some .tps files for its own database in this directory and a .ini file for storing informations of window positions.

Step 1 after Opening the Program: (for later convenience)

   - In the Main Menu click "File" and then "Settings"
   - doubleclick the second record named "Browser for web searches"
   - Paste or write in the content field the path to your preferred Browser. e.g: 
        C:\Program Files (x86)\Google\Chrome\Application\chrome.exe
        and click OK.
   - doubleclick the third record named "Search engine url"
   - Paste or write in the content field the string, your search engine will be called as parameter to the browser.
       e.g: https://google.de/search?q=arduino
        and click OK.
        
   Close Settings, youre done so far.
     
Step 2:

   - In "Projects" insert a new Project, give it a name and a brief description.
   - In your systems file explorer find the .ino file of your project an drop it or type it in the startfile field.
      e.g.: C:\Projekte\ESP32\CountdownFrame\TEST\TEST.ino
   - Add the lookup-paths of your IDE environment to the list. (these paths will be scanned for all the .h files, that are 
   included in your project.
   
   Press OK.
   
 Step 3:
 
  - In the Project List click "browse project files"
    Its empty and you decide, wether you insert thousands of files manually or click the green button "autofill" to let the program do the job ;-)
     (It may take a while to scan all the subdirs but with a ssd its done in < 60 sec.)
   If its done, you can search for files with the yellow search field top right and open them in your systems editor, but the main goal of this list is to support the wizard, you read about in Step 4, so close the files browser.
   
Step 4:

  - Open "Projects" and doubleclick on your project in this list.
  - Move the window to an appropriate position and size, so you can work with two open windows in seperate programs.
  - Press the green "Wizard" Button.
  - Open your Project in the Arduino IDE.


Usage:

  With the Wizard Window you can search for classes (type in the green field and press tab) and get all of their declaration informations.

On a highlighted entry in the List:

You can open the header File of this class in your external editor
Search on the web for the class details (according to step 1)

With the button "on doubleclick..." you tell the wizard, what happens on doubleclick:
  - copy to clipboard   (so you can paste it in the ide)
  - open file           (opens the header file like the button)
  - keyboard injection  (since drag an drop of simple text wont work on Targets like the Editor or the IDE, i push the string to the keyboard-buffer on losing focus. You drag the entry out of the window, release the mouse button and left click in your editor. Some parts of the Line are stripped ("virtual", "void" and everything after ");" )
  Try it with short strings...unfortunately its not that quick.
  
  
  
   
    
 
 
 
        

