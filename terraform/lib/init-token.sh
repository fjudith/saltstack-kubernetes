#!/usr/bin/env bash
set -e

function usage {
    echo "USAGE: $0 <output-dir>"
    echo "  example: $0 ./ssl/token.csv"
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

OUTFILE=${OUTFILE:-"$OUTDIR/token.csv"}

if [ -f "$OUTFILE" ];then
    exit 0
fi

export BOOTSTRAP_TOKEN=$(head -c 16 /dev/urandom | od -An -t x | tr -d ' ')
echo "Token: ${BOOTSTRAP_TOKEN}"

cat > $OUTFILE <<EOF
${BOOTSTRAP_TOKEN},kubelet-bootstrap,10001,"system:bootstrappers"
EOF
