class tools{
	include papi
        class{"extrae":
                papi        => "/opt/papi/5.4.1",
                mpi         => "/opt/mpich/3.1.4",
                mpi_flavour => 'mpich',
                boost       => '/opt/boost/1.58.0',
                fft         => '/opt/fftw/3.3.4',
        }
        include environment_modules
        $extraeDeps = ['fftw','mpich','boost','papi']
        Class[$extraeDeps] -> Build_source::Compile['extrae']
}
