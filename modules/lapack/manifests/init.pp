class lapack {
	build_source{"$module_name":
		url             => "http://www.netlib.org/lapack/lapack-3.5.0.tgz",
		version         => "3.5.0",
		type            => 'cmake',
		packages        => ["gfortran"],
		module_type     => "sci-libs",
		module_app_name => "lapack",
	}
}
