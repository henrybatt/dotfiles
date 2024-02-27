# Requires installer to set $target_path, $backup_path, and $log_output to function

# Moves a directory from the source to the target with optional verbose message
transfer_dir() {
	local dirname="$1"
	local source_dir="$2"
	local target_dir="$3"
	local message=${4:-"Transferring"}

	printf "$message $dirname to $target_dir from $source_dir\n" >> "$log_output"

	if [ -d "$target_dir/$dirname" ]; then 
		rm -rif "$target_dir/$dirname"
	fi

	mkdir -p "$target_dir/$dirname"

	if [ -L "$source_dir/$dirname" ]; then
		cp -r "$source_dir/$dirname" "$target_dir/$(dirname $dirname)"
		unlink "$source_dir/$dirname"
	fi

	mv -f "$source_dir/$dirname" "$target_dir/$(dirname $dirname)"

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
		[ -d "$file" ] && [ -d "$target_path/$file" ] && backup_dir "$file"
	done
	true
}

# Do a full backup reversion from $backup_path back into $target_path
backup_revert() {
	printf "Reverting backup of files\n" >> "$log_output"
	for file in .config/*; do
		# Revert backups into target_path if they are tracked
		[ -d "$file" ] && [ -d "$backup_path/$file" ] && revert_dir_backup "$file"
	done
	true
}

# Backup management controller using installer flags
backup_controller_run() {
	
	if [ -L "$target_path_default/.config" ]; then
		unlink ~/.config
	fi

	if [ "$undo_backup" = true ]; then
		backup_revert; exit 0
	elif [ "$no_backup" = true ]; then
		printf "Skipping Backup\n" >> "$log_output"
	else 
		backup_begin
	fi
}

