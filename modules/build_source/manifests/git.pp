#################################################################
# This module clone git repositories.				#
# Params:                     					#
# url  => Git repository url					#
# dest => (defaults to /Usr/src/$title) destination folder  	#
#################################################################
define build_source::git(
	$url, 
	$dest = "/usr/src/$title", 
) {
	include stdlib
	ensure_resource('secure_package','git',{})
	Exec {
		user    => 'root',
		timeout => $timeout,
		path    => '/usr/bin:/bin',
	}
	exec { "Clone $title":
       		command => "git clone $url $dest",
		creates => $dest,
		require => Package["git"]
	}
}
