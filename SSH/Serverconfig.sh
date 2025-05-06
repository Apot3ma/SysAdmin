sudo apt update -y
sudo apt upgrade -y
sudo apt install openssh-server -y
sudo systemctl restart ssh
systemctl status ssh

echo "Servidor establecido, ingrese en esta ip en el cliente"
hostname -I
