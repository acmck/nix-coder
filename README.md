# nix-coder

The purpose of this repo is to build a "bare" linux container, for use with
Coder. The image should be built using nix.

Coder.com is a WebIDE for enterprise, based on
[code-server](https://github.com/coder/code-server). Coder providers several
"packaged" images for different stacks - e.g. nodejs, goland, Jupyter etc.

## Coder prerequisites 

The upstream documentation is not the best, with some contradictory information
available.

See:

 * [Writing custom images](https://coder.com/docs/coder/latest/images/writing)
 * [Minimums](https://github.com/coder/enterprise-images/#image-minimums)
 * [Examples](https://github.com/coder/enterprise-images/tree/main/images)

 ## Building

 1. Build image using `buildLayeredImage` using
    [dockerTools](https://nixos.org/manual/nixpkgs/stable/#sec-pkgs-dockerTools)

 ```bash
$ nix-build coder.nix -o image.tgz
these 3 derivations will be built:
  /nix/store/x4qzzjjj5djgkyaycvjv715wzrsncfy4-nix-shell-conf.json.drv
  /nix/store/3v0frirvln7fl218i84lbh0p3fi4w3a8-stream-nix-shell.drv
  /nix/store/ifrf633ss3lfjqlsjwn2hik5s7ba9haj-nix-shell.tar.gz.drv
building '/nix/store/x4qzzjjj5djgkyaycvjv715wzrsncfy4-nix-shell-conf.json.drv'...
{
  "architecture": "amd64",
  "config": {
[...]
Creating layer 100 with customisation...
Adding manifests...
Done.
/nix/store/anbpi6cs7rpry3k721q4mg3238ll93z1-nix-shell.tar.gz
```

2. Copy the image to a registry

```
$ skopeo --insecure-policy copy --dest-creds $CR_USER:$CR_PASS docker-archive:image.tgz docker://docker.io/acmck/nix-coder:0.0.1
Getting image source signatures
Copying blob fe9a5a345a02 done  
Copying blob 7bbfd6521109 done  
Copying blob 7c1f6edde326 done  
Copying blob 2faefbc8b956 done  
Copying blob e16e38ea2351 [==================================>---] 27.0MiB / 29.7MiB
Copying blob 685eb47c96a1 done
[]...]
Copying blob d6ee5dc9f6ff skipped: already exists  
Copying config 8720a993bf done  
Writing manifest to image destination
Storing signatures
```

3. Pull the tag, update coder workspace with new tag and try and start
   workspace.

## Issues

Coder copies assets to the running container in Step 9. This seems to be
successful, however, the workspace fails at a later step (step 11 - Failed to
start networking agent).

The step appears to fail on using a `tini` runtime, found at `/var/tmp/coder/init`.

## TODO

 [x] Build layer images 
 [ ] Make it work with coder 
 [ ] Pipeline 
 [ ] Copy the `configure` file to image (this is ran at runtime by coder)