if status is-interactive
    set -g fish_greeting
    if type -q fastfetch
        fastfetch
    end
end
