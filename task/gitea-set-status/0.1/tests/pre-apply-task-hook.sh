#!/usr/bin/env bash

kubectl -n ${tns} create secret generic gitea --from-literal token="secret"
