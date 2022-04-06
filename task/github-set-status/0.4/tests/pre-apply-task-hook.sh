#!/usr/bin/env bash

kubectl -n ${tns} create secret generic github-secret --from-literal token="secret"
