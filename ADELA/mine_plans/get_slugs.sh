#! /bin/bash

# Obtener Slugs
for i in `seq 10`; do page="http://adela.datos.gob.mx/api/v1/organizations?page=$i"; curl -Ls $page | jq '.["results"][]["slug"]' >> slugs.txt; done
# Obtener ligas
for i in `cat slugs.txt`; do echo $i | sed 's/"//g' | awk '{print "http://adela.datos.gob.mx/"$1"/plan.json"}' >> urls.txt ;done
# Obtener planes
# for i in `cat urls.txt`; do curl -Ls $i | jq '.' | wc -l >> lines.txt; done
