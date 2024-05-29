#!/bin/bash -eu

action_root="$(dirname "$(realpath "$BASH_SOURCE")")"

flags=""
destination=""
case "$INPUT_COMPRESS" in
  gzip | gz)
    flags="$flags -z"
    if [ ! -z "$INPUT_DESTINATION" ]; then
      destination="$(echo "$INPUT_DESTINATION" | sed -e 's~\.gz$~~')"
      echo "destination=$destination.gz" >> $GITHUB_OUTPUT
    else
      echo "destination=$INPUT_IMAGE.gz" >> $GITHUB_OUTPUT
    fi
    ;;
  xz)
    flags="$flags -Z"
    if [ ! -z "$INPUT_DESTINATION" ]; then
      destination="$(echo "$INPUT_DESTINATION" | sed -e 's~\.xz$~~')"
      echo "destination=$destination.xz" >> $GITHUB_OUTPUT
    else
      echo "destination=$INPUT_IMAGE.xz" >> $GITHUB_OUTPUT
    fi
    ;;
  none | "false" | "")
    echo "destination=$INPUT_DESTINATION" >> $GITHUB_OUTPUT
    ;;
  *)
    echo "Error: unrecognized compression type: $INPUT_COMPRESS"
    exit 1
    ;;
esac
if [ "$INPUT_COMPRESS_PARALLEL" == "true" ]; then
  flags="$flags -a"
fi
if [ "$INPUT_PREVENT_EXPANSION" == "true" ]; then
  flags="$flags -s"
fi
if [ "$INPUT_ADVANCED_FS_REPAIR" == "true" ]; then
  flags="$flags -r"
fi
if [ "$INPUT_VERBOSE" == "true" ]; then
  flags="$flags -v"
fi

echo "Running pishrink.sh $flags \"$INPUT_IMAGE\" \"$destination\"..."
sudo "$action_root/pishrink.sh" $flags "$INPUT_IMAGE" "$destination"
