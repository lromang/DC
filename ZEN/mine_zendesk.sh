#! /bin/bash

### Remove previous data
##rm users.txt satisfaction_ratings.txt organizations.txt tickets.txt

##############################
####### Organizations ########
##############################
for i in $(seq $1)
do
    lines=$(curl -Ls "https://mxabierto.zendesk.com/api/v2/organizations.json?page=$i"  -v -u luis.roangarci@gmail.com:Ikidefenix131090 | jq '.["organizations"]' | wc -l)
    if [ $lines -gt 1 ]
       then
           curl -Ls "https://mxabierto.zendesk.com/api/v2/organizations.json?page=$i"  -v -u luis.roangarci@gmail.com:Ikidefenix131090 | jq '.["organizations"][] | {id: .["id"], name: .["name"], org_name: .["details"]}'  | sed -e 's/{//g' -e 's/}//g' -e 's/"//g'| grep -vE '^$' >> organizations.txt
    fi
done

##############################
########### Users ############
##############################
for i in $(seq $1)
do
    lines=$(curl -Ls "https://mxabierto.zendesk.com/api/v2/users.json?page=$i"  -v -u luis.roangarci@gmail.com:Ikidefenix131090 | jq '.["users"]' | wc -l)
    if [ $lines -gt 1 ]
    then
     curl -Ls "https://mxabierto.zendesk.com/api/v2/users.json?page=$i"  -v -u luis.roangarci@gmail.com:Ikidefenix131090 | jq '.["users"][] | {requester: .["id"], url: .["url"], u_name: .["name"], org: .["organization_id"], role: .["role"], email: .["email"]}'  | sed -e 's/{//g' -e 's/}//g' -e 's/"//g'| grep -vE '^$' >> users.txt
    fi    
done

##############################
####### Satisfaction #########
##############################
for i in $(seq $1)
do
    lines=$(curl -Ls "https://mxabierto.zendesk.com/api/v2/satisfaction_ratings.json?page=$i"  -v -u luis.roangarci@gmail.com:Ikidefenix131090 | jq '.["satisfaction_ratings"]' | wc -l)
    if [ $lines -gt 1 ]
    then
          curl -Ls "https://mxabierto.zendesk.com/api/v2/satisfaction_ratings.json?page=$i"  -v -u luis.roangarci@gmail.com:Ikidefenix131090 | jq '.["satisfaction_ratings"]| .[] | {id: .["id"], requester_id: .["requester_id"], date: .["created_at"], score: .["score"], comment: .["comment"] }' | sed -e 's/{//g' -e 's/}//g' -e 's/"//g'| grep -vE '^$' >> satisfaction_ratings.txt
    fi    
done

##############################
########### tickets ##########
##############################
for i in $(seq $1)
do
    lines=$(curl -Ls "https://mxabierto.zendesk.com/api/v2/tickets.json?page=$i"  -v -u luis.roangarci@gmail.com:Ikidefenix131090 | jq '.["tickets"]' | wc -l)
    if [ $lines -gt 1 ]
    then
curl -Ls "https://mxabierto.zendesk.com/api/v2/tickets.json?page=$i"  -v -u luis.roangarci@gmail.com:Ikidefenix131090 | jq '.["tickets"][] |  {id: .["id"], requester:.["requester_id"], organization: .["organization_id"], subject: .["subject"], description: .["description"], date: .["created_at"], url: .["url"], status: .["status"], tags: .["tags"][1]}'| sed -e 's/{//g' -e 's/}//g' -e 's/"//g'| grep -vE '^$' >> tickets.txt
    fi    
done





