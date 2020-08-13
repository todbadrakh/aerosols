# Configuration file for the Sphinx documentation builder.
#
# This file only contains a selection of the most common options. For a full
# list see the documentation:
# https://www.sphinx-doc.org/en/master/usage/configuration.html

# -- Path setup --------------------------------------------------------------

# If extensions (or modules to document with autodoc) are in another directory,
# add these directories to sys.path here. If the directory is relative to the
# documentation root, use os.path.abspath to make it absolute, like shown here.
#
# import os
# import sys
# sys.path.insert(0, os.path.abspath('.'))


# -- Project information -----------------------------------------------------

project = 'aerosols'
copyright = '2020, Tuguldur T. Odbadrakh'
author = 'Tuguldur T. Odbadrakh'
release = '0.1.1'

# -- General configuration ---------------------------------------------------
templates_path = ['_templates']
exclude_patterns = ['_build', 'Thumbs.db', '.DS_Store']

#html_theme = 'default'
html_static_path = ['_static']
extensions_path = ['_extensions']
extensions = ['sphinxcontrib.fulltoc']
