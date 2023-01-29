#!/usr/bin/env bash

# Prerequisites, e.g. on Debian 11:
# apt install dnsutils net-tools

### Constant declarations ###

GOOGLEDNS1="8.8.8.8"
GOOGLEDNS2="8.8.4.4"

CLOUDFLAREDNS1="1.1.1.1"
CLOUDFLAREDNS2="1.0.0.1"

QUAD9DNS1="9.9.9.9"
QUAD9DNS2="149.112.112.112"

### Variable declarations ###

THISSCRIPTPATH=$(readlink -f $0)
THISDIRPATH=$(dirname $THISSCRIPTPATH)
SUBSCRIPT=$THISDIRPATH/.scripts

DOMAIN=$1

LOCALDNSFROMRESOLVCONF=`grep -E -o "([0-9]{1,3}[\.]){3}[0-9]{1,3}" /etc/resolv.conf | tail -1`
LOCALDNSFROMRESOLVCONFHOSTNAME=`dig -x $LOCALDNSFROMRESOLVCONF +short | tail -1`

LOCALNETWORKGATEWAY=`netstat -rn | awk '{if($1=="default" || $1=="0.0.0.0" ) print $2}' | head -1`
LOCALNETWORKGATEWAYHOSTNAME=`dig -x $LOCALNETWORKGATEWAY +short | tail -1`

### Procedures ###

if [ -z "$1" ] || [ $# != 1 ]; then
  echo "Please append one hostname or IP address"
  exit 1
fi

$SUBSCRIPT/check-for-software-existence.sh nslookup netstat dig

$SUBSCRIPT/highlighted-output.sh "Check Google DNS"

nslookup $DOMAIN $GOOGLEDNS1 #| grep --color=always 'SERVFAIL\|$' 
nslookup $DOMAIN $GOOGLEDNS2 #| grep --color=always 'SERVFAIL\|$' 

$SUBSCRIPT/highlighted-output.sh "Check Cloudflare DNS"

nslookup $DOMAIN $CLOUDFLAREDNS1 #| grep --color=always 'SERVFAIL\|$' 
nslookup $DOMAIN $CLOUDFLAREDNS2 #| grep --color=always 'SERVFAIL\|$' 

$SUBSCRIPT/highlighted-output.sh "Check Quad9 DNS"

nslookup $DOMAIN $QUAD9DNS1 #| grep --color=always 'SERVFAIL\|$' 
nslookup $DOMAIN $QUAD9DNS2 #| grep --color=always 'SERVFAIL\|$' 

$SUBSCRIPT/highlighted-output.sh "Check local DNS"
$SUBSCRIPT/highlighted-output.sh "Requesting DNSv4 server from resolv.conf: $LOCALDNSFROMRESOLVCONF ($LOCALDNSFROMRESOLVCONFHOSTNAME)"

nslookup $DOMAIN $LOCALDNSFROMRESOLVCONF #| grep --color=always 'SERVFAIL\|$' 

$SUBSCRIPT/highlighted-output.sh "Requesting local network gateway for DNS: $LOCALNETWORKGATEWAY ($LOCALNETWORKGATEWAYHOSTNAME)"

nslookup $DOMAIN $LOCALNETWORKGATEWAY #| grep --color=always 'SERVFAIL\|$' 