
# ~/.config/fish/config.fish

# Only run interactive configuration in interactive shells.
# config.fish is normally sourced for interactive and non-interactive
# Fish sessions, so guard interactive-only settings.
set fish_greeting ""
if not status is-interactive
    return
end

# --------------------------------------------------
# History
# --------------------------------------------------

# Ignore duplicate entries and entries beginning with a space.
# Fish saves and merges history automatically.
# Equivalent intent to Bash HISTCONTROL=ignoreboth.

# History size is managed differently in Fish.
# Bash HISTSIZE and HISTFILESIZE have no direct equivalent.

# --------------------------------------------------
# Debian chroot
# --------------------------------------------------

if not set -q debian_chroot; and test -r /etc/debian_chroot
    set -gx debian_chroot (cat /etc/debian_chroot)
end


# --------------------------------------------------
# Prompt
# --------------------------------------------------

function fish_prompt
    set -l last_status $status

    if set -q debian_chroot
        set_color --bold
        printf '(%s)' $debian_chroot
        set_color normal
    end

    set_color --bold green
    printf '%s@%s' (whoami) (hostname -s)
    set_color normal

    printf ':'

    set_color --bold blue
    printf '%s' (prompt_pwd)
    set_color normal

    if test $last_status -eq 0
        printf '> '
    else
        set_color --bold red
        printf ' (%s)' $last_status
        set_color normal
        printf '> '
    end
end

function fish_title
    set -l chroot_prefix

    if set -q debian_chroot
        set chroot_prefix "($debian_chroot)"
    end

    printf '%s%s@%s: %s' \
        $chroot_prefix (whoami) (hostname -s) (prompt_pwd)
end


# --------------------------------------------------
# Aliases
# --------------------------------------------------

if test -x /usr/bin/dircolors
    alias ls 'ls --color=auto'
    # alias dir 'dir --color=auto'
    # alias vdir 'vdir --color=auto'

    alias grep 'grep --color=auto'
    alias fgrep 'fgrep --color=auto'
    alias egrep 'egrep --color=auto'
end

alias ll 'ls -alF'
alias la 'ls -A'
alias l 'ls -CF'

# --------------------------------------------------
# Alert notification
# Usage: sleep 10; alert
# --------------------------------------------------

function alert
    set -l last_status $status
    set -l icon terminal

    if test $last_status -ne 0
        set icon error
    end

    # Fish history does not expose Bash's numbered history format.
    # Use the most recent command from the history database.
    set -l last_command (builtin history | head -n 1)

    set last_command (string replace -r \
        '[;&|][[:space:]]*alert$' '' -- $last_command)

    notify-send --urgency=low -i $icon "$last_command"
end

# --------------------------------------------------
# Bash aliases file compatibility
# --------------------------------------------------

# Source only if this file contains Fish-compatible syntax.
# Bash syntax in ~/.bash_aliases will NOT work in Fish.
if test -f ~/.config/fish/aliases.fish
    source ~/.config/fish/aliases.fish
end

# --------------------------------------------------
# fnm (Fast Node Manager)
# --------------------------------------------------

set -gx FNM_PATH "$HOME/.local/share/fnm"

if test -d "$FNM_PATH"
    fish_add_path --prepend "$FNM_PATH"

    if type -q fnm
        fnm env --shell fish | source
    end
end

# --------------------------------------------------
# Local environment
# --------------------------------------------------

#if test -f "$HOME/.local/bin/env"
    # This file must contain Fish-compatible syntax.
#    source "$HOME/.local/bin/env"
#end

