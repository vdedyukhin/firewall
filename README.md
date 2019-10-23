# Firewall scripts for RHEL & CentOS

(c) Niki Kovacs 2019 

This repository provides a variety of firewall template scripts for servers
running Red Hat Enterprise Linux or CentOS.

Three different contexts are covered:

  * `public`: Internet facing server 

  * `router`: LAN router

  * `simple`: standalone LAN server

Install the required `iptables` and `iptables-services` packages, since the
scripts rely on them.

Remove the conflicting `firewalld` package.

Choose the directory most suited to your configuration (`public`, `router` or
`simple`) and copy the `firewall.sh` script to a sensible location like your
`~/bin` directory. 

Edit the handful of variables at the beginning of the `firewall.sh`script to
adapt it to your network configuration.

You'll want to add some basic services like DNS, web, mail, etc. Check out a
section marked `# Add various services here #` in the script. The respective
`services` subdirectories provide template stubs for the most common services,
which you can copy and paste into the script. 

Start the firewall:

```
$ sudo ./firewall.sh --start
```

Stop the firewall:

```
$ sudo ./firewall.sh --stop
```

Display the current status:

```
$ sudo ./firewall.sh --status
```

The router version contains an extra `--nat` option which enables IP
masquerading without starting the firewall:

```
$ sudo ./firewall.sh --nat
```

Last but not least, the public server version properly integrates `fail2ban` if
it's installed on your system. 



