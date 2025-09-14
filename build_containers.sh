#!/bin/bash

set -e

docker build --tag sq_via_apt --file Dockerfile.apt_install .
docker build --tag sq_via_cargo --file Dockerfile.cargo_install .
