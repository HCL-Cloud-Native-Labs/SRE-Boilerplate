## Install k3s on Ubuntu 18.04 LTS 

### Step1: `To install K3s on a one node cluster you simply have to run the following command with root privileges:`

This will install the K3s binary under /usr/local/bin/k3s and create multiple symlinks to that binary. The installer will also create a Systemd service unit and start the service with each boot:

	systemctl status k3s.service

		

