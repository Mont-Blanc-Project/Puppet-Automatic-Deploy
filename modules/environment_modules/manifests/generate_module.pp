#Copyright (c) 2015, Barcelona Supercomputing Center 
#All rights reserved.
#
#Redistribution and use in source and binary forms, with or without
#modification, are permitted provided that the following conditions are met:
#
#1. Redistributions of source code must retain the above copyright notice, this
#   list of conditions and the following disclaimer.
#2. Redistributions in binary form must reproduce the above copyright notice,
#   this list of conditions and the following disclaimer in the documentation
#   and/or other materials provided with the distribution.
#
#THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
#ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
#WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
#DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
#ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
#(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
#LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
#ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
#(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
#SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
#The views and conclusions contained in the software and documentation are those
#of the authors and should not be interpreted as representing official policies,
#either expressed or implied, of the FreeBSD Project.

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
