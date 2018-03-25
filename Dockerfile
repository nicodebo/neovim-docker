FROM alpine:latest as builder

WORKDIR /mnt/build/ctags

RUN apk update && apk add \
	git \
	xfce4-dev-tools \
	build-base

RUN \
	git clone https://github.com/universal-ctags/ctags \
	&& cd ctags \
	&& ./autogen.sh \
	&& ./configure --prefix=/usr/local \
	&& make \
	&& make install


FROM alpine:latest

LABEL \
        maintainer="n.debonnaire@gmail.com" \
        url.github="https://github.com/nicodebo/neovim-docker" \
        url.dockerhub="https://hub.docker.com/r/nicodebo/neovim-docker/"

ENV \
        UID="1000" \
        GID="1000" \
        UNAME="neovim" \
        GNAME="neovim" \
        SHELL="/bin/sh" \
        WORKSPACE="/mnt/workspace" \
	NVIM_CONFIG="/home/neovim/.config/nvim" \
	NVIM_PCK="/home/neovim/.local/share/nvim/site/pack" \
	ENV_DIR="/home/neovim/.local/share/vendorvenv" \
	NVIM_PROVIDER_PYLIB="python3_neovim_provider" \
	PATH="/home/neovim/.local/bin:${PATH}"

COPY --from=builder /usr/local/bin/ctags /usr/local/bin

RUN apk update && apk add \
	# needed by neovim :CheckHealth to fetch info
	curl \
	# needed to change uid and gid on running container
	shadow \
	# needed to install apk packages
	sudo \
	# needed to switch user
        su-exec \
	# needed for neovim python3 support
	python3 \
	python3-dev \
	# needed for pipsi
	py3-virtualenv \
	# needed to compile python greenlet
	gcc \
	musl-dev \
	# needed to clone git repo
	git \
        neovim \
        neovim-doc

RUN \
	addgroup "${GNAME}" \
	&& adduser -D -G "${GNAME}" -g "" -s "${SHELL}" "${UNAME}" \
        && echo "${UNAME} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

RUN \
	sudo -u neovim python3 -m venv "${ENV_DIR}/${NVIM_PROVIDER_PYLIB}" \
	&& "${ENV_DIR}/${NVIM_PROVIDER_PYLIB}/bin/pip" install neovim

RUN \
	curl https://raw.githubusercontent.com/mitsuhiko/pipsi/master/get-pipsi.py | sudo -u neovim python3 \
	&& sudo -u neovim pipsi install python-language-server

RUN \
	mkdir -p "${NVIM_PCK}/common/start" "${NVIM_PCK}/filetype/start" "${NVIM_PCK}/colors/opt" \
	&& git -C "${NVIM_PCK}/common/start" clone --depth 1 https://github.com/tpope/vim-commentary \
	&& git -C "${NVIM_PCK}/common/start" clone --depth 1 https://github.com/tpope/vim-surround \
	&& git -C "${NVIM_PCK}/common/start" clone --depth 1 https://github.com/tpope/vim-obsession \
	&& git -C "${NVIM_PCK}/common/start" clone --depth 1 https://github.com/yuttie/comfortable-motion.vim \
	&& git -C "${NVIM_PCK}/common/start" clone --depth 1 https://github.com/wellle/targets.vim \
	&& git -C "${NVIM_PCK}/filetype/start" clone --depth 1 https://github.com/mattn/emmet-vim \
	&& git -C "${NVIM_PCK}/filetype/start" clone --depth 1 https://github.com/lervag/vimtex \
	&& git -C "${NVIM_PCK}/filetype/start" clone --depth 1 https://github.com/captbaritone/better-indent-support-for-php-with-html \
	&& git -C "${NVIM_PCK}/colors/opt" clone --depth 1 https://github.com/fxn/vim-monochrome \
	&& git -C "${NVIM_PCK}/common/start" clone --depth 1 https://github.com/autozimu/LanguageClient-neovim \
	&& cd "${NVIM_PCK}/common/start/LanguageClient-neovim/" && sh install.sh \
	&& chown -R neovim:neovim /home/neovim/.local

COPY entrypoint.sh /usr/local/bin/

VOLUME "${WORKSPACE}"
VOLUME "${NVIM_CONFIG}"

ENTRYPOINT ["sh", "/usr/local/bin/entrypoint.sh"]

# TODO: Remove unused packages in the final image
