#!/bin/bash

kubectl delete clusterrole orka-runner --ignore-not-found
kubectl delete clusterrolebinding orka-runner --ignore-not-found

cp ${TMPF} ${TMPF}.mod
python3 ${taskdir}/tests/mods/mod_task.py ${TMPF}.mod > ${TMPF}
rm -f ${TMPF}.mod
