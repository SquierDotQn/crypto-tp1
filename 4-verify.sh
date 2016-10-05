#!/bin/bash

# fait par le marchand

check_file=$1
fact_file=$2

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

# Vérifier les infos entre facture et chèque
cat $fact_file | grep "fact_id"     > tmp_verify_fact
cat $fact_file | grep "price"       > tmp_verify_fact
cat $fact_file | grep "merch_acc"   > tmp_verify_fact

cat $check_file | grep "fact_id"    > tmp_verify_check
cat $check_file | grep "price"      > tmp_verify_check
cat $check_file | grep "merch_acc"  > tmp_verify_check

echo "## Verification des informations du chèque par rapport à la facture ##"
diff tmp_verify_fact tmp_verify_check
if [ $? -ne "0" ]
then
    echo "ERREUR: Différence entre les informations du chèque et de la facture"
    rm tmp_verify_fact
    rm tmp_verify_check
    exit 1
fi
rm tmp_verify_fact
rm tmp_verify_check

echo "FIN: Vérification des informations complète, le chèque $check_file est valide et cohérent avec les informations de la facture $fact_file."
