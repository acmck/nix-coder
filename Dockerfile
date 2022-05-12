# Image used by coder env until nix build works, containing toolchain
# referenced in .coder/coder.yaml
FROM codercom/enterprise-base:arch

RUN sh <(curl -L https://nixos.org/nix/install) --daemon

RUN sudo pacman --noconfirm -Syu skopeo