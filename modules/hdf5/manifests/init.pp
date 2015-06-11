#dependences =  gfortran, g++
class hdf5 (
		$mpi='',
) {
	$CFLAGS="-O3"
	$FCFLAGS="-O3"
	build_source{"$module_name":
		url             => "http://www.hdfgroup.org/ftp/HDF5/current/src/hdf5-1.8.15-patch1.tar.gz",
		env             => ["CFLAGS=$CFLAGS","CXXFLAGS=$CFLAGS","FCFLAGS=-O3"],
		options         => template("$module_name/options.erb"),
		version         => "1.8.15",
		packages        => ["gfortran"],
		module_type     => "sci-libs",
		module_app_name => "hdf5",
		module_desc     => "HDF5 libraries"
	}
}
