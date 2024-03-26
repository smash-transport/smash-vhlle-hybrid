#!/usr/bin/env python3

#===================================================
#
#    Copyright (c) 2024
#      SMASH Hybrid Team
#
#    GNU General Public License (GPLv3 or later)
#
#===================================================

# This is a simple script to check a python requirement and it is ASSUMED
# to be called with two arguments: the python package name and the version
# specifier (the latter must be correctly specified, i.e. according to
# https://peps.python.org/pep-0440/#version-specifiers).
#
# This script prints:
#
#   "found|version|OK"
#   if the package is installed and the version requirement is satisfied (exit 0)
#
#   "---|---|---"
#   if the package is NOT installed (exit 1)
#
#   "found|version|---"
#   if the package is installed, but the version requirement is NOT satisfied (exit 2)
#
#   "?|---|---"
#   if it was not possible to check requirement (exit 3)
#
# NOTE: This script should avoid as much as possible to import modules that are not
#       guaranteed to be always present, because this is a tool to check requirements.
#       This is why the import about non-standard modules is in a try-except block.

import sys
import os
import subprocess

try:
    from packaging.requirements import Requirement
except:
    print('?|---|---')
    exit(3)

requirement = sys.argv[1] + sys.argv[2]
package_name = sys.argv[1]

if os.environ.get('HYBRID_TEST_MODE') is not None:
    # Mock pip, useful in handler unit tests
    installed_packages = {"numpy": "1.26.4"}
else:
    pip_freeze_list = subprocess.check_output([sys.executable, '-m', 'pip', 'freeze'])
    pip_freeze_list = [line.decode().split('==') for line in pip_freeze_list.split()]
    installed_packages = {r[0]: r[1] for r in pip_freeze_list}

if package_name not in installed_packages.keys():
    print("---|---|---")
    exit(1)
else:
    available_version = installed_packages[package_name]
    if available_version in Requirement(requirement).specifier:
        print(f"OK|{available_version}|OK")
        exit(0)
    else:
        print(f"wrong|{available_version}|---")
        exit(2)
