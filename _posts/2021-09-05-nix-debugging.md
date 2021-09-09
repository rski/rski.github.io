---
title: Debug symbols for binaries with Nix
---

Howdy,

The other week I was trying to produce an invoice for my contracting services, which meant using the venerable GnuCash. Unfortunately for everyone involved, some combination of dates on the invoice resulted in a segfault when trying to print it. This led me to a rabbit hole of trying to produce debugging symbols. `@ilkecan` on the Nix matrix was most helpful in putting the pieces together. This post details what worked and what I expected to work but didn't.

# enableDebugging - pack debug info in the binary #

This is probably the easiest way to get going, and it has two properties:

- it disables optimisations
- it packs debug information in the resulting binary.

This means that it is not particularly useful for shipping a derivation, but it is more than good enough for local debugging. For example,

```bash
nix show-derivation (env NIX_PATH=nixpkgs=$HOME/Code/nix/nixpkgs nix-instantiate  --expr "with import <nixpkgs> {}; enableDebugging gnucash")
```

dumps information about the new derivation. The interesting parts are under env, `NIX_CFLAGS_COMPILE` and `dontStrip`:

```
rski@neonauticus ~/C/n/nixpkgs ((21.05))> nix show-derivation (env NIX_PATH=nixpkgs=$HOME/Code/nix/nixpkgs nix-instantiate  --expr "with import <nixpkgs> {}; enableDebugging gnucash") | jq -r '.[].env.NIX_CFLAGS_COMPILE'
-DGLIB_DISABLE_DEPRECATION_WARNINGS -ggdb -Og
nix show-derivation (env NIX_PATH=nixpkgs=$HOME/Code/nix/nixpkgs nix-instantiate  --expr "with import <nixpkgs> {}; gnucash") | jq -r '.[].env.NIX_CFLAGS_COMPILE'
-DGLIB_DISABLE_DEPRECATION_WARNINGS
```

Compared to the original derivation, Nix has added a couple of extra flags to be passed to the compiler. Similarly, `dontStrip` is set to 1, so that the build stage that strips debug info from the binary does not do so.

To compile the binary:

```bash
env NIX_PATH=nixpkgs=$HOME/Code/nix/nixpkgs nix-build  --expr "with import <nixpkgs> {}; enableDebugging gnucash"
```

This produces a `./result/bin/gnucash` symlink that points to the Nix store, which can be debugged with

```bash
gdb --args bash ./result/bin/gnucash
```

