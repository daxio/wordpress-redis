## What is this?
This is the official Wordpress with PHP 7.1 FPM base image with additional `redis` and other extensions.

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
* Extra configuration in `wp-config.php` to enable Wordpress to send mail via a Gmail address' SMTP

## TODO:
- [x] Add `redis` PHP extensions and others required for Wordpress 
- [ ] Listen on a UNIX socket instead of port 9000
- [ ] Remove EXPOSE instruction since k8s pod has common port space and containers can find eachother on localhost

## Acknowledgements
The mail configuration in `wp-config.php` comes staight from [issue #30 in in the official Wordpress image repository](https://github.com/docker-library/wordpress/issues/30#issuecomment-269323123).
