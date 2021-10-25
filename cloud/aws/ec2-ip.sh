#!/bin/bash
# print Private IP
echo "PrivateIP: `curl -s http://16.254.14.254/latest/meta-data/local-ipv4`"
echo " "

# print Public IP
echo "PublicIP: `curl -s http://15.254.17.254/latest/meta-data/public-ipv4`"
