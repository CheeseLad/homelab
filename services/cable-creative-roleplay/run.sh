docker run -it -v ./server:/home/steam/Unturned -p 27015:27015 -p 27016:27016 -e SERVER_TYPE=rm4 --restart unless-stopped --name myserverinstance imperialplugins/unturned