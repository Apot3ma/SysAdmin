#!/bin/bash
sudo apt-get update
sudo apt-get upgrade -y

#instalar y configurar vsftpd
sudo apt-get install vsftpd -y
sudo systemctl start vsftpd

