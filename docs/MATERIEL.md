# Notes matérielles : POCO X3 Pro (vayu)

Informations tirées du noyau Android de Xiaomi
([MiCode/Xiaomi_Kernel_OpenSource, branche `vayu-r-oss`](https://github.com/MiCode/Xiaomi_Kernel_OpenSource/tree/vayu-r-oss))
et du port mainline de 2023.

## Comparaison avec le POCO X3 NFC (surya)

| | X3 NFC (surya) | X3 Pro (vayu) | Réutilisable ? |
|---|---|---|---|
| SoC | SM7150-AC (SD732G) | SM8150-AC (SD860) | Non : noyau sm8150-mainline |
| PMIC | PM6150 / PM6150L | PM8150 / PM8150B / PM8150L | Pilotes communs dans le noyau |
| Écran | NT36672C, Huaxing ou Tianma, DSC 120 Hz | NT36672C, **Tianma ou CSOT**, DSC 120 Hz | Structure du pilote oui, séquences d'init non |
| Tactile | NT36672C SPI | NT36672C SPI | **Oui**, même pilote |
| Rétroéclairage | WLED PM6150L | WLED PM8150L | Oui (même pilote `qcom-wled`) |
| Amplis audio | TAS2562 + TAS2564 | TAS2562/TAS256x ou CS35L41 | Partiellement |
| Codec audio | Interne (LPASS) | WCD9340 en SLIMbus | Non |
| Vibreur | AW8624 (I2C) | Haptique PM8150B | Non |
| NFC | NXP | NXP NQ310 (selon variante) | Oui (`nxp-nci`) |
| WiFi / BT | WCN3990 | WCN3998 | Oui |
| Stockage | UFS 2.1 + microSD | UFS 3.1 + microSD | Oui |

## Écran

| | Tianma | CSOT |
|---|---|---|
| Nom Android | `dsi_j20s_36_02_0a_video_display` | `dsi_j20s_42_02_0b_video_display` |
| Compatible mainline | `tianma,nt36672c-j20s` | `csot,nt36672c-j20s` |
| DTB | `sm8150-xiaomi-vayu-tianma` | `sm8150-xiaomi-vayu-csot` |
| Firmware tactile | `j20s_novatek_ts_fw01.bin` | `j20s_novatek_ts_fw02.bin` |

Paramètres communs : 1080×2400, 4 voies DSI, vidéo, DSC 1.1 (tranches de
540×20, 8 bpp), 120 Hz, porches H 67/12/40, V 33/2/30.

Alimentations : `vddio` = PM8150 L14 (1,8 V), `lab`/`ibb` = LCDB du PM8150L
(laissé allumé par le bootloader pour l'instant), rétroéclairage WLED
PM8150L (3 chaînes, OVP 28 V, 22,5 mA), GPIO 27 = activation du rétroéclairage.

## Brochage (TLMM)

| GPIO | Fonction |
|---|---|
| 0-3 | SPI de l'élément sécurisé NFC (réservé) |
| 6 | Reset écran |
| 8 | TE (vsync) écran |
| 12 | Reset tactile |
| 27 | Activation du rétroéclairage |
| 43-46 | UART Bluetooth (QUP 13) |
| 47 | IRQ NFC |
| 48 | Téléchargement firmware NFC |
| 55-58 | SPI tactile (QUP 17) |
| 89, 92 | Reset amplis audio |
| 96 | Détection microSD |
| 102 | Activation NFC |
| 113 | Demande d'horloge NFC |
| 114-117 | SPI émetteur IR (QUP 1) |
| 122 | IRQ tactile |
| 126-129 | SPI lecteur d'empreintes (réservé) |
| 175 | Reset UFS |

## Bus

| Bus mainline | Périphérique |
|---|---|
| `spi1` | Émetteur infrarouge |
| `i2c9` | NFC (0x28) |
| `spi17` | Tactile NT36672C |
| `uart13` | Bluetooth WCN3998 |
| `mdss_dsi0` | Écran |

## Batterie

5160 mAh, tension max 4,475 V, deux fournisseurs (NVT et Sunwoda), charge
rapide 33 W via pompe de charge BQ25970 (pas encore gérée : la charge se fait
au débit standard du PM8150B).
