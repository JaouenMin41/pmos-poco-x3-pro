#!/bin/sh
# SPDX-License-Identifier: MIT
#
# Construit le noyau vayu hors de pmbootstrap, pour développer et tester vite.
#
#   ./scripts/build-kernel.sh            clone sm8150-mainline, applique les patchs,
#                                        compile Image.gz, modules et DTB
#   ./scripts/build-kernel.sh --dtbs     ne compile que les DTB vayu
#   ./scripts/build-kernel.sh --export   régénère kernel/patches/ depuis build/linux
#
# Variables : JOBS (défaut : nproc), LLVM=1 pour compiler avec clang (défaut),
# CROSS_COMPILE=aarch64-linux-gnu- pour utiliser GCC à la place.

set -eu

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SRC="$REPO_DIR/build/linux"
BASE_URL="https://gitlab.com/sm8150-mainline/linux.git"
BASE_BRANCH="sm8150/6.17"
BASE_COMMIT="c340f8ec4fa41eb94b82f233ddcce15fd0aaec17"
JOBS="${JOBS:-$(nproc)}"

if [ -z "${CROSS_COMPILE:-}" ]; then
	export LLVM="${LLVM:-1}"
fi
export ARCH=arm64

prepare_tree() {
	if [ ! -d "$SRC/.git" ]; then
		git clone --branch "$BASE_BRANCH" --single-branch "$BASE_URL" "$SRC"
	fi
	cd "$SRC"
	if ! git rev-parse -q --verify vayu >/dev/null; then
		git checkout -b vayu "$BASE_COMMIT"
		git -c user.name="${GIT_AUTHOR_NAME:-vayu-build}" -c user.email="${GIT_AUTHOR_EMAIL:-vayu-build@localhost}" \
			am "$REPO_DIR"/kernel/patches/*.patch
	else
		git checkout vayu
	fi
}

case "${1:-}" in
--export)
	cd "$SRC"
	rm -f "$REPO_DIR"/kernel/patches/*.patch
	git format-patch --no-signature -o "$REPO_DIR/kernel/patches" "$BASE_COMMIT"..vayu
	exit 0
	;;
esac

prepare_tree
make defconfig sm8150.config
scripts/kconfig/merge_config.sh -m .config "$REPO_DIR/kernel/vayu.config" >/dev/null
make olddefconfig

if [ "${1:-}" = "--dtbs" ]; then
	make -j"$JOBS" qcom/sm8150-xiaomi-vayu-tianma.dtb qcom/sm8150-xiaomi-vayu-csot.dtb
else
	make -j"$JOBS" Image.gz modules dtbs
fi

echo
echo "Noyau : $SRC/arch/arm64/boot/Image.gz"
echo "DTB   : $SRC/arch/arm64/boot/dts/qcom/sm8150-xiaomi-vayu-*.dtb"
