#!/usr/bin/env sh

sed -i 's/margin:.*\,/margin: 0.02,/' \
  $(pipenv --venv)/share/jupyter/nbextensions/rise/reveal.js/js/reveal.js
bash -lc "pipenv run jupyter-notebook ${*}"
