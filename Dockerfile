FROM registry.fedoraproject.org/fedora:rawhide

EXPOSE 8888

RUN cd && set -ex &&\
  dnf --assumeyes install aria2 findutils gcc git-core make zeromq-devel jq \
    which neovim starship gnu-free-sans-fonts fortune-mod \
    bzip2 bzip2-devel libffi-devel readline-devel openssl-devel sqlite sqlite-devel xz xz-devel zlib-devel \
    libjpeg-devel openjpeg2-devel lcms2-devel harfbuzz-devel libraqm-devel libimagequant-devel &&\
  printf 'source <("/usr/bin/starship" init bash --print-full-init)\n' > /etc/profile.d/starship.sh &&\
  useradd -UmG users -c 'Default User' -u 5150 demo &&\
  python3 -m ensurepip
#   dnf --assumeyes autoremove &&\
#   dnf --assumeyes clean all &&\
#   find /etc -name \*.rpmnew -delete &&\
#   rm -rf -- /root/.cache

USER demo
ENV CFLAGS="-O2 -pipe -march=native -Wno-unused-value -Wno-empty-body -Wno-parentheses-equality" \
    # CONFIGURE_OPTS="--enable-optimizations" \
    PYTHON_BUILD_ARIA2_OPTS="--min-split-size=1M --max-connection-per-server=10 --optimize-concurrent-downloads=true"
RUN cd && PATH="${HOME}/.local/bin:${PATH}" && set -ex &&\
  mkdir -p "${HOME}/.config/pip" &&\
  printf "[global]\ndisable-pip-version-check = True" >> "${HOME}/.config/pip/pip.conf" &&\
  git clone --depth 1 --single-branch https://github.com/pyenv/pyenv.git ~/.pyenv &&\
  mkdir -p ${HOME}/.local/bin &&\
  ln -rsv ~/.pyenv/bin/pyenv ~/.local/bin/ &&\
  printf 'eval "$(pyenv init -)"' >> ${HOME}/.bashrc
#   eval "$(pyenv init -)" &&\
RUN pyenv install --verbose 3.9-dev &&\
RUN  pyenv install --verbose 3.7.6 &&\
RUN  pyenv install --verbose 2.7.17 &&\
RUN  pyenv install --verbose pypy3.6-7.3.0 &&\
RUN  pyenv global 3.9-dev pypy3.6-7.3.0 3.6.10
#   rm -rf -- ~/.cache
RUN cd && PATH="${HOME}/.local/bin:${PATH}" && eval "$(pyenv init -)" && set -ex &&\
  python3 -m pip install --no-cache-dir --user git+https://github.com/pipxproject/pipx.git@c6515ff &&\
  pipx install poetry &&\
  pipx run --spec=pyjokes pyjoke &&\
  pipx run cowsay $(fortune -s) &&\
  pipx install git+https://github.com/pypa/pipenv.git@d10b2a216a25623ba9b3e3c4ce4573e0d764c1e4
#  rm -rf -- ~/.cache

ENV PIPENV_CACHE_DIR="/home/demo/.cache/pip" \
    PIPENV_IGNORE_VIRTUALENVS=1 \
    PIPENV_SKIP_LOCK=true
WORKDIR /home/demo/project
COPY [ "Pipfile", "./" ]
RUN PATH="${HOME}/.local/bin:${PATH}" && set -ex &&\
  pipenv --python "$(pyenv which pypy3)" install &&\
  rm -rf -- ~/.cache &&\
  pipenv install --dev &&\
  pipenv run python3 -m pip uninstall --yes gnupg &&\
  mkdir -p ~/pipenv-example

COPY --chown=5150:users [ "entrypoint.sh", "./" ]
ENTRYPOINT [ "./entrypoint.sh" ]
CMD [ "--no-browser", "--ip=0.0.0.0", "--debug" ]
