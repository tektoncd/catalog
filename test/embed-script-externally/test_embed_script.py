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
import os.path
import tempfile
import unittest

import embed_script

taskreplace = """
apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: git-clone
spec:
  steps:
    - name: step1
      script: "#include %s"
"""


class Test(unittest.TestCase):
    def setUp(self):
        self.test_file = tempfile.NamedTemporaryFile(delete=False).name

    def tearDown(self):
        os.remove(self.test_file)

    def test_replace(self):
        scriptstr = "Et ipsa scientia potestas est"
        fp = open(self.test_file, 'w')
        fp.write(scriptstr)
        fp.close()

        blob = taskreplace % (self.test_file)
        ret = embed_script.replace(blob)
        if not ret:
            self.fail("we didn't get any task back")
        if scriptstr not in ret[0]:
            self.fail("we didn't get any replacement in task")

    def test_skip(self):
        strs = "nowheretobefile.bash"
        blob = taskreplace % strs
        ret = embed_script.replace(blob)
        if not ret:
            self.fail("we should still have task back")

        # TODO: monkeypatch sys.write to caputre the warning, but that's another fight for another day
        if "#include %s" % (strs) not in ret[0]:
            self.fail("we should have kept the #include")


if __name__ == '__main__':
    unittest.main()