The Nix code of interest is under [enableDebugging](https://github.com/NixOS/nixpkgs/blob/7e9b0dff974c89e070da1ad85713ff3c20b0ca97/pkgs/top-level/all-packages.nix#L678) and [keepDebugInfo](https://github.com/NixOS/nixpkgs/blob/7e9b0dff974c89e070da1ad85713ff3c20b0ca97/pkgs/stdenv/adapters.nix#L183).

## caveats ##
One caveat worth mentioning at this point, is that at the time of writing it's [broken on the latest nixpkgs](https://github.com/NixOS/nixpkgs/issues/136756). This is the reason for using the 21.05 branch in the examples above.

Another problem that I encountered and have not figured out yet is that even on 21.05 `nix-build`ing `gnucash` works, but `nix-build`ing `enableDebugging gnucash` does not, as a warning kills the build. Currently, I am not sure what causes the compiler to emit the warning and/or consider it fatal.

On the plus side, the warning was fixed in GnuCash 4.6, so merely [updating](https://github.com/NixOS/nixpkgs/pull/135957) it in nixpkgs fixes that. I also had to submit a [patch](https://github.com/NixOS/nixpkgs/pull/135957/files) to fix another warning, which will be in the next version of GnuCash. As luck would have it, GnuCash 4.6 seems to have fixed my original problem too.

# separateDebugInfo - keep debug info elsewhere in the store #

`separateDebugInfo` is similar enough to `enableDebugging`, but has different properties:

- the debug information is kept in a different path in the store
- the binary does _not_ have optimisations turned off.

This makes it safe to enable in a shipping derivation. In fact, various packages in nixpkgs do have it enabled by default,e.g.

```bash
rg -l "separateDebugInfo = true" pkgs/development/libraries/glibc/default.nix
pkgs/development/libraries/glibc/default.nix
```

The great advantage of this is that for slower to compile packages or low level packages where debug info is quite frequently useful, there is no need to recompile them locally. If the nixpkgs derivation has `separateDebugInfo` set, the debug info can be fetched from the cache.

## caveats ##

I believe the biggest caveat at this point is figuring out what needs to be configured so that nix creates a symlink unlder `~/.nix-profile/lib/debug`, pointing to the debug info in the store. The Nix documentation implies that it should just work if you do some things, but that is not the case. Here is a case by case breakdown of what neeeds to be done:

- installing the package via `nix-env`

If you are installing the package via `nix-env`, the package needs to be overriden. The override will look something like:

```
gnucash.overrideAttrs (old: rec {
      name = "mygnucash";
      separateDebugInfo = true;
      meta = old.meta // { outputsToInstall = old.meta.outputsToInstall or [ "out" ] ++ [ "debug" ]; };
)
```

This is because `nix-env` only installs `out`. `meta.outputsToInstall` needs to explicitly contain the `debug` output.
[The Nix manual](https://nixos.org/manual/nixpkgs/stable/#stdenv-separateDebugInfo) says that `separateDebugInfo` will automatically add `debug` to the derivation's outputs, which is right, but it will not be installed as is implied.

For a NixOS system, on top of this, `environment.enableDebugInfo = true` needs to be set. The code for `environment.enableDebugInfo` is [here.](https://github.com/NixOS/nixpkgs/blob/7e9b0dff974c89e070da1ad85713ff3c20b0ca97/nixos/modules/config/debug-info.nix)

I am not sure whether other settings are needed to make this work on a non-NixOS system, as I have not experimented on one. I would expect none.

- installing via `environment.systemPackages` on NixOS

This only requires setting `separateDebugInfo = true` in the override and `environment.enableDebugInfo = true` in the NixOS config. The debug info in this case will be available under `/run/current-system/sw/lib/debug` instead of `~/.nix-profile`.

- installing via `home-manager`

home-manager provides `home.enableDebugInfo`. This will add `debug` to `extraOutputsToInstall` and will also set `$NIX_DEBUG_INFO_DIRS` to include the `lib/debug` directory with the resulting symlinks. This is similar to the equivalent NixOS setting. This allows `gdb` to find the debug symbols, according to [the oridinal PR that introduced it](https://github.com/nix-community/home-manager/commit/0056a5aea1a7b68bdacb7b829c325a1d4a3c4259)

I would expect home-manager to not require overriding `meta.outputsToInstall` either, only `separateDebugInfo` if the original derivation does not set it.

# Recap #

All being said and done, `enableDebugging` and `separateDebugInfo` allow getting debug symbols for a package with their own tradeoffs. They can be used together or separately, depending on what properties you want to keep in the binary you are looking to debug.

There are different ways to get the result of `separateDebugInfo` depending on how the derivation is installed. I hope I've illuminated a bit of each, because figuring out what I had to do and where symlinks ended up was what lead me to asking on matrix in the first place.

And, as a tip from me to past me that you might also find useful: to debug something installed with nix, `gdb --args bash gnucash` is probably the right invocation.

# Useful links #

- [Debug Symbols on NixOS wiki](https://nixos.wiki/wiki/Debug_Symbols) This NixOS wiki entry also explains teaching gdb how to find the source.
- [Mayflower - Inspecting coredumps like it's 2021](https://nixos.mayflower.consulting/blog/2021/09/06/coredumpctl) This was posted while I was writing. That is what I get for procrastinating. I would like to consider these articles as a good complement to each other.
- [Nix: Under the hood by Gabriella Gonzalez](https://www.youtube.com/watch?v=GMQPzv3Sx58) Honourable mention, this is a very good talk from which I learned a lot of useful tricks, some of which ended up in this page.
