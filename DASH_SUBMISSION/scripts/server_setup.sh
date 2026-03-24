sudo apt update
sudo apt install -y ffmpeg apache2 iperf3 iproute2 git
sudo systemctl enable apache2
sudo systemctl restart apache2
sudo mkdir -p /var/www/html/streams/video1 /var/www/html/streams/video2
sudo cp -r ~/ffmpeg_lab/dash/video1/* /var/www/html/streams/video1/
sudo cp -r ~/ffmpeg_lab/dash/video2/* /var/www/html/streams/video2/
sudo chown -R www-data:www-data /var/www/html/streams
sudo chmod -R 755 /var/www/html/streams
sudo ufw allow 80/tcp
sudo ufw status
