#!/bin/bash

#Check if the respective folder structure exists with right permissions in /usr/local/etc/haproxy/ssl as this folder is being mounted via volume claim and might not be initialised.

mkdir -p /usr/local/etc/haproxy/ssl/
mkdir -p /usr/local/etc/haproxy/ssl/certificate_requests
mkdir -p /usr/local/etc/haproxy/ssl/certs
mkdir -p /usr/local/etc/haproxy/ssl/public_keys 
mkdir -p /usr/local/etc/haproxy/ssl/private_keys 
mkdir -p /usr/local/etc/haproxy/ssl/private 

chown -R haproxy:root /usr/local/etc/haproxy/ssl/
