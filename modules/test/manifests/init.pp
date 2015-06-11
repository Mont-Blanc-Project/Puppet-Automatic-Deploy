define test{
	$unwind = 'a'
	$papi = 'b'
	$mpi = 'c'
	$opencl = 'd'
	$boost = 'e'
	$fft = 'f'
	file{"/tmp/$title":
		ensure  => file,
		content => template("test/options.erb")
	}
}
