Team #1
===============
##Prerequisites
Ruby 1.8.7  
##Installation
###Gems

    run 'bundle install'

Note: To install nokogiri on linux you need some native c-files. See
http://nokogiri.org/tutorials/installing_nokogiri.html for more
information.

On Linux Nokogiri seems only to work if you install
    sudo apt-get install ruby-nokogiri

Same thing for rspec and json
    sudo apt-get install ruby-json
    sudo apt-get install ruby-rspec

###Mail
**important:** mails must be sent from a gmail account!    
create an file named 'email.conf' in the directory trade/app/private    
enter the following informations  
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
login the system using  
ese@mail.ch  
PW: ese 

##Tests
If you want to use rspec in RubyMine you have to install the ruby rspec
    sudo apt-get install rspec

To use selenium tests you need to install firefox. Downlaod it from
http://www.mozilla.org/de/firefox/fx/ and the selenium plugin
http://seleniumhq.org/projects/ide/

To start the selenium test open firefox then click Tools => Selenium
IDE on the menu bar. A new window should open. Click File =>
Open Test Suite... then search for "Tests for Trading System" in
trade/test/Selenium and open it. Start the app (see under
Start the app) and the left green arrow on the top of the
Selenium Window. This tests can only be run one time and
will fail the second time (simply because it's not possible
to buy the same item twice). If you want to run the test
a second time you have to restart the app.

###Running coverage
To see only tests with coverage below 50% you can use:
    rake models_missing
To see whole coverage of the models test you can use
    rake models_rcov

###Documentation
The documentation for the model used for this project
you can find under www.jokr.ch/doc/index.html.

enjoy!