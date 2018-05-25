#!/usr/bin/env bash
set -e

function usage {
    echo "USAGE: $0 <output-dir>"
    echo "  example: $0 ./ssl/encryption-key.txt"
}

if [ -z "$1" ]; then
    usage
    exit 1
fi

OUTDIR="$1"

if [ ! -d $OUTDIR ]; then
    echo "ERROR: output directory does not exist:  $OUTDIR"
    exit 1
fi

OUTFILE=${OUTFILE:-"$OUTDIR/encryption-key.txt"}

if [ -f "$OUTFILE" ];then
    exit 0
fi

export ENCRYPTION_KEY=$(head -c 32 /dev/urandom | base64)
echo "Encryption key: ${ENCRYPTION_KEY}"

cat > $OUTFILE <<EOF
${ENCRYPTION_KEY}
EOF
