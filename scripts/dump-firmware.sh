#!/bin/sh
# SPDX-License-Identifier: MIT
#
# Copie les firmwares du POCO X3 Pro depuis la recovery (TWRP / OrangeFox)
# vers le PC, puis les convertit en .mbn si pil-squasher est disponible.
#
# Usage : ./scripts/dump-firmware.sh [dossier-de-sortie]
#
# Le téléphone doit être démarré en recovery et visible avec `adb devices`.
# Rien n'est écrit sur le téléphone en dehors de /tmp (en RAM).

set -eu

OUT="${1:-./vayu-firmware}"
REMOTE=/tmp/fwdump

die() { echo "erreur : $*" >&2; exit 1; }

command -v adb >/dev/null || die "adb introuvable"
adb get-state 2>/dev/null | grep -q recovery || die "le téléphone doit être en recovery (TWRP/OrangeFox)"

mkdir -p "$OUT"

# Monte une partition en lecture seule et copie un motif de fichiers.
# $1 : nom de partition (by-name ou mapper), $2 : type de fs, $3.. : motifs
dump_part() {
	part="$1"; fstype="$2"; shift 2
	dev=""
	for cand in "/dev/block/by-name/$part" "/dev/block/by-name/${part}_a" "/dev/block/mapper/$part" "/dev/block/mapper/${part}_a"; do
		if adb shell "test -e $cand" 2>/dev/null; then dev="$cand"; break; fi
	done
	if [ -z "$dev" ]; then
		echo "  (partition $part absente, ignorée)"
		return 0
	fi
	echo "==> $part ($dev)"
	adb shell "mkdir -p $REMOTE/$part && (mount -t $fstype -o ro $dev $REMOTE/$part 2>/dev/null || mount -o ro $dev $REMOTE/$part)" \
		|| { echo "  impossible de monter $part"; return 0; }
	mkdir -p "$OUT/$part"
	for pat in "$@"; do
		adb shell "ls $REMOTE/$part/$pat 2>/dev/null" | tr -d '\r' | while read -r f; do
			[ -n "$f" ] && adb pull "$f" "$OUT/$part/" >/dev/null && echo "  $(basename "$f")"
		done
	done
	adb shell "umount $REMOTE/$part" || true
}

adb shell "mkdir -p $REMOTE"

dump_part modem vfat "image/*.mdt" "image/*.b??" "image/*.mbn" "image/*.jsn" "image/*.bin"
dump_part dsp ext4 "*"
dump_part bluetooth vfat "image/*"
dump_part vendor ext4 "firmware/*" "firmware_mnt/image/*"

# Conversion .mdt + .bXX -> .mbn (https://github.com/linux-msm/pil-squasher)
if command -v pil-squasher >/dev/null; then
	echo "==> conversion en .mbn"
	find "$OUT" -name '*.mdt' | while read -r mdt; do
		mbn="${mdt%.mdt}.mbn"
		if [ ! -e "$mbn" ]; then
			pil-squasher "$mbn" "$mdt" && echo "  $(basename "$mbn")"
		fi
	done
else
	echo "pil-squasher non installé : les fichiers .mdt/.bXX n'ont pas été convertis."
fi

echo
echo "Firmwares copiés dans : $OUT"
echo "Ne publiez pas ces fichiers : ils sont propriétaires."
