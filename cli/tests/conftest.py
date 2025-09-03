import os
import sys

# This is required for pytest to find the location of our sources.
# Required because we do not work with a proper python package with
# development mode.
_project_root = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
sys.path.insert(0, _project_root)
sys.path.insert(0, os.path.join(_project_root, "src"))
