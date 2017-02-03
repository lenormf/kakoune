#! /usr/bin/env bash

readonly PATH_DIR=$(dirname "$(readlink -e "$0")")
readonly PATH_ROOT=$(readlink -e "${PATH_DIR}/..")
readonly PATH_DIR_SRC=$(readlink -e "${PATH_ROOT}/src")
readonly PATH_DIR_RC=$(readlink -e "${PATH_ROOT}/rc")
readonly PATH_DIR_FUZZ="${PATH_ROOT}/fuzz"
readonly PATH_KAK="${PATH_DIR_SRC}/kak"

function _echo {
    printf %s\\n "$@"
}

function fatal {
    _echo "$@" >&2
    exit 1
}

function fuzz_with_seed {
    seed=$1
    ratio=$2

    find "${PATH_DIR_RC}" -type f -name \*.kak | while read -r rc; do
        if [ $((RANDOM % 2)) -ne 0 ]; then
            continue
        fi

        path_tmp=$(mktemp)
        if zzuf -s "${seed}" -r "${ratio}" -i < "${rc}" > "${path_tmp}"; then
            rm -f "${rc}"
            mv "${path_tmp}" "${rc}"
        else
            fatal "Unable to fuzz file: ${rc} (output: ${path_tmp})"
        fi
    done

    mkdir -p "${PATH_DIR_FUZZ}"

    path_out="${PATH_DIR_FUZZ}/out"
    eval "${PATH_KAK} -clear"
    eval "${PATH_KAK} -s kak-fuzz -ui json -e 'quit!'" > "${path_out}" 2>&1
    code_exit=$?

    if [ "${code_exit}" -gt 127 ]; then
        _echo "Packing files with parameters: seed=${seed} ratio=${ratio}"

        path_archive="${PATH_DIR_FUZZ}/pack_${code_exit}_$1_$(date +%s).tar"

        if ! tar cf "${path_archive}" -C "$(dirname "${path_out}")" "${path_out##*/}" >/dev/null; then
            fatal "Unexpected error: unable to pack resource files"
        fi

        git diff --name-only -- "${PATH_DIR_RC}" | while read -r f; do
            if ! tar rf "${path_archive}" -C "${PATH_ROOT}" "${f}" >/dev/null; then
                fatal "Unexpected error: unable to pack resource files"
            fi
        done
    fi
}

function main {
    if ! command -v zzuf 1>/dev/null; then
        fatal "No such command: zzuf"
    fi

    if [ ! -x "${PATH_KAK}" ]; then
        fatal "No such file: ${PATH_KAK}"
    fi

    while true; do
        SEED_ZZUF=${RANDOM}
        ## XXX: bash won't support high accuracy, but we're not intersted in fuzzing more than 9.9% anyway
        RATIO_ZUFF=$(printf '%.3d' $((RANDOM % 99 + 1)) | sed 's/^/./')

        fuzz_with_seed "${SEED_ZZUF}" "${RATIO_ZUFF}"

        git checkout "${PATH_DIR_RC}"
    done
}

main "$@"
