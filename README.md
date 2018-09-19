
Before delving into the maddness below, make sure you haven't missed any of this awesomeness:

- https://www.spinnaker.io/setup/bakery/ 
- https://github.com/docker/infrakit


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
     - re-import network config
       - touch /etc/vmware/placeholder && vmware-networks --migrate-network-settings /etc/vmware/placeholder && vmware-networks --start && rm /etc/vmware/placeholder
     - service vmware restart
     - vmware player host also running Docker.  Until using the netcfg tool to specify the bridging network (vmnet0), I wasn't sure if the docker0 device was in conflict.  To elimate that possibility, stopped Docker and removed ```ip link del docker0``` the docker0 device (also ```nmcli connection delete docker0``` if NetworkManager is in the mix).
     - after a later RedHat kernel update for EL7.4 reached my CentOS host, vmware would no longer start.  My particular combination of EL7 kernel and VMWare version matched this vmware community thread: https://communities.vmware.com/thread/567498 .  Working through that ( a patch community.vmware.com member "dariusd" - thank you! - to compat_netdevice.h in the vmnet module ) resolved the issue.  It went something like:

```
vmware_libdir=$(awk '$1~/^libdir/{print $3}' /etc/vmware/config | xargs echo)
if test -f ${vmware_libdir}/modules/source/vmnet.tar
then
mkdir ~/vmnet-fix
cd ~/vmnet-fix
curl -kROL https://communities.vmware.com/servlet/JiveServlet/download/2686431-179601/VMware-Workstation-12.5.7-vmnet-RHEL74.patch.zip
unzip -o VMware-Workstation-12.5.7-vmnet-RHEL74.patch.zip
unalias cp && cp -f ${vmware_libdir}/modules/source/vmnet.tar ./vmnet-12.5.7.tar
tar xf vmnet-12.5.7.tar
yum -y install patch
patch -p0 < ~/vmnet-fix/VMware-Workstation-12.5.7-vmnet-RHEL74.patch
tar cf vmnet.tar vmnet-only/
sudo cp vmnet.tar ${vmware_libdir}/modules/source/vmnet.tar
sudo vmware-modconfig --console --install-all
else
echo vmware_libdir evaluated to \"${vmware_libdir}\" and ${vmware_libdir}/modules/source/vmnet.tar does not exist
fi
```


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
