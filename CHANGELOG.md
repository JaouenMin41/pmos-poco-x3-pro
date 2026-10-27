# Journal des modifications

Format inspiré de [Keep a Changelog](https://keepachangelog.com/fr/1.1.0/).

## [Non publié]

### Ajouté
- Noyau : base sm8150-mainline `sm8150/6.17` (commit `c340f8ec4fa4`).
- Noyau : pilote DRM `panel-xiaomi-vayu-nt36672c` pour les dalles Tianma
  (`36 02 0a`) et CSOT (`42 02 0b`), généré depuis le device tree Xiaomi.
- Noyau : pilote tactile Novatek NT36xxx SPI, repris du port surya (sm7150-mainline).
- Noyau : device tree `sm8150-xiaomi-vayu-{tianma,csot}` avec écran, GPU,
  tactile, charge, jauge, USB-C, WiFi, Bluetooth, modem, microSD, flash, NFC, IR.
- Noyau : correctif de compilation du DTB raphael (référence à un nœud `ipa` absent).
- pmaports : paquets `device-xiaomi-vayu` et `linux-postmarketos-qcom-sm8150` en overlay.
- Scripts : `install-overlay.sh`, `build-kernel.sh`, `dump-firmware.sh`.
- Documentation : installation (Windows + WSL2), protocole de test, firmwares, matériel.
