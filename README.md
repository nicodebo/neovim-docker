# Neovim-docker

My **personal** neovim environment (neovim + tools) as a Docker image

## Why ?

- Keep track of all external tools, specifically installed for neovim (ctags,
  syntax checkers, language server protocol,…)
- Keep track of all installed plugins
- Easily deploy your developement environnement on different machine with
  docker-hub
- Safely try new tools (e.g. language server protocol) in the sandbox environment

## Usage

`cd` into your top level project directory, then run the following docker
command:

```
docker run \
  --rm -it \
  [-e UID="1000" \]
  [-e GID="1000" \]
  [-v <your init.vim directory>:/home/neovim/.config/nvim \]
  -v <your workspace top level dir>:/mnt/workspace \
   nicodebo/neovim-docker:latest \
  [nvim arguments]
```

### Examples

* Open neovim with file1 and file2 stacked horizontally:

```

docker run \
    --rm -it \
    -v $(pwd):/mnt/workspace \
    nicodebo/neovim-docker:latest \
    -o file1 file2
```

* Open neovim with file1 and use your custom neovim configuration stored in the
  `.dotfile` directory under your `$HOME`:

```
docker run \
    --rm -it \
    -v $(pwd):/mnt/workspace \
    -v $HOME/.dotfiles/nvim:/home/neovim/.config/nvim \
    nicodebo/neovim-docker:latest \
    file1
```

* File permission issues may arise if the default `user id (1000)` and `group
  id (1000)` of the container does not match user id and group id of the host.

```
docker run \
    --rm -it \
    -v $(pwd):/mnt/workspace \
    -e UID="1003" \
    -e GID="1004" \
    nicodebo/neovim-docker:latest \
    -o file1 file2
```

You can find out your host user id and group id with the following command: `$ id`

## Local runtime/binary

For conveniance, you might want to define a function in your shell
configuration (bashrc, zshrc,…) to run neovim-docker as an executable, e.g.:

```
nvim() {
    docker run \
        --rm -it \
        -v $(pwd):/mnt/workspace \
        -v $HOME/.dotfiles/nvim:/home/neovim/.config/nvim \
        nicodebo/neovim-docker:latest \
        "$@"
       }
```

## Limitation

You must `cd` into the directory (preferably the top level directory of your
project) where the files you want to edit are located.

## Related project

* <https://github.com/bencao/vim_in_docker>
* <https://github.com/JAremko/alpine-vim>
* <https://github.com/JAremko/docker-emacs>
