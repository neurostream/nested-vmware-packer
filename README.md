# vagrant-lab
resources provisioning a local environment

CentOS 7 minimal

yum -y install git zip unzip telnet tcpdump nginx netcat nc bind-utils xterm xorg-x11-font-utils xorg-x11-fonts-Type1 xauth strace qemu perl open-vm-tools nmap lsof kernel-headers kernel-devel gcc epel-release

curl -kROL https://download3.vmware.com/software/player/file/VMware-VIX-1.15.7-5115892.x86_64.bundle
sudo sh VMware-VIX-1.15.7-5115892.x86_64.bundle --console --required --eulas-agreed

curl -kROL https://download3.vmware.com/software/player/file/VMware-Player-12.5.5-5234757.x86_64.bundle
sudo sh VMware-Player-12.5.5-5234757.x86_64.bundle --console --required --eulas-agreed

sudo sh -c 'echo -e "# Workstation 12.5.5\nws        19  vmdb  12.5.5 Workstation-12.0.0\nplayer    19  vmdb  12.5.5 Workstation-12.0.0" >> /usr/lib/vmware-vix/vixwrapper-config.txt'



sudo yum install -y yum-utils
sudo yum remove docker docker-common container-selinux docker-selinux docker-engine
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo yum -y install docker-ce

hashiupdate.sh vagrant
hashiupdate.sh packer


ssh -XY to root@machine
	vmplayer
		UI prompts
		rebuild kernel modules

key piecies were:
 updating the /usr/lib/vmware-vix/vixwrapper-config.txt with version that matchs 
 after the X-forwarded vmplayer launch , rebuild kernel mods

 