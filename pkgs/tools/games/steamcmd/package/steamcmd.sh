#!@bash@/bin/bash -e

# Modified steamcmd for maximum container compatibility

# Always run steamcmd in the user's Steam root.
STEAMROOT=@steamRoot@

# Add coreutils to PATH for mkdir, ln and cp used below
PATH=$PATH${PATH:+:}@coreutils@/bin

# Create a facsimile Steam root if it doesn't exist.
if [ ! -e "$STEAMROOT" ]; then
  mkdir -p "$STEAMROOT"/{appcache,config,logs,Steamapps/common}
  mkdir -p ~/.steam
  ln -sf "$STEAMROOT" ~/.steam/root
  ln -sf "$STEAMROOT" ~/.steam/steam
fi

# Copy the system steamcmd install to the Steam root.
if [ ! -e "$STEAMROOT/steamcmd.sh" ]; then
  mkdir -p "$STEAMROOT/linux32"
  cp @out@/share/steamcmd/steamcmd.sh "$STEAMROOT/."
  cp @out@/share/steamcmd/linux32/* "$STEAMROOT/linux32/."
fi

# Set up library path for 32-bit libraries
export LD_LIBRARY_PATH="@glibc@/lib:@gccLib@/lib:$STEAMROOT/linux32${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"

# Run steamcmd directly without bubblewrap
exec "$STEAMROOT/steamcmd.sh" "$@"
