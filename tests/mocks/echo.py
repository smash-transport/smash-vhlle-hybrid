#!/usr/bin/env python3

#===================================================
#
#    Copyright (c) 2025
#      SMASH Hybrid Team
#
#    GNU General Public License (GPLv3 or later)
#
#===================================================

# This is a simple script to provide a fake executable for testing mocking purposes.
# It has a --version option to provide a fake version, which can be injected through
# the MOCK_ECHO_VERSION environment variable.

import sys
import os

if sys.argv[1] == "--version":
    environment_version = os.environ.get("MOCK_ECHO_VERSION")
    if environment_version is None:
        print("Fake-version-3.1.1")
    else:
        print(environment_version)
else:
    print(' '.join(sys.argv[1:]))
