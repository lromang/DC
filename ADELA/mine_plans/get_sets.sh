#! /bin/bash

curl -Ls http://catalogo.datos.gob.mx/api/3/action/current_package_list_with_resources | jq '.["result"][] | {Inst: .["organization"]["title"], Dataset: .["name"], Desc: .["notes"], Published: .["metadata_created"], resources: .["resources"] | length}' | sed -e 's/{//g' -e 's/}//g' -e 's/"//g' -e 's/\\.*//g'| grep -vE "^$" | sed -e 's/^ +//g' -e 's/,$//g' > set_data.txt


