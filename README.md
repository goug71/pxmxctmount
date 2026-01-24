# pxmxctmount
Proxmox CT Alternate MountPoint scan for Influx

This script parses running CTs, then check for extra MountPoints, attach to each CT with extramountpount and run df on them, then formats the output to upload it to telegraf
It also comes with a systemd unit and a default config (as shell parameters) file

TODO : packaging, maybe...
