#!/bin/sh
# Uso: die-on-failure.sh <processname>
# Si <processname> muere de forma no esperada, hace shutdown de supervisord (PID 1) para que Docker reinicie el contenedor.

PROC="$1"

while true; do
  # Protocolo de eventlistener: indicar que estamos listos
  echo "READY"

  # Leer cabecera del evento (línea con 'len:<N>')
  read -r HEADER || exit 0

  LEN=$(echo "$HEADER" | sed -n 's/.* len:\([0-9]\+\).*/\1/p')
  [ -z "$LEN" ] && LEN=0

  # Leer payload binario de longitud LEN
  PAYLOAD=""
  if [ "$LEN" -gt 0 ]; then
    # Leer exactamente LEN bytes de stdin
    PAYLOAD=$(dd bs=1 count="$LEN" 2>/dev/null)
  fi

  # Responder OK al eventlistener protocol
  echo "RESULT 2"
  echo "OK"

  # ¿Es un evento de salida/fallo de nuestro proceso crítico?
  case "$HEADER" in
    *PROCESS_STATE_FATAL*|*PROCESS_STATE_EXITED*)
      if echo "$PAYLOAD" | grep -q "processname:${PROC}" && echo "$PAYLOAD" | grep -q "expected:0"; then
        # Apagar supervisord -> el contenedor sale -> Docker lo reinicia por la política --restart
        supervisorctl shutdown
      fi
      ;;
  esac
done
