#################################################################
# This module installs applications from bootstrap.             #
# Params:                                                       #
# sourceFolder => The folder from where bootstrap is executed   # 
# dest         => (defaults to /opt/$title) destination folder  #
# options      => (optional) options to pass to the bootstrap   #
# builder      => (defaults to $title) name of the builder      #
# 		  equivalent to the make command		#
# environment  => (optional) array of environmental variables 	#
# buildDir     => (optional) subfolder from where to build      # 
# buildArgs    => (optional) arguments to the builder		#
#################################################################
define build_source::bootstrap(
	$sourceFolder, 
	$dest = "/opt/$title", 
	$options = '', 
	$builder = "$title",
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
	exec { "bootstrap $title":
		command   => "$sourceFolder/bootstrap.sh $options --prefix=$dest",
		logoutput => 'on_failure',
		creates   => "$dest",
	}
	exec { "$builder --> $title":
		command => "$sourceFolder/$builder $buildArgs",
		creates => "$dest",
		require   => Exec["bootstrap $title"]	
	}
	exec { "$builder install --> $title":
		command => "$sourceFolder/$builder install",
		creates => "$dest",
		require   => Exec["$builder --> $title"]
	}
}
