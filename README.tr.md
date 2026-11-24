# funkin-nix

NixOS için **Friday Night Funkin' (FNF)** (v0.4.1 Weekend 1 / V-Slice) Flake paketi. Otomatik FHS izolasyonu (tam `libvlc` ara sahne video desteği, OpenGL ve ses uyumluluğu) ve isteğe bağlı **Türkçe Hikaye Modu** diyalogları içerir.

---

[Click here for English README](README.md)

---

## Özellikler

- **NixOS'te Sıfır Zahmetle Çalışma:** NixOS'in dinamik kütüphane eksikliklerine takılmadan OpenGL, ALSA/PipeWire ve video ara sahneleri için gereken `libvlc` bağımlılıklarını otomatik çözer.
- **Türkçe Hikaye Desteği (`funkin-tr`):** Hikaye modundaki diyalogları ve seviyeleri (özellikle Hafta 6 Senpai, Roses, Thorns) Türkçe olarak oynayabilmenizi sağlar.
- **Kullanıcı Verisi İzolasyonu:** Yüksek skorları (`scores.json`) ve modları `~/.local/share/funkin` klasöründe saklar. Böylece `/nix/store` salt okunur kalırken ayarlarınız ve modlarınız korunur.
- **Masaüstü Entegrasyonu:** Başlatıcınızda (Rofi, Walker, GNOME, KDE, Quickshell vb.) görünmesi için `.desktop` kısayolu ve simgesiyle gelir.

## Hızlı Başlangıç

### Kurmadan Doğrudan Oyna:

```bash
# Orijinal (İngilizce)
nix run github:tempestian/funkin-nix

# Türkçe Hikaye Modu
nix run github:tempestian/funkin-nix#funkin-tr
```

---

## NixOS Sistemine Ekleme

### 1. Flake Girdisi Ekleme

`flake.nix` dosyanızda `inputs` kısmına ekleyin:

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

### 2. Paket Listesine Ekleme

`configuration.nix` (veya `home.nix`) dosyanıza ekleyin:

```nix
environment.systemPackages = with pkgs; [
  # Standart FNF
  funkin

  # Veya Türkçe Hikaye Modlu FNF:
  # funkin-tr
];
```

Veya overlay kullanmadan doğrudan `inputs` ile:

```nix
environment.systemPackages = [
  inputs.funkin-nix.packages.${pkgs.system}.default
  # veya: inputs.funkin-nix.packages.${pkgs.system}.funkin-tr
];
```

---

## Lisans

Friday Night Funkin', The Funkin' Crew Inc. tarafından geliştirilmiştir (Apache 2.0).  
Bu Flake deposu [tempestian](https://github.com/tempestian) tarafından sürdürülmektedir.
