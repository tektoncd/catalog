#!/bin/bash

cp ${TMPF} ${TMPF}.mod
python3 ${taskdir}/tests/mods/mod_task.py ${TMPF}.mod > ${TMPF}
rm -f ${TMPF}.mod
