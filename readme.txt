Fait par Théo Plockyn.


Les chèques et factures se trouvent dans le dossier transactions/
Les clés se trouvent dans les différents dossiers des acteurs.


Etape 1: #######################################################################
./1-runOnceInit.sh

La première étape génère des clés pour tout le monde si elles ne sont pas présentes, les partage pour permettre aux différents acteurs de ne pas s'introduire dans les fichiers des autres.
Elle génère aussi, dans le dossier transactions/ un chèque avec un ID aléatoire, et son nom est séquentiel.

Le contenu du chèque est :

Un ID unique aléatoire
Le numéro de compte du client
La clé publique du client

La signature par la banque des informations ci-dessus, afin d'empêcher l'altération des données présentes, ou même la création totale d'un faux chèque


Etape 2: #######################################################################
./2-genFact.sh price

Cette étape, faite normalement par le marchand, génère un fichier de facture dans transactions/ avec un nom séquentiel.

Le contenu de la facture est :

Un ID unique aléatoire
Le prix de la transaction
Le numéro de compte du marchand

La signature par la banque du numéro de compte du marchand, afin de s'assurer que le numéro de compte du marchand est véritable, les faux comptes marchands ne sont pas possibles.


Etape 3: #######################################################################
./3-fillCheck.sh checkfile factfile

Cette troisième étape, effectuée par le client, permet de remplir l'un des chèques généré en étape 1 à partir des informations de la facture passée en paramètre.

On ajoute au chèque :

L'ID de la facture
Le prix
Le numéro de compte du marchand

Et le client signe l'entièreté du chèque, ajouté à la fin du fichier, afin d'éviter que le marchand ne modifie les informations.


Etape 4: #######################################################################
./4-verify.sh checkfile factfile

Cette étape, effectuée par le marchand, vérifie que le chèque n'est pas contrefait grâce à la signature de la banque, puis vérifie que les informations du chèque se trouvent bien dans la signature du chèque par le client grâce à la clé présente dans le chèque ( vérifiée par la signature de la banque ).
Si ces deux vérifications successives sont bonnes, le marchant vérifie que les informations du chèque correspondent bien à celles de la facture originale. Les informations vérifiées sont l'ID de la facture, le prix et le numéro de compte du marchand.


Etape 5: #######################################################################
./5-cashing.sh checkfile

Cette dernière étape, effectuée par la banque, vérifie d'abord que le chèque n'a pas déjà été utilisé, puis que la transaction de la facture n'a pas déjà été réglée avec un autre chèque.
La banque revérfie ensuite que le chèque est véritable grâce à la signature que la banque a créé pour le chèque à l'étape 1, puis que les informations présentes sont bien dans la signature du client.
Enfin, le fichier csv contenant les numéros de chèques, de transaction et s'ils ont déjà bien été utilisés est mis à jour pour répercuter l'encaissement.
