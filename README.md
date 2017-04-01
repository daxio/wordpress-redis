## What is this?
This is the official Wordpress with PHP 7.1 base image with additional `redis` and other extensions.

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
- [ ] Listen on a UNIX socket instead of port 9000
- [ ] Remove EXPOSE instruction since k8s pod has common port space and containers can find eachother on localhost
