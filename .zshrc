# Init Starship Prompt
eval "$(starship init zsh)"

# Init zoxide
eval "$(zoxide init zsh --cmd cd)"

# Aliases
alias ls="eza --icons always"
alias cat="bat"
alias lg="lazygit"

# Set tools colour theme
export LS_COLORS="$(vivid generate catppuccin-mocha)"
