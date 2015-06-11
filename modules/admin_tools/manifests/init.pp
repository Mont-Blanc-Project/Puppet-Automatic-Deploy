class admin_tools {
	include stdlib
	$packages = ['screen','vim','bash-completion','command-not-found','htop','mlocate','zsh','bc']
	ensure_packages($packages)
}
