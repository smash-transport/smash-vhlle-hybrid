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
#   "OK|version|OK"
#   if the package is installed and the version requirement is satisfied (exit 0)
#
#   "OK|---|OK"
#   if the package is installed, has no version, but there is no version requirement (exit 0)
#
#   "---|---|---"
#   if the package is NOT installed (exit 1)
#
#   "OK|version|---"
#   if the package is installed, but the version requirement is NOT satisfied (exit 2)
#
#   "?|---|---"
#   if it was not possible to check requirement (exit 3)
#
#   "OK|---|?"
#   if the package is installed, but has no version and it was not possible to check requirement (exit 4)
#
# NOTE: This script should avoid as much as possible to import modules that are not
#       guaranteed to be always present, because this is a tool to check requirements.
#       This is why the import about non-standard modules is in a try-except block.

import sys
import os
import subprocess

package_name = sys.argv[1]
version_specifier = sys.argv[2]
requirement = package_name + version_specifier

try:
    from packaging.requirements import Requirement
except:
    if package_name == 'packaging':
        print('---|---|---')
        exit(1)
    else:
        print('?|---|---')
        exit(3)

if os.environ.get('HYBRID_TEST_MODE') is not None:
    # Mock pip, useful in handler unit tests
    installed_packages = {"packaging": "24", "numpy": "1.26.4", "pyDOE": "", "PyYAML": "5.0"}
else:
    pip_freeze_list = subprocess.check_output([sys.executable, '-m', 'pip', 'list', '--format=freeze'])
    pip_freeze_list = [line.decode().split('==') for line in pip_freeze_list.split()]
    installed_packages = {}
    for r in pip_freeze_list:
        if len(r) == 1:
            installed_packages[r[0]] = ''
        elif len(r) == 2:
            installed_packages[r[0]] = r[1]

if package_name not in installed_packages.keys():
    print("---|---|---")
    exit(1)
else:
    available_version = installed_packages[package_name]
    if available_version == "":
        if version_specifier == "":
            print("OK|---|OK")
            exit(0)
        else:
            print("OK|---|?")
            exit(4)
    else:
        if available_version in Requirement(requirement).specifier:
            print(f"OK|{available_version}|OK")
            exit(0)
        else:
            print(f"wrong|{available_version}|---")
            exit(2)
