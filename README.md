# funkin-nix

Nix flake packaging **Friday Night Funkin' (FNF)** (v0.4.1 Weekend 1 / V-Slice) for NixOS, featuring automatic FHS isolation (full `libvlc` video cutscene & OpenGL audio support) and optional **Turkish Story Mode** translations.

---

[Türkçe README için tıklayın](README.tr.md)

---

## Features

- **Ready to play on NixOS:** Runs smoothly in a tailored FHS environment with all OpenGL, ALSA/PipeWire, and `libvlc` cutscene video dependencies pre-configured.
- **Turkish Story Mode (`funkin-tr`):** Includes custom Turkish translations for interactive story mode dialogues and levels (Week 6 Senpai, Roses, Thorns, etc.).
- **User data isolation:** Saves scores, custom data, and user mods in `~/.local/share/funkin` so the Nix store stays immutably clean while custom mods and scores persist.
- **Desktop integration:** Provides `.desktop` files and application icons for your launcher (Rofi, Walker, GNOME, KDE, Quickshell, etc.).

## Quick Start

### Run directly without installing:

```bash
# Default (English)
nix run github:tempestian/funkin-nix

# Turkish Story Mode
nix run github:tempestian/funkin-nix#funkin-tr
```

---

## Installation via NixOS Configuration

### 1. Add Flake Input

In your `flake.nix`:

```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    funkin-nix = {
      url = "github:tempestian/funkin-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, funkin-nix, ... }@inputs: {
    nixosConfigurations.myhostname = nixpkgs.lib.nixosSystem {
      modules = [
        {
          nixpkgs.overlays = [ funkin-nix.overlays.default ];
        }
        ./configuration.nix
      ];
    };
  };
}
```

### 2. Add to System or Home Packages

In your `configuration.nix` (or `home.nix`):

```nix
environment.systemPackages = with pkgs; [
  # Default English
  funkin

  # Or Turkish Story Mode:
  # funkin-tr
];
```

Or without overlays directly from inputs:

```nix
environment.systemPackages = [
  inputs.funkin-nix.packages.${pkgs.system}.default
  # or inputs.funkin-nix.packages.${pkgs.system}.funkin-tr
];
```

---

## License

Friday Night Funkin' is created by The Funkin' Crew Inc. (Apache 2.0).  
This flake repository is maintained by [tempestian](https://github.com/tempestian).
