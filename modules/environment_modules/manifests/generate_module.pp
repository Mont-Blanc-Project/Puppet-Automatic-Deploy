#################################################################################
# This module is used to generate a environment module for a software		#
# Parameters:									#
#   type      => module type (compiler, application, tool, etc.)		#
#   prefix    => installation path of the software				#
#   modname   => (defaults = $title) name of the module, spaces are not allowed	#
#   app_name  => (defaults = $title) Application name (long)			#
#   conflicts => (defaults = $title) Array containing all the conflicts of 	#
#		 the modulefile							#
#   desc      => (optional) application name					#
#   extra_vars=> (optional) A hash map with any optional variables, the keys are#
#		 the variable name and the value the value of themselves	#
#   version   => (defaults = 'default') version of the application		#
#################################################################################
define environment_modules::generate_module(	$type,
					$prefix,
					$modname=$title,
					$app_name = $title,
					$conflicts= [$title],
					$desc='',
					$extra_vars = '',
					$version='default'
){
	require stdlib
	$envPrefix = $::environment_modules::prefix
	File {
		owner => 'root',
		group => 'root'
	}
	
	ensure_resource('environment_modules::folder',"$type")
	
	$MODULE_FOLDER_PATH = "$envPrefix/Modules/default/modulefiles/$type"
	file { "modulefile folder $modname":
		path    => "$MODULE_FOLDER_PATH/$modname",
		ensure  => 'directory',
		mode    => '755',
		require => Environment_modules::Folder["$type"],
		alias   => "modulefile folder $modname"
	}
	
	if ( $desc != '' ) {
		$APP_DESC = "($desc)"
	}
	if ( $version == '' ) {
		$APP_VER = "default"
	} else {
		$APP_VER = $version
	}
	
	file { "$modname modulefile":
		path    => "$MODULE_FOLDER_PATH/$modname/$APP_VER",
		ensure  => 'file',
		mode    => '644',
		content => template("environment_modules/generic_module.erb"),
		require => File["modulefile folder $modname"],
		alias   => "$modname modulefile"
	}
	file { "$modname default_version":
		path    => "$MODULE_FOLDER_PATH/$modname/.version",
		ensure  => file,
		content => template("environment_modules/generic_version.erb"),
		mode    => '644',
		require => File["$modname modulefile"]
	}
}
