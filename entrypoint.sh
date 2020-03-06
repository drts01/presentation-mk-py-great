#!/usr/bin/env bash
source ~/.bashrc

sed -i 's/margin:.*\,/margin: 0.02,/' \
  $(pipenv --venv)/share/jupyter/nbextensions/rise/reveal.js/js/reveal.js

pipenv run jupyter-notebook ${*}
