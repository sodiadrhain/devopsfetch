#!/bin/bash
#
# install devopsfetch
#
# A tool for devops named devopsfetch that collects and displays system information, including active ports, user logins, Nginx configurations, Docker images, and container statuses. 
# Implement a systemd service to monitor and log these activities continuously.

user=$(whoami)
install_path=/home/$user/installations/devopsfetch

install_docker() {
    echo "--- installing docker"
    # Add Docker's official GPG key:
    sudo apt-get update
    sudo apt-get install ca-certificates curl
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc

    # Add the repository to Apt sources:
    echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update
    sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    # add user to docker group
    sudo usermod -aG docker $user

    # start docker
    sudo service docker start
}


install_nginx() {
    echo "--- installing nginx"
    sudo apt update
    sudo apt install nginx

    # start nginx
    sudo service nginx start
}

setup_systemd() {
    sudo bash -c "echo '
        [Unit]
        Description=DevopsFetch Service

        [Service]
        Type=oneshot
        ExecStart='bash $install_path/devopsfetch.sh'
        RemainAfterExit=yes

        [Install]
        WantedBy=multi-user.target' >> /etc/systemd/system/devopsfetch.service"

    # Enable and start the service
    sudo systemctl daemon-reload
    sudo systemctl start devopsfetch.service
    sudo systemctl enable devopsfetch.service
}

setup_logging() {
    touch /var/log/devopsfetch.log
    chmod 664 /var/log/devopsfetch.log
}

#  check if docker is installed else install it
if [[ ! $(docker -v | grep -w "Docker version") ]]; then
    echo "docker not installed"
    install_docker
fi


#  check if nginx is installed else install it
if [[ ! $(nginx -v | grep "nginx version") ]]; then
    echo "nginx not installed"
    install_nginx
fi

# start and create service
setup_systemd

# setup log file and path
setup_logging

# installation complete
# setup necessary commands
sudo chmod +x install.sh
sudo mkdir -p $install_path
sudo cp -R $(pwd)/. $install_path
sudo chmod +x $install_path/devopsfetch.sh

# check if exists bashrc in  installed
if [[ ! $(cat ~/.bashrc | grep -w devopsfetch) ]]; then
    echo  "alias devopsfetch='bash $install_path/devopsfetch.sh'" >> ~/.bashrc 
    source ~/.bashrc
fi
 
echo "Devopsfetch installed"
echo "command devopsfetch -h for help"

