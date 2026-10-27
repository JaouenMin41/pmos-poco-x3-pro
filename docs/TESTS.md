# Protocole de test

Chaque test a un identifiant (`T01`, `T02`…) à reprendre dans les
[rapports de test](https://github.com/JaouenMin41/pmos-poco-x3-pro/issues/new?template=rapport-de-test.yml).
Les commandes se lancent **sur le téléphone**, en SSH (`ssh user@172.16.42.1`)
ou dans un terminal local.

Commencez toujours par récupérer le `dmesg` complet :

```sh
sudo dmesg > dmesg-$(date +%F-%H%M).txt
```

## Niveau 1 : démarrage et affichage

| ID | Test | Commande / action | Résultat attendu |
|---|---|---|---|
| T01 | Le noyau démarre | `uname -a` | `6.17.0-sm8150…` |
| T02 | Réseau USB | Depuis le PC : `ping 172.16.42.1` | Réponses |
| T03 | Dalle détectée | `dmesg \| grep -iE "nt36672c\|dsi\|panel"` | Pas d'erreur `Failed to initialize panel` |
| T04 | Image à l'écran | Regarder l'écran | Console ou interface lisible, pas de couleurs ni de lignes parasites |
| T05 | Rétroéclairage | `ls /sys/class/backlight/` puis `echo 500 \| sudo tee /sys/class/backlight/*/brightness` | La luminosité change |
| T06 | Écran éteint / rallumé | Appui court sur Power (interface graphique) | L'écran se rallume correctement |
| T07 | Tactile détecté | `dmesg \| grep -i nt36` et `ls /dev/input/` | Firmware chargé, un `event` en plus |
| T08 | Tactile fonctionne | `sudo evtest` (choisir le tactile) puis toucher l'écran | Événements `ABS_MT_POSITION_X/Y` cohérents |
| T09 | GPU | `dmesg \| grep -i adreno` puis `glxinfo -B` (paquet `mesa-utils`) | `Adreno 640`, pas `llvmpipe` |

## Niveau 2 : énergie et connectivité

| ID | Test | Commande / action | Résultat attendu |
|---|---|---|---|
| T10 | Batterie | `cat /sys/class/power_supply/*/uevent` | Capacité et tension plausibles |
| T11 | Charge | Brancher le chargeur, relire T10 | `STATUS=Charging`, courant positif |
| T12 | USB-C hôte (OTG) | Brancher une clé USB via un adaptateur OTG | `lsblk` la montre |
| T13 | WiFi | `nmcli dev wifi list` | Réseaux visibles, connexion possible |
| T14 | Bluetooth | `bluetoothctl` puis `power on` et `scan on` | Appareils visibles |
| T15 | Modem | `mmcli -L` puis `mmcli -m 0` | Modem présent, carte SIM lue |
| T16 | Appels / SMS | Via l'interface (phosh) | |
| T17 | microSD | `lsblk` | `mmcblk0` présent |
| T18 | Boutons | `sudo evtest` sur `gpio-keys` et `pm8941_pwrkey` | Volume +/-, Power |

## Niveau 3 : périphériques secondaires

| ID | Test | Commande / action | Résultat attendu |
|---|---|---|---|
| T20 | Flash LED | `ls /sys/class/leds/` puis `echo 1 \| sudo tee /sys/class/leds/white:flash/brightness` | Le flash s'allume |
| T21 | NFC | `dmesg \| grep -i nfc` et `ls /sys/class/nfc/` | `nfc0` présent (si votre carte a le NFC) |
| T22 | Infrarouge | `ls /dev/lirc*` | `/dev/lirc0` présent |
| T23 | Suspend | `sudo rtcwake -m mem -s 20` | Le téléphone se réveille après 20 s |

## Informations à toujours joindre

```sh
uname -a
cat /proc/device-tree/model; echo
cat /proc/cmdline
sudo dmesg
```
