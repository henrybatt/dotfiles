# Requires installer to set $target_path, and $log_output to function

# Re/Generate the .stow-local-ignore file based on the template
stow_ignore_generation() {
	printf "Generating .stow-local-ignore\n" >> "$log_output"
	cp "scripts/.stow-local-ignore-regen-template" ".stow-local-ignore"
}

# Updates the .stow-local-ignore with a new ignore item
stow_ignore_update() {
	local item_to_append="$1"
	printf "$item_to_append\n" >> ".stow-local-ignore"
}

# Use stow to install the dot files
stow_installer() {
	if [ ! -f ".stow-local-ignore" ]; then
		stow_ignore_generation 
	fi

	printf "Installing dotfiles into $target_path\n" >> "$log_output"
	stow .
}
