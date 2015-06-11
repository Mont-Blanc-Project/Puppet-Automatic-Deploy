class mali {
	file{"/dev/mali0":
		owner => 'root',
		group => 'root',
		mode  => '666',
	}
	package{"opencl-headers":
		ensure => installed,
	}
	file{"/usr/local/lib/libOpenCL.so"
		ensure => "/usr/local/lib/libmali.so",
		force  => true,
	}
}
