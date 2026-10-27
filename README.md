<div align="center">

# postmarketOS (Nura) sur POCO X3 Pro

**Linux mainline sur le Xiaomi POCO X3 Pro (`xiaomi-vayu`, Snapdragon 860 / SM8150)**

[![Noyau](https://img.shields.io/badge/noyau-6.17%20sm8150--mainline-blue)](https://gitlab.com/sm8150-mainline/linux)
[![Statut](https://img.shields.io/badge/statut-exp%C3%A9rimental-orange)](#matrice-des-fonctionnalités)
[![Build](https://github.com/JaouenMin41/pmos-poco-x3-pro/actions/workflows/kernel.yml/badge.svg)](https://github.com/JaouenMin41/pmos-poco-x3-pro/actions/workflows/kernel.yml)
[![Licence](https://img.shields.io/badge/licence-MIT%20%2F%20GPL--2.0-lightgrey)](#licences)

</div>

---

Ce dépôt suit le portage de [postmarketOS](https://nura.eco) (renommé **Nura** en
septembre 2026) sur le **POCO X3 Pro**, avec pour objectif d'avoir le plus de
fonctionnalités possible sur un noyau Linux mainline.

Le point de départ est le port du **POCO X3 NFC** (`xiaomi-surya`, SM7150), qui
est très avancé : les deux téléphones partagent beaucoup de composants (dalles
NT36672C, tactile Novatek SPI, WiFi/BT Qualcomm, PMIC de la même famille). Le
SoC est en revanche différent (SM8150 au lieu de SM7150), donc le travail
consiste à reprendre les pilotes et le savoir-faire de surya et à les adapter
au noyau communautaire [sm8150-mainline](https://gitlab.com/sm8150-mainline/linux).

> [!WARNING]
> Projet **expérimental**. Rien n'a encore été validé sur l'appareil. Lisez le
> [guide d'installation](docs/INSTALLATION.md) en entier avant de flasher quoi
> que ce soit, et sauvegardez vos données.

## Pourquoi ce dépôt ?

Un port vayu existe déjà dans pmaports (catégorie *testing*), mais il est resté
bloqué en 2023 sur un noyau 6.4 : affichage en simple framebuffer (pas de
rétroéclairage ni de mise en veille de l'écran), GPU désactivé, pilote tactile
importé d'Android, pas de gestion de la charge. Depuis, le noyau sm8150-mainline
est passé en 6.17 et a **perdu** le support de vayu.

Ce dépôt :

1. remet vayu sur le noyau sm8150-mainline 6.17 ;
2. ajoute un **vrai pilote d'écran DSI** pour les deux dalles du X3 Pro ;
3. reprend le **pilote tactile NT36xxx SPI** du port surya ;
4. active GPU, charge, jauge batterie, USB-C, NFC, IR, microSD, flash ;
5. fournit les paquets pmaports prêts à utiliser avec `pmbootstrap`.

## Matrice des fonctionnalités

Légende : ✅ fonctionne · 🧪 implémenté, à tester · 🚧 en cours · ❌ pas encore · ➖ hors périmètre

| Fonction | Port 2023 (6.4) | Ce port (6.17) | Notes |
|---|:-:|:-:|---|
| Démarrage, UFS, USB réseau | ✅ | 🧪 | |
| Écran (DSI, dalle Tianma) | ⚠️ framebuffer | 🧪 | Pilote DSC 120 Hz généré depuis le DT Xiaomi |
| Écran (DSI, dalle CSOT) | ⚠️ framebuffer | 🧪 | DTB séparé `-csot` |
| Rétroéclairage (WLED) | ❌ | 🧪 | |
| Tactile (NT36672C SPI) | ⚠️ pilote Android | 🧪 | Pilote surya, firmware chargé par l'hôte |
| GPU (Adreno 640) | ❌ | 🧪 | Accélération Mesa freedreno |
| Charge + jauge batterie | ❌ | 🧪 | PM8150B, 5160 mAh |
| USB-C (OTG, rôle hôte) | ❌ | 🧪 | USB 2.0 uniquement (matériel) |
| WiFi (WCN3998) | ✅ | 🧪 | |
| Bluetooth | ✅ | 🧪 | |
| Modem (appels, SMS, data) | ❓ | 🧪 | Via ModemManager + firmware |
| microSD | ✅ | 🧪 | |
| Boutons (power, volume) | ✅ | 🧪 | |
| Flash LED | ❌ | 🧪 | |
| NFC (NXP NQ310) | ❌ | 🧪 | Selon les variantes de carte |
| Émetteur infrarouge | ❌ | 🧪 | `ir-spi-led` |
| Audio (haut-parleurs, micro, jack) | ❌ | 🚧 | WCD9340 + amplis TAS2562/CS35L41 |
| Vibreur | ❌ | ❌ | |
| Capteurs (accéléro, proximité…) | ❌ | ❌ | Via SLPI + hexagonrpcd |
| Caméras | ❌ | ❌ | |
| Lecteur d'empreintes | ❌ | ➖ | Pas de pilote libre |
| Mise en veille (suspend) | ❌ | 🚧 | |

La matrice est mise à jour à chaque retour de test. Le détail des tests à
faire est dans [docs/TESTS.md](docs/TESTS.md).

## Démarrage rapide

Il faut un PC sous Linux (ou Windows avec **WSL2**), `adb`/`fastboot`, et un
POCO X3 Pro au bootloader déverrouillé.

```sh
# 1. Installer pmbootstrap et l'initialiser pour xiaomi-vayu
pmbootstrap init            # appareil : xiaomi-vayu, interface : console ou phosh

# 2. Ajouter les paquets de ce dépôt dans pmaports
git clone https://github.com/JaouenMin41/pmos-poco-x3-pro
./pmos-poco-x3-pro/scripts/install-overlay.sh

# 3. Construire et exporter les images
pmbootstrap install
pmbootstrap export

# 4. Tester sans rien écraser (rootfs sur microSD, démarrage temporaire)
fastboot boot boot.img
```

Toutes les étapes, y compris la méthode qui ne touche pas à Android, sont
détaillées dans [docs/INSTALLATION.md](docs/INSTALLATION.md).

## Organisation du dépôt

```
.
├── kernel/
│   ├── patches/          # Patchs à appliquer sur sm8150-mainline (branche sm8150/6.17)
│   └── vayu.config       # Fragment de configuration noyau propre à vayu
├── pmaports/             # Paquets pmaports (overlay pour pmbootstrap)
│   └── device/testing/
│       ├── device-xiaomi-vayu/
│       ├── firmware-xiaomi-vayu/
│       └── linux-postmarketos-qcom-sm8150/
├── scripts/              # Outils : overlay, build du noyau, extraction des firmwares
├── docs/                 # Installation, matériel, firmwares, protocole de test
├── ROADMAP.md
└── CHANGELOG.md
```

## Feuille de route

Voir [ROADMAP.md](ROADMAP.md). En résumé : valider l'affichage et le tactile,
puis la charge et le modem, puis l'audio, puis les capteurs.

## Contribuer

Les retours de test sont la contribution la plus utile : ouvrez une issue avec
le modèle **Rapport de test**. Voir [CONTRIBUTING.md](CONTRIBUTING.md).

## Crédits

- **Arseniy Velikanov** (adomerle) : port vayu d'origine (DTS, firmwares, pmaports)
- **Danila Tikhonov, David Wronek, Jens Reidel** et l'équipe
  [sm7150-mainline](https://github.com/sm7150-mainline) : port surya (X3 NFC),
  pilotes de dalles NT36672C
- **AngeloGioacchino Del Regno, 99degree** : pilote tactile NT36xxx SPI
- L'équipe [sm8150-mainline](https://gitlab.com/sm8150-mainline/linux) : noyau SM8150
- [linux-mdss-dsi-panel-driver-generator](https://github.com/msm8916-mainline/linux-mdss-dsi-panel-driver-generator) :
  génération des séquences d'init des dalles
- La communauté postmarketOS / Nura

## Licences

- Scripts, documentation et paquets pmaports : [MIT](LICENSE)
- Patchs noyau (`kernel/`) : GPL-2.0, comme le noyau Linux
- Les firmwares propriétaires ne sont **pas** distribués ici : ils sont
  téléchargés par les paquets ou extraits de votre propre téléphone.
