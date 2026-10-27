# Installation et test sur le POCO X3 Pro

Ce guide part d'un PC **Windows** avec WSL2 (c'est la configuration de départ du
projet). Sous Linux, ignorez simplement la partie WSL et utilisez `fastboot`
directement depuis votre terminal.

> [!CAUTION]
> Flasher un téléphone comporte des risques. Faites les sauvegardes de
> l'étape 2 avant tout. La méthode A (microSD + `fastboot boot`) ne modifie
> **rien** sur le téléphone : commencez toujours par elle.

## Sommaire

1. [Prérequis](#1-prérequis)
2. [Sauvegardes](#2-sauvegardes-obligatoires)
3. [Installer pmbootstrap dans WSL2](#3-installer-pmbootstrap-dans-wsl2)
4. [Construire l'image](#4-construire-limage)
5. [Méthode A : test sans rien écraser](#5-méthode-a--test-sans-rien-écraser-recommandé)
6. [Méthode B : installation sur la mémoire interne](#6-méthode-b--installation-sur-la-mémoire-interne)
7. [Revenir à Android](#7-revenir-à-android)
8. [Récupérer des logs](#8-récupérer-des-logs)

## 1. Prérequis

- POCO X3 Pro (`vayu` ou `bhima`) avec **bootloader déverrouillé**
- Une recovery custom (TWRP ou OrangeFox) pour les sauvegardes
- `adb` et `fastboot` sur le PC ([platform-tools](https://developer.android.com/tools/releases/platform-tools))
- Windows 10/11 avec WSL2, ou un PC Linux
- Pour la méthode A : une carte **microSD** de 8 Go minimum et un lecteur

### Connaître sa dalle d'écran

Le X3 Pro existe avec deux dalles (Tianma et CSOT) qui demandent chacune leur
DTB. Redémarrez dans la recovery puis :

```sh
adb shell "cat /proc/cmdline | tr ' ' '\n' | grep dsi_display"
```

| Résultat | Dalle | DTB à utiliser |
|---|---|---|
| `dsi_j20s_36_02_0a_video_display` | Tianma | `sm8150-xiaomi-vayu-tianma` (par défaut) |
| `dsi_j20s_42_02_0b_video_display` | CSOT | `sm8150-xiaomi-vayu-csot` |

## 2. Sauvegardes obligatoires

Dans la recovery (TWRP/OrangeFox), téléphone branché :

```sh
mkdir sauvegarde-vayu && cd sauvegarde-vayu
for p in boot dtbo vbmeta vendor_boot persist modemst1 modemst2 fsg fsc; do
  adb shell "test -e /dev/block/by-name/$p && dd if=/dev/block/by-name/$p of=/tmp/$p.img" && adb pull /tmp/$p.img
done
```

Gardez ce dossier précieusement. `persist`, `modemst1`, `modemst2`, `fsg` et
`fsc` contiennent les calibrations propres à **votre** appareil (IMEI, WiFi,
capteurs) et ne se retrouvent nulle part ailleurs.

Profitez-en pour extraire les firmwares (voir [FIRMWARE.md](FIRMWARE.md)).

## 3. Installer pmbootstrap dans WSL2

Dans un PowerShell **administrateur** :

```powershell
wsl --install -d Ubuntu
```

Redémarrez si demandé, ouvrez « Ubuntu », créez votre utilisateur, puis :

```sh
sudo apt update
sudo apt install -y git python3 openssl
git clone https://gitlab.postmarketos.org/postmarketOS/pmbootstrap.git ~/pmbootstrap
mkdir -p ~/.local/bin
ln -s ~/pmbootstrap/pmbootstrap.py ~/.local/bin/pmbootstrap
exec bash
pmbootstrap --version
```

> [!NOTE]
> Depuis le passage à Nura, le dépôt peut avoir changé d'adresse. Si le
> `git clone` échoue, suivez la page d'installation de pmbootstrap sur
> [nura.eco](https://nura.eco) et dites-le dans une issue pour qu'on corrige ce guide.

## 4. Construire l'image

```sh
pmbootstrap init
```

Réponses conseillées :

| Question | Réponse |
|---|---|
| Channel | `edge` |
| Vendor / Device | `xiaomi` / `vayu` |
| User interface | `console` pour le premier test, puis `phosh` ou `plasma-mobile` |
| Non-free firmware | `y` |
| Le reste | valeurs par défaut |

Ajoutez ensuite les paquets de ce dépôt (noyau 6.17, pilote d'écran, DTS) :

```sh
git clone https://github.com/JaouenMin41/pmos-poco-x3-pro ~/pmos-poco-x3-pro
~/pmos-poco-x3-pro/scripts/install-overlay.sh
```

Le script sauvegarde les paquets d'origine de pmaports avant de les remplacer
et affiche les différences. Pour une dalle **CSOT**, ajoutez `--panel csot`.

Construisez puis exportez :

```sh
pmbootstrap install --password 147147   # mot de passe temporaire de test
pmbootstrap export
ls -l /tmp/postmarketOS-export/
```

Copiez les images vers Windows (l'explorateur voit WSL sous `\\wsl$\Ubuntu`) :

```sh
mkdir -p /mnt/c/vayu && cp -L /tmp/postmarketOS-export/{boot.img,xiaomi-vayu.img} /mnt/c/vayu/
```

## 5. Méthode A : test sans rien écraser (recommandé)

Le système est écrit sur la microSD et le noyau est démarré **une seule fois**
depuis la RAM. Au redémarrage suivant, Android revient tout seul.

1. Écrivez `C:\vayu\xiaomi-vayu.img` sur la microSD avec
   [balenaEtcher](https://etcher.balena.io/) ou [Rufus](https://rufus.ie/) (mode image DD).
2. Insérez la carte dans le téléphone.
3. Éteignez le téléphone, puis **Volume bas + Power** pour entrer en fastboot.
4. Dans PowerShell :

```powershell
cd C:\vayu
fastboot devices
fastboot boot boot.img
```

L'initramfs cherche les partitions `pmOS_boot` / `pmOS_root` sur tous les
périphériques, microSD comprise.

**Que regarder pendant le test** : voir [TESTS.md](TESTS.md). En résumé :
l'écran s'allume-t-il, le tactile répond-il, le PC voit-il une interface réseau
USB (`ssh user@172.16.42.1`) ?

Si le téléphone redémarre en boucle ou reste sur le logo POCO, voir
[Si ça ne démarre pas](#si-ça-ne-démarre-pas).

## 6. Méthode B : installation sur la mémoire interne

> [!WARNING]
> Cette méthode **efface toutes les données Android** (partition `userdata`).

```powershell
fastboot flash boot boot.img
fastboot flash userdata xiaomi-vayu.img
fastboot reboot
```

Les mises à jour du noyau se font ensuite directement depuis le téléphone
(`deviceinfo_flash_kernel_on_update`), ou depuis WSL avec
`pmbootstrap flasher flash_kernel` si `fastboot` est accessible.

## 7. Revenir à Android

- **Méthode A** : redémarrez, c'est tout.
- **Méthode B** : flashez la ROM de votre choix depuis la recovery, ou restaurez
  `boot.img` depuis vos sauvegardes : `fastboot flash boot sauvegarde-vayu/boot.img`.

## 8. Récupérer des logs

Depuis le PC, une fois le téléphone démarré et branché en USB :

```sh
ssh user@172.16.42.1
sudo dmesg > dmesg.txt
```

Si le système ne démarre pas jusqu'au bout, le noyau garde ses logs en RAM
(ramoops). Redémarrez dans la recovery **sans couper l'alimentation** puis :

```sh
adb shell "cat /sys/fs/pstore/console-ramoops*" > ramoops.txt
```

Joignez ces fichiers à un [rapport de test](https://github.com/JaouenMin41/pmos-poco-x3-pro/issues/new?template=rapport-de-test.yml).

## Si ça ne démarre pas

| Symptôme | Piste |
|---|---|
| Retour immédiat en fastboot | Image de boot refusée : envoyez la sortie de `fastboot boot boot.img` |
| Bloqué sur le logo POCO | Le bootloader applique la `dtbo` d'Android sur notre DTB. Essayez `fastboot erase dtbo` (restaurable avec votre sauvegarde) |
| Écran noir mais réseau USB OK | Pilote d'écran : envoyez `dmesg` |
| Redémarrage après quelques secondes | Récupérez `ramoops` (section 8) |
