server {
    listen 80;
    listen [::]:80;

    server_name ${domain};

    root /var/www/${domain};
    index index.html;

    location / {
         try_files $uri $uri/ =404;
    }
}

# Security headers
add_header X-Content-Type-Options nosniff;
add_header X-Frame-Options "SAMEORIGIN";
add_header X-XSS-Protection "1; mode=block";

# Logging (optional)
access_log /var/log/nginx/${domain}_access.log;
error_log /var/log/nginx/${domain}_error.log;

# SSL configuration (optional)
# Uncomment the following lines if you have SSL certificates
# listen 443 ssl;
# ssl_certificate /etc/nginx/ssl/${domain}.crt;
# ssl_certificate_key /etc/nginx/ssl/${domain}.key;