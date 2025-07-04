#!/usr/bin/env bash
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.

set -e
set -u
set -o pipefail

main() {
    local -r source_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

    if [[ ! -f "${source_dir}/.env" ]]; then
        echo "You must create ${source_dir}/.env"
        echo "You can use ${source_dir}/.env.example as a template"
    fi

    source "${source_dir}/.env"

    echo "Remove all RCs"
    dev_base_url=https://dist.apache.org/repos/dist/dev/arrow
    old_rcs=$(
      svn ls ${dev_base_url}/ | \
      (grep -E '^apache-arrow-nanoarrow-[0-9]' || :) | \
      sort --version-sort
    )
    for old_rc in ${old_rcs}; do
      echo "Remove RC: ${old_rc}"
      svn \
        delete \
        --username=${APACHE_USERNAME} \
        -m "Remove old Apache Arrow nanoarrow RC: ${old_rc}" \
        ${dev_base_url}/${old_rc}
    done

    echo "Keep only the latest release"
    release_base_url=https://dist.apache.org/repos/dist/release/arrow
    old_releases=$(
      svn ls ${release_base_url}/ | \
      (grep -E '^apache-arrow-nanoarrow-[0-9]' || :) | \
      sort --version-sort --reverse | \
      tail -n +2 | \
      sort --version-sort
    )
    for old_release_version in $old_releases; do
      echo "Remove old release: ${old_release_version}"
      svn \
        delete \
        --username=${APACHE_USERNAME} \
        -m "Remove old Apache Arrow nanoarrow release: ${old_release_version}" \
        ${release_base_url}/${old_release_version}
    done

    echo "Success! See the current artifacts:"
    echo "  ${dev_base_url}/"
    echo "  ${release_base_url}/"
}

main "$@"
