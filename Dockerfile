FROM lucee/lucee:6.0-nginx

# Set umask so that files and folders are created with full rights
ENV UMASK 0000

# Set the working directory
WORKDIR /var/www