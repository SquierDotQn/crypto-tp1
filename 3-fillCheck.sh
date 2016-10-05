#!/bin/bash

# fait par le client

check_file=$1
fact_file=$2

# Verif de l'identité du marchand
cat $fact_file | grep -A 3 "fact_bank_sign" | tail -n 3 | base64 -d > tmp_sign

echo "## Verification de l'identité du marchand ##"
openssl dgst -sha256 -verify client/bank.pub -signature tmp_sign marchand/marchand.compte 

if [ $? -ne "0" ]
then
    echo "ERREUR: Verification échouée"
    rm tmp_sign
    exit 1
fi
rm tmp_sign


cat $fact_file | grep "price:"      >> $check_file
cat $fact_file | grep "merch_acc:"  >> $check_file 
cat $fact_file | grep "fact_id:"    >> $check_file 

client_sign=`openssl dgst -sha256 -sign client/client.key $check_file | base64`

echo "client_sign:" >> $check_file 
echo "$client_sign" >> $check_file 


echo "FIN: Remplissage du chèque $check_file complet."
