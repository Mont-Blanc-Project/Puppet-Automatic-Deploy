#########################################################################
# This module is used to install software from sources 			#
# Parameters:							  	#
#   type      => (default = 'configure') it is used to specify the type	#
#                of build required by the software			#
#   url       => url of the software files, it can be a git repository 	#
#                or a compressed package(see archive.pp for more info)	#
#   env       => (optional) Array of environment variables		#
#   options   => (optional) options for the software configuration 	#
#   version   => (optional) version of the software(used to infer the 	#
#                destination folder) more details at Folders section	#
#   srcDest   => (optional) Location of the source files		#
#   dest      => (optional) Where to install the software		#
#   defPrefix => (default = /opt) part of the install folder path when 	#
#                no dest is specified, more details at Folders section	#
#   buildDir  => (optional) Subfolder where to build the software	# 
#   builder   => (optional and only useful to bootstrap) name of the 	#
#                binary that is in chanrge of building and installing	#
#   configDir => (optional) Subfolder where to fins the configure tool	#
#   preConf   => (optional) command to execute before the configuration	# 
#   packages  => (optional) array of packages needed by this software	#
#   buildArgs => (optional) arguments to pass to the builder		#
# Folders:								#
#   Source folder  => If srcDest is undefined, the source folder is:	#
#		      /usr/src/$name/$version				#
#   Install folder => If dest is undefined the install folder is:	#
#		      $defPrefix/$name/$version 			#
#   In both cases if version is unspecified the $version subfolder will #
#   not be created							#
# module_ Parameters:							#
#   module_type      => With this option it is specified the type of 	#
#		        software we are installing, if this parameter 	#
#			is set the environment module is created	#
#   module_modname   => (optional) The name given to the environment	#
#		        module						#
#   module_app_name  => (optional) The (long) name given to the 	#
#		        environment module				#
#   module_conflicts => (optional) Array of the modulename that 	#
#			conflict with this module			#
#   module_desc      => (optional) Brief description of this software 	#
#   module_extra_vars=> (optional) A hash maps containing any extra 	#
#			variables that need to be defined		#
#########################################################################
define build_source (	$type = 'configure',
			$url,
			$env = '',
			$options ='',		
			$env='',
			$options = '',
			$version = '',
			$srcDest = '',
			$dest = '',
			$defPrefix ='/opt',
			$buildDir = '',
			$builder = '',
			$configDir = '',
			$preConf ='',
			$packages ='',
			$buildArgs = '',
			$module_type = '',
			$module_modname = '',
			$module_app_name = '',
			$module_conflicts ='',
			$module_desc = '',
			$module_extra_vars = '',
){
	include stdlib
	if($srcDest == ''){
                if($version == ''){
                        $sourceFolder = "/usr/src/$name"
                }
                else {
                        $sourceFolder = "/usr/src/$name/$version"
                }
        }
        else {
                $sourceFolder = $srcDest
        }
	if($configDir != '') {
		$confLoc = "$configDir"
		$srcConfFolder = "$sourceFolder/$confLoc"
	} else {
		$confLoc = ''
		$srcConfFolder = $sourceFolder
	}
	case $type {
                'cmake': {		
			$reqInst = Build_source::Cmake["$title"]
			$creates = "${confLoc}/CMakeLists.txt"
			$generalDependences = ["gcc","make","g++","cmake"]
		}
                'configure': { 
			$reqInst = Build_source::Compile["$title"]
			$creates = "${confLoc}/configure"
			$generalDependences = ["gcc","make","g++"]
		}
                'bootstrap': { 
			$reqInst = Build_source::Bootstrap["$title"]
			$creates = "${confLoc}/bootstrap.sh"
			$generalDependences = []
		}
                default: { fail('Type of installation not supported')}
        }
	if($packages != ''){
		$allDeps = concat($packages,$generalDependences)
	} else {
		$allDeps = $generalDependences
	}
	ensure_packages($allDeps)
	Package[$allDeps] -> $reqInst
	if($dest == ''){
                if($version == ''){
                        $destFolder = "$defPrefix/$name"
                }
                else {
                        $destFolder = "$defPrefix/$name/$version"
                }
        }
        else {
                $destFolder = $dest
        }
	$extension = inline_template('<%= File.extname(@url) %>')
        if($extension == ".git"){
                build_source::git{"$title":
                        url    => $url,
                        dest   => $sourceFolder,
                        before => $reqInst
                }
                $requirement=Build_source::Git["$title"]
        } else {
                build_source::archive{"$title":
                        url     => $url,
                        dest    => $sourceFolder,
                        creates => $creates,
                        before  => $reqInst
                }
                $requirement=Build_source::Archive["$title"]

        }	
	if ($preConf != '') {
		exec {"preconfigure of $title":
                        command => $preConf,
                        path    => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games',
                        user    => 'root',
                        group   => 'root',
                        cwd     => $sourceFolder,
                        creates => $destFolder,
                        before  => $reqInst,
                        require => $requirement
                }
	}
	case $type {
                'cmake': {
			build_source::cmake{"$title":
				sourceFolder => $srcConfFolder,
				dest 	     => $destFolder, 
				options      => $options,
				environment  => $env,
				buildDir     => $buildDir,
				buildArgs    => $buildArgs
			}
                }
                'configure': {
			build_source::compile{"$title":
				sourceFolder => $srcConfFolder,
				dest 	     => $destFolder, 
				options      => $options,
				environment  => $env,
				buildDir     => $buildDir,
				buildArgs    => $buildArgs
			}
                }
                'bootstrap': {
			build_source::bootstrap{"$title":
				sourceFolder => $srcConfFolder,
				dest 	     => $destFolder, 
				options      => $options,
				builder	     => $builder,
				environment  => $env,
				buildDir     => $buildDir,
				buildArgs    => $buildArgs
			}
        	}
		default: {}
	} 
	#Module stuff
	if defined(Class['environment_modules']){
		if($module_type != '') {
			if($module_modname != ''){
				$mod_modname = $module_app_name
			} else {
				$mod_modname = $title
			}
			if($module_app_name != ''){
				$mod_app_name = $module_app_name
			} else {
				$mod_app_name = upcase("$title")
			}
			if($module_conflicts != ''){
				$mod_conflicts = $module_conflicts
			} else {
				$mod_conflicts = [$title]
			}
			if($module_desc != ''){
				$mod_desc = $module_desc
			} else {
				$mod_desc = ''
			}
			if($module_extra_vars != ''){
				$mod_extra_vars = $module_extra_vars
			} else {
				$mod_extra_vars = ''
			}
			environment_modules::generate_module{$title:
				type       => $module_type,
				version    => $version,
				prefix     => $destFolder,
				modname    => $mod_modname,
				app_name   => $mod_app_name,
				conflicts  => $mod_conflicts,
				desc       => $mod_desc,
				extra_vars => $mod_extra_vars,
				require    => $reqInst,
			}
		}
	}
}

