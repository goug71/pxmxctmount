# pxmxctmount
Proxmox CT Alternate MountPoint scan for Influx

This script 
 - parses running CTs, then
 - checks for extra MountPoints,
 - attach to each CT with extramountpount and
 - run df on them, then
 - formats the output for direct influx upload

It also comes with a systemd unit and a default config (as shell parameters) file

TODO : packaging, maybe...
