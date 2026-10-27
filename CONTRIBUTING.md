# Contribuer

Merci de votre intérêt ! Ce projet avance surtout grâce aux **tests sur de
vrais téléphones**.

## Signaler un résultat de test

1. Suivez [docs/INSTALLATION.md](docs/INSTALLATION.md), méthode A de préférence.
2. Passez les tests de [docs/TESTS.md](docs/TESTS.md) que vous pouvez.
3. Ouvrez une issue avec le modèle **Rapport de test**, en joignant le `dmesg`.

Précisez toujours votre **dalle** (Tianma ou CSOT) et la variante du
téléphone (vayu / bhima).

## Proposer un patch noyau

Les patchs vivent dans `kernel/patches/` et s'appliquent sur la branche
`sm8150/6.17` de [sm8150-mainline](https://gitlab.com/sm8150-mainline/linux).

```sh
./scripts/build-kernel.sh           # clone, applique les patchs, compile
# modifiez le noyau dans build/linux, commitez, puis :
./scripts/build-kernel.sh --export  # régénère kernel/patches/
```

Règles :

- un patch par sujet, message de commit au format du noyau (`sous-système: résumé`) ;
- pas de firmware propriétaire dans le dépôt ;
- le DT doit compiler sans avertissement (`make CHECK_DTBS=y qcom/sm8150-xiaomi-vayu-tianma.dtb`).

## Paquets pmaports

Après modification de `kernel/patches/` ou de la configuration, mettez à jour
la liste `source=` et les `sha512sums` de
`pmaports/device/testing/linux-postmarketos-qcom-sm8150/APKBUILD`
(`pmbootstrap checksum linux-postmarketos-qcom-sm8150`).
