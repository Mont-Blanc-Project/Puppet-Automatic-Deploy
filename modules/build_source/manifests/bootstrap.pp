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
