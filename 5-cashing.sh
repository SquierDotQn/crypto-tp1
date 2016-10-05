#!/bin/bash

# fait par la banque

check_file=$1

check_id=`cat $check_file | grep "check_id" | cut -d':' -f2`
fact_id=`cat $check_file | grep "fact_id" | cut -d':' -f2`

if [[ `cat bank/checks.csv | grep $check_id | cut -d',' -f3` -ne 0 ]]
then
    echo "ERREUR: Chèque déjà encaissé"
    exit 1
fi
if [[ `cat bank/checks.csv | grep $fact_id | wc -l` -ne 0 ]]
then
    echo "ERREUR: Facture déjà réglée"
    exit 1
fi


# Vérifier que les infos du chèque soient véritables
# partie banque
cat $check_file | grep -A 3 "bank_sign" | tail -n 3 | base64 -d >> tmp_verify_sign

cat $check_file | grep "check_id"           >  tmp_verify
cat $check_file | grep "client_acc"         >> tmp_verify
cat $check_file | grep -A 6 "client_pkey"   >> tmp_verify
echo "## Verification de l'identité du client ##"
openssl dgst -sha256 -verify marchand/bank.pub -signature tmp_verify_sign tmp_verify
if [ $? -ne "0" ]
then
    echo "ERREUR: Verification de l'identité client échouée"
    rm tmp_verify_sign
    rm tmp_verify
    exit 1
fi
rm tmp_verify
rm tmp_verify_sign

# partie client
cat $check_file | grep -B 16 "client_sign" | head -n 16             > tmp_verify_client
cat $check_file | grep -A 3 "client_sign" | tail -n 3 | base64 -d   > tmp_verify_client_sign
cat $check_file | grep -A 6 "client_pkey" | tail -n 6               > client_key
echo "## Verification de l'intégrité des informations du chèque ##"
openssl dgst -sha256 -verify client_key -signature tmp_verify_client_sign tmp_verify_client
if [ $? -ne "0" ]
then
    echo "ERREUR: Verification des informations du chèque échouée"
    rm tmp_verify_client
    rm tmp_verify_client_sign
    rm client_key
    exit 1
fi
rm tmp_verify_client
rm tmp_verify_client_sign
rm client_key


# Chèque OK, on encaisse
cp bank/checks.csv bank/checks_tmp.csv
sed "s/$check_id,undefined,0/$check_id,$fact_id,1/g" bank/checks_tmp.csv > bank/checks.csv
rm bank/checks_tmp.csv



