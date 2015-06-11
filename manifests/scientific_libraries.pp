class scientific_libraries {
	class{"hdf5":
                mpi     => "/opt/mpich/3.1.4",
        }
        Build_source::Compile['mpich'] -> Build_source::Compile['hdf5']
        include fftw
        include boost
        include lapack
        include opengl
	#include atlas
}
