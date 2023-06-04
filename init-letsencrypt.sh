#!/bin/bash

set -e

envfile=${ENVFILE:-.env}
. ${envfile}

domains=$DOMAINS
rsa_key_size=4096
email="oliver@van-porten.de" # Adding a valid address is strongly recommended
staging=${STAGING:-0} # Set to 1 if you're testing your setup to avoid hitting request limits

echo "### Fetch nginx config ..."
docker compose --env-file $envfile run --rm --entrypoint "/bin/sh -c '\
  curl -s https://raw.githubusercontent.com/certbot/certbot/master/certbot-nginx/certbot_nginx/_internal/tls_configs/options-ssl-nginx.conf -o /etc/letsencrypt/options-ssl-nginx.conf; \
  curl -s https://raw.githubusercontent.com/certbot/certbot/master/certbot/certbot/ssl-dhparams.pem -o /etc/letsencrypt/ssl-dhparams.pem'" nginx
echo

echo "### Creating dummy certificate for $domains ..."
path="/etc/letsencrypt/live/$domains"
docker compose --env-file $envfile run --rm --entrypoint "/bin/sh -c \"\ 
  mkdir -p /etc/letsencrypt/live/$domains && \
  apk add openssl && \
  openssl req -x509 -nodes -newkey rsa:$rsa_key_size -days 1\
    -keyout '$path/privkey.pem' \
    -out '$path/fullchain.pem' \
    -subj '/CN=localhost'\"" nginx
echo

if [ ! -e $ONLY_SELF_SIGNED ] 
then
  echo Only making self-signed cert, exiting here...
  exit
fi

echo "### Starting nginx ..."
docker compose --env-file $envfile up --force-recreate -d nginx
echo

echo "### Deleting dummy certificate for $domains ..."
docker compose run --rm --entrypoint "/bin/sh -c '\
  rm -Rf /etc/letsencrypt/live/$domains && \
  rm -Rf /etc/letsencrypt/archive/$domains && \
  rm -Rf /etc/letsencrypt/renewal/$domains.conf'" certbot
echo

echo "### Requesting Let's Encrypt certificate for $domains ..."
#Join $domains to -d args
domain_args=""
for domain in "${domains[@]}"; do
  domain_args="$domain_args -d $domain"
done

# Select appropriate email arg
case "$email" in
  "") email_arg="--register-unsafely-without-email" ;;
  *) email_arg="--email $email" ;;
esac

# Enable staging mode if needed
if [ $staging != "0" ]; then staging_arg="--staging"; fi

docker compose --env-file $envfile run --rm --entrypoint "\
  certbot certonly --webroot -w /var/www/certbot \
    $staging_arg \
    $email_arg \
    $domain_args \
    --rsa-key-size $rsa_key_size \
    --agree-tos \
    --force-renewal" certbot
echo

echo "### Reloading nginx ..."
docker compose --env-file $envfile exec nginx nginx -s reload
