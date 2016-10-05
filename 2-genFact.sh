#!/bin/bash

#fait par le marchand

nb_facts=`ls transactions/ -l | grep fact | wc -l`
fact_file="transactions/fact`expr $nb_facts + 1`"

price=$1
macc=`cat marchand/marchand.compte | tr -d '\n'`
bank_sign=`cat marchand/marchand.sign`
fact_id=`tr -cd '[:digit:]' < /dev/urandom | fold -w10 | head -n1`

echo "fact_id:$fact_id" >> $fact_file
echo "price:$price"     >> $fact_file
echo "merch_acc:$macc"  >> $fact_file
echo "fact_bank_sign:"  >> $fact_file
echo "$bank_sign"       >> $fact_file # n° compte signé

echo "FIN: Génération de la facture complète"
