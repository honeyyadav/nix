{
  description = "Example nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    hashicorp-tap = {
      url = "https://github.com/hashicorp/homebrew-tap";
      flake = false;
    };
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, nix-homebrew, hashicorp-tap }:
  let
    configuration = { pkgs, ... }: {

      nixpkgs.config.allowUnfree = true;

      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages =
        [ 
          pkgs.neovim
          pkgs.fzf
          pkgs.k9s
          pkgs.kubectl
          pkgs.kubectx
          # pkgs.lens
	        # pkgs.vscode
        ];

      fonts.packages = [
        (pkgs.nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
      ];

      homebrew = {
        enable = true;
        brews = [
          "zsh-autosuggestions"
          "zsh-syntax-highlighting"
          "mas"
          # "fzf"
          "bat"
          "fd"
          "zoxide"
          "eza"
          # "yazi"
          "starship"
          # "qbittorrent"
          "tmux"
          "atuin"
          "stow"
          "hashicorp/tap/terraform"
        ];
        casks = [ 
            # "firefox"
            # "google-chrome"
            "the-unarchiver"
            "visual-studio-code"
            "maccy"
            "raycast"
            "hiddenbar"
            "itsycal"
            "tailscale"
            "iterm2"
            "appcleaner"
            "iina"
            # "pixelsnap"
            "transmission"
            "ghostty"
            "warp"
        ];
        masApps = {
          "Dropover" = 1355679052;
        };
        onActivation.cleanup = "zap";
        onActivation.autoUpdate = true;
        onActivation.upgrade = true;
      };

      # TODO:-
      # tailscale or twingate
      

      system.defaults = {
        dock = {
	        autohide = true;
          orientation = "left";
	        tilesize = 36;
	        wvous-tr-corner = 4;
          persistent-apps = [
            # "/Applications/Google Chrome.app"
          ];
	      };

        controlcenter.BatteryShowPercentage = true;

        loginwindow.GuestEnabled = false;
        WindowManager.EnableStandardClickToShowDesktop = false;
        finder = {
          FXDefaultSearchScope = "SCcf";
                FXPreferredViewStyle = "clmv";
          ShowPathbar = true;
          FXEnableExtensionChangeWarning = false;
        };

      };

      # targets.darwin.defaults."com.apple.menuextra.battery".ShowPercent = "YES";

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Enable alternative shell support in nix-darwin.
      # programs.fish.enable = true;

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 5;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";
      security.pam.enableSudoTouchIdAuth = true;
      users.users.honeyyadav.home = "/Users/honeyyadav";
      nix.configureBuildUsers = true;
      nix.useDaemon = true;
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#macpersonal
    darwinConfigurations."macpersonal" = nix-darwin.lib.darwinSystem {
      modules = [ 
        configuration
        nix-homebrew.darwinModules.nix-homebrew
        {
          nix-homebrew = {
            # Install Homebrew under the default prefix
            enable = true;

            # Apple Silicon Only: Also install Homebrew under the default Intel prefix for Rosetta 2
            enableRosetta = true;

            # User owning the Homebrew prefix
            user = "honeyyadav";

            autoMigrate = true;

            # Optional: Declarative tap management
            taps = {
              # "homebrew/homebrew-core" = homebrew-core;
              # "homebrew/homebrew-cask" = homebrew-cask;
              # "homebrew/homebrew-bundle" = homebrew-bundle;
              "hashicorp/tap" = hashicorp-tap;
            };

            # Optional: Enable fully-declarative tap management
            #
            # With mutableTaps disabled, taps can no longer be added imperatively with `brew tap`.
            # mutableTaps = false;
          };
        }
      ];
    };
  };
}
