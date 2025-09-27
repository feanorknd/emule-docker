#!/bin/sh

if [ ! -f "/data/download" ]; then
    echo "Creating download directory..."
    mkdir -p /data/download
fi

if [ ! -f "/data/tmp" ]; then
    echo "Creating tmp directory..."
    mkdir -p /data/tmp
fi

if [ ! -f "/app/config" ]; then
    echo "Creating config directory..."
    mkdir -p /app/config
fi

if [ ! -f "/app/config/preferences.ini" ]; then
    echo "Creating config file..."
    cp -n /app/preferences.ini /app/config/preferences.ini
fi

cp -n /app/config_bak/* /app/config

echo "Creating logs folder..."
mkdir -p /app/config/logs

if [ $UID != "0" ]; then
    echo "Fixing permissions..."
    useradd --shell /bin/bash -u ${UID} -U -d /app -s /bin/false emule && \
    usermod -G users emule
    chown -R ${UID}:${GID} /data
    chown -R ${UID}:${GID} /app
fi

echo "Applying configuration..."
echo "Disabled: /app/launcher to keep current preferences file"

echo "Running virtual desktop..."
/usr/bin/supervisord -n &

echo "Linking logs for emule..."
if [ -d /app/logs ]; then rm -Rf /app/logs; fi
ln -s /app/config/logs /app/logs

SLEEPSECONDS=1
if [ ${SLEEP_SECONDS} -ge 1 ]; then
    SLEEPSECONDS=${SLEEP_SECONDS}
fi

echo "Waiting to run emule... 5"
sleep $SLEEPSECONDS
echo "Waiting to run emule... 4"
sleep $SLEEPSECONDS
echo "Waiting to run emule... 3"
sleep $SLEEPSECONDS
echo "Waiting to run emule... 2"
sleep $SLEEPSECONDS
echo "Waiting to run emule... 1"
sleep $SLEEPSECONDS

echo "Disabled: /usr/bin/wine /app/emule.exe"
echo "Launching: exec gosu emule /usr/bin/wine /app/emule.exe"
echo "Installed gosu in Dockerfile"
exec gosu emule /usr/bin/wine /app/emule.exe
