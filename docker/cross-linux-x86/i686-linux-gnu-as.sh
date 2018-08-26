#!/usr/bin/env bash
exec ${0/${CROSS_NAME}-/x86_64-linux-gnu-} --32 "$@"
