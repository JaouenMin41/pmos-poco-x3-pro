#!/bin/sh
# SPDX-License-Identifier: MIT
#
# Copie les paquets de ce dépôt dans le pmaports utilisé par pmbootstrap.
# Les paquets d'origine sont sauvegardés avant d'être remplacés.
#
# Usage : ./scripts/install-overlay.sh [--panel tianma|csot] [--restore]

set -eu

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
OVERLAY="$REPO_DIR/pmaports/device/testing"
PACKAGES="device-xiaomi-vayu linux-postmarketos-qcom-sm8150"
PANEL=tianma
RESTORE=0

while [ $# -gt 0 ]; do
	case "$1" in
	--panel) PANEL="$2"; shift 2 ;;
	--restore) RESTORE=1; shift ;;
	-h|--help) sed -n '3,8p' "$0"; exit 0 ;;
	*) echo "option inconnue : $1" >&2; exit 1 ;;
	esac
done

case "$PANEL" in
tianma|csot) ;;
*) echo "dalle inconnue : $PANEL (tianma ou csot)" >&2; exit 1 ;;
esac

command -v pmbootstrap >/dev/null || { echo "pmbootstrap introuvable" >&2; exit 1; }
PMAPORTS="$(pmbootstrap config aports 2>/dev/null || true)"
if [ -z "$PMAPORTS" ] || [ ! -d "$PMAPORTS/device" ]; then
	PMAPORTS="$(pmbootstrap config work 2>/dev/null || true)/cache_git/pmaports"
fi
if [ -z "$PMAPORTS" ] || [ ! -d "$PMAPORTS/device" ]; then
	echo "pmaports introuvable : lancez d'abord 'pmbootstrap init'" >&2
	exit 1
fi

BACKUP="$PMAPORTS/.vayu-overlay-backup"

# Retrouve le dossier d'un paquet, quelle que soit sa catégorie
find_pkg() {
	find "$PMAPORTS/device" -mindepth 2 -maxdepth 2 -type d -name "$1" | head -n 1
}

if [ "$RESTORE" = 1 ]; then
	[ -d "$BACKUP" ] || { echo "aucune sauvegarde à restaurer" >&2; exit 1; }
	for pkg in $PACKAGES; do
		[ -d "$BACKUP/$pkg" ] || continue
		dest="$(cat "$BACKUP/$pkg.path")"
		rm -rf "$dest"
		cp -a "$BACKUP/$pkg" "$dest"
		echo "restauré : $dest"
	done
	rm -rf "$BACKUP"
	exit 0
fi

mkdir -p "$BACKUP"
for pkg in $PACKAGES; do
	dest="$(find_pkg "$pkg")"
	[ -n "$dest" ] || dest="$PMAPORTS/device/testing/$pkg"

	if [ -d "$dest" ] && [ ! -d "$BACKUP/$pkg" ]; then
		cp -a "$dest" "$BACKUP/$pkg"
		echo "$dest" > "$BACKUP/$pkg.path"
	fi

	echo "==> $pkg -> $dest"
	if [ -d "$BACKUP/$pkg" ]; then
		diff -ru "$BACKUP/$pkg" "$OVERLAY/$pkg" | sed -n '1,40p' || true
	fi
	rm -rf "$dest"
	cp -a "$OVERLAY/$pkg" "$dest"
done

# Choix de la dalle
sed -i "s|^deviceinfo_dtb=.*|deviceinfo_dtb=\"qcom/sm8150-xiaomi-vayu-$PANEL\"|" \
	"$(find_pkg device-xiaomi-vayu)/deviceinfo"
pmbootstrap checksum device-xiaomi-vayu >/dev/null

echo
echo "Overlay installé (dalle : $PANEL). Sauvegarde des paquets d'origine : $BACKUP"
echo "Étape suivante : pmbootstrap install && pmbootstrap export"
echo "Pour annuler : $0 --restore"
