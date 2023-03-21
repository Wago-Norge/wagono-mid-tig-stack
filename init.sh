
wget wget -O onboarding.sh https://raw.githubusercontent.com/Wago-Norge/wagono-mid-tig-stack/main/onboarding.sh --no-check-certificate
wget wget -O influxdb-init.iql https://raw.githubusercontent.com/Wago-Norge/wagono-mid-tig-stack/main/influx/influxdb-init.iql --no-check-certificate
wget wget -O influxdb.conf https://raw.githubusercontent.com/Wago-Norge/wagono-mid-tig-stack/main/influx/influxdb.conf --no-check-certificate
wget wget -O telegraf.conf https://raw.githubusercontent.com/Wago-Norge/wagono-mid-tig-stack/main/telegraf/telegraf.conf --no-check-certificate

chmod +x onboarding.sh
chmod +x influxdb-init.iql
chmod +x influxdb.conf
chmod +x telegraf.conf

mv influxdb-init.iql /home/admin
mv influxdb.conf /home/admin
mv telegraf.conf /home/admin












