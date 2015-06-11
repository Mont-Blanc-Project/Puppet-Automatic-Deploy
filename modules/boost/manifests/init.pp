class boost {
	build_source{"$module_name":
		url             => "http://sourceforge.net/projects/boost/files/boost/1.58.0/boost_1_58_0.tar.gz",
		version         => "1.58.0",
		type            => 'bootstrap',
		builder         => 'b2',
		packages        => ["python-dev","libxml2-dev","libxslt1-dev","libbz2-dev"],
		module_type     => "sci-libs",
		module_app_name => "boost",
		module_desc     => "Boost C++ Librarires"
	}
}
