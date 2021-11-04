# Scripts pour le PEB

__À noter : le nom réel des scripts est précédé de `AlP_PEB_`. Le préfixe a été ici retiré pour faciliter la lecture.__

## Installation des scripts

Il existe deux manières d'installer ces scripts, les résultats sont similaires hormis le [launcher](https://github.com/Alban-Peyrat/Scripts-WinIBW/PEB.md#launcher) qui diffère entre les deux. 

### En tant que scripts utilisateurs (VBS)

__Fermez WinIBW.__
Accédez au dossier de WinIBW (par exemple en faisant clic-droit puis `Ouvrir l'emplacement du fichier`), puis ouvrez le dossier `Profiles`, puis celui correspondant à votre nom d'utilisateur.
Modifiez ensuite le fichier `winibw.vbs` avec `Bloc-notes` (par exemple), rendez-vous à la fin du fichier et collez l'intégralité du contenu du fichier [`scripts_PEB.vbs`](https://github.com/Alban-Peyrat/Scripts-WinIBW/blob/main/scripts_PEB.vbs).
Enregistrez et fermez le document.

Vous pourrez retrouver les scripts dans la catégorie `Fonctions`.

### En tant que scripts standarts (JS)

__Fermez WinIBW.__
Accédez au dossier de WinIBW (par exemple en faisant clic-droit puis `Ouvrir l'emplacement du fichier`), puis ouvrez le dossier `Profiles`, puis celui correspondant à votre nom d'utilisateur.
Modifiez ensuite le fichier `user_pref.js` avec `Bloc-notes` (par exemple), rendez-vous à la fin du fichier et collez sur une nouvelle ligne ce texte : `user_pref("ibw.standardScripts.script.99", "resource:/Profiles/[NOM D'UTILISATEUR]/peyrat_peb.js");`.
Modifiez le `[NOM D'UTILISATEUR]` avec le vôtre.
Enregistrez et fermez le document.
Collez ensuite le fichier [`peyrat_peb.js`](https://github.com/Alban-Peyrat/Scripts-WinIBW/blob/main/peyrat_peb.vbs) au même emplacement que `user-pref.js`.

Vous pourrez retrouver les scripts dans la catégorie `Standart Fonctions`.

## Utiliser les scripts

Rappels :
* si vous avez installé les scripts en tant que scripts utilisateurs, vous les retrouverez dans la catégorie `Fonctions`, si vous les avez installés en tant que scripts standarts, vous les retrouverez dans la catégorie `Standart Fonctions` ;
* les scripts sont précédés de la mention `AlP_PEB_`.


### Via boutons

Ouvrez le menu `Options` puis `Personnaliser...` puis `Commandes` et retrouvez le script qui vous intéresse dans la liste des commandes de la bonne catégorie.
Effectuez ensuite un cliqué-déposé vers votre barre de menu.
__Si vous sélectionnez d'afficher du texte, vous pouvez modifier le texte du bouton via l'option `Texte bouton :`.__

### Via raccourcis

Ouvrez le menu `Options` puis `Personnaliser...` puis `Clavier`.
Retrouvez le script qui vous intéresse dans la liste des commandes de la bonne catégorie et affectez-y un raccourci.

## Présentation des scripts

### `getNumDemande`

Renvoie dans le presse-papier le numéro de la demande PEB.

__Détails :__ Renvoie la variable `P3GA*`.

### `getNumDemandePostValidation`

Renvoie dans le presse-papier le numéro de la demande PEB __venant d'être effectuée__.

__Détails :__ Le script récupère le premier message affiché dans la barre des messages et renvoie les dix premiers caractères en suivant l'expression `no.` (suivi d'un espace).

### `getRCRDemandeur`

Renvoie dans le presse-papier du RCR demandeur.

__Détails :__ Renvoie la variable `libID`.

### `Launcher`

Ouvre une boîte de dialogue qui permet de lancer l'exécution d'un des autres scripts de PEB que j'ai développés.

__Détails :__ la boîte de dialogue varie selon si l'on utilise les scripts en VBS ou en JS. __En JS__, la boite de dialogue propose des options cliquables, qui exécuteront les scripts associés . __En VBS__, la boîte de dialogue demande d'entrer le numéro associé au script :
  * 0 (VBS) / `Get no demande PEB` (JS) : exécuter [`getNumDemande`](https://github.com/Alban-Peyrat/Scripts-WinIBW/PEB.md#getnumdemande) ;
  * 1 (VBS) / `Get no demande PEB post-validation` (JS) : exécuter [`getNumDemandePostValidation`](https://github.com/Alban-Peyrat/Scripts-WinIBW/PEB.md#getnumdemandepostvalidation) ;
  * 3 (VBS) / `Get RCR demandeur` (JS) : exécuter [`getRCRDemandeur`](https://github.com/Alban-Peyrat/Scripts-WinIBW/PEB.md#getrcrdemandeur) ;
  * 4 (VBS) / `Get RCR fournisseur en attente` (JS) : pas encore implenté.

_À noter : le numéro 2 sera dédié à la récupération du PPN, qui est en cours de développement._