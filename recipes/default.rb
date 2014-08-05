package "apache2" do
	action :install
end

file "/var/www/html/boot.ipxe" do
	action :create
	content <<endipxe
#!ipxe		
kernel http://sjbs-server/boot/linux debian-installer/locale=en_US console-setup/ask_detect=false keyboard-configuration/modelcode=SKIP interface=auto netcfg/get_domain=knight.mcquaid.org preseed/url=http://sjbs-server/boot/preseed.cfg
initrd http://sjbs-server/boot/initrd.gz
boot
endipxe
end

bash "download_linux" do
	not_if do
		File.exists?("/var/www/html/boot/linux")
	end
	code <<-EOH
		mkdir /var/www/html/boot
		cd /var/www/html/boot
		wget http://archive.ubuntu.com/ubuntu/dists/trusty-updates/main/installer-i386/current/images/netboot/ubuntu-installer/i386/linux
		wget http://archive.ubuntu.com/ubuntu/dists/trusty-updates/main/installer-i386/current/images/netboot/ubuntu-installer/i386/initrd.gz
	EOH
end

file "/var/www/html/boot/preseed.cfg" do
	action :create
	content <<endpreseed
	d-i mirror/country string manual
	d-i mirror/protocol string http
	d-i mirror/http/hostname string sjbs-server:3142
	d-i mirror/http/directory string /ubuntu
	d-i mirror/http/proxy string
	
	d-i clock-setup/utc boolean true
	d-i time/zone string US/Eastern
	d-i clock-setup/ntp boolean true
	d-i clock-setup/ntp-server string sjbs-server
	
	d-i partman-auto/disk string /dev/sda
	d-i partman-auto/method string regular
	d-i partman-auto/choose_recipe select atomic
	d-i partman-partitioning/confirm_write_new_label boolean true
	d-i partman/choose_partition select finish
	d-i partman/confirm boolean true
	d-i partman/confirm_nooverwrite boolean true

	d-i passwd/user-fullname string Administrator
	d-i passwd/username string administrator
	d-i passwd/user-password password Magis123
	d-i passwd/user-password-again password Magis123
	d-i user-setup/encrypt-home boolean false

	d-i pkgsel/update-policy unattended-upgrades
	tasksel tasksel/first multiselect standard, xubuntu-desktop
	
	d-i grub-installer/only_debian boolean true

	d-i finish-install/reboot_in_progress note
	d-i debian-installer/exit/poweroff boolean true
endpreseed
end

package "apt-cacher-ng" do
	action :install
end

package "ntp" do
	action :install
end
