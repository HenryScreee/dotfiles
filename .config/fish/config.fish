if status is-interactive
    # Hide the default "Welcome to Fish" message
    set -g fish_greeting
    
    # Apply Pywal colors (silently)
    wal -R -q
    
    # Run the fetch tool
    fastfetch
end
