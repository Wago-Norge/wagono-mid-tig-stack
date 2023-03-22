
# This setup script is experimental.


### FUNCTIONS ####

remove_container () {
    local_rm=$(docker rm "$1")
    wait
    echo "Onboarding status: "$1" container removed" >> midlog.txt
    echo "$local_rm"
}

run_telegraf () {
    local local_run=$(docker run -d --name "$1" --device=/dev/serial:/dev/serial:rw -v /home/admin/telegraf.conf:/etc/telegraf/telegraf.conf:ro arm32v7/telegraf:latest)
    wait
    echo "Onboarding status: "$1" container started" >> midlog.txt
    echo "$local_run"
}

run_influx () {
    local local_run=$(docker run -d --name "$1" -p 8086:8086 -e INFLUXDB_ADMIN_USER=admin -e INFLUXDB_ADMIN_PASSWORD=wago -e INFLUXDB_MONITOR_STORE_ENABLED=FALSE -v influx-vol-data:/var/lib/influxdb -v /home/admin/influxdb.conf:/etc/influxdb/influxdb.conf -v /home/admin/influxdb-init.iql:/docker-entrypoint-initdb.d/influxdb-init.iql arm32v7/influxdb:latest -config /etc/influxdb/influxdb.conf)
    wait
    echo "Onboarding status: "$1" container started" >> midlog.txt
    echo "$local_run"
}


run_grafana () {
    local local_run=$(docker run -d --name "$1" -p 3000:3000 -v grafana-vol-data:/var/lib/grafana grafana/grafana:latest)
    wait
    echo "Onboarding status: "$1" container started" >> midlog.txt
    echo "$local_run"   
}

# ONLY FOR TESTING
run_demo () {
    docker pull "$1" >> midlog.txt
    wait
    echo "Onboarding status: $1 pulled" >> midlog.txt
    local_install="$1"
    echo "$local_install"
}


## BRUKES IKKE
remove_image () {
    local image="$(check_image "$1")"
    if [ "$image" = "true" ]; then
        echo "Onboarding status: Keeping image for "$1"" >> midlog.txt  
    else
        case "$1" in 
            "telegraf")
                local_rmi=$(docker rmi arm32v7/telegraf)
                echo "Onboarding status: "$1" image removed" >> midlog.txt
                wait
                ;;
            "influx")
                local_rmi=$(docker rmi arm32v7/influxdb)
                echo "Onboarding status: "$1" image removed" >> midlog.txt
                wait
                ;;
            "grafana")
                local_rmi=$(docker rmi grafana/grafana)
                echo "Onboarding status: "$1" image removed" >> midlog.txt          
                wait
                ;;
            * ) 
                ;;
        esac
    fi
    # Return "telegraf", "influx" or "grafana"
    echo "$local_rmi"
}

install_image () {
    docker pull "$1" >> midlog.txt
    wait
    echo "Onboarding status: "$1" pulled" >> midlog.txt
    local_install="$1"
    echo "$local_install"
}

create_volume () {
    local volume="$(docker volume create "$1")"
    wait
    echo "Onboarding status: Volume "$1" created" >> midlog.txt
    echo "$volume"
}

# Inspect if the containter is running, return the status to main
inspect () {
    local container=$(docker ps -a | grep $1)
    if [ "$container" != "" ]; then
        local container_Status=$(docker container inspect -f '{{.State.Status}}' "$1")
        case "$container_Status" in 
            "exited")
                echo "Onboarding status: "$1" container has status $container_Status" >> midlog.txt
                local stat_con="$container_Status"
                ;;
            "running")
                echo "Onboarding status: "$1" container has status $container_Status" >> midlog.txt
                local stat_con="$container_Status"
                ;;
            "stopped")
                echo "Onboarding status: "$1" container has status $container_Status" >> midlog.txt
                local stat_con="$container_Status"
                ;;
            "created")
                echo "Onboarding status: "$1" container has status $container_Status" >> midlog.txt
                local stat_con="$container_Status"
                ;;
            * ) 
                ;;
        esac
    else
        local stat_con="Onboarding status: "$1" not found.." >> midlog.txt
    fi
    echo "$stat_con"
}

