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
