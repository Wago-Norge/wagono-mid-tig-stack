

version="1.0.0"

### FUNCTIONS ####

remove_container () {
    local_rm=$(docker rm "$1")
    wait
    echo "Onboarding status: "$1" container removed" >> midlog.txt
    echo "$local_rm"
}

run_telegraf () {
    ret="$(change_ip)"
    wait


    ### TEST ###
    if [ "$2" = "armv7l" ]; then
        local local_run=$(docker run -d --name "$1" --device=/dev/serial:/dev/serial:rw -v /home/admin/telegraf.conf:/etc/telegraf/telegraf.conf:ro arm32v7/telegraf:latest)
    elif [ "$2" = "x86_64" ]; then
        local local_run=$(docker run -d --restart unless-stopped --name "$1" --device=/dev/ttyUSB0:/dev/serial:rw -v /home/edge/telegraf.conf:/etc/telegraf/telegraf.conf:ro telegraf:latest)
    else
        echo "Onboarding status: Error: Can't resolve architecture!" >> midlog.txt > /dev/stderr
    fi
    ### TEST ###

    
    
    
    
    wait
    echo "Onboarding status: "$1" container started" >> midlog.txt
    echo "$local_run"
}

run_influx () {


    
    
    ### TEST ###
    if [ "$2" = "armv7l" ]; then
        local local_run=$(docker run -d --name "$1" -p 8086:8086 -e INFLUXDB_ADMIN_USER=admin -e INFLUXDB_ADMIN_PASSWORD=wago -e INFLUXDB_MONITOR_STORE_ENABLED=FALSE -v influx-vol-data:/var/lib/influxdb -v /home/admin/influxdb.conf:/etc/influxdb/influxdb.conf -v /home/admin/influxdb-init.iql:/docker-entrypoint-initdb.d/influxdb-init.iql arm32v7/influxdb:latest -config /etc/influxdb/influxdb.conf)
    elif [ "$2" = "x86_64" ]; then
        local local_run=$(docker run -d --restart unless-stopped --name "$1" -p 8086:8086 -e INFLUXDB_ADMIN_USER=admin -e INFLUXDB_ADMIN_PASSWORD=wago -e INFLUXDB_MONITOR_STORE_ENABLED=FALSE -v influx-vol-data:/var/lib/influxdb -v /home/edge/influxdb.conf:/etc/influxdb/influxdb.conf -v /home/edge/influxdb-init.iql:/docker-entrypoint-initdb.d/influxdb-init.iql influxdb:1.8 -config /etc/influxdb/influxdb.conf)
    else
        echo "Onboarding status: Error: Can't resolve architecture!" >> midlog.txt > /dev/stderr
    fi
    ### TEST ###
    
    
    wait
    echo "Onboarding status: "$1" container started" >> midlog.txt
    echo "$local_run"
}

run_grafana () {


    echo "DEBUG: $2" >> midlog.txt

    
    ### TEST ###
    if [ "$2" = "armv7l" ]; then
        local local_run=$(docker run -d --name "$1" -p 3000:3000 -v grafana-vol-data:/var/lib/grafana grafana/grafana:latest)
    elif [ "$2" = "x86_64" ]; then
        local local_run=$(docker run -d --restart unless-stopped --name "$1" -p 3000:3000 -v grafana-vol-data:/var/lib/grafana grafana/grafana:latest)
    else
        echo "Onboarding status: Error: Can't resolve architecture!" >> midlog.txt > /dev/stderr
    fi
    ### TEST ###
    
    
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

# NOT USED
# NB! Archtecture not implemented
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

    echo "$local_rmi"
}

install_image () {
    # Do not hide output
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
                "Onboarding status: "$1" container has status unknown status (is it removed?)" >> midlog.txt
                local stat_con="unknown"
                ;;
        esac
    else
        echo "Onboarding status: "$1" container not found.." >> midlog.txt
        local stat_con="unknown"
    fi
    echo "$stat_con"
}

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

