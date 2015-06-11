#dependences = g++, gfortran, hwloc
class openmpi (  $slurm=''
){
	$CFLAGS="-O3"
	$FCFLAGS="-O3"
	build_source{"$module_name":
		url             => "http://www.open-mpi.org/software/ompi/v1.8/downloads/openmpi-1.8.3.tar.gz",
		env             => ["CFLAGS=$CFLAGS","CXXFLAGS=$CFLAGS","FCFLAGS=$FCFLAGS"],
		options         => template("$module_name/options.erb"),
		version         => "1.8.3",
		packages        => ["gfortran","libhwloc-dev"],
		module_type     => "compilers",
		module_app_name => "openmpi"
	}
}
