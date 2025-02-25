---
description: Wago Energy Meters (MID 879-30xx) with TIG-stack (Telegraf+Influx+Grafana).
---

# README

<figure><img src=".gitbook/assets/image.png" alt=""><figcaption></figcaption></figure>

## Supported Devices

* PFC200
* CC100
* TP-panels and Edge Controller
* Edge PC

## Prepare the controller (omitted for Edge PC)

In WBM:

1. Set PLC Runtime to 'none'.
2. Enable 'IP Forwarding through multiple interfaces'.
3. Enable Docker.
4. Enable and set a NTP time server.
5. Format a memory card as 'ext4' with label 'docker'.

Extend the docker data directory from internal flash to memory card. Change to “data-root”:“/media/docker”:

```
nano /etc/docker/daemon.json 
```

Reboot the controller.

## 879-30xx Setup

Default password is 0000.

1. Download the Android app from store.
2. Enter the MID menu and select bluetooth.
3. Scan the QR-code.
4. Go to settings and change modbus settings according to telegraf configuration.

Meter is using RS-485: Modbus® address 001 • Baud rate 9600 • 8 data bits • Parity: Even • 1 stop bit.

### Wiring

CC100: D+ -> A, D- > B/-

PFC200: Pin 3 -> B/-, Pin 8 -> A

Edge PC: Please check manual for the USB-to-Serial converter used.

## Automated setup

To install the TIG stack we provide a script.

Log in to the controller as root-user and provide the password:

```
ssh root@<ip-address>
```

Download the init script:

```
wget -O init.sh https://raw.githubusercontent.com/Wago-Norge/wagono-mid-tig-stack/main/init.sh --no-check-certificate
```

Make the script executable:

```
chmod +x init.sh
```

Run the installation script and pass the amount of MIDs to be configured:

```
./init.sh <x>
```

> x is restricted to maximum 10 MID meeters -> ./init.sh 10\
> Please use excact amount of meeters. See issuetracker.

In case of any problems run:

```
./onboarding --help
```

Configure Influxdb in Grafana as described below in the "manual setup".

## Manual setup  

Permit docker to access serial port:

```
sudo chmod ugo+rw /dev/serial
```

### Setup Telegraf

Get Telegraf from Dockerhub:

```
docker pull arm32v7/telegraf
```

Copy the script to '/home/admin' and make them executable:

```
chmod +x /home/admin/telegraf.conf
```

Create the container:

```
docker create --name telegraf --device=/dev/serial:/dev/serial:rw -v /home/admin/telegraf.conf:/etc/telegraf/telegraf.conf:ro arm32v7/telegraf:latest
```

### Setup Influx

Get Influx v1.8 from Dockerhub:

```
docker pull arm32v7/influxdb
```

Make a volume for data:

```
docker volume create influx-vol-data
```

Copy scripts to '/home/admin' and make them executable:

```
chmod +x /home/admin/influxdb.conf && chmod +x /home/admin/influxdb-init.iql
```

Create the container:

```
docker create --name influx -p 8086:8086 \
        -e INFLUXDB_ADMIN_USER=admin \
        -e INFLUXDB_ADMIN_PASSWORD=wago \
        -e INFLUXDB_MONITOR_STORE_ENABLED=FALSE \
        -v influx-vol-data:/var/lib/influxdb \
        -v /home/admin/influxdb.conf:/etc/influxdb/influxdb.conf \
        -v /home/admin/influxdb-init.iql:/docker-entrypoint-initdb.d/influxdb-init.iql \
        arm32v7/influxdb:latest -config /etc/influxdb/influxdb.conf
```

### Setup Grafana

Get Influx Grafana from Dockerhub:

```
docker pull grafana/grafana
```

Make a volume for data:

```
docker volume create grafana-vol-data
```

Create the container:

```
docker create --name grafana -p 3000:3000 -v grafana-vol-data:/var/lib/grafana grafana/grafana:latest
```

Default user is 'admin' and password 'wago123'.

There is an API key for Websockets live data present.

### Setup start conditions

Copy the provided script to '/etc/init.d' and make it executable:

```
chmod +x /etc/init.d/docker-tic-stack
```

Then make a symlink to this script in /'etc/init.d':

```
ln -s /etc/init.d/docker-tic-stack /etc/rc.d/S99_zz_docker_tic_Stack
```

### Run the stack

Repower the controller or execute 'reboot' command:

```
reboot
```

### Configure Grafana

Quickly get started with datasource for Influxdb:

1. Settings ->Add datasource -> InfluxDB
2. URL: [http://IPADDRESS:8086](http://10.0.0.228:8086)
3. Database: wagodb
4. User: admin
5. Password: wago123

Add token for Telegraf websocket data:

1. Settings -> API keys -> New API Key
2. Key Name: telegraf
3. Role: Admin
4. Time To Live: 1y

Import the Grafana dashboards.

##
