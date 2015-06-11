class papi{
	$CFLAGS="-O3"
	$FFLAGS="-O3"
	build_source{"$module_name":
		url             => "http://icl.cs.utk.edu/projects/papi/downloads/papi-5.4.1.tar.gz",
		env             => ["CFLAGS=$CFLAGS","FFLAGS=$FFLAGS"],
		version         => "5.4.1",
		configDir       => "src",
		module_type     => "tools",
		module_app_name => "papi"
	}
}
