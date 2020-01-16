# nixos-config-rpi
NixOS configuration for Raspberry Pi used in burn-in.


## Installation
Download the latest `NixOS` `aarch64` release from [1] (official, but
experimental). Note that this is officially termed as 'unstable', but should be
sufficient in our case. This branch can be used as a rolling release.

> This image relying on the raspberry pi foundation's kernel, and the raspberry
> pi foundation's boot chain, rather than our preferred u-boot based images using
> the mainline kernel.
>
> This specific image will not be kept for stable releases, and will be removed
> from Nixpkgs once a mainline-based u-boot-based generic image can boot on the
> raspberry pi 4.

Write the image to an SD card. In Linux, suppose we have a sdcard `mmcblk0`
with 2 partitions `mmcblk0p1` and `mmcblk0p1`, then we should write to
`mmcblk0`, **not** either of the partitions, with the following command:
```
sudo dd if=<nixos.img> of=/dev/mmcblk0
```

> On first boot, the rootfs will be automatically resized to use all available
> spaces of the SD card.

After the `dd` command is completed, mount the `/dev/mmcblk0p2` to `/mnt`:
```
sudo mount /dev/mmcblk0p1 /mnt
```

Then clone the `rpi4` NixOS configuration:
```
cd /mnt  # Choose the correct mount path if differs
mkdir -p etc/nixos
cd /etc/nixos
git init .
git remote add origin https://github.com/umd-lhcb/nixos-config-rpi
git fetch origin
git checkout rpi4
```

Then `umount` the SD card partition.


[1]: https://hydra.nixos.org/job/nixos/trunk-combined/nixos.sd_image_raspberrypi4.aarch64-linux


## System configuration
On first boot, set the password of root with:
```
sudo passwd root
```

Then switch to root user:
```
su
```

Now we reconfigure the system with our settings:
```
sudo nixos-rebuild switch
```

There might be some warnings and errors at this step. Ignore them. Reboot.
Now the user `lhcb` with `sudo` permission will be created.

Now we add the official `unstable` channel:
```
sudo nix-channel --add --add https://nixos.org/channels/nixos-unstable nixos
```

We can update the system with:
```
sudo nixos-rebuild switch --upgrade
```

If everything works, we can remove the old system generations with:
```
sudo nix-collect-garbage -d
```
