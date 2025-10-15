# To install Prometheus on Ubuntu, download the latest binary, create a dedicated user and directories, move the files, set correct ownership, and create a systemd service file to run it as a service. After installation, you can access the web interface at http://&lt;your_server_ip&gt;:9090 to start configuring it. [1, 2, 3, 4]  
# Step 1: Update and install necessary tools [2, 5]  
First, update your package list and install curl or wget if they are not already present. [6, 7]  
sudo apt update
sudo apt install curl wget

# Step 2: Create a system user and directories [2]  
Create a user for Prometheus to run as and create the necessary directories. [1, 2, 3]  
sudo useradd --no-create-home --shell /bin/false prometheus
sudo mkdir /etc/prometheus
sudo mkdir -p /var/lib/prometheus
sudo chown -R prometheus:prometheus /etc/prometheus
sudo chown -R prometheus:prometheus /var/lib/prometheus

# Step 3: Download and extract Prometheus [5, 8]  
Download the latest release from the official Prometheus website and extract it. [2, 3]  
# Find the latest version on https://prometheus.io/download/
# Example for a specific version:
wget https://github.com/prometheus/prometheus/releases/download/v2.45.0/prometheus-2.45.0.linux-amd64.tar.gz
tar -xvf prometheus-*.tar.gz
cd prometheus-*-linux-amd64

# Step 4: Install the Prometheus binaries [1]  
# Move the Prometheus binaries and configuration files to the correct locations and set their ownership to the prometheus user. [2, 3]  
sudo mv prometheus promtool /usr/local/bin/
sudo mv consoles console_libraries /etc/prometheus/
sudo mv prometheus.yml /etc/prometheus/
sudo chown -R prometheus:prometheus /etc/prometheus/consoles
sudo chown -R prometheus:prometheus /etc/prometheus/console_libraries

# Step 5: Create a systemd service file [5, 9]  
# Create a prometheus.service file to manage Prometheus as a system service. [1, 3, 10]  
sudo nano /etc/systemd/system/prometheus.service

# Add the following content to the file: 
# [Unit]
# Description=Prometheus
# Wants=network-online.target
# After=network-online.target

# [Service]
# User=prometheus
# Group=prometheus
# Type=simple
# ExecStart=/usr/local/bin/prometheus \
#     --config.file /etc/prometheus/prometheus.yml \
#     --storage.tsdb.path /var/lib/prometheus/ \
#     --web.console.templates=/etc/prometheus/consoles \
#     --web.console.libraries=/etc/prometheus/console_libraries

# [Install]
# WantedBy=multi-user.target

# Step 6: Start and enable the Prometheus service [4, 10, 11]  
Reload the systemd manager configuration, start the Prometheus service, and enable it to start on boot. [1, 2, 3]  
sudo systemctl daemon-reload
sudo systemctl start prometheus
sudo systemctl enable prometheus

Check the service status to ensure it is running correctly: [2, 5]  
sudo systemctl status prometheus

# Step 7: Access Prometheus 
# Open your web browser and go to http://&lt;your_server_ip&gt;:9090 to access the Prometheus web interface. [3, 4]  





