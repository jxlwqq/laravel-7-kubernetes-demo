#!/usr/bin/env bash

set -e

cd /var/www/laravel
rm -f public/storage

echo 'migrate'
php artisan migrate --force

echo 'publish'
# php artisan vendor:publish --tag=laravel-pagination

echo 'cache'
php artisan config:cache
php artisan view:cache
php artisan route:cache
php artisan event:cache

echo "cron"
mkdir -p /var/spool/cron/crontabs/
cp crontab /var/spool/cron/crontabs/root
chmod 0644 /var/spool/cron/crontabs/root
crontab /var/spool/cron/crontabs/root
cron -f &

echo "queue"
php artisan queue:work --queue={default} --verbose --tries=3 --timeout=90 &

echo 'http'
exec apache2-foreground
