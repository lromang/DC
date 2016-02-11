#! /bin/bash

curl -Ls http://adela.datos.gob.mx/api/v1/catalogs | jq '.' | grep -E '"slug": .*,' | awk -F ':' '{print $2}' | sed -e 's/"//g' -e 's/,//g' > dependencies.txt && echo "inst_slug, inventario" > inventarios.csv;  echo "inst_slug, plan" > plans.csv
for i in `cat dependencies.txt`
do  
	inve=$(curl -Ls "http://adela.datos.gob.mx/$i/catalogo.json" | jq '.' | grep -oiE 'Inventario Institucional de Datos .*' | sed -e 's/"//g' -e 's/,//g' | uniq) 
	echo "$i, $inve" | grep -Ev ',[[:space:]]$' | grep '.*,' >> inventarios.csv
        plan=$(curl -Ls "http://adela.datos.gob.mx/$i/catalogo.json" | jq '.' | grep -oiE 'plan de apertura institucional .*' | sed -e 's/"//g' -e 's/,//g' | uniq) 
	echo "$i, $plan" |grep -Ev ',[[:space:]]$' | grep '.*,' >> plans.csv
done

