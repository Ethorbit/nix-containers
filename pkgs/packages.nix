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
    # Add containers here
    # Note to self: 
    # DO NOT TRY TO REINVENT THE WHEEL BY PORTING EXISTING IMAGES
    # This only wastes very valuable time for absolutely no reason!
    #
    # If an image exists and it's based on Ubuntu, JUST USE IT!
}
