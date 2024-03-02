display_help() {
	printf "./install.sh [OPTION]... [ARGS] ...
Install these dotfiles onto your system

where:
	-h	Show this help text
	-v 	Enable verbose outputs
	-s 	Skip backups, just install
	-u 	Undo the backup back into target path (does not install dotfiles)
	-r	Regenerate the .stock-ignore and .gitignore files
	-i 	Disable the installer (for some reason)
	-t 	Set target path to save dotfiles (default is $HOME) [ARGS]
	-b 	Set backup path to backup existing dotfiles (default is ./backups) [ARGS]
	-l 	Set log file to pipe verbose outputs to [ARGS]
\n"
exit 0
}


# Get -flags
while getopts hvnsrit:b:l: flag; do
	case "$flag" in
		h) display_help ;;			# Display the help message
		v) verbose=true ;;			# Enable verbose mode
		s) skip_backup=true ;; 		# Skip backups
		u) undo_backup=true ;;		# Revert a backup
		r) regen_ignores=true ;;	# Regenerate .ignore files
		i) install_disable=true ;;	# Disable installing
		t) target_path=${OPTARG} ;; # Set the target path to save configs
		b) backup_path=${OPTARG} ;; # Set path to backup existing config
		l) verbose_file=${OPTARG};; # Set file output for verbose	
		*) display_help ;;			# Any other args parsed, show help
	esac
done


# Setup default values for flags
backup_path_default="backups"
target_path_default="$HOME"

verbose=${verbose-$false}
undo_backup=${undo_backup-$false}
skip_backup=${skip_backup-$false}
regen_ignores=${regen_ignores-$false}
install_disable=${install_disable-$false}
target_path=${target_path-$target_path_default}
backup_path=${backup_path-$backup_path_default}


# Verbose and Logging management (pipes prints)
if [ "$verbose" = true ]; then 
	log_output=${verbose_file-"/dev/stdout"}
else
	log_output=${verbose_file-"/dev/null"}
fi


# Backup files based on flags
source scripts/backup-manager.sh
backup_controller_run "$undo_backup" "$skip_backup"


# Regenerate the .ignore files
if [ "$regen_ignores" = true ]; then
	printf "Regerating .ignore files (.gitignore)\n" >> "$log_output"
	cp "scripts/.gitignore-regen-template" ".gitignore"
fi


# Update .ignore files with new backups if needed
if [ "$backup_path" != "$backup_path_default" ]; then
	printf "Updated .ignore files to include new backup path" >> "$log_output"
	printf "$backup_path\n" >> ".gitignore"
fi


# Install the dotfiles
if [ "$install_disable" != true ]; then 	
	printf "Installing dotfiles into $target_path\n" >> "$log_output"

	# Create ./config if missing
	if [ ! -d "$target_path/.config" ]; then
		mkdir -p "$target_path/.config"
	fi

	# Link our dotfiles/.config into new .config
	for file in .config/*; do
		unlink "$target_path/$file"
		ln -sf "$PWD/$file" "$target_path/$file"
	done
else 
	printf "Skipping Installer\n" >> "$log_output"
fi

