#dependences = bison, flex
class gnu_compiler {
	#GMP
	$GMP_VER = "6.0.0a"
	$GMP_DEST = "/opt/gmp/$GMP_VER"
	$CFLAGS_GMP="-O3"
	build_source{"gmp":
		url      => "https://gmplib.org/download/gmp/gmp-6.0.0a.tar.xz",
		env      => ["CFLAGS=$CFLAGS_GMP"],
		dest     => $GMP_DEST,
		packages => ["bison","flex"]
	}
	
	#MPFR
	$CFLAGS_MPFR="-O3 -fPIC"
	$MPFR_VER = "3.1.2"
	$MPFR_DEST = "/opt/mpfr/$MPFR_VER"
	build_source{"mpfr":
		url     => "http://www.mpfr.org/mpfr-current/mpfr-3.1.2.tar.xz",
		env     => ["CFLAGS=$CFLAGS_MPFR"],
		options => template("$module_name/options_mpfr.erb"),
		dest	=> $MPFR_DEST,
		require => Build_source["gmp"]
	}
	#MPC
	$CFLAGS_MPC="-O3 -fPIC"
	$MPC_VER = "1.0.3"
	$MPC_DEST = "/opt/mpc/$MPC_VER"
	build_source{"mpc":
		url     => "ftp://ftp.gnu.org/gnu/mpc/mpc-1.0.3.tar.gz",
		env     => ["CFLAGS=$CFLAGS_MPC"],
		options => template("$module_name/options_mpc.erb"),
		dest	=> $MPC_DEST,
		require => [Build_source["mpfr"],Build_source["gmp"]]
	}
	#ISL
	$CFLAGS_ISL="-O3 -fPIC"
	$ISL_VER = "0.14"
	$ISL_DEST = "/opt/isl/$ISL_VER"
	build_source{"isl":
		url      => "http://mirror1.babylon.network/gcc/infrastructure/isl-0.14.tar.bz2",
		env      => ["CFLAGS=$CFLAGS_ISL"],
		options  => template("$module_name/options_isl.erb"),
		dest 	 => $ISL_DEST,
		require  =>  Build_source["gmp"],
		packages => ["llvm-dev","clang","libclang-dev"]
	}
	#CLOOG
	$CFLAGS_CLOOG="-O3 -fPIC"
	$CLOOG_VER = "0.18.3"
	$CLOOG_DEST = "/opt/cloog/$CLOOG_VER"
	build_source{"cloog":
		url     => "http://www.bastoul.net/cloog/pages/download/cloog-0.18.3.tar.gz",
		env     => ["CFLAGS=$CFLAGS_CLOOG"],
		options => template("$module_name/options_cloog.erb"),
		dest	=> $CLOOG_DEST,
		require => [Build_source["isl"],Build_source["gmp"]]
	}
	#GCC
	$CFLAGS_GCC="-O3"
	$GCC_VER="5.1.0"
	$GCC_PREFIX="/opt/gcc/$GCC_VER"
	build_source{"gcc":
		url             => "http://mirror1.babylon.network/gcc/releases/gcc-5.1.0/gcc-5.1.0.tar.gz",
		env             => ["CFLAGS=$CFLAGS_GCC"],
		dest            => $GCC_PREFIX,
		options         => template("$module_name/options_gcc.erb"),
		require         => [Build_source["cloog"],Build_source["isl"],Build_source["gmp"],Build_source["mpc"],Build_source["mpfr"]],
		module_type     => "compilers",
		module_app_name => "gcc",
		module_modname  => "gcc",
		module_desc     => "GNU Compiler Suite",
		version         => "5.1.0"
	}
}
