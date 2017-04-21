# packer vagrant vmware lab
<pre>
packer lab for nested+headless vmware player 12 for linux builds
    \-> vmware-iso -> OVA
    \-> vagrant postprocessor -> box file
</pre>

Notes related to provisioning a local environment for Vagrant use with parallel builds of an OVA for VMWare/ESX/ESXi/vSphere deployment.

CentOS 7 x86_64 minimal iso

```
yum -y install git zip unzip telnet tcpdump nginx netcat nc bind-utils xterm xorg-x11-font-utils xorg-x11-fonts-Type1 xauth strace qemu perl open-vm-tools nmap lsof kernel kernel-headers kernel-devel gcc epel-release
```

```
curl -kROL https://download3.vmware.com/software/player/file/VMware-VIX-1.15.7-5115892.x86_64.bundle
sudo sh VMware-VIX-1.15.7-5115892.x86_64.bundle --console --required --eulas-agreed

curl -kROL https://download3.vmware.com/software/player/file/VMware-Player-12.5.5-5234757.x86_64.bundle
sudo sh VMware-Player-12.5.5-5234757.x86_64.bundle --console --required --eulas-agreed
```

```
sudo sh -c 'echo -e "# Workstation 12.5.5\nws        19  vmdb  12.5.5 Workstation-12.0.0\nplayer    19  vmdb  12.5.5 Workstation-12.0.0" >> /usr/lib/vmware-vix/vixwrapper-config.txt'

```





ssh -XY to root@machine
	vmplayer
		UI prompts
		rebuild kernel modules
		
key piecies were:
 - updating the /usr/lib/vmware-vix/vixwrapper-config.txt with version that matchs 
 - after the X-forwarded vmplayer launch , rebuild kernel mods
 - ensure CPU virtualization features are enabled in the bios ( or virtual bios, as was my case - nested vmplayer)
 - in the exec chain ( not sure if it was packer->vmrun->--or->vmplayer ), linux.iso was expected to be located under /usr/lib/vmware/isoimages/ AS WELL as wherever the provisioner file source location ( relative to the current working directy of the packer executable was run from)
 - the yum updated kernel-headers did not match the running kernel-version, which the UI launched kernel mod link was referencing. after kernel was updated and kernel-headers were the same, then things ran
 


other notes for docker and hashicorp tool installs:
```
sudo yum install -y yum-utils
sudo yum remove docker docker-common container-selinux docker-selinux docker-engine
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo yum -y install docker-ce
```

# hashiupdate.sh is a total hack that I only expect to make my life easier for a few weeks.  It relies on the naming scheme and the fastly mirror index that existed at the moment the script was written. example use: 
```
hashiupdate.sh vagrant 
hashiupdate.sh packer
```
