# devopsfetch.sh
A tool for devops named devopsfetch that collects and displays system information
Including active ports, user logins, Nginx configurations, Docker images, and container statuses. 

It also Implement a `systemd` service to monitor and log activities continuously.

```sh
#!/bin/bash
# INSTALLATION
# ...

bash ./install.sh

# After install exit terminal and open a new terminal and run
bash devopsfetch -h
```

## CLI & Usage

### PORTS

```sh
# - Display all active ports and services (-p or --port)
# - Provide detailed information about a specific port (-p <port_number>)

# Examples:

bash devopsfetch -p

bash devopsfetch -p 5000
```

### Docker

```sh
# - List all Docker images and containers (-d or --docker)
# - Provide detailed information about a specific container (-d <container_name>)

# Examples:

bash devopsfetch -d

bash devopsfetch -d docker_name
```

### PORTS

```sh
# - Display all active ports and services (-p or --port)
# - Provide detailed information about a specific port (-p <port_number>)

# Examples:

bash devopsfetch -p

bash devopsfetch -p 5000
```

### Nginx

```sh
# - Display all Nginx domains and their ports (-n or --nginx)
# - Provide detailed configuration information for a specific domain (-n <domain>)

# Examples:

bash devopsfetch -n

bash devopsfetch -n nginx_domain
```

### Users

```sh
# - List all users and their last login times (-u or --users)
# - Provide detailed information about a specific user (-u <username>)

# Examples:

bash devopsfetch -u
bash devopsfetch -u root
```

### Time Range

```sh
# - Display activities within a specified time range (-t or --time)

# Examples:

bash devopsfetch -t
bash devopsfetch -t 2024-07-14
```


```sh
#!/bin/bash
# uninstall
# ...

bash ./uninstall.sh

```