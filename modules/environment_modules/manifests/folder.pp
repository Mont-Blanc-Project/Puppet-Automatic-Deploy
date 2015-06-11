define environment_modules::folder{
	require stdlib
	$prefix = $::environment_modules::prefix
	file {"environment_modules $title":
		path => "$prefix/Modules/default/modulefiles/$title",
		ensure => "directory",
		mode => '755',
	}
	file_line {"modulespath $title":
		path    => "$prefix/Modules/default/init/.modulespath",
		line    => "$prefix/Modules/default/modulefiles/$title",
	}
}
