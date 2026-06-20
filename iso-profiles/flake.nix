{
  description = "Garuda Linux iso-profiles flake ❄️";

  inputs = {
    # Devshell to set up a development environment
    devshell.url = "github:numtide/devshell";
    devshell.flake = false;

    # Flake parts
    flake-parts.url = "github:hercules-ci/flake-parts";

    # Common used input of our flake inputs
    flake-utils.url = "github:numtide/flake-utils";

    # The single source of truth
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Easy linting of the flake and all kind of other stuff
    pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";
    pre-commit-hooks.inputs.nixpkgs.follows = "nixpkgs";

    # TODO: https://github.com/NixOS/nix/pull/9163
    src-buildiso = {
      type = "gitlab";
      owner = "garuda-linux";
      repo = "tools%2Fbuildiso-docker";
      flake = false;
    };
  };
  outputs =
    { devshell
    , flake-parts
    , nixpkgs
    , pre-commit-hooks
    , self
    , ...
    } @ inp:
    let
      inputs = inp;

      perSystem =
        { pkgs
        , system
        , ...
        }: {
          checks.pre-commit-check = pre-commit-hooks.lib.${system}.run {
            hooks = {
              commitizen.enable = true;
              nixpkgs-fmt.enable = true;
              markdownlint.enable = true;
              pkgbuilds-shellcheck = {
                enable = true;
                name = "PKGBUILD shellcheck";
                entry = "${pkgs.shellcheck}/bin/shellcheck";
                files = "(.sh$)";
                types = [ "text" ];
                language = "system";
              };
              pkgbuilds-style = {
                enable = true;
                name = "PKGBUILD shfmt";
                entry = "${pkgs.shfmt}/bin/shfmt -d -w";
                files = "(.sh$)";
                types = [ "text" ];
                language = "system";
              };
              prettier.enable = true;
              yamllint.enable = true;
            };
            src = ./.;
          };

          devShells =
            let
              buildiso = ''
                if ! command -v docker &>/dev/null; then
                  echo "This command requires Docker to be installed. Please install Docker and try again."
                  exit 1
                fi
                if ! docker images | grep buildiso &>/dev/null; then
                  docker build ${inputs.src-buildiso} -t buildiso
                fi
                docker run --rm -it --privileged --name buildiso \
                       -v "./buildiso/buildiso:/var/cache/garuda-tools/garuda-chroots/buildiso" \
                       -v "./buildiso/cron:/var/spool/anacron" \
                       -v "./buildiso/pkg:/var/cache/pacman/pkg/" \
                       -v "./buildiso/iso:/var/cache/garuda-tools/garuda-builds/iso/" \
                       -v "./buildiso/logs:/var/cache/garuda-tools/garuda-logs/" \
                       buildiso /bin/bash
              '';
              makeDevshell = import "${inp.devshell}/modules" pkgs;
              mkShell = config:
                (makeDevshell {
                  configuration = {
                    inherit config;
                    imports = [ ];
                  };
                }).shell;
            in
            rec {
              default = garuda-shell;
              garuda-shell = mkShell {
                devshell.name = "garuda-shell";
                commands = [
                  { package = "commitizen"; }
                  { package = "markdownlint-cli"; }
                  { package = "pre-commit"; }
                  { package = "nodePackages.prettier"; }
                  { package = "shellcheck"; }
                  { package = "shfmt"; }
                  { package = "yamllint"; }
                  {
                    name = "buildiso";
                    help = "Spawns a local buildiso shell to build to ./buildiso (needs Docker)";
                    category = "infra-nix";
                    command = buildiso;
                  }
                ];
                devshell.startup = {
                  preCommitHooks.text = self.checks.${system}.pre-commit-check.shellHook;
                  garudaEnv.text = ''
                    export LC_ALL="C.UTF-8"
                    export NIX_PATH=nixpkgs=${nixpkgs}
                  '';
                };
              };
            };

          formatter = pkgs.nixpkgs-fmt;
        };
    in
    flake-parts.lib.mkFlake { inherit inputs; } {
      # Flake modules
      imports = [ inputs.pre-commit-hooks.flakeModule ];

      # The available systems
      systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];

      # This applies to all systems
      inherit perSystem;
    };
}
