
arch=$(uname -m)

if [ "$arch" = "armv7l" ]; then
    wget -O onboarding.sh https://raw.githubusercontent.com/Wago-Norge/wagono-mid-tig-stack/main/onboarding.sh --no-check-certificate
    wget -O influxdb-init.iql https://raw.githubusercontent.com/Wago-Norge/wagono-mid-tig-stack/main/influx/influxdb-init.iql --no-check-certificate
    wget -O influxdb.conf https://raw.githubusercontent.com/Wago-Norge/wagono-mid-tig-stack/main/influx/influxdb.conf --no-check-certificate
    wget -O telegraf.conf https://raw.githubusercontent.com/Wago-Norge/wagono-mid-tig-stack/main/telegraf/telegraf.conf --no-check-certificate
    wget -O docker-tic-stack https://github.com/Wago-Norge/wagono-mid-tig-stack/tree/main/etc/init.d/docker-tic-stack --no-check-certificate
    chmod +x onboarding.sh
    chmod +x influxdb-init.iql
    chmod +x influxdb.conf
    chmod +x telegraf.conf
    chmod +x docker-tic-stack
    mv onboarding.sh /home/admin
    mv influxdb-init.iql /home/admin
    mv influxdb.conf /home/admin
    mv telegraf.conf /home/admin
    mv docker-tic-stack /etc/init.d
    ln -s /etc/init.d/docker-tic-stack /etc/rc.d/S99_zz_docker_tic_Stack
    cd /home/admin
elif [ "$arch" = "x86_64" ]; then
    wget -O onboarding.sh https://raw.githubusercontent.com/Wago-Norge/wagono-mid-tig-stack/main/onboarding.sh --no-check-certificate
    wget -O influxdb-init.iql https://raw.githubusercontent.com/Wago-Norge/wagono-mid-tig-stack/main/influx/influxdb-init.iql --no-check-certificate
    wget -O influxdb.conf https://raw.githubusercontent.com/Wago-Norge/wagono-mid-tig-stack/main/influx/influxdb.conf --no-check-certificate
    wget -O telegraf.conf https://raw.githubusercontent.com/Wago-Norge/wagono-mid-tig-stack/main/telegraf/telegraf.conf --no-check-certificate
    chmod +x onboarding.sh
    chmod +x influxdb-init.iql
    chmod +x influxdb.conf
    chmod +x telegraf.conf
    mv onboarding.sh /edge/admin
    mv influxdb-init.iql /edge/admin
    mv influxdb.conf /edge/admin
    mv telegraf.conf /edge/admin
    cd /home/edge
else
    echo "Onboarding status: Error: Can't resolve architecture!" 
fi

cnt=$1
./onboarding.sh $cnt





