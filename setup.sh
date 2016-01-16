#!/bin/sh

sudo cp etc/apt/apt.conf.d/20auto-upgrades /etc/apt/apt.conf.d/20auto-upgrades
sudo cp etc/apt/apt.conf.d/50unattended-upgrades /etc/apt/apt.conf.d/50unattended-upgrades

sudo apt-get install -y unattended-upgrades
sudo service unattended-upgrades restart

sudo apt-get install -y build-essential ruby2.0 ruby2.0-dev

sudo gem install bundler

bundle install --deployment

crontab <<END
0,30 * * * * sh /home/ubuntu/every_word_the_musical/run.sh
END
