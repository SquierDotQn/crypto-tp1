#!/bin/bash

# BANK GEN
if [[ `ls -l | grep dr | grep bank | wc -l` -eq 0 ]] 
then
    mkdir bank/; cd bank/
    openssl genrsa 1024 > bank.key ; cat bank.key | openssl rsa -pubout > bank.pub
    cd ..
    echo "LOG: Clés de la banque générés"
else
    echo "LOG: Les informations de la banque sont déjà générées"
fi

# CLIENT GEN
if [[ `ls -l | grep dr | grep client | wc -l` -eq "0" ]] 
then
    mkdir client/; cd client/
    openssl genrsa 1024 > client.key ; cat client.key | openssl rsa -pubout > client.pub
    echo "012345" > client.compte
    cd ..
    echo "LOG: Clés du client générés"
else
    echo "LOG: Les informations du client sont déjà générées"
fi

# MARCHAND GEN
if [[ `ls -l | grep dr | grep marchand | wc -l` -eq "0" ]]
then
    mkdir marchand/; cd marchand/
    openssl genrsa 1024 > marchand.key ; cat marchand.key | openssl rsa -pubout > marchand.pub
    echo "543210" > marchand.compte
    openssl dgst -sha256 -sign ../bank/bank.key marchand.compte | base64 > marchand.sign
    cd ..
    echo "LOG: Clés du marchand générés"
else
    echo "LOG: Les informations du marchand sont déjà générées"
fi

# PARTAGE
cp bank/bank.pub marchand/
cp bank/bank.pub client/
cp client/client.pub bank/
cp marchand/marchand.pub bank/
echo "LOG: Partage des clés"

# CHECK GEN
check_id=`tr -cd '[:digit:]' < /dev/urandom | fold -w10 | head -n1`

nb_checks=`ls transactions/ | grep check | wc -l`
check_file="transactions/check`expr $nb_checks + 1`"
client_acc=`cat client/client.compte | tr -d '\n'`
client_pkey=`cat client/client.pub`


# id du chèque, id de la facture, utilisé 0 non | 1 oui
echo "$check_id,undefined,0" >> bank/checks.csv

echo "check_id:$check_id"       >  $check_file
echo "client_acc:$client_acc"   >> $check_file
echo "client_pkey:"             >> $check_file
echo "$client_pkey"             >> $check_file

echo "LOG: Chèque généré du nom de $check_file"

bank_sign=`openssl dgst -sha256 -sign bank/bank.key $check_file | base64`

echo "LOG: Chèque signé"

echo "bank_sign:" >> $check_file
echo "$bank_sign" >> $check_file


echo "FIN: L'initialisation est complète"
