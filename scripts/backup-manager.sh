# Requires installer to set $target_path, $backup_path, and $log_output to function

# Moves a directory from the source to the target with optional verbose message
transfer_dir() {
	local dirname="$1"
	local source_dir="$2"
	local target_dir="$3"
	local message=${4:-"Transferring"}

	printf "$message $dirname to $target_dir from $source_dir\n" >> "$log_output"

	# Cleanup target dir
	if [ -d "$target_dir/$dirname" ]; then 
		rm -rif "$target_dir/$dirname"
	fi

	local parent_path="$(dirname $dirname)"

	mkdir -p "$target_dir/$parent_path"

	# Move files into backup (copies linked files before breaking links)
	if [ -L "$source_dir/$dirname" ]; then
		cp -Lr "$source_dir/$dirname" "$target_dir/$parent_path"
		unlink "$source_dir/$dirname"
	else
		mv -f "$source_dir/$dirname" "$target_dir/$parent_path"
	fi 
}


# Backup a directory from $target_path into $backup_path
backup_dir() {
	local dirname="$1"	
	transfer_dir "$dirname" "$target_path" "$backup_path" "Backing up"
}


# Revert a directory backup from $backup_path back into $target_path
revert_dir_backup() {
	local dirname="$1"	
	transfer_dir "$dirname" "$backup_path" "$target_path" "Reverting backup: "
}


# Begin a full .config wide backup from $target_path into $backup_path
backup_begin() {
	printf "Backing up files\n" >> "$log_output"
	for file in .config/*; do
		# Back up dotfile if it already exists and is to be replaced
		[ -e "$file" ] && [ -e "$target_path/$file" ] && backup_dir "$file"
	done
	true
}


# Removes all empty directories in given directory (including self) 
empty_dir_cleanup() {
	local dirname="$1"
	printf "Cleaning up $dirname" >> "$log_output"
	find "$dirname" -type d -empty -delete
}


# Do a full backup reversion from $backup_path back into $target_path
backup_revert() {
	printf "Reverting backup of files\n" >> "$log_output"
	for file in "$backup_path/.config"/*; do
		# Revert backups into target_path if they are tracked
		local config_name=${file#"$backup_path/"} # Strips backup path from the file
		[ -e "$file" ] && [ -e "$config_name" ] && revert_dir_backup "$config_name"
	done
	empty_dir_cleanup "$backup_path"
	true
}


# Backup management controller (3 modes based on args)
# Regular backup, undo backup, and skip backup
backup_controller_run() {
	local undo="$1"
	local skip="$2"

	if [ "$skip" = true ]; then
		printf "Skipping Backup\n" >> "$log_output"
	elif [ "$undo" = true ]; then
		backup_revert; exit 0
	else 
		backup_begin
	fi
}

