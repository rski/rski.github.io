---
title: "Nix: the Swiss Army knife of dotfile management"
---

As I put the finishing tweaks on migrating my dotfiles from NixOS to my new Ubuntu-based work laptop, it dawned on me how much easier Nix has made the whole process. Last time I did this, it was from NixOS to NixOS, which was basically free. This time, Nix really got to shine, and I'd be remiss if I didn't compile a few notes about it. So, welcome to this weeks' Nix propaganda article: Xmas edition.

# Config files become completely portable between systems

Something the usual methods of managing dotfiles have in common is that they leave a lot of things up to the whims of the underlying system. In the past, the first step I would be forced to take is tweak my awesomewm config to cater to the idiosyncrasies of the packaged awesome. In theory, the awesomewm version was the same, in practice libraries were missing, certain things were slightly different or on different paths, and it was always a pain to figure out battery indicators out of all things. On one distro cbatticon is not packaged and the lua lib for awesome is easier to find and use, on another the opposite. Nix makes all that go away by managing everything: the installation of awesomewm, cbatticon and any awesome libraries written in lua that I want to use, be they already available in nixpkgs or repos on $hosted\_git\_service that I want to pull locally.

Invariably when Nix is mentioned, a big selling point is the reproducability of builds and how you can pin the inputs to specific versions to avoid __impurities_[^1]. That is very nice and useful, but not really needed in this case. I simply point my systems to the unstable nix channel, getting 90% of the benefit for 10% of the effort: Two versions of the same nix package off by a couple of days are almost always functionally equivalent, bar any breaking changes merging. Two different distros' versions of the same piece of software can be wildly different.

The only caviat is that nix can only take you so far. For example, home-manager generates an .xsession file that will start awesomewm, but you need sudo access on Ubuntu to add Xsession as a login option[^2].

# Nix is more than a difficult symlink creator

This is a double edged sword[^3], but once you get past the initial hurdle things really start to take off. Both Nix/home-manager and stow can link config files into paths under `$HOME`. Here are some thing you can do with Nix _beyond_ that:

- link repositories into `$HOME` paths

Bash scripting and/or submodules are an option, but why do that when with home-manager it's [as simple as](https://gitlab.com/rski/dotfiles/-/blob/ebbeb2c1a3b4b019675ce82a84e1016b3d8c6dcf/nixpkgs/home.nix#L391):

    xdg.configFile."cheat/cheatsheets/community".source = pkgs.fetchFromGitHub {
      owner = "cheat";
      repo = "cheatsheets";
      rev = "9006d4ec749ea25b404397ea450cca3d240f52af";
      sha256 = "0lhi4kaj04v7yflpm5m4mjnk779wcpxiwi6i43psavxzmjiraz6r";
    };

With Nix, it doesn't even have to be limited to a repository. The above code is a shorthand for "copy the GitHub repo into /nix/store/, and create a symlink at `~/.config/cheat/cheatsheets/community` that points to the resulting store path". By the virtue of Nix, this symlink could point the result of a compilation, or a file belonging to a package already installed with nix[^4].

- use the Nix language to handle system differences

Sure, portable bash is a thing, but so is sticking a fork in your eyes. With Nix:

    let
      inNixos = builtins.pathExists /etc/nixos;
      wmCommand =
        if !inNixos then pkgs.lib.mkForce "${nixGL}/bin/nixGL ${pkgs.awesome}/bin/awesome" else pkgs.lib.mkDefault "";
    ...

I will be the first to admit this looks like a bunch of gobbledygook, but once you get with Nix, this is infinitely better than anything I could hope to achieve with bash or any other Unix footgun.

- avoid YAML and JSON

It is entirely possible[^5] to write out a data structure in Nix and have that serialised into YAML or JSON or whathave you, thereby avoiding the feeling of korporate kubernetes dayjob.

# Customizing programs becomes a breeze

The Nix community provides overlays for newever versions of programs that I very frequently want. I have been using the emacs overlay to get Emacs built from master for a long time now, and it works wonderfully. And yes, I do use home-manager to [set up the overlay](https://gitlab.com/rski/dotfiles/-/blob/ebbeb2c1a3b4b019675ce82a84e1016b3d8c6dcf/nixpkgs/home.nix#L399). The more time passes since the last time I had to search "emacs install build deps ubuntu", the happier I am as a person.

In a similar fashion, overrides make it possible to take something that is already packaged in nixpkgs and build it with different flags, patches or whatever else you might come up with.

# Nix/home-manager can configure more than you care for

For a very long time I was told home-manager was great, and I did not listen. Do not make my mistake. I am not sure how I lived without it. It can manage anything between xkeyboard options, user services and env variables.

Similar to NixOS, `home-manager` provides modules and comes with man pages and other documentation for all of it. I cannot overstate how convenient it is to let a `home-manager` module generate a config for me after specifying a few interesting options in Nix. [My fish config](https://gitlab.com/rski/dotfiles/-/blob/ebbeb2c1a3b4b019675ce82a84e1016b3d8c6dcf/nixpkgs/home.nix#L260) contains almost no fish. The Nix module provides a good structure and generates config files that behave better than what I would have written after an hour with the fish docs.

# It's not all roses

Nix is not all that perfect. Other than the aforementioned learning curve and the language being a bit "not that great", throwing nixpkgs into the mix of a non-NixOS distribution can break things. This is an unfortunate result of how programs built with Nix have their runtime deps isolated.

One problem that is easy to run into, is spawining non-nix programs from within ones installed with Nix can cause them to blow up. `gnome-terminal` in Ubuntu has been tested to work with the python libraries under `/usr/share`. If it is started by a program whose wrapper sets `PYTHONPATH`, that won't work out well[^6]. A simple solution is to avoid mixing programs, probably using as much Nix as possible.

The other issue that I encountered is that Nix + OpenGL on non-NixOS systems is a bit broken. Thankfully [nixGL](https://github.com/guibou/nixGL) fixes all that and it worked perfectly for me without any effort. Special shout out to their test suite being an executable Haskell file that uses nix-shell as the interpreter that installs its dependencies and runs it.

[^1]: Whatever that might mean ¯\_(ツ)_/¯

[^2]: https://gitlab.com/rski/dotfiles/-/commit/22ec88186de7f54808d543a4622ea328cb17ddda

[^3]: something something learning curve

[^4]: Ummmm acccctually, Nix will install any packages as needed for you. For example, with `..."awesomeshare".source = "${pkgs.awesome}/share" ;` nix will realise awesome into the store and create the symlink, without even putting awesome into the `$PATH`.

[^5]: At least I think it is. I've never done it.

[^6]: This does sound suspiciously similar to coloured functions, https://journal.stuffwithstuff.com/2015/02/01/what-color-is-your-function/
