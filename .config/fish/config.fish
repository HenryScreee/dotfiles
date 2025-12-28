if status is-interactive
    set -g fish_greeting
    
    # --- PYWAL PERSISTENCE ---
    # This applies the colors to the current terminal window immediately
    cat ~/.cache/wal/sequences &
    
    if type -q fastfetch
        fastfetch
    end
end