## Check created containers and return the menu-parameter
check_containers () {
    # Telegraf
    local is_telegraf=$(docker ps -a | grep "$1")
    if [ "$is_telegraf" != "" ]; then
        is_telegraf="true"
    else
        is_telegraf="false"
    fi
    # Influx
    local is_influx=$(docker ps -a | grep "$2")
        if [ "$is_influx" != "" ]; then
        is_influx="true"
    else
        is_influx="false"
    fi
    # Grafana
    local is_grafana=$(docker ps -a | grep "$3")
    if [ "$is_grafana" != "" ]; then
        is_grafana="true"
    else
        is_grafana="false"
    fi


    if [ $is_telegraf == "true" ] && [ $is_influx == "true" ] && [ $is_grafana == "true" ]; then
        echo "Onboarding status: Found container Telegraf, Influx and Grafana" >> midlog.txt
        onboard="TIG"
        echo "$onboard"
    elif [ $is_telegraf == "false" ] && [ $is_influx == "true" ] && [ $is_grafana == "false" ]; then
        echo "Onboarding status: Found container Influx" >> midlog.txt
        onboard="?I?"
        echo "$onboard"
    elif [ $is_telegraf == "false" ] && [ $is_influx == "false" ] && [ $is_grafana == "true" ]; then
        echo "Onboarding status: Found container Grafana" >> midlog.txt
        onboard="??G"
        echo "$onboard"
    elif [ $is_telegraf == "true" ] && [ $is_influx == "true" ] && [ $is_grafana == "false" ]; then
        echo "Onboarding status: Found container Telegraf and Influx" >> midlog.txt 
        onboard="TI?"
        echo "$onboard"
    elif [ $is_telegraf == "true" ] && [ $is_influx == "false" ] && [ $is_grafana == "false" ]; then
        echo "Onboarding status: Found container Telegraf" >> midlog.txt
        onboard="T??"
        echo "$onboard"
    elif [ $is_telegraf == "false" ] && [ $is_influx == "true" ] && [ $is_grafana == "true" ]; then
        echo "Onboarding status: Found container Influx and Grafana" >> midlog.txt
        onboard="?IG"
        echo "$onboard"
    elif [ $is_telegraf == "true" ] && [ $is_influx == "false" ] && [ $is_grafana == "true" ]; then
        echo "Onboarding status: Found container Telegraf and Grafana" >> midlog.txt
        onboard="T?G"
        echo "$onboard"
    elif [ $is_telegraf == "false" ] && [ $is_influx == "false" ] && [ $is_grafana == "false" ]; then
        echo "Onboarding status: No containers found" >> midlog.txt
        onboard="???"
        echo "$onboard"
    else
        echo "Error function check containers" >> midlog.txt
        onboard=""
    fi
}

check_image () {
    local image=$(docker images | grep "$1")
        if [ "$image" != "" ]; then
        local is_image="true"
        echo "Onboarding status: Image "$1" excists" >> midlog.txt
    else
        local is_image="false"
        echo "Onboarding status: Image "$1" does not excists, downloading.." >> midlog.txt     
    fi
    echo "$is_image"
}

# NOT USED
check_volume () {
    local is_volume=$(docker volume ls | grep "$1")
        if [ "$is_volume" != "" ]; then
        local is_volume="true"
        echo "Onboarding status: Volume "$1" excists" >> midlog.txt
    else
        local is_volume="false"
        echo "Onboarding status: Volume "$1" does not excists" >> midlog.txt     
    fi
    echo "$is_volume"
}







### MAIN ####


# Force removal of images and containers, not volumes. 
if [ "$1" = "force" ]; then
    echo "Onboarding status: Forced removal of MID TIG stack" > midlog.txt > /dev/stderr
    docker stop $(docker ps -a -q)
    wait
    docker rm $(docker ps -a -q)
    wait
    docker rmi $(docker images -a -q)
    wait
fi

# Check image -> excists -> remove -> create/run container, else pull image, create volume and run container (do not delete excisting image or volumes!)
echo "Logging to file /home/admin/midlog.txt" > midlog.txt > /dev/stderr
# Be sure the serial port is accessible
chmod ugo+rw /dev/serial
# Check docker containers, do decide what to install
onboard="$(check_containers "telegraf" "influx" "grafana")"

# ONLY FOR TESTING
# onboard="demo"


