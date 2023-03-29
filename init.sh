
wget -O onboarding.sh https://raw.githubusercontent.com/Wago-Norge/wagono-mid-tig-stack/main/onboarding.sh --no-check-certificate
wget -O influxdb-init.iql https://raw.githubusercontent.com/Wago-Norge/wagono-mid-tig-stack/main/influx/influxdb-init.iql --no-check-certificate
wget -O influxdb.conf https://raw.githubusercontent.com/Wago-Norge/wagono-mid-tig-stack/main/influx/influxdb.conf --no-check-certificate
wget -O telegraf.conf https://raw.githubusercontent.com/Wago-Norge/wagono-mid-tig-stack/main/telegraf/telegraf.conf --no-check-certificate
wget -O telegraf.conf https://raw.githubusercontent.com/Wago-Norge/wagono-mid-tig-stack/main/etc/init.d/docker-tic-stack --no-check-certificate

chmod +x onboarding.sh
chmod +x influxdb-init.iql
chmod +x influxdb.conf
chmod +x telegraf.conf
chmod +x docker-tic-stack

mv influxdb-init.iql /home/admin
mv influxdb.conf /home/admin
mv telegraf.conf /home/admin
mv docker-tic-stack /etc/init.d

ln -s /etc/init.d/docker-tic-stack /etc/rc.d/S99_zz_docker_tic_Stack

cnt=$1
./onboarding.sh $cnt










