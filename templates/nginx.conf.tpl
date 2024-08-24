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