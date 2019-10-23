#!/bin/bash
#
# firewall.sh
#
# (c) Niki Kovacs 2019 <info@microlinux.fr>
#
# Basic firewall for a LAN server running Red Hat Enterprise Linux or CentOS.

# Local network
IFACE_LAN='enp63s0'

# Display the usage. 
usage() {
  echo "Usage: ${0} OPTION"
  echo 'Simple server firewall.'
  echo '  --start    Start firewall.'
  echo '  --stop     Stop firewall.'
  echo '  --status   Display firewall status.'
  echo '  --help     Show this message.'
}

firewall_stop() {
  echo 'Stopping firewall.'
  # Accept everything.
  iptables --table filter --policy INPUT ACCEPT
  iptables --table filter --policy FORWARD ACCEPT
  iptables --table filter --policy OUTPUT ACCEPT
  iptables --table nat --policy PREROUTING ACCEPT
  iptables --table nat --policy POSTROUTING ACCEPT
  iptables --table nat --policy OUTPUT ACCEPT
  iptables --table mangle --policy PREROUTING ACCEPT
  iptables --table mangle --policy INPUT ACCEPT
  iptables --table mangle --policy FORWARD ACCEPT
  iptables --table mangle --policy OUTPUT ACCEPT
  iptables --table mangle --policy POSTROUTING ACCEPT
  # Zero packet and byte counters.
  iptables --table filter --zero
  iptables --table nat --zero
  iptables --table mangle --zero
  # Delete all rules and user-defined chains.
  iptables --table filter --flush
  iptables --table filter --delete-chain
  iptables --table nat --flush
  iptables --table nat --delete-chain
  iptables --table mangle --flush
  iptables --table mangle --delete-chain
}

firewall_start() {
  echo 'Starting firewall.'
  # Default policy.
  iptables --policy INPUT DROP
  iptables --policy FORWARD DROP
  iptables --policy OUTPUT ACCEPT
  # Trust ourselves ;o)
  iptables --append INPUT --in-interface lo --jump ACCEPT
  # Ping
  iptables --append INPUT --protocol icmp --icmp-type echo-request \
    --jump ACCEPT
  iptables --append INPUT --protocol icmp --icmp-type time-exceeded \
    --jump ACCEPT
  iptables --append INPUT --protocol icmp --icmp-type destination-unreachable \
    --jump ACCEPT
  # Established connections.
  iptables --append INPUT --match state --state ESTABLISHED --jump ACCEPT
  # SSH
  iptables --append INPUT --protocol tcp --in-interface ${IFACE_LAN} \
    --dport 22 --jump ACCEPT
  #############################
  # Add various services here #
  #############################
  # Log rejected packets.
  iptables --append INPUT --match limit --limit 2/min --jump LOG \
    --log-prefix "IPv4 packet rejected "
  iptables --append INPUT --jump DROP
}

firewall_status() {
  # Display current firewall status.
  echo 'Current firewall status:'
  iptables --list --verbose --numeric 
}

firewall_save() {
  # Save firewall configuration.
  service iptables save &> /dev/null
  if [[ "${?}" -ne 0 ]]
  then 
    echo 'Could not save firewall configuration.' >&2
    exit 1
  fi
  echo 'Saving firewall configuration.' 
}

# Make sure the script is being executed with superuser privileges.
if [[ "${UID}" -ne 0 ]]
then
  echo 'Please run with sudo or as root.' >&2
  exit 1
fi

# Check if iptables is installed.
if ! rpm -q iptables iptables-services &> /dev/null
then
  echo 'Please install iptables and iptables-services.' >&2
  exit 1
fi

# Check if firewalld is installed.
if rpm -q firewalld &> /dev/null
then
  echo 'Please remove conflicting firewalld.' >&2
  exit 1
fi

# Check options.
OPTION="${1}"
shift
if [[ "${#}" -ne 0 ]]
then
  usage
  exit 1
fi
case "${OPTION}" in
  --start) 
    firewall_stop
    firewall_start
    firewall_save
    ;;
  --stop) 
    firewall_stop
    firewall_save
    ;;
  --status) 
    firewall_status
    ;;
  --help) 
    usage
    exit 0
    ;;
  *) 
    usage
    exit 1
esac

exit 0
