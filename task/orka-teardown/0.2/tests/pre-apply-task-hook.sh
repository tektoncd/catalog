#!/bin/bash

# Modify orka-init
ORKA_INIT=$(mktemp /tmp/.mm.XXXXXX)
MOD_SCRIPT=${taskdir}/tests/mods/mod_task.py
cp task/orka-init/0.2/orka-init.yaml ${ORKA_INIT}
python3 ${MOD_SCRIPT} ${ORKA_INIT} > ${ORKA_INIT}.mod

# Add orka-init
${KUBECTL_CMD} -n "${tns}" apply -f ${ORKA_INIT}.mod
rm -f ${ORKA_INIT} ${ORKA_INIT}.mod

# Modify task
cp ${TMPF} ${TMPF}.read
python3 ${MOD_SCRIPT} ${TMPF}.read > ${TMPF}
rm -f ${TMPF}.read
