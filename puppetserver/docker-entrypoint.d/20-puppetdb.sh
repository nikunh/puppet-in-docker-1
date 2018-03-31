#!/bin/bash

#CN=$(hostname)
CN=${PUPPETSERVER_CERT_CN:-`hostname`}

PUPPETDB_URL=https://${PUPPETDB_SERVER_URL}/status/v1/services/puppetdb-status

if [ -n "$PUPPETDB_SERVER_URL" ]; then
  # Wait for PuppetDB API to be available
  while ! curl -s -f $PUPPETDB_URL \
          --cacert /etc/puppetlabs/puppet/ssl/certs/ca.pem \
          --cert /etc/puppetlabs/puppet/ssl/certs/${CN}.pem \
          --key /etc/puppetlabs/puppet/ssl/private_keys/${CN}.pem > /dev/null; do
    echo "---> Waiting for PuppetDB API at ${PUPPETDB_SERVER_URL}..."
    sleep 10
  done
  echo "---> PuppetDB ready at ${PUPPETDB_SERVER_URL}..."

#put here to copy created certificates to be accesible by k8s fully quallified domain name. Otheriwse puppetdb stays in accesible when puppet tries to connect with FQDN
cp ./etc/puppetlabs/puppet/ssl/certs/${CN}.pem /etc/puppetlabs/puppet/ssl/certs/`hostname -A`.pem
chown puppet /etc/puppetlabs/puppet/ssl/certs/`hostname -A`.pem
cp /etc/puppetlabs/puppet/ssl/private_keys/${CN}.pem /etc/puppetlabs/puppet/ssl/private_keys/`hostname -A`.pem
chown puppet /etc/puppetlabs/puppet/ssl/private_keys/`hostname -A`.pem



  if [ "${USE_LEGACY_PUPPETDB}" == "true" ]; then
    echo "---> Configuring Puppetserver to connect to PuppetDB (legacy config)"
    cat <<EOF>/etc/puppetlabs/puppet/puppetdb.conf
[main]
server = ${PUPPETDB_SERVER_URL}
port = 8081
EOF
  else
    echo "---> Configuring Puppetserver to connect to PuppetDB"
    cat <<EOF>/etc/puppetlabs/puppet/puppetdb.conf
[main]
server_urls = https://${PUPPETDB_SERVER_URL}
soft_write_failure = true
EOF
  fi
  puppet config set storeconfigs_backend puppetdb --section main
  puppet config set storeconfigs true --section main
  puppet config set reports puppetdb --section main
fi
