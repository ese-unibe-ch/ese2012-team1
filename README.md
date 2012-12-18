Team #1
===============
##Prerequisites
    Ruby 1.8.7

#Installation

##Using Installation Script
###Unix Based Systems (Tested on Ubuntu and Debian)
Get the latest release of ESE TredyngSystem by #1:

    wget https://tux1.pillo-srv.ch/jokr.tar.bz2

Extract files:

    tar xfvj jokr.tar.bz2

Move into directory JOKR:

    cd JOKR/

Start the installer (needs root privileges)

  Ubuntu:
  
    sudo ./installer.sh
    
  Debian:
  
    su root
    ./installer.sh
    
Start the Trading System with the Startup Script:

    ./start.sh

  Alternative start app.rb direct:

    cd ./trade/
    ruby app/app.rb


###Windows (Tested on Windows XP, 7 and 8)
Get the latest release of ESE TredyngSystem by #1:

[https://tux1.pillo-srv.ch/jokr.tar.bz2](https://tux1.pillo-srv.ch/jokr.tar.bz2)

Extract the archive:

    Use your favourite Archive tool.

Open the directory JOKR.

Start the Batch Script:

    installer.bat

Start the Trading System with the Startup Script:

    start.bat

  Alternative start app.rb in command line:

    cd .\trade\
    ruby app\app.rb


##Manual Installation
###Gems

    run 'bundle install'

Note: To install nokogiri on linux you need some native c-files.

See [http://nokogiri.org/tutorials/installing_nokogiri.html](http://nokogiri.org/tutorials/installing_nokogiri.html) for more information.


On Linux Nokogiri seems only to work if you install

    sudo apt-get install ruby-nokogiri


Same thing for rspec and json

    sudo apt-get install ruby-json
    sudo apt-get install ruby-rspec


###Mail
Mails can be sent through every SMTP account.

Create a file named 'email.conf' in the directory trade/app/private

Enter the following information:

    from_address = 'yourEmail@yourHost.tld'
    smtp_server = 'mailServer.yourHost.tld'
    username = 'yourUserName'
    password = 'yourPassword'

  
##Start the app

change to trade directory

    cd trade
  
run the app

    ruby app/app.rb


##Login
Login to the system using

E-Mail: ese@mail.ch

Password: ese

##Tests
If you want to use rspec in RubyMine you have to install the ruby rspec (Only if you're not using the Install Script)

    sudo apt-get install rspec


###Running coverage
To see only tests with coverage below 50% you can use:

    rake models_missing

To see whole coverage of the models test you can use

    rake models_rcov


enjoy!
