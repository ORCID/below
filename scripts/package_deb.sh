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

# Package an already built below binary as a .deb in target/<triple>/debian/.
#   scripts/package_deb.sh <target triple>
# The binary must be at target/<triple>/release/below.

set -eu

cd "$(dirname "$(realpath "$0")")"/..

triple=$1
crate_version=$(sed -n 's/^version = "\(.*\)"/\1/p' below/Cargo.toml | head -1)

# Commits since the v<crate_version> tag sort after that release and before the next.
describe=$(git describe --tags --match "v$crate_version" --long --abbrev=12)
since=$(sed -E 's/^.*-([0-9]+)-g[0-9a-f]+$/\1/' <<<"$describe")
commit=$(sed -E 's/^.*-g([0-9a-f]+)$/\1/' <<<"$describe")
version=$crate_version
if [ "$since" != 0 ]; then
  version="$crate_version+git$since.$commit"
fi

cargo deb --package below --no-build --target "$triple" --deb-version "$version"