change_ip () {

    filename="telegraf.conf"
    local influx_status="false"
    local grafana_status="false"

    # local IP
    local ip=$(ip route get 8.8.8.8 | awk '{ print $7; exit }')
    echo "Onboarding status: Current IP address controller: $ip"  >> midlog.txt

    # Influx IP in telegraf.conf
    local url_influx=$(grep -m 1 "urls" telegraf.conf | awk {'print $3'})
    local url_influx_lenght=$(echo ${#url_influx})
    local start_influx_cut=10
    local end_influx_cut=$(($url_influx_lenght - 7)) 
    local ip_influx=$(grep -m 1 "urls" telegraf.conf | awk {'print $3'} | cut -c $start_influx_cut-$end_influx_cut)

    echo "Onboarding status: Current IP to influx in telegraf.conf is: $ip_influx"  >> midlog.txt

    if [ "$ip" != "$ip_influx" ]; then
        echo "Onboarding status: Changing influxdb IP in telegraf.conf from $ip_influx to $ip"  >> midlog.txt
        sed -i 's|'"$ip_influx"'|'"$ip"'|g' telegraf.conf
        influx_status="true"
    else
        echo "Onboarding status: Keeping current Influxdb IP"  >> midlog.txt
    fi

    # Grafana IP in telegraf.conf
    url_grafana=$(grep "ws" telegraf.conf | awk {'print $3'})
    url_grafana_lenght=$(echo ${#url_grafana})
    start_grafana_cut=7
    end_grafana_cut=$(($url_grafana_lenght - 38))  
    ip_grafana=$(grep "ws" telegraf.conf | awk {'print $3'} | cut -c $start_grafana_cut-$end_grafana_cut)

    echo "Onboarding status: Current IP to Grafana in telegraf.conf is: $ip_grafana"  >> midlog.txt

    if [ "$ip" != "$ip_grafana" ]; then
        echo "Onboarding status: Changing influxdb IP in telegraf.conf from $ip_grafana to $ip"  >> midlog.txt
        sed -i 's|'"$ip_grafana"'|'"$ip"'|g' telegraf.conf
        grafana_status="true"
    else
        echo "Onboarding status: Keeping current Grafana IP"  >> midlog.txt
    fi
    
    # return
    if [ "$influx_status" == "true" ] && [ "$grafana_status" == "true" ]; then
        echo "true"
    else
        echo "false"
    fi
  
}


mid_conf () {

    local user_amount=$1
    user_amount=$((user_amount - 1))
    echo "Onboarding status: Requested amount of mids from user: $1" >> midlog.txt

    # Amount of excisting requests
    local modbus=$(grep -ow "inputs.modbus.request" telegraf.conf | wc -l)

    if [ $modbus = 1 ]; then
    
        local field_start=$(awk '/fields/ {print FNR}' telegraf.conf)
        local field_start=$((field_start + 1))
        local line_start=$(awk '/inputs.modbus.request/ {print FNR}' telegraf.conf)
        local line_start=$(($line_start -1))
        local amount=$(awk "NR >= $line_start" telegraf.conf | awk '/address/ {print NR":"}' | awk 'END { print NR }')
        local fields_end=$(( $field_start + $amount ))
        local lenght=$(( fields_end - line_start ))

     
        local new_request_start=$(($fields_end + 1))
        local new_request_end=$(($new_request_start + $lenght + 1))

        
        local space_pos=$fields_end
        local space_line="\ \ "

        for j in $(eval echo "{1..20}")
        do
            sed -i -e "${space_pos}a$space_line" telegraf.conf
            space_pos=$(( $fields_end + $j ))
        done

        local count_old=$line_start
        local count_new=$new_request_start

        for k in $(eval echo "{1..$user_amount}")
        do
            for i in $(eval echo "{1..$lenght}")
            do
                count_old=$(( $line_start + $i))
                request=$(awk "NR >= $count_old && NR <= $count_old" telegraf.conf)

                if [[ "$request" == *"slave_id"* ]]; then
                    old_mb_Addr=$(echo "$request" | grep "slave_id" | awk {'print $3'})
                    new_mb_addr=$((k+1))
                    modified_line=${request//$old_mb_Addr/$new_mb_addr}
                    echo "Onboarding status: Modbus address field modified from $old_mb_Addr to $new_mb_addr"  >> midlog.txt
                    request=$modified_line
                fi
               
                sed -i -e "${count_new}a$request" telegraf.conf
                count_new=$(($new_request_start + $i))

            done
            new_request_start=$count_new
        done
    else
        echo please change telegraf.conf to have 1 request
    fi
}


configure_grafana () {

    local ip=$1
    local user=$2
    local password=$3
    local org=$4

    local cnt_wait="1"
    local server_listen="";
 
    while [ "$server_listen" == "" ] && [ "$cnt_wait" -le "10" ]; do
        echo "Onboarding status: Waiting for Grafana to start.." >> midlog.txt
        local logs="$(docker logs grafana --tail 10)"
        echo "Onboarding status: Grafana logs: $logs"  >> midlog.txt
        server_listen=$(echo $logs | grep "HTTP Server Listen")
        echo "Onboarding status: Reading logs for "HTTP Server Listen": $server_listen"  >> midlog.txt
        cnt_wait=$((cnt_wait+1))
        sleep 10
    done
    sleep 5
    echo "Onboarding status: Grafana up!" >> midlog.txt

    echo "Onboarding status: Grafana: Creating organization: $org"  >> midlog.txt

    local res=$(curl -X POST -H "Content-Type: application/json" -d '{"name":"'$org'"}' http://$user:$password@$ip:3000/api/orgs) >> midlog.txt
    wait
    echo "Onboarding status: Grafana: result: $res"  >> midlog.txt

    if [ "$res" != "" ]; then

        local id=$(echo "$res" | grep "Organization created" | awk {'print $2'} | cut -c 18-19)
        wait
        local cnt=$(echo ${#id})

        if [ "$cnt" > "1" ]; then
            local temp=$(echo "$id" | grep "}")
            if [ "$temp" != "" ]; then  
                id=$(echo "$res" | grep "Organization created" | awk {'print $2'} | cut -c 18-18)
            fi
        fi

        if [ "$id" != "" ]; then
            echo "Onboarding status: Grafana: Organization $org created with id $id"  >> midlog.txt
            echo "Onboarding status: Grafana: Switching organization.."  >> midlog.txt

            res=$(curl -X POST http://$user:$password@$ip:3000/api/user/using/$id)
            wait
            echo "Onboarding status: Grafana: result: $res"  >> midlog.txt
            temp=$(echo "$res" | grep "Active organization changed" | cut -c 13-39) 

            if [[ "$temp" == "Active organization changed" ]]; then
                echo "Onboarding status: Grafana: Organization $org changed successfully"  >> midlog.txt
                echo "Onboarding status: Grafana: reading token.."  >> midlog.txt

                res=$(curl -X POST -H "Content-Type: application/json" -d '{"name":"apikeycurl", "role": "Admin"}' http://$user:$password@$ip:3000/api/auth/keys)
                wait
                echo "Onboarding status: Grafana: result: $res"  >> midlog.txt
                temp=$(echo "$res" | grep "apikeycurl" | cut -c 36-150)
                cnt=$(echo ${#temp})
                local token=$(echo $temp| cut -c 1-$((cnt-1)))
                echo "Onboarding status: Grafana: token is: $token"  >> midlog.txt

                local old=$(grep "Bearer" telegraf.conf | awk {'print $4'})
                echo "Onboarding status: Changing grafana token in telegraf.conf from $old to $token"  >> midlog.txt
                #sed -i 's|'"$old"'|'"$token"'"''|g' telegraf.conf
                sed -i 's|'"$old"'|'"$token"'|g' telegraf.conf

                echo "grafana configured"
            fi
        fi
    else
       echo "Onboarding status: Can't connect to Grafana. Onboarding is cancelled. See log for more information."  > /dev/stderr
       echo "Onboarding status: No connection to Grafana? result is: $res" >> midlog.txt 
    fi
}








# Remaining: 
# add edge pc

# save original
ret="$(cp telegraf.conf telegraf_copy.conf)"
wait

echo "Logging to file /home/admin/midlog.txt" > midlog.txt > /dev/stderr

arch=$(uname -m)
echo "Architecture is $arch" >> midlog.txt 

# Force removal of containers and volumes, keep images.
if [ "$1" = "--clean" ]; then
    echo "Onboarding status: Forced removal of MID TIG stack" >> midlog.txt > /dev/stderr
    echo "Onboarding status: Stopping containers" >> midlog.txt > /dev/stderr 
    docker stop $(docker ps -a -q)
    wait
    echo "Onboarding status: Removing containers" >> midlog.txt > /dev/stderr
    docker rm $(docker ps -a -q)
    wait
    #docker rmi $(docker images -a -q)
    #wait
    echo "Onboarding status: Removing grafana-vol-data" >> midlog.txt > /dev/stderr    
    docker volume rm grafana-vol-data
    wait
    echo "Onboarding status: Removing influx-vol-data" >> midlog.txt > /dev/stderr
    docker volume rm influx-vol-data
    wait
    # retrieve original file
    ret="$(cp telegraf_copy.conf telegraf.conf)"
    wait
    echo "*****************************************************"
    echo "Onboarding status: Cleaning finnished" >> midlog.txt > /dev/stderr
    echo "Onboarding status: Run ./onboard -help for information" > /dev/stderr  
    echo "******************************************************"
elif [ "$1" = "-help" ] ||  [ "$1" = "-h" ]; then
    echo " "
    echo "  Version: $version"
    echo "  Usage: onboarding [options]"
    echo "  "
    echo "  [options]":
    echo "      number: amount of MID meeters 1-10"
    echo "      --clean: stop and remove containers and volumes. Keep images."
    echo "  "
else 

    if [ "$arch" = "armv7l" ]; then
        chmod ugo+rw /dev/serial
    elif [ "$arch" = "x86_64" ]; then


        # MUST CHECK IF EXCISTS!!! else abort....
        chmod ugo+rw /dev/ttyUSB0
    
    
    
    
    else
        echo "Onboarding status: Error: Can't resolve architecture!" >> midlog.txt > /dev/stderr
    fi

    if [ "$1" = "1" ]; then
        echo "Onboarding status: Selected amount of mids allready configured in Telegraf.conf" >> midlog.txt
        onboard="$(check_containers "telegraf" "influx" "grafana")" 
    else 
        if  [ "$1" -gt "0" ] && [ "$1" -le "10" ]; then
            # save original
            ret="$(cp telegraf.conf telegraf_copy.conf)"
            wait
            mid_conf=$(mid_conf "$1")
            onboard="$(check_containers "telegraf" "influx" "grafana")"
        else
            echo "Onboarding status: Please choose between 1 and 10" > midlog.txt > /dev/stderr 
        fi
    fi
fi









case "$onboard" in 

    "???")  # Install Telegraf + Influx + Grafana (default)

        echo "Onboarding status: No MID TIG stack found" >> midlog.txt > /dev/stderr
        
    while true; do
    read -p "Do you want install? (y/n) " yn

        case $yn in 

            [yY] ) echo "Onboarding status: Please wait.. keep calm, this could take several minutes" 

                # GRAFANA (start Grafana first- issuetracker)
                image=$(check_image "grafana")
                if [ "$image" = "false" ]; then



                    ### TEST ###
                    if [ "$arch" = "armv7l" ]; then
                        ret="$(install_image "grafana/grafana:latest")"
                        echo "Onboarding status: Docker image for "$ret" pulled"
                    elif [ "$arch" = "x86_64" ]; then
                        ret="$(install_image "grafana/grafana:latest")"
                        echo "Onboarding status: Docker image for "$ret" pulled"
                    else
                        echo "Onboarding status: Error: Can't resolve architecture!" >> midlog.txt > /dev/stderr
                    fi
                    ### TEST ###



                else
                    return_container_stat="$(inspect "grafana")"

                    if [ "$return_container_stat" = "running" ]; then
                        ret="$(docker stop grafana)"
                        echo "Onboarding status: Grafana container stopped" >> midlog.txt
                        wait
                    fi
                    if [ "$return_container_stat" = "unknown" ]; then
                        echo "Onboarding status: Remove Grafana could not be executed.." >> midlog.txt
                    else
                        ret=$(remove_container "Grafana")
                        echo "Onboarding status: "$ret" container removed"
                    fi
                fi

                ret="$(create_volume "grafana-vol-data")"



                    
                ### TEST ###
                ret="$(run_grafana "grafana" "$arch")"
                ### TEST ###



                echo "Onboarding status: Grafana container started"   
                
                ip_addr=$(ip route get 8.8.8.8 | awk '{ print $7; exit }')
                ret="$(configure_grafana "$ip_addr" "admin" "admin" "wago")"

                if [ "$ret" = "grafana configured" ]; then

                    # INFLUX

                    # Install image
                    image=$(check_image "influx")
                    if [ "$image" = "false" ]; then



                        ### TEST ###
                        if [ "$arch" = "armv7l" ]; then
                            ret="$(install_image "arm32v7/influxdb:latest")"
                            echo "Onboarding status: Docker image for "$ret" pulled"
                        elif [ "$arch" = "x86_64" ]; then
                            ret="$(install_image "influxdb:1.8")"
                            echo "Onboarding status: Docker image for "$ret" pulled"
                        else
                            echo "Onboarding status: Error: Can't resolve architecture!" >> midlog.txt > /dev/stderr
                        fi
                         ### TEST ###
               
                        
                    else
                        return_container_stat="$(inspect "influx")"
                        # If running, stop it
                        if [ "$return_container_stat" = "running" ]; then
                            ret="$(docker stop influx)"
                            echo "Onboarding status: Influx container stopped" >> midlog.txt
                            wait
                        fi
                        # Remove container 
                        if [ "$return_container_stat" = "unknown" ]; then
                            echo "Onboarding status: Remove Influx could not be executed.." >> midlog.txt
                        else
                            ret=$(remove_container "influx")
                            echo "Onboarding status: "$ret" container removed"
                        fi
                    fi
                    
                    ret="$(create_volume "influx-vol-data")"

                    # Run container 


                    ### TEST ###                    
                    ret="$(run_influx "influx" "$arch")"
                    ### TEST ###



                    echo "Onboarding status: Influx container started"   



                    # TELEGRAF
                    image=$(check_image "telegraf")
                    if [ "$image" = "false" ]; then




                        ### TEST ###
                        if [ "$arch" = "armv7l" ]; then
                            ret="$(install_image "telegraf:latest")"
                            echo "Onboarding status: Docker image for "$ret" pulled"
                        elif [ "$arch" = "x86_64" ]; then
                            ret="$(install_image "telegraf:latest")"
                            echo "Onboarding status: Docker image for "$ret" pulled"
                        else
                            echo "Onboarding status: Error: Can't resolve architecture!" >> midlog.txt > /dev/stderr
                        fi
                         ### TEST ###                    
                        
                    
                    
                    
                    
                    
                    else
                        return_container_stat="$(inspect "telegraf")"

                        if [ "$return_container_stat" = "running" ]; then
                            ret="$(docker stop telegraf)"
                            echo "Onboarding status: Telegraf container stopped" >> midlog.txt
                            wait
                        fi
                        if [ "$return_container_stat" = "unknown" ]; then
                            echo "Onboarding status: Remove Telegraf could not be executed.." >> midlog.txt
                        else
                            ret=$(remove_container "telegraf")
                            echo "Onboarding status: "$ret" container removed"
                        fi
                    fi


                    ### TEST ###
                    ret="$(run_telegraf "telegraf" "$arch")"
                    ### TEST ###


                    echo "Onboarding status: Telegraf container started"    
                fi     
                
                exit;;

            # No - exit the case
            [nN] ) echo "exiting.." 
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
    "TIG") # Stack present
        echo Onboarding status: a complete MID TIG stack is allready present >> midlog.txt > /dev/stderr 
        echo "Please run "./onboarding.sh force" to re-install stack)" > /dev/stderr
        ;;
esac

echo "Onboarding status: Finnished" >> midlog.txt > /dev/stderr


