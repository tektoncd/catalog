#!/usr/bin/env bash

kubectl -n ${tns} create secret generic gitlab-secret --from-literal token="secret"