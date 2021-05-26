#!/usr/bin/env python3
#
# Copyright 2021 The Tekton Authors
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
import argparse
import io
import os.path
import re
import sys
import typing

from ruamel.yaml import YAML

REGEXP = r"^#include\s*([^$]*)"


def replace(yamlBlob: str) -> typing.List:
    yaml = YAML()
    docs = yaml.load_all(yamlBlob)
    rets = []
    for doc in docs:
        if "spec" not in doc and "tasks" not in doc["spec"]:
            continue
        for task in doc["spec"]["steps"]:
            if "script" not in task:
                continue
            if not task["script"].startswith("#include "):
                continue
            match = re.match(REGEXP, task["script"])
            if not match:
                continue
            filename = match[1].strip()
            if not os.path.exists(filename):
                sys.stderr.write(
                    f"WARNING: we could not find a file called: {filename} in task: {doc['metadata']['name']} step: {task['name']}"
                )
                continue
            fp = open(filename)
            task["script"] = fp.read()
            fp.close()
        output = io.StringIO()
        yaml.dump(doc, output)
        rets.append(output.getvalue())
    return rets


def parse_args():
    parser = argparse.ArgumentParser(
        description="Manage your embedded Tekton script task externally")
    parser.add_argument("yaml_file", help="Yaml file to parse")
    return parser.parse_args()


if __name__ == "__main__":
    args = parse_args()
    replaced = replace(open(args.yaml_file))
    for doc in replaced:
        if not doc or not doc.strip():
            continue
        print("---")
        print(doc)
