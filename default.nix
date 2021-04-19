{ system ? builtins.currentSystem
, obelisk ? import ./.obelisk/impl {
    inherit system;
    iosSdkVersion = "13.2";

    # You must accept the Android Software Development Kit License Agreement at
    # https://developer.android.com/studio/terms in order to build Android apps.
    # Uncomment and set this to `true` to indicate your acceptance:
    # config.android_sdk.accept_license = false;

    # In order to use Let's Encrypt for HTTPS deployments you must accept
    # their terms of service at https://letsencrypt.org/repository/.
    # Uncomment and set this to `true` to indicate your acceptance:
    # terms.security.acme.acceptTerms = false;
  }
, pkgs ? import <nixpkgs> {}
}:
with obelisk;
let reflex-dom-framework = pkgs.fetchFromGitHub {
      owner = "reflex-frp";
      repo = "reflex-dom";
      rev = "6a7782a61e90e7369a8278441eb47f702bb7c63b";
      sha256 = "13y2h9cqhll55qgk7x33wnz88822irkdxych1c0fbw20jghhp96h";
    };
in
  project ./. ({ ... }: {
    android.applicationId = "systems.obsidian.obelisk.examples.minimal";
    android.displayName = "Obelisk Minimal Example";
    ios.bundleIdentifier = "systems.obsidian.obelisk.examples.minimal";
    ios.bundleName = "Obelisk Minimal Example";
    overrides = self: super: {
      reflex-dom = self.callCabal2nix "reflex-dom" (reflex-dom-framework + /reflex-dom) {};
      reflex-dom-core = pkgs.haskell.lib.dontCheck (
        self.callCabal2nix "reflex-dom-core" (
          reflex-dom-framework + /reflex-dom-core
        ) {}
      );
    };
  })
