# README

## !!! EXPERIMENTAL !!!

Wago Energy Meters (MID 879-30xx) with TIG-stack (Telegraf+Influx+Grafana).

<figure><img src=".gitbook/assets/image (1).png" alt=""><figcaption></figcaption></figure>

## 879-30xx Setup

Default passwor is 0000.

1. Download the Android app from store.
2. Enter the MID menu and select bluetooth.
3. Scan the QR-code.
4. Go to settings and change modbus settings according to telegraf configuration.

## Manually setup of TIG stack

### Prepare the controller

In WBM:

1. Set PLC Runtime to 'none'.
2. Enable 'IP Forwarding through multiple interfaces'.
3. Enable Docker.
4. Enable and set a NTP time server.
5. Format a memory card as 'ext4' with label 'Docker'.

Extend the docker data directory from internal flash to memory card:

```
// change to “data-root”:“/media/docker”
nano /etc/docker/deamon.json 
```

Permit docker to access serial port:

```
// For Edge controller
sudo chmod ugo+rw /dev/ttymxc1
// For CC100
abc
```

Reboot the controller.

### Setup Telegraf

Get Telegraf from Dockerhub:

```
docker pull arm32v7/telegraf
```

Copy the script to '/home/admin' and make them executable:

```
chmod +x telegraf.conf
```

Create the container:

```
docker create --name telegraf --restart unless-stopped --device=/dev/ttymxc1:/dev/ttymxc1:rw -v /home/admin/telegraf.conf:/etc/telegraf/telegraf.conf:ro arm32v7/telegraf:latest
```

### Setup Influx

Get Influx v1.8 from Dockerhub:

```
docker pull arm32v7/influxdb
```

Make a volume for data:

```
docker volume create grafana-storage
```

Copy scripts to '/home/admin' and make them executable:

```
chmod +x influxdb.conf && chmod +x influxdb-init.iql
```

Create the container:

```
docker create --name influx --restart unless-stopped -p 8086:8086 \
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
docker create --name grafana --restart unless-stopped -p 3000:3000 -v grafana-storage:/var/lib/grafana grafana/grafana:latest
```

Default user is 'admin' and password 'wago123'.

There is an API key for Websockets live data present.

## !!! NOT FINNISHED !!!



### Run the stack

```
docker start telegraf && docker start influx && docker start grafana
```

## Automated setup of TIG stack

TBA: med docker compose, script->REST-API WBM?
