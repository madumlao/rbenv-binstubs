#!/usr/bin/env bash

check_for_binstubs()
{
  local root
  local potential_path
  local global_bundle_config
  root="$PWD"
  global_bundle_config=${BUNDLE_CONFIG:-$HOME/.bundle/config}
  while [ -n "$root" ]; do
    if [ -f "$root/Gemfile" ]; then
      if [ -n "$BUNDLE_BIN" ]; then
        case "$BUNDLE_BIN" in
        '"'/*)
            potential_path="${value%'"'}"
            potential_path="${potential_path#'"'}/$RBENV_COMMAND"
            ;;
        '"'*)
            potential_path="${value%'"'}"
            potential_path="$root/${potential_path#'"'}/$RBENV_COMMAND"
            ;;
        /*)
            potential_path="$BUNDLE_BIN/$RBENV_COMMAND"
            ;;
        ?*)
            potential_path="$root/$BUNDLE_BIN/$RBENV_COMMAND"
            ;;
        esac
      else
        potential_path="$root/bin/$RBENV_COMMAND"
        if [ -f "$global_bundle_config" ]; then
          while read key value 
          do
            case "$key" in
            'BUNDLE_BIN:')
                case "$value" in
                '"'/*)
                    potential_path="${value%'"'}"
                    potential_path="${potential_path#'"'}/$RBENV_COMMAND"
                    ;;
                '"'*)
                    potential_path="${value%'"'}"
                    potential_path="$root/${potential_path#'"'}/$RBENV_COMMAND"
                    ;;
                /*)
                    potential_path="$value/$RBENV_COMMAND"
                    ;;
                ?*)
                    potential_path="$root/$value/$RBENV_COMMAND"
                    ;;
                esac
                break
                ;;
            esac
          done < "$global_bundle_config"
        fi
      fi
      if [ -f "$root/.bundle/config" ]; then
	while read key value 
	do
	  case "$key" in
	  'BUNDLE_BIN:')
	      case "$value" in
              '"'/*)
                  potential_path="${value%'"'}"
                  potential_path="${potential_path#'"'}/$RBENV_COMMAND"
                  ;;
              '"'*)
                  potential_path="${value%'"'}"
                  potential_path="$root/${potential_path#'"'}/$RBENV_COMMAND"
                  ;;
	      /*)
		  potential_path="$value/$RBENV_COMMAND"
		  ;;
	      *)
		  potential_path="$root/$value/$RBENV_COMMAND"
		  ;;
	      esac
	      break
	      ;;
	  esac
	done < "$root/.bundle/config"
      fi
      if [ ! -d "$potential_path" ] && [ -x "$potential_path" ] && head -n1 "$potential_path" | grep -q '^#.*ruby'; then
	RBENV_COMMAND_PATH="$potential_path"
      fi
      break
    fi
    root="${root%/*}"
  done

  # if shim / local version doesnt exist, default to system path
  if ! [ -x "$RBENV_COMMAND_PATH" ]; then
    PATH="$(remove_from_path "${RBENV_ROOT}/shims")"
    RBENV_COMMAND_PATH="$(command -v "$RBENV_COMMAND" || true)"
  fi
}

if [ -z "$DISABLE_BINSTUBS" ]; then
  check_for_binstubs
fi

