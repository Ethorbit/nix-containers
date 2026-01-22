{
    pkgs,
    pkgs-unstable,
    pkgs-ethorbit,
    lib
}:

with pkgs;

let
    buildImage = dockerTools.buildImage;
in
{
    steamcmd = buildImage (import ./tools/games/steamcmd { inherit pkgs; });
}