case "$onboard" in 

    "demo")

        echo "demo started"
        ret="$(run_demo "alpine:latest")"    
        echo "Onboarding status: "$ret" image pulled"
        ;;


        
    "???")  # Install Telegraf + Influx + Grafana (default)

        echo "Onboarding status: No MID TIG stack found" >> midlog.txt > /dev/stderr
        
            while true; do
            read -p "Do you want install? (y/n) " yn

            case $yn in 

                [yY] ) echo "Onboarding status: Please wait.."

                    # TELEGRAF

                    # Install image - do not reinstall any excisting images
                    image=$(check_image "telegraf")
                    if [ "$image" = "false" ]; then
                        ret="$(install_image "arm32v7/telegraf:latest")"
                        echo "Onboarding status: Docker image for "$ret" pulled"
                    else
                        return_container_stat="$(inspect "telegraf")"
                        # If running, stop it
                        if [ "$return_container_stat" = "running" ]; then
                            ret="$(docker stop telegraf)"
                            echo "Onboarding status: Telegraf container stopped" >> midlog.txt
                            wait
                        fi

                        # Remove container
                        ret=$(remove_container "telegraf")
                        echo "Onboarding status: "$ret" container removed"
                    fi

                    # Run container (function returns container id)
                    ret="$(run_telegraf "telegraf")"
                    echo "Onboarding status: Telegraf container started"   

                    # INFLUX

                    # Install image - do not reinstall/create any excisting images or volumes
                    image=$(check_image "influx")
                    if [ "$image" = "false" ]; then
                        ret="$(install_image "arm32v7/influxdb:latest")"
                        echo "Onboarding status: Docker image for "$ret" pulled"
                        ret="$(create_volume "influx-vol-data")"
                    else
                        return_container_stat="$(inspect "influx")"
                        # If running, stop it
                        if [ "$return_container_stat" = "running" ]; then
                            ret="$(docker stop influx)"
                            echo "Onboarding status: Influx container stopped" >> midlog.txt
                            wait
                        fi

                        # Remove container
                        ret=$(remove_container "influx")
                        echo "Onboarding status: "$ret" container removed"
                    fi

                    # Run container (function returns container id)
                    ret="$(run_influx "influx")"
                    echo "Onboarding status: Influx container started"   

                    # GRAFANA

                    # Install image - do not reinstall/create any excisting images or volumes
                    image=$(check_image "grafana")
                    if [ "$image" = "false" ]; then
                        ret="$(install_image "grafana/grafana:latest")"
                        echo "Onboarding status: Docker image for "$ret" pulled"
                        ret="$(create_volume "grafana-vol-data")"
                    else
                        return_container_stat="$(inspect "grafana")"
                        # If running, stop it
                        if [ "$return_container_stat" = "running" ]; then
                            ret="$(docker stop grafana)"
                            echo "Onboarding status: Grafana container stopped" >> midlog.txt
                            wait
                        fi

                        # Remove container
                        ret=$(remove_container "Grafana")
                        echo "Onboarding status: "$ret" container removed"
                    fi

                    # Run container (function returns container id)
                    ret="$(run_grafana "grafana")"
                    echo "Onboarding status: Grafana container started"   

                    exit;;

                # No - exit the case
                [nN] ) echo exiting..;
                    exit;;
                
                # Else
                * ) echo invalid response;;
            esac
        done
        ;;       
    

    "?I?") # Install Telegraf + Grafana
        echo "Onboarding status: Only found partial MID TIG stack with Influxdb, Grafana and Telegraf are missing" >> midlog.txt > /dev/stderr
        echo "Partial installation not yet supported (please run "./onboarding.sh force" to re-install stack)" > /dev/stderr
        ;;
    "??G") # Install Telegraf + Influx
        echo "Onboarding status: Only found partial MID TIG stack with Grafana, Influxdb and Telegraf are missing" >> midlog.txt > /dev/stderr
        echo "Partial installation not yet supported (please run "./onboarding.sh force" to re-install stack)" > /dev/stderr
        ;;       
    "TI?") # Install Grafana
        echo "Onboarding status: Only found partial MID TIG stack with Influxdb and Telegraf, Grafana is missing" >> midlog.txt > /dev/stderr
        echo "Partial installation not yet supported (please run "./onboarding.sh force" to re-install stack)" > /dev/stderr
        ;;
    "T??") # Install Influx + Grafana
        echo "Onboarding status: Only found partial MID TIG stack with telegraf, Influxdb and Grafana are missing" >> midlog.txt > /dev/stderr 
        echo "Partial installation not yet supported (please run "./onboarding.sh force" to re-install stack)" > /dev/stderr
        ;;
    "T?G") # Install Influx
        echo "Onboarding status: Only found partial MID TIG stack with Grafana and Telegraf, Influxdb is missing" >> midlog.txt > /dev/stderr 
        echo "Partial installation not yet supported (please run "./onboarding.sh force" to re-install stack)" > /dev/stderr
        ;;
    "?IG") # Install Telegraf
        echo "Onboarding status: Only found partial MID TIG stack with Influx and Grafana, Telegraf is missing" >> midlog.txt > /dev/stderr 
        echo "Partial installation not yet supported (please run "./onboarding.sh force" to re-install stack)" > /dev/stderr
        ;;
    "TIG") # Stck present
        echo Onboarding status: a complete MID TIG stack is allready present >> midlog.txt > /dev/stderr 
        echo "Please run "./onboarding.sh force" to re-install stack)" > /dev/stderr


esac

echo "Onboarding status: Finnished" >> midlog.txt > /dev/stderr

### TESTS ###

## check volumes binds
#case "$1" in 
#    "influx")
#        local volume=$(docker container inspect -f '{{.HostConfig.Binds}}' $1)
#        if [ $volume == "[influx-vol-data:/var/lib/influxdb]" ]; then
#            local stat_vol= "Onboarding status: Found "$1" volume: $volume"
#            #echo "$stat_vol" 
#        
#        fi
#        ;;
#    "grafana")
#        if [ $grafana_volume == "[grafana-vol-data:/var/lib/grafana]" ]; then
#            local stat_vol= "Onboarding status: Found "$1" volume: $volume"
#            #echo "$stat_vol"
#
#        fi
#        ;;
#    * ) 
#        local stat_vol= "Onboarding status: No volumes found"
#        #echo "$stat_vol"
#        ;;
#esac