echo "Running dev Startup"

bash /usr/local/bin/tsugi-mysql-startup.sh return

COMPLETE=/usr/local/bin/tsugi-dev-complete
if [ -f "$COMPLETE" ]; then
    echo "Dev startup already has run"
else

# sanity check in case Docker went wrong with freshly mounted html folder
if [ -d "/var/www/html" ] ; then
    echo "Normal case: /var/www/html is a directory";
else
    if [ -f "/var/www/html" ]; then
        echo "OOPS /var/www/html is a file";
        rm -f /var/www/html
        mkdir /var/www/html
        echo "<h1>Test Page</h1>" > /var/www/html/index.html
    else
        echo "OOPS /var/www/html is not there";
        rm -f /var/www/html
        mkdir /var/www/html
        echo "<h1>Test Dev Page</h1>" > /var/www/html/index.html
    fi
fi

echo "Installing phpMyAdmin"
rm -rf /var/www/html/phpMyAdmin
cd /root
unzip phpMyAdmin-4.7.9-all-languages.zip
mv phpMyAdmin-4.7.9-all-languages /var/www/html/phpMyAdmin
rm phpMyAdmin-4.7.9-all-languages.zip

if [ -z "$MYSQL_ROOT_PASSWORD" ]; then
ROOT_PASS=root
else
ROOT_PASS=$MYSQL_ROOT_PASSWORD
fi  

mysql -u root --password=$ROOT_PASS << EOF
    CREATE DATABASE tsugi DEFAULT CHARACTER SET utf8;
    GRANT ALL ON tsugi.* TO 'ltiuser'@'localhost' IDENTIFIED BY 'ltipassword';
    GRANT ALL ON tsugi.* TO 'ltiuser'@'127.0.0.1' IDENTIFIED BY 'ltipassword';
EOF

# This might be a read-write volume from before
if [ ! -d /var/www/html/tsugi/.git ]; then
  cd /var/www/html/
  rm /var/www/html/index.html
  if [ -n "$MAIN_REPO" ] ; then
    echo Cloning $MAIN_REPO
    git clone $MAIN_REPO site
  else
    echo Cloning default repo
    git clone https://github.com/tsugicloud/dev-jekyll-site.git site
  fi
  cd site
  mv .git* .hta* * ..
  cd ..
  rm -r site 

  cd /var/www/html/
  git clone https://github.com/tsugiproject/tsugi.git

  # Make sure FETCH_HEAD and ORIG_HEAD are created
  cd /var/www/html/tsugi
  git pull

  # Seed with a few tools
  cd /var/www/html/tsugi/mod
  git clone https://github.com/tsugitools/youtube
  git clone https://github.com/tsugitools/attend
  git clone https://github.com/tsugitools/cats

  mv /root/www/info.php /var/www/html
  mv /root/www/config.php /var/www/html/tsugi
fi

# Create/update the tables
cd /var/www/html/tsugi/admin
php upgrade.php

# Make git work from the browser
cp /usr/bin/git /usr/local/bin/gitx
chown www-data:www-data /usr/local/bin/gitx
chmod a+s /usr/local/bin/gitx
chown -R www-data:www-data /var/www/html/tsugi

# if COMPLETE
fi

touch $COMPLETE

echo ""
if [ "$@" == "return" ] ; then
  echo "Tsugi Dev Returning..."
  exit
fi

exec bash /usr/local/bin/monitor-apache.sh

# Should never happen
# https://stackoverflow.com/questions/2935183/bash-infinite-sleep-infinite-blocking
echo "Tsugi Dev Sleeping forever..."
while :; do sleep 2073600; done
