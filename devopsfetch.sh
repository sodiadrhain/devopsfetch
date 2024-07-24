#!/bin/bash
#
# devopsfetch
#
# A tool for devops named devopsfetch that collects and displays system information
# Including active ports, user logins, Nginx configurations, Docker images, and container statuses. 
# Implement a systemd service to monitor and log these activities continuously.

version="v1.0"
log_path=/var/log/devopsfetch.log

usage() {
    echo -e "--- Devopsfetch $version
Usage:
    [Ports]: 
        - Display all active ports and services (-p or --port)
        - Provide detailed information about a specific port (-p <port_number>)
        Examples:
            devopsfetch -p
            devopsfetch -p 5000

    [Docker]: 
        - List all Docker images and containers (-d or --docker)
        - Provide detailed information about a specific container (-d <container_name>)
        Examples:
            devopsfetch -d
            devopsfetch -d docker_name

    [Nginx]: 
        - Display all Nginx domains and their ports (-n or --nginx)
        - Provide detailed configuration information for a specific domain (-n <domain>)
        Examples:
            devopsfetch -n
            devopsfetch -n nginx_domain

    [Users]: 
        - List all users and their last login times (-u or --users)
        - Provide detailed information about a specific user (-u <username>)
        Examples:
            devopsfetch -u
            devopsfetch -u root
            
    [Time Range]: 
        - Display activities within a specified time range (-t or --time)
        Examples:
            devopsfetch -t
            devopsfetch -t 2024-07-14
"
}

get_ports() {
    # Provide detailed information about a specific port
    if [[ $@ != "" ]]; then
          echo "LIST OF RUNNING SERVICES ON PORT $@"
          echo
          printf "%-15s %-25s %-10s\n" "User" "Service" "Port"
          sudo lsof -i -P -n | grep $@ | awk '{ printf "%-15s %-25s %-10s\n", $3, $1, $9 }'
        log "gets port information for $@" 
        exit 0
    fi

    # Display all active ports and services
    echo "LIST OF ALL RUNNING SERVICES"
    echo
    printf "See all running ports and services below:\n"
      printf "%-15s %-25s %-10s\n" "User" "Service" "Port"
      sudo lsof -i -P -n | grep LISTEN | awk '{ printf "%-15s %-25s %-10s\n", $3, $1, $9 }'
    log "gets all runnning ports information"
}

get_docker() {
    # Provide detailed information about a specific container
    if [[ $@ != "" ]]; then
        echo "SHOWING INFORMATION FOR $@"
        echo
        docker inspect $@
        log "gets docker information for $@"
        exit 0
    fi

    # List all Docker images and containers
    echo "LIST OF ALL RUNNING DOCKER IMAGES"
    echo
    printf "%-30s %-20s %-25s\n" "Image Name" "Container ID" "Created At"
    docker ps --format "{{.Image}} {{.ID}} {{.CreatedAt}}" | awk '{ printf "%-30s %-20s %-25s\n", $1, $2, $3" "$4" "$5 }'
    log "gets all docker images"

    echo
    echo

    echo "LIST OF ALL DOCKER CONTAINERS"
    echo
    printf "%-30s %-20s %-25s\n" "Container Name" "Container ID" "Created At"
    docker ps -a --format "{{.Names}} {{.ID}} {{.CreatedAt}}" | awk '{ printf "%-30s %-20s %-25s\n", $1, $2, $3" "$4" "$5 }'
    log "gets all docker containers"
}

get_nginx() {
    # Provide detailed information about a specific domain
    if [[ $@ != "" ]]; then
        echo "LIST OF PORTS FOR DOMAIN: $@"
        echo
        printf "%-30s %-10s\n" "Domain Name" "Port"
        grep -r 'server_name\|listen' /etc/nginx/conf.d/ | awk -v domain="$@" '
        /server_name/ { 
        split($0, a, ":")
        file = a[1]
        gsub(/[ \t]*server_name[ \t]+/, "", $0)
        gsub(/[ \t]*;[ \t]*/, "", $0)
        domain_name = $0
        }
        /listen/ {
        split($0, a, ":")
        file = a[1]
        gsub(/[ \t]*listen[ \t]+/, "", $0)
        gsub(/[ \t]*;[ \t]*/, "", $0)
        port = $0
        if (domain_name == domain) {
            printf "%-30s %-10s\n", domain_name, port
            domain_name = ""
        }
        }'
        log "gets nginx information for $@"
        exit 0
    fi

    # Display all Nginx domains and their ports (-n or --nginx)
    echo "LIST OF ALL NGINX DOMAINS AND PORTS"
    echo
    printf "%-30s %-10s\n" "Domain Name" "Port"
    grep -r 'server_name\|listen' /etc/nginx/conf.d/ | awk '
    /server_name/ { 
      split($0, a, ":")
      file = a[1]
      gsub(/[ \t]*server_name[ \t]+/, "", $0)
      gsub(/[ \t]*;[ \t]*/, "", $0)
      domain = $0
    }
    /listen/ {
      split($0, a, ":")
      file = a[1]
      gsub(/[ \t]*listen[ \t]+/, "", $0)
      gsub(/[ \t]*;[ \t]*/, "", $0)
      port = $0
      if (domain != "") {
        printf "%-30s %-10s\n", domain, port
        domain = ""
      }
    }'
   log "gets all nginx domains and ports"
}

get_activity_user() {
    if [[ $@ != "" ]]; then
        # Provide detailed information about a specific user
        printf "Login activities for $@:\n"
        last $@
        log "gets user activities for $@"
    fi

    # List all users and their last login times
    echo "LIST OF USERS AND THEIR LAST LOGIN TIMES"
    echo
    printf "%-20s %-30s\n" "User" "Last Login Time"
    last $@ -F | awk '($1 !~ /^(reboot|wtmp|btmp)$/ && NF >= 7) { printf "%-20s %-30s\n", $1, $4" "$5" "$6" "$7" "$8 }' | uniq
    log "gets all users activities"
}

get_activity_time_range() {
    # Display activities within a specified time range as specified in the command passed
    if [[ $2 != "" ]]; then
        printf "Displaying activities between $1 and $2:\n"

        start=$(date -d "$1" +%s)
        end=$(date -d "$2 + 1 day" +%s)

        # Read through the log file and filter based on date range
        while IFS= read -r line; do
            log_date=$(echo "$line" | awk '{print $1}')
            log_time=$(echo "$line" | awk '{print $2}')
            log=$(date -d "$log_date $log_time" +%s)

            if [[ $log -ge $start && $log -le $end ]]; then
                echo "$line"
            fi
        done < $log_path

        log "gets log activities between $1 and $2"
        exit 0
    fi

    if [[ $1 != "" ]]; then
        printf "Displaying activity log for $1:\n"
        cat $log_path | grep $1
        log "gets all log activities $1"
        exit 0
    fi 

    printf "Displaying all log activities:\n"
    cat $log_path
    log "gets log activities"
}

log() {
    sudo bash -c "echo '$(date +'%Y-%m-%d %T') >> $(whoami) >> $@' >> $log_path"
}

main() {
    log "passed flag: $1"
    case "$1" in
        -p | --port ) get_ports $2;;
        -d | --docker ) get_docker $2;;
        -n | --nginx ) get_nginx $2;;
        -u | --users ) get_activity_user $2;;
        -t | --time ) get_activity_time_range $2 $3;;
        -h | --help ) usage;;
        * ) echo "[error] Invalid method '$1'" && usage;;
    esac
}


# entry point
main "$@"