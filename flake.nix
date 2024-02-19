{
  description = "Shell for CIM class";

  outputs = {
    self,
    nixpkgs,
  }: let
    system = "x86_64-linux";
  in {
    devShells.${system}.default = with import nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };
      mkShell {
        packages = [
          ghdl-llvm
          gtkwave
        ];
      };
  };
}
