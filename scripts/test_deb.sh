#!/bin/bash
#
# Copyright (c) Facebook, Inc. and its affiliates.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Install a below .deb in an Ubuntu container running systemd and check the
# binary reports the package version and the recording service is enabled.
#   scripts/test_deb.sh <path/to/below.deb> [image]

set -eu

deb=$1
image=${2:-ubuntu:22.04}
container=below-deb-test

docker rm -f "$container" >/dev/null 2>&1 || true
docker run -d --name "$container" --privileged --cgroupns=host \
  --tmpfs /run --tmpfs /run/lock "$image" /bin/bash -c '
    export DEBIAN_FRONTEND=noninteractive
    apt-get update -qq
    apt-get install -y -qq systemd systemd-sysv >/dev/null
    exec /lib/systemd/systemd' >/dev/null
trap 'docker rm -f "$container" >/dev/null' EXIT

for _ in $(seq 60); do
  docker exec "$container" systemctl is-system-running >/dev/null 2>&1 && break
  sleep 2
done

# Not /tmp: systemd may mount a tmpfs over it after docker cp has written there.
docker cp "$deb" "$container:/root/below.deb"
docker exec "$container" apt-get install -y -qq /root/below.deb
docker exec "$container" below --version
test "$(docker exec "$container" below --version)" = "below $(dpkg-deb --field "$deb" Version)"
docker exec "$container" systemctl is-enabled below
