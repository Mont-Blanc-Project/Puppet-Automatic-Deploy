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
