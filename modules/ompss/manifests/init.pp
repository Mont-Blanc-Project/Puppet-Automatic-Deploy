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

#dependences = binutils-dev,libxml2-dev,gfortran,libiberty-dev
class ompss (  $opencl='',
		$extrae='',
		$mpi='',
){
	# Some preparations
	require stdlib
	$mcxx_dependences = ["bison","flex","gperf","libsqlite3-dev","sqlite3","pkg-config"]
	ensure_packages($mcxx_dependences)
	Package[$mcxx_dependences] -> Build_source::Compile["$module_name mcxx"]

	# Download the OmpSs tarball
	build_source::archive{"$module_name":
		url     => "http://pm.bsc.es/sites/default/files/ftp/ompss/releases/ompss-latest.tar.gz",
		creates => "mcxx"
	}

	# We need to rename the folders...
	Exec {
		user    => 'root',
		group   => 'root',
		path    => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games',
	}
	exec {"rename nanox folder":
		command => "mv /usr/src/ompss/nanox-* /usr/src/ompss/nanox",
		require => Build_source::Archive["$module_name"],
		creates => "/usr/src/ompss/nanox"
	}
	exec {"rename mercurium folder":
		command => "mv /usr/src/ompss/mcxx-* /usr/src/ompss/mcxx",
		require => Build_source::Archive["$module_name"],
		creates => "/usr/src/ompss/mcxx"
	}

	# Compile Nanox
	$NANOX_CFLAGS="-O3"
	$NANOX_CXXFLAGS="-O3"
	$NANOX_FCFLAGS="-O3"
	$NANOX_PREFIX="/opt/ompss/nanox"
	build_source::compile{"$module_name nanox":
		sourceFolder => "/usr/src/ompss/nanox",
		environment  => ["CFLAGS=$NANOX_CFLAGS","CXXFLAGS=$NANOX_CXXFLAGS","FCFLAGS=$NANOX_FCFLAGS"],
		options      => template("$module_name/nanox_options.erb"),
		dest         => $NANOX_PREFIX,
		require      => Exec["rename nanox folder"]
	}
	
	# Compile Mercurium
	$MCXX_CFLAGS="-O3"
	$MCXX_CXXFLAGS="-O3"
	$MCXX_FCFLAGS="-O3"
	build_source::compile{"$module_name mcxx":
		sourceFolder => "/usr/src/ompss/mcxx",
		environment  => ["CFLAGS=$MCXX_CFLAGS","CXXFLAGS=$MCXX_CXXFLAGS","FCFLAGS=$MCXX_FCFLAGS"],
		options      => template("$module_name/mcxx_options.erb"),
		dest         => "/opt/ompss/mcxx",
		require       => [Exec["rename mercurium folder"],Build_source::Compile["$module_name nanox"]]
	}
}
