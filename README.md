## What is this?
This is the official Wordpress with PHP 7.3 **FPM** base image with additional `redis` and other extensions. It's without a webserver and instead has PHP FPM listening on port 9000. It would require a web server such as NGINX to send requests upstream to this port in order to work

## What's included:
* PHP extensions (additional to default PHP installation):
  * `redis`
  * `imagick`
  * `libsodium`
  * `exif`
  * `gettext`
  * `intl`
  * `mcrypt`
  * `socket`
  * `zip`

## TODO:
- [x] Add `redis` PHP extensions and others required for Wordpress
