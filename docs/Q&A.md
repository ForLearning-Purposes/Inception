#### SSL cert gen key
```sh
$ openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
-keyout server.key -out server.crt \
-subj "/C=AT/ST=Vienna/L=Vienna/O=42Vienna/OU=Student/CN=msimic.42.fr"

```