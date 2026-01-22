# Nix port of
# https://github.com/CM2Walki/steamcmd/blob/master/bullseye/Dockerfile
#
# TODO: fix steamcmd.sh being totally broken

{
    pkgs,
    User ? "steam",
    Group ? "steam",
    PUID ? 1000,
    PGID ? 1000
}:

with pkgs;

let
    HomeDir = "/home/${User}";
    SteamcmdDir = "${HomeDir}/steamcmd";

    # Build package with steamRoot set to container path
    package = callPackage ./package {
        steamRoot = SteamcmdDir;
    };
in
{
    name = "steamcmd";
    tag = "latest";

    copyToRoot = buildEnv {
        name = "image-root";
        paths = [
            package
            bashInteractive
            coreutils
            su
            # Only include libraries, not bins that collide
            glibc.out
            gcc-unwrapped.lib
            # 32-bit libraries
            pkgsi686Linux.glibc
            pkgsi686Linux.gcc-unwrapped.lib
        ];
        pathsToLink = [ "/bin" "/lib" "/share" ];
        ignoreCollisions = true;
    };

    runAsRoot = ''
        ${dockerTools.shadowSetup}
        
        # Create a group and user
        groupadd -g ${toString PGID} -r ${Group}
        useradd \
          -u ${toString PUID} \
          -r \
          -g ${Group} \
          -d /home/${User} \
          -M \
          -s /bin/bash \
          ${User}

        # Create the home directory and set permissions
        mkdir -p ${HomeDir}
        chown -R ${User}:${Group} ${HomeDir}
        
        # Create steamcmd directory with subdirectories
        mkdir -p ${SteamcmdDir}/{appcache,config,logs,Steamapps/common,linux32}
        mkdir -p ${HomeDir}/.steam
        chown -R ${User}:${Group} ${HomeDir}

        # Create the 32-bit dynamic linker symlink
        mkdir -p /lib
        ln -sf ${pkgsi686Linux.glibc}/lib/ld-linux.so.2 /lib/ld-linux.so.2
    '';

    config = {
        inherit User;

        Env = [
            "STEAM_RUNTIME=0"
            "USER=${User}"
            "HOMEDIR=${HomeDir}"
            "STEAMCMDDIR=${SteamcmdDir}"
        ];

        WorkingDir = SteamcmdDir;

        Entrypoint = [ "${package}/bin/steamcmd" ];
    };
}
