if status is-interactive
    # Commands to run in interactive sessions can go here
    set -g fish_greeting
    if type -q fastfetch
        fastfetch
    end
end

# Environment variables
set -gx EDITOR nano
set -gx VISUAL nano
