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

This Packer -based runtime call stack looks like:


build.sh
  packer
    vmrun
      vmplayer
      
Key preparation to getting VMware Player -driven Packer builds on CentOS 7 Linux were:
 - updating the /usr/lib/vmware-vix/vixwrapper-config.txt with version that matchs 
 - after the X-forwarded vmplayer launch , rebuild kernel mods
 - ensure CPU virtualization features are enabled in the bios ( or virtual bios, as was my case - nested vmplayer)
 - in the exec chain ( not sure if it was packer->vmrun->--or->vmplayer ), linux.iso was expected to be located under /usr/lib/vmware/isoimages/ AS WELL as wherever the provisioner file source location ( relative to the current working directy of the packer executable was run from)
 - the yum updated kernel-headers did not match the running kernel-version, which the UI launched kernel mod link was referencing. after kernel was updated and kernel-headers were the same, then things ran
 - error message related to not being able to detect the IP address:
     - /usr/lib/vmware/bin/vmware-netcfg to rebuild vmnet devices at the standard instance numbers for each net type:
       - bridged network (VMnet0)
       - NAT network (VMnet8) ...seems to be something special about having vmnet8 in place
       - host-only network (VMnet1)
     - vmware-modconfig --console --install-all
     - service vmware restart
     


other notes for docker and hashicorp tool installs:
```
sudo yum install -y yum-utils
sudo yum remove docker docker-common container-selinux docker-selinux docker-engine
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo yum -y install docker-ce
```

hashiupdate.sh is a total hack that I only expect to make my life easier for a few weeks.
It relies on Hashicorp's naming scheme and the Fastly mirror indexing format that existed at the time of writing this and the script itself. Example use: 

```
hashiupdate.sh vagrant 
hashiupdate.sh packer
```


I'm using templates and provisioners from the boxcutter/centos repo.  good stuff.
