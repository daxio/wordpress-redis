#!/bin/bash
set -euo pipefail

file_env() {
  local var="$1"
  local fileVar="${var}_FILE"
  local def="${2:-}"
  if [ "${!var:-}" ] && [ "${!fileVar:-}" ]; then
    echo >&2 "error: both $var and $fileVar are set (but are exclusive)"
    exit 1
  fi
  local val="$def"
  if [ "${!var:-}" ]; then
    val="${!var}"
  elif [ "${!fileVar:-}" ]; then
    val="$(< "${!fileVar}")"
  fi
  export "$var"="$val"
  unset "$fileVar"
}

envs=(
  MAILER_ADMIN_EMAIL
  MAILER_APP_PASSWORD
  MAILER_YOUR_NAME
)

haveConfig=
for e in "${envs[@]}"; do
  file_env "$e"
  if [ -z "$haveConfig" ] && [ -n "${!e}" ]; then
    haveConfig=1
  fi
done

# only touch "wp-config.php" if we have environment-supplied configuration values
if [ "$haveConfig" ]; then
  : "${MAILER_ADMIN_EMAIL:=name@domain.tld}"
  : "${MAILER_APP_PASSWORD:=googleapppassword}"
  : "${MAILER_YOUR_NAME:=name}"

  # version 4.4.1 decided to switch to windows line endings, that breaks our seds and awks
  # https://github.com/docker-library/wordpress/issues/116
  # https://github.com/WordPress/WordPress/commit/1acedc542fba2482bab88ec70d4bea4b997a92e4
  sed -ri -e 's/\r$//' wp-config*

  if [ ! -e wp-config.php ]; then
    awk '/^\/\*.*stop editing.*\*\/$/ && c == 0 { c = 1; system("cat") } { print }' wp-config-sample.php > wp-config.php <<'EOPHP'
// configure phpmailer
add_action( 'phpmailer_init', 'mail_relay' );
function mail_relay( $phpmailer ) {
    $phpmailer->isSMTP();
    $phpmailer->Host = 'smtp.gmail.com';
    $phpmailer->SMTPAutoTLS = true;
    $phpmailer->SMTPAuth = true; 
    $phpmailer->Port = 465;
    $phpmailer->Username = 'ADMIN_EMAIL';
    $phpmailer->Password = 'APP_PASSWORD';

    // Additional settings
    $phpmailer->SMTPSecure = "ssl"; 
    $phpmailer->From = "ADMIN_EMAIL";
    $phpmailer->FromName = "YOUR_NAME";
}
EOPHP
    chown www-data:www-data wp-config.php
  fi

  # see http://stackoverflow.com/a/2705678/433558
  sed_escape_lhs() {
    echo "$@" | sed -e 's/[]\/$*.^|[]/\\&/g'
  }
  sed_escape_rhs() {
    echo "$@" | sed -e 's/[\/&]/\\&/g'
  }
  php_escape() {
    php -r 'var_export(('$2') $argv[1]);' -- "$1"
  }
  set_config() {
    key="$1"
    value="$2"
    var_type="${3:-string}"
    start="(['\"])$(sed_escape_lhs "$key")\2\s*,"
    end="\);"
    if [ "${key:0:1}" = '$' ]; then
      start="^(\s*)$(sed_escape_lhs "$key")\s*="
      end=";"
    fi
    sed -ri -e "s/($start\s*).*($end)$/\1$(sed_escape_rhs "$(php_escape "$value" "$var_type")")\3/" wp-config.php
  }

  set_config 'ADMIN_EMAIL' "$MAILER_ADMIN_EMAIL"
  set_config 'APP_PASSWORD' "$MAILER_APP_PASSWORD"
  set_config 'YOUR_NAME' "$MAILER_YOUR_NAME"

fi

exec "$@"
