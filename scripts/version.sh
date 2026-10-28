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


# Print the version for a build of this checkout. Commits since the
# v<crate version> tag sort after that release and before the next.

set -eu

cd "$(dirname "$(realpath "$0")")"/..

crate_version=$(sed -n 's/^version = "\(.*\)"/\1/p' below/Cargo.toml | head -1)
describe=$(git describe --tags --match "v$crate_version" --long --abbrev=12)
since=$(sed -E 's/^.*-([0-9]+)-g[0-9a-f]+$/\1/' <<<"$describe")
commit=$(sed -E 's/^.*-g([0-9a-f]+)$/\1/' <<<"$describe")
if [ "$since" = 0 ]; then
  echo "$crate_version"
else
  echo "$crate_version+git$since.$commit"
fi
