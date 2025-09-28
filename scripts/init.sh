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

echo "Linking logs for emule..."
if [ -d /app/logs ]; then rm -Rf /app/logs; fi
ln -s /app/config/logs /app/logs

SLEEPSECONDS="${SLEEP_SECONDS:-1}"

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


# --- Clipboard fix para Wine: usar PRIMARY selection ---
# Define explícitamente el WINEPREFIX del usuario "emule"
export WINEARCH="${WINEARCH:-win64}"
export WINEPREFIX="${WINEPREFIX:-/app/.wine}"

echo "Inicializando WINEPREFIX (si no existe) como usuario 'emule'..."
gosu emule /usr/bin/wineboot --init || true

echo "Aplicando clave de registro UsePrimarySelection=1..."
gosu emule /usr/bin/wine reg add "HKCU\\Software\\Wine\\X11 Driver" \
  /v UsePrimarySelection /t REG_SZ /d 1 /f || true
# --- fin clipboard fix ---

#echo "Disabled: /usr/bin/wine /app/emule.exe"
#echo "Launching: exec gosu emule /usr/bin/wine /app/emule.exe"
#echo "Installed gosu in Dockerfile"
#exec gosu emule /usr/bin/wine /app/emule.exe

echo "Launching everything from here..."
/usr/bin/supervisord -n

