# apache-php
Dockerfile apache and php with wordpress

# Execute dockerfile
sudo docker build -t apache-php:latest .

# Create Docker

docker run -itd -p 8000:80 --name wordpress apache-php:latest

# Remove unwanted files and images

 docker ps -a

 docker rmi $(docker images --filter "dangling=true" -q --no-trunc)

 docker image prune
