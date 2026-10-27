# Feuille de route

L'ordre suit ce qui rend le téléphone utilisable au quotidien le plus vite.

## Étape 1 : démarrer et afficher (en cours)

- [x] Remettre vayu sur le noyau sm8150-mainline 6.17
- [x] Pilote DSI pour les dalles Tianma et CSOT (DSC, 120 Hz)
- [x] Rétroéclairage WLED
- [x] Pilote tactile NT36672C SPI (repris du port surya)
- [x] GPU Adreno 640
- [x] Compilation complète du noyau validée (clang, arm64)
- [ ] Premier démarrage sur l'appareil (Tianma)
- [ ] Validation sur une dalle CSOT
- [ ] Choix automatique de la dalle au démarrage (un seul DTB)

## Étape 2 : énergie et connectivité

- [x] Charge et jauge batterie PM8150B (DT)
- [x] USB-C : changement de rôle hôte/périphérique (DT)
- [ ] Valider WiFi, Bluetooth, modem (appels, SMS, données)
- [ ] Courbe de charge et limites de courant adaptées à la batterie 5160 mAh
- [ ] Mise en veille (suspend) et autonomie

## Étape 3 : audio

- [ ] Codec WCD9340 en SLIMbus (le noyau sm8150 a déjà la carte son SM8150)
- [ ] Amplificateurs : identifier la variante (TAS2562 ou CS35L41) puis les décrire dans le DT
- [ ] Profils UCM (alsa-ucm-conf) pour haut-parleurs, écouteur, micros, jack
- [ ] Audio des appels

## Étape 4 : périphériques secondaires

- [x] Flash LED, microSD, émetteur IR, NFC (DT)
- [ ] Vibreur (haptique PM8150B)
- [ ] Capteurs via SLPI + hexagonrpcd + iio-sensor-proxy (rotation, proximité, luminosité)
- [ ] Décodage vidéo matériel (Venus)

## Étape 5 : à plus long terme

- [ ] Caméras
- [ ] Remonter les patchs vers sm8150-mainline puis pmaports
- [ ] Passer la catégorie pmaports de *testing* à *community*
