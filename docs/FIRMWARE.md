# Firmwares

Plusieurs composants du X3 Pro ont besoin de firmwares propriétaires signés
par Qualcomm/Xiaomi. Ils ne sont pas redistribuables ici.

## Ce qui est fourni par les paquets

Le paquet `firmware-xiaomi-vayu` de pmaports télécharge le jeu de firmwares
préparé par Arseniy Velikanov ([gitlab.com/adomerle/firmware-xiaomi-vayu](https://gitlab.com/adomerle/firmware-xiaomi-vayu)) :

| Fichier | Rôle | Chemin installé |
|---|---|---|
| `adsp.mbn` | DSP audio, gestion de l'USB-C et de la charge | `/lib/firmware/qcom/sm8150/vayu/` |
| `cdsp.mbn` | DSP de calcul | `/lib/firmware/qcom/sm8150/vayu/` |
| `modem.mbn` | Modem | `/lib/firmware/qcom/sm8150/vayu/` |
| `wlanmdsp.mbn`, `board-2.bin`, `firmware-5.bin` | WiFi | voir paquet |
| `a640_zap.mbn`, `a640_gmu.bin`, `a630_sqe.fw` | GPU | `/lib/firmware/qcom/` |
| `j20s_novatek_ts_fw01.bin` | Tactile, dalle Tianma | `/lib/firmware/` |
| `j20s_novatek_ts_fw02.bin` | Tactile, dalle CSOT | `/lib/firmware/` |

Le Bluetooth utilise `qca/crnv21.bin` et `qca/crbtfw21.tlv` de `linux-firmware`.

## Ce qui manque encore

| Fichier | Rôle |
|---|---|
| `slpi.mbn` | Hub capteurs (accéléromètre, proximité, luminosité…) |
| `venus.mbn` | Décodage vidéo matériel |
| `ipa_fws.mbn` | Accélération réseau du modem |

## Extraire les firmwares de votre téléphone

Depuis la recovery (TWRP/OrangeFox), téléphone branché, lancez
[`scripts/dump-firmware.sh`](../scripts/dump-firmware.sh) depuis WSL ou Linux :

```sh
./scripts/dump-firmware.sh ~/vayu-firmware
```

Le script monte en lecture seule les partitions `modem` (NON-HLOS), `dsp`,
`bluetooth` et `vendor`, puis copie les firmwares utiles. Les fichiers restent
sur votre PC : ils ne doivent pas être publiés dans ce dépôt.
