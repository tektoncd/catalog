#!/usr/bin/env bash

kubectl -n ${tns} create secret generic github --from-literal token="secret"
