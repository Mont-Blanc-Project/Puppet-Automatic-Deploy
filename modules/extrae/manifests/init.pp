class extrae (  $unwind='',
		$papi='',
		$mpi='',
		$mpi_flavour='',
		$opencl='',
		$boost='',
		$fft='',
){
	$CFLAGS="-O3 -funwind-tables -g"
	$mpi_add = $mpi ? {
		''      => 'no_mpi',
		default => $mpi_flavour,
	}
	build_source{"$module_name":
		url               => "$module_name/extrae-3.1.0.tar.bz2",
		env               => ["CFLAGS=$CFLAGS","CXXFLAGS=$CFLAGS","FCFLAGS=-O3"],
		options           => template("$module_name/options.erb"),
		dest              => "/opt/extrae/3.1.0/$mpi_add",
		version           => "3.1.0",
		packages          => ["gfortran","libxml2-dev","binutils-dev","libiberty-dev","dpkg-dev"],
		module_type       => "tools",
		module_app_name   => "extrae",
		module_desc       => "Extrae Tool",
		module_extra_vars => {'EXTRAE_HOME' => "/opt/extrae/3.1.0/$mpi_add"}
	}
}
