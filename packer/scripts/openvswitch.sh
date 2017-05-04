yum -y install libcap-ng checkpolicy selinux-policy-devel git nc wget curl perl gcc make python python-six python-devel openssl-devel kernel-devel kernel-headers graphviz kernel-debug-devel autoconf automake rpm-build redhat-rpm-config libtool
cd && mkdir -p openvswitch && cd openvswitch
rm -rf ovs
git clone https://github.com/openvswitch/ovs.git
cd ovs
git pull
major=$(git branch --list --all | grep remotes/origin/branch- | awk -F 'branch-' '{print $2}' | awk -F '.' '{print $1}' | uniq | sort -n | tail -1)
latestbranch=$(git branch --list --all | grep remotes/origin/branch-${major}. | sort -t . --key=2n | tail -1 | awk '{print $1}')
git checkout ${latestbranch}
basefilename="openvswitch-"$(grep -E "^AC_INIT" configure.ac | awk -F ',' '{print $2}' | awk '{print $1}')
./boot.sh
./configure
make
make clean
sed 's/openvswitch-kmod, //g' rhel/openvswitch.spec > rhel/openvswitch_no_kmod.spec
mkdir -p ~/rpmbuild/SOURCES/
(
	cd ..
	tar  --exclude=".git*" --transform "s/^ovs/$basefilename/" -zcvf ~/rpmbuild/SOURCES/${basefilename}.tar.gz ovs
) 
rpmbuild -bb --nocheck rhel/openvswitch_no_kmod.spec
ls -l ~/rpmbuild/RPMS/x86_64/
mkdir -p /dev/shm/rpm
cp -v ~/rpmbuild/RPMS/x86_64/*rpm /dev/shm/rpm
yum -y localinstall /dev/shm/rpm/"$basefilename"*rpm
echo 'pathmunge /usr/share/openvswitch/scripts/ovs-ctl' > /etc/profile.d/openvswitch.sh
chkconfig openvswitch on 
service openvswitch restart
cd && rm -rf openvswitch rpmbuild

