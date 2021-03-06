#!/bin/bash
# Jenkins script:
# Global settings in Jenkins add DISPLAY variable (Manage Jenkins -> Configuration System->Global Properties)
# How to change jenkins password "sudo passwd jenkins"
# Jenkins plugin: xUnit, HTML Publisher, Clover PHP
# Build steps: export DISPLAY=:99
# Build step: phpunit --log-junit /var/lib/jenkins/jobs/test/workspace/junit.xml --coverage-clover /var/lib/jenkins/jobs/test/workspace/coverage.xml /home/selenium/facebook/php-webdriver/example.php
# Path to Junit file starting from "/var/lib/jenkins/jobs/test/workspace/".
# Commands after re-start: service selenium start, sudo service xvfb start, export DISPLAY=:99, x11vnc -display :99
echo "Would you like to install Jenkins(yes/no)?"
read JENKINS
echo "Would you like to install kate IDE(yes/no)?"
read KATE
echo "Would you like to install SELENIUM server(yes/no)?"
read SELENIUM
echo "Would you like to install facebook webdriver (yes/no)?"
read FACEBOOK_DRIVER
echo "Would you like to install php webdriver (yes/no)?"
read PHP_DRIVER
echo "Would you like to install PHP with PHPUnit (yes/no)?"
read PHPUnit
echo "Would you like to install Python/WEBDRIVER (yes/no)?"
read PYTHON
echo "Enter virtualenv name:"
read VIRTUALENV_NAME

# Add selenium user
out=$(cat /etc/passwd|grep selenium)
echo $out
if [ -z $out ]; then
  sudo useradd -m selenium
  sudo passwd selenium
  sudo adduser selenium sudo
  sudo usermod -s /bin/bash selenium
  su selenium
fi

# Install curl
out=$(which curl)
echo $out
if [ -z $out ]; then
  sudo apt-get install curl
fi

# Install GIT
out=$(which git)
echo $out
if [ -z $out ]; then
  sudo apt-get install git-core -y
  git config --global user.name "rbyelyy"
  git config --global user.email rbyelyy@gmail.com
