#!/bin/sh

#  c7-elasticsearch1_4.sh
#  
#
#  Created by Andrea Guarise on 7/30/15.
#
# USes: ELDATADIR ELCLUSTERNAME ELMASTER ELTYPE
LOGFILE=/tmp/elasticsearch.log

CLUSTERNAME=t2-el

rpm --import https://packages.elasticsearch.org/GPG-KEY-elasticsearch >> $LOGFILE 2>&1

cat > /etc/yum.repos.d/elasticsearch.repo  << EOL
[elasticsearch-1.4]
name=Elasticsearch repository for 1.4.x packages
baseurl=http://packages.elasticsearch.org/elasticsearch/1.4/centos
gpgcheck=1
gpgkey=http://packages.elasticsearch.org/GPG-KEY-elasticsearch
enabled=1
EOL

yum -y install avahi-tools >> $LOGFILE 2>&1


if [[ "$ELTYPE" =~ "master" ]]; then
SERVICE_NAME="el-master-${CLUSTERNAME}"
cat > /etc/avahi/services/$SERVICE_NAME.service << EOL

<!-- See avahi.service(5) for more information about this configuration file -->

<service-group>

<name replace-wildcards="yes">%h</name>

<service>
<type>_$SERVICE_NAME._tcp</type>
<port>9200</port>
</service>

</service-group>
EOL

#open avahi port

firewall-cmd --zone=public --add-port=5353/udp --permanent >> $LOGFILE 2>&1
firewall-cmd --reload >> $LOGFILE 2>&1
fi


yum -y install elasticsearch >> $LOGFILE 2>&1

chkconfig --add elasticsearch >> $LOGFILE 2>&1

if [ -n "${ELCLUSTERNAME}" ]; then
echo "Using clustername specified by user: ${ELCLUSTERNAME}"
CLUSTERNAME=${ELCLUSTERNAME}
fi
NODENAME=`uname -n`
sed -e "s@#cluster.name: elasticsearch@cluster.name: ${CLUSTERNAME}@g;s@#node.name: .*\$@node.name: ${NODENAME}@g" /etc/elasticsearch/elasticsearch.yml > /etc/elasticsearch/elasticsearch.yml.new
mv -f /etc/elasticsearch/elasticsearch.yml.new /etc/elasticsearch/elasticsearch.yml

if [ -n "${ELDATADIR}" ]; then
echo "Using datadir specified by user: ${ELDATADIR}"
DATADIR=${ELDATADIR}
sed -e "s@#path.data: /path/to/data\$@path.data: ${DATADIR}/data@g;s@#path.work: /path/to/work@path.work: ${DATADIR}/work@g" /etc/elasticsearch/elasticsearch.yml > /etc/elasticsearch/elasticsearch.yml.new
    mv -f /etc/elasticsearch/elasticsearch.yml.new /etc/elasticsearch/elasticsearch.yml
    chown -R elasticsearch:elasticsearch ${DATADIR}
fi
if [ -z "${ELMASTER}" ]; then
echo "try with avahi" >> $LOGFILE 2>&1
ELMASTER=`avahi-browse -a -t -p -r | grep el-master | cut -f 8 -d ";" | tr '\n' ' ' | sed -e "s@\s*\(.*\)@\1@g"`
export ELMASTER
fi
if [ -n "${ELMASTER}" ]; then
echo "Setting master: ${ELMASTER}" >> $LOGFILE 2>&1
tmp=""
for i in ${ELMASTER[@]}; do tmp="\"$i\",$tmp"; done
elmaster=`echo $tmp |sed -e "s/\(.*\),$/\1/g"`
sed -e "s@#discovery.zen.ping.unicast.hosts: .*\$@discovery.zen.ping.unicast.hosts: [${elmaster}]@g" /etc/elasticsearch/elasticsearch.yml > /etc/elasticsearch/elasticsearch.yml.new
mv -f /etc/elasticsearch/elasticsearch.yml.new /etc/elasticsearch/elasticsearch.yml
fi
if [ -n "${ELTYPE}" ]; then
if [[ "$ELTYPE" =~ "master" ]]; then
     cat >> /etc/elasticsearch/elasticsearch.yml << EOL
node.master: true
node.data: false
EOL
fi
if [[ "$ELTYPE" =~ "data" ]]; then
cat >> /etc/elasticsearch/elasticsearch.yml << EOL
node.master: false
node.data: true
EOL
fi
if [ "$ELTYPE" = "client" ]; then
cat >> /etc/elasticsearch/elasticsearch.yml << EOL
node.master: false
node.data: false
EOL
fi
fi
chkconfig elasticsearch on >> $LOGFILE 2>&1
service elasticsearch start >> $LOGFILE 2>&1

firewall-cmd --zone=public --add-port=9200-9300/tcp --permanent
firewall-cmd --reload
