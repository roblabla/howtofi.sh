#!/bin/sh

set -e

docker load < $(nix-build --no-out-link default.nix)
docker stop gollum || true
docker rm gollum || true
docker run --name gollum --rm -d -p 4567:4567 -v $(pwd):/wiki -v $HOME/.ssh/howtofish_ecdsa:/ssh_key gollum gollum --config /wiki/config.rb