fi
# Installing Jenkins
if [ $JENKINS = "yes" ]; then
  wget -q -O - http://pkg.jenkins-ci.org/debian/jenkins-ci.org.key | sudo apt-key add -
  sudo sh -c 'echo deb http://pkg.jenkins-ci.org/debian binary/ > /etc/apt/sources.list.d/jenkins.list'
  sudo apt-get update -y
  sudo apt-get install jenkins -y

  # Update Jenkins
  sudo apt-get update -y
  sudo apt-get install jenkins -y

  # Verify that jenkins installed and launched
  out=$(curl http://localhost:8080/)
  if [ "$out" = *"<title>Dashboard [Jenkins]</title>"* ]; then
    echo "Jenkins installed & run!"
  else
    echo "Jenkins is not installed:-( - TBD add verification and fixing steps in sh script"
  fi
fi

# Installing Kate IDE
if [ $KATE = "yes" ]; then
  out=$(which kate)
  if [ -z $out ]; then
    sudo apt-get install kate -y
    echo "KATE installed"
  else
    echo "KATE already installed!"
  fi
fi

# Installing selenium server
if [ $SELENIUM = "yes" ]; then
  sudo mkdir /usr/local/lib/selenium
  cd /usr/local/lib/selenium
  sudo wget http://selenium-release.storage.googleapis.com/2.42/selenium-server-standalone-2.42.2.jar
  sudo mkdir -p /var/log/selenium/
  sudo chmod a+w /var/log/selenium/
  curl https://raw.github.com/rbyelyy/myrepo/master/selenium_script > /home/selenium/selenium
  sudo cp /home/selenium/selenium /etc/init.d
  sudo chmod +x /etc/init.d/selenium
  export DISPLAY=:99 # TBD - Have to be changed to variable
  service selenium start
fi

# Install XVFB
out=$(dpkg --get-selections|grep xvfb)
echo $out
if [ -z "$out" ]; then
 # Install XVFB DISPLAY :99
 sudo apt-get install xvfb
 curl https://raw.github.com/rbyelyy/myrepo/master/xvfb_script > /home/selenium/xvfb
 sudo cp /home/selenium/xvfb /etc/init.d
 sudo chmod +x /etc/init.d/xvfb
 sudo /etc/init.d/xvfb start
fi

# Install x11 and vmcserver
out=$(dpkg --get-selections|grep x11vnc)
echo $out
if [ -z "$out" ]; then
 # Install x11vnc server
 sudo apt-get install x11vnc -y
 x11vnc -bg -display :99
 sudo apt-get install vncviewer -y
 sudo apt-get install libgl1-mesa-dri -y
 sudo apt-get install xfonts-100dpi xfonts-75dpi xfonts-scalable xfonts-cyrillic -y
fi

if [ $PHPUnit = "yes" ]; then
  # Install PHP
  sudo apt-get install php5-curl -y
  pear channel-discover pear.phpunit.de
  pear install phpunit/PHPUnit
  pear install phpunit/phpunit_selenium

  # Install PHP PHPCural and PEAR
  sudo apt-get install php5 -y
  sudo apt-get install php5-curl -y
  sudo apt-get install php-pear -y

  # Install PHPUnit+Selenium
  sudo pear channel-discover pear.phpunit.de
  sudo pear channel-discover pear.symfony-project.com
  sudo pear channel-discover components.ez.no
  sudo pear update-channels
  sudo pear upgrade-all
  sudo pear install --alldeps phpunit/PHPUnit
  sudo pear install --force --alldeps phpunit/PHPUnit
  sudo pear install phpunit/PHPUnit_Selenium
fi

if [ $PHP_DRIVER = "yes" ]; then
  # PHP webdriver bidding (Install official bidding. Very poor)
  export DISPLAY=:99
  cd ~
  mkdir php_webdriver
  cd php_webdriver
  wget http://php-webdriver-bindings.googlecode.com/files/php-webdriver-bindings-0.9.0.zip
  unzip php-webdriver-bindings-0.9.0.zip
  cd php-webdriver-bindings-0.9.0
fi
if [ $FACEBOOK_DRIVER = "yes" ]; then
  # Install Facebook PHP bidding (Install Facebook bidding)
  export DISPLAY=:99
  cd ~
  mkdir facebook
  cd facebook
  git clone https://github.com/facebook/php-webdriver.git
  cd php-webdriver/

  # Create base PHP script
  cd /home/selenium/facebook/php-webdriver
  curl https://raw.github.com/rbyelyy/myrepo/master/php_facebook_test > /home/selenium/facebook/php-webdriver/example.php
  phpunit example.php
fi

if [ $PYTHON = "yes" ]; then
 # Install python 2.7
 out=$(dpkg --get-selections|grep python2.7-dev)
 echo $out
 if [ -z "$out" ]; then
  sudo apt-get install python2.7 python2.7-dev
 fi
 
 # Install PIP and virtualenv
 out=$(which easy_install)
 if [ -z "$out" ]; then
 # Install easy_install tool
 curl -O http://python-distribute.org/distribute_setup.py
 sudo python2.7 distribute_setup.py
 fi
 out=$(which pip)
 if [ -z "$out" ]; then
 # Install pip tool
 sudo easy_install-2.7 pip
 fi
 
 # Create virtual env
 cd ~
 if [ ! -d "my_env" ]; then
   mkdir my_env
 fi
 cd my_env
 out=$(which virtualenv)
 if [ -z "$out" ]; then
 # Install virtualenv tool
 sudo apt-get install python-virtualenv -y
 fi
 if [ ! -d ~/my_env/ddd ]; then
   virtualenv $VIRTUALENV_NAME
 fi
 source ~/my_env/$VIRTUALENV_NAME/bin/activate
 out=$(pip freeze|grep selenium)
 if [ -z "$out" ]; then
   pip install selenium
 fi
 # Create base Python script
 curl https://raw.github.com/rbyelyy/myrepo/master/python_google_test > /home/selenium/my_env/example.py
 python /home/selenium/my_env/example.py
fi
