ORO CRM - CALLEO X Poc - (NGINX + PHP-FPM)
==========================================

### Set FACL

Set files rights

```bash
setfacl -Rm u:www-data:rwX -Rm d:u:www-data:rwX /var/www/app/app/logs /var/www/app/app/cache /var/www/app/app/attachment /var/www/app/www/media /var/www/app/www/upload
```
