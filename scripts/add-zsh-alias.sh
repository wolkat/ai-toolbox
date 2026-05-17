#!/bin/zsh

add-zsh-alias() {
  local zshrc="$HOME/.zshrc"
  local alias_name=""
  local alias_value=""

  if [[ $# -eq 0 || $# -gt 2 ]]; then
    echo "Usage: add-zsh-alias [name] 'value'"
    echo "  1 arg: auto-generate name from value"
    echo "  2 args: name and value"
    echo "Examples:"
    echo "  add-zsh-alias 'git status'"
    echo "  add-zsh-alias gs 'git status'"
    return 1
  fi

  if [[ $# -eq 1 ]]; then
    alias_value="$1"
    alias_name=$(echo "$alias_value" | awk '{for(i=1;i<=NF;i++) printf "%s", substr($i,1,1)}')
  else
    alias_name="$1"
    alias_value="$2"
  fi

  if [[ -z "$alias_name" || -z "$alias_value" ]]; then
    echo "Error: name and value cannot be empty"
    return 1
  fi

  local escaped_value="${alias_value//\'/\'\\\'\'}"

  local existing_line=$(grep "^alias ${alias_name}=" "$zshrc" 2>/dev/null)
  if [[ -n "$existing_line" ]]; then
    local current_value=$(echo "$existing_line" | sed "s/alias ${alias_name}=['\"]\\(.*\\)['\"]/\\1/")
    echo "Alias '$alias_name' already exists in ~/.zshrc"
    echo "  Current: alias $alias_name='$current_value'"
    echo "  New:     alias $alias_name='$alias_value'"
    echo -n "Update? [y/N] "
    read -q reply
    echo
    if [[ "$reply" != "y" && "$reply" != "Y" ]]; then
      echo "Aborted."
      return 1
    fi
  fi

  local backup="$zshrc.backup.$(date +%Y%m%d_%H%M%S)"
  cp "$zshrc" "$backup"
  echo "Backup created: $backup"

  if [[ -n "$existing_line" ]]; then
    sed -i '' "s|^alias ${alias_name}=.*|alias ${alias_name}='${escaped_value}'|" "$zshrc"
  else
    echo "alias ${alias_name}='${escaped_value}'" >> "$zshrc"
  fi

  source "$zshrc"
  if [[ $? -eq 0 ]]; then
    if [[ -n "$existing_line" ]]; then
      echo "Updated alias: alias ${alias_name}='${alias_value}'"
    else
      echo "Added alias: alias ${alias_name}='${alias_value}'"
    fi
  else
    echo "Error: failed to source ~/.zshrc"
    return 1
  fi
}