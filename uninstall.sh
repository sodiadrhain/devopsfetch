remove_nginx() {
    sudo systemctl stop nginx
    sudo apt-get remove nginx
    echo "--- nginx removed"
}

remove_docker() {
    sudo systemctl stop docker
    sudo apt-get purge docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-ce-rootless-extras
    sudo rm -rf /var/lib/containerd
    echo "--- docker removed"
}

remove_systemd() {
    service_name=devopsfetch.service
    sudo systemctl stop $service_name
    sudo systemctl disable $service_name
    sudo rm /etc/systemd/system/$service_name
    sudo rm /usr/lib/systemd/system/$service_name 
    sudo systemctl daemon-reload
    sudo systemctl reset-failed
}

# remove installed packages
remove_nginx
remove_docker
remove_systemd

# remove from bash
sudo chmod +x uninstall.sh
sed -i '/^alias devopsfetch/d' ~/.bashrc
source ~/.bashrc