#################################################################
# This module installs applications using cmake.		#
# Params:                                                       #
# sourceFolder => The folder from where cmake is executed   	# 
# dest         => (defaults to /opt/$title) destination folder  #
# options      => (optional) options to pass to the cmake   	#
# environment  => (optional) array of environmental variables   #
# buildDir     => (optional) subfolder from where to build      # 
# buildArgs    => (optional) arguments to make		        #
#################################################################
define build_source::cmake(
	$sourceFolder, 
	$dest = "/opt/$title", 
	$options = '', 
	$environment = '',
	$buildDir = '',
	$buildArgs = '',
) {
	include stdlib
	if ($environment != '') {
		Exec {
			environment => $environment
		}
	}

	if ($buildDir != '') {
		$workDir="$sourceFolder/$buildDir"
	} else {
		$workDir="$sourceFolder"
	}
	ensure_resource('file',$workDir,{'ensure' => 'directory','owner'  => 'root','group'  => 'root'})

	Exec {
		user     => 'root',
		group    => 'root',
		timeout  => 0,
		path     => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games',
		cwd      => "$workDir",
	}

	exec { "cmake for $title":
		command   => "cmake -D CMAKE_INSTALL_PREFIX=$dest $options $sourceFolder",
		logoutput => 'on_failure',
		creates   => "$dest",
	}
	
	exec { "make for $title":
		command => "make $makeArgs",
		creates => "$dest",
		require => Exec["cmake for $title"]
	}
  
	exec { "make install for $title":
		command => 'make install',
		creates => "$dest",
		require => Exec["make for $title"]
	}
}
