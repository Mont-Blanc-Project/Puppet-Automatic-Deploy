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

#dependences = 
class atlas (  $archdef='',
){
	define core_performance {
		exec {"Put core $title in performance": 
			command => "/bin/echo performance > /sys/devices/system/cpu/cpu${title}/cpufreq/scaling_governor",
			user    => 'root',
			group   => 'root',
			path    => '/bin:/usr/bin:/usr/local/bin:/sbin:/usr/sbin:/usr/local/sbin',
			onlyif  => 'dpkg -l cpufrequtils',
			before  => Build_source["$module_name"]
		}
	}
	include stdlib
	$cpus = range(0,$::processorcount-1)
	core_performance{$cpus:}
	file { "lapack .tar.gz functions for atlas":
		path   => "/tmp/lapack.tar.gz",
		ensure => file,
		source => "puppet:///modules/$module_name/lapack-3.5.0.tgz",
		before => Build_source["$module_name"]
	}
	$CFLAGS="-O3"
	build_source{"$module_name":
		url             => "http://sourceforge.net/projects/math-atlas/files/Developer%20%28unstable%29/3.11.34/atlas3.11.34.tar.bz2",
		version         => "3.11.34",
		buildDir        => "$::architecture",
		buildArgs       => "build",
		packages        => ["gfortran"],
		module_type     => "sci-libs",
		module_app_name => "atlas",
		module_desc     => "Automatically Tunned Linear Algebra Software"
	}
}
