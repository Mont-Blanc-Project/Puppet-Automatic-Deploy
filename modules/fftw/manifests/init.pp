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

#dependences = gfortran
class fftw{
	$CFLAGS="-O3"
	$FFLAGS="-O3"
	build_source{"$module_name single precision":
		url      => "http://www.fftw.org/fftw-3.3.4.tar.gz",
		srcDest  => "/usr/src/fftw/3.3.4",
		env	     => ["CFLAGS=$CFLAGS","FFLAGS=$FFLAGS"],
		buildDir => "single_precision",
		options  => "--enable-fma --enable-threads --enable-shared --enable-single",
		dest     => "/opt/fftw/3.3.4_single",
		version  => "3.3.4_single",
		packages => ["gfortran"]
	}
	build_source{"$module_name double precision":
		url             => "http://www.fftw.org/fftw-3.3.4.tar.gz",
		srcDest         => "/usr/src/fftw/3.3.4",
		env	            => ["CFLAGS=$CFLAGS","FFLAGS=$FFLAGS"],
		buildDir        => "double_precision",
		dest            => "/opt/fftw/3.3.4",
		options         => "--enable-fma --enable-threads --enable-shared",
		version         => "3.3.4",
		module_type     => "sci-libs",
		module_app_name => "fftw",
		module_modname  => "fftw",
		module_desc     => "Fastest Fourier Transform in the West"
	}

	exec { "merge libraries":
		user    => 'root',
		group   => 'root',
		path    => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games',
		command => "cp -a /opt/fftw/3.3.4_single/lib/lib* /opt/fftw/3.3.4/lib",
		require => [Build_source["$module_name single precision"],Build_source["$module_name double precision"]],
		creates => "/opt/fftw/3.3.4/lib/libfftw3f.la"
	}
}
