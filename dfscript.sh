#!/bin/sh

#This script gathers extra mountpoints from proxomx CT and feeds them to Influx
#default value should come from /etc/default/dfscript

INFLUX_PORT=${INFLUX_PORT:-8086}
INFLUX_ORG="${INFLUX_ORG:-MyOrg}"
INFLUX_BUCKET="${INFLUX_BUCKET:-MyBucket}"
INFLUX_PRECISION="${INFLUX_PRECISION:-s}"

if [ -z "${INFLUX_TOKEN}" ]
then
  echo "Missing INFLUX_TOKEN. Exiting..."
  exit 1
fi

if [ -z "${INFLUX_HOST}" ]
then
  echo "Missing INFLUX_HOST. Exiting..."
  exit 1
fi

node="$(hostname | cut -d. -f1)"

get_metrics() {
        pct list | 
                awk '$2=="running" {printf("%s %s\n", $1, $3)}' |
                while read ct name
                do 
                        pct config ${ct} |
                                grep -P '^mp\d+: ' |
                                sed 's/,/\n/g' |
                                egrep '^mp=' |
                                cut -d= -f2 |
                                lxc-attach -n ${ct} -- xargs -r df -B1 | 
                                awk -v ct="${ct}" -v name="${name}" -v node=${node} '
                        $1!="Filesystem" { 
                                printf("ct_disk,node=%s,ct_id=%d,ct_name=%s,dev=%s,mountpoint=%s size=%d,used=%d,avail=%d,percent=%02.2f\n",\
                                        node, ct, name,\
                                        $1, $6, $2, $3, $4,\
                                        $3 * 100 / $2\
                                );
                        }'&
                done | 
                        tee "$(mktemp /tmp/plux_XXXX)" |
                        curl -s --request POST \
                                "http://${INFLUX_HOST}:${INFLUX_PORT}/api/v2/write?org=${INFLUX_ORG}&bucket=${INFLUX_BUCKET}&precision=${INFLUX_PRECISION}" \
                                --header "Authorization: Token ${INFLUX_TOKEN}" \
                                --header "Content-Type: text/plain; charset=utf-8" \
                                --header "Accept: application/json" \
                                --data-binary @-
}

while sleep 10
do
        get_metrics
done
