with import <nixpkgs> {};

let
    nonRootShadowSetup = { user, uid, gid ? uid }: with pkgs; [
      (
      writeTextDir "etc/shadow" ''
        root:!x:::::::
        ${user}:!:::::::
      ''
      )
      (
      writeTextDir "etc/passwd" ''
        root:x:0:0::/root:${runtimeShell}
        ${user}:x:${toString uid}:${toString gid}::/home/${user}:/bin/bash
      ''
      )
      (
      writeTextDir "etc/group" ''
        root:x:0:
        ${user}:x:${toString gid}:
      ''
      )
      (
      writeTextDir "etc/gshadow" ''
        root:x::
        ${user}:x::
      ''
      )
    ];
in

pkgs.dockerTools.buildLayeredImage {
  name = "nix-shell";
  tag = "0.0.1";
  created = "now";

  contents = with pkgs; [
    kubectl
    kubernetes-helm
    terraform
    yq
    jq
    bash
    coreutils
    python3
    moreutils
    git
    cacert
    curl
    getent
    shadow
    sudo
    gnutar
    nix
    docker
    docker-compose
    systemd
    python3
  ] ++ nonRootShadowSetup { uid = 1000; user = "coder"; };

  fakeRootCommands = ''
      mkdir -p ./var/tmp/
      chmod 1777 ./var/tmp/
    '';

  config = {
    Cmd = [ "/bin/bash" ];
    WorkingDir = "/home/coder";
    User = "coder";
    Env = [
      "SSL_CERT_FILE=/etc/ssl/certs/ca-bundle.crt"
      "NIX_PAGER=cat"
    ];
  };
}
