#Copyright (c) 2015, Barcelona Supercomputing Center 
#All rights reserved.
#
#Redistribution and use in source and binary forms, with or without
#modification, are permitted provided that the following conditions are met:
#
#1. Redistributions of source code must retain the above copyright notice, this
#   list of conditions and the following disclaimer.
#2. Redistributions in binary form must reproduce the above copyright notice,
#   this list of conditions and the following disclaimer in the documentation
#   and/or other materials provided with the distribution.
#
#THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
#ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
#WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
#DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
#ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
#(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
#LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
#ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
#(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
#SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
#The views and conclusions contained in the software and documentation are those
#of the authors and should not be interpreted as representing official policies,
#either expressed or implied, of the FreeBSD Project.

#IDEA: pillar el basename, clustername i demas de el hostname
class slurm_client ( $basename,
			$init_node_number,
			$end_node_number,
			$clustername,
			$accounting_hostname,
			$controller_hostname,
			$controller_ip_address,
			$slurmdbd_pass,
			$root_db_user,
			$root_db_pass
) {
	if ( $server != 'no' ) {
		$dependences = ["munge","libmunge-dev","libcr-dev","libpam0g-dev","libssl-dev","openssl","libmysqld-dev","mysql-common","pkg-config","libxml2-dev","hwloc","libmysqlclient-dev","libhwloc-dev","mysql-client","mysql-server"]
	} else {
		$dependences = ["munge","libmunge-dev","libcr-dev","libpam0g-dev","libssl-dev","openssl","libmysqld-dev","mysql-common","pkg-config","libxml2-dev","hwloc","libmysqlclient-dev","libhwloc-dev","mysql-client"]
	}
	# installation
	build_source{"$module_name":
		url      => "$module_name/slurm-14.11.7.tar.bz2",
		options  => template("$module_name/options.erb"),
		version  => "14.11.7",
		packages => ["munge","libmunge-dev","libcr-dev","libpam0g-dev","libssl-dev","openssl","libmysqld-dev","mysql-common","pkg-config","libxml2-dev","hwloc","libmysqlclient-dev","libhwloc-dev","mysql-client"]
	}
	
	# SLURM user configuration
	group { "$module_name group":
		name   => "slurm",
		ensure => present,
		gid    => 999,
		system => true
	}
	user {  "$module_name user":
		name    => "$module_name",
		ensure  => present,
		uid     => '999',
		system  => true,
		gid     => '999',
		require => Group["$module_name group"]
	}

	# SLURM needed folders
	File {
		user    => "slurm",
		group   => "slurm",
		require => User["$module_name user"],
		mode    => '644'
	}
	$slurmdir = "/opt/slurm/14.11.7"
	$bindir = "$slurmdir/bin"
	$sbindir = "$slurmdir/sbin"
	$libdir = "$slurmdir/lib"
	$sysconfdir = "$slurmdir/etc"
	$BLUEGENE_LOADED_FALSE = "FALSE"

	# Variables for slurm.conf
	$nProcessors = $::processorcount
	$nSockets = $::physicalprocessorcount
	$memory = $::memorysize_mb


	file {
	"$module_name sysconfdir folder":
		ensure => directory,
		mode   => '755',
		path   => "$sysconfdir";
	"$module_name script folder":
		ensure  => directory,
		mode    => '755',
		path    => "$sysconfdir/scripts";
	"$module_name var folder":
		ensure => directory,
		mode   => '755',
		path   => "$slurmdir/var";
	"$modeule_name var_log folder":
		ensure  => directory,
		mode    => '755',
		path    => "$slurmdir/var/log";
	"$modeule_name var_slurm folder":
		ensure => directory,
		mode   => '755',
		path   => "$slurmdir/var/slurm";
	}

	# SLURM Files
	file {
	"$module_name init script":
		ensure  => file,
		user    => 'root',
		group   => 'root',
		mode    => '755',
		content => template("$module_name/init.d.slurm.erb"),
		path   => "/etc/init.d/slurm";
	"$module_name ld_library_path file":
		ensure    => file,
		user      => 'root',
		group     => 'root',
		content   => template("$module_name/ldconfig.erb"),
		path      => "/etc/ld.so.conf.d/slurm.conf";
		notify    => Exec["$module_name exec ldconfig"]; 
	"$module_name slurm configuration file":
		ensure  => file,
		path    => "$sysconfdir/slurm.conf",
		content => template("$module_name/slurm_configuration.erb");
	"$module_name slurm DB configuration":
		ensure  => file,
		path    => "$sysconfdir/slurmdbd.conf",
		content => template("$module_name/slurm_db_configuration.erb");
	"$module_name slurm ssl public key":
		ensure => file,
		path   => "$sysconfdir/public.key",
		source => "puppet:///$module_name/public.key"; # MUST be put there by the user or generated by the server
	}

	exec { "$module_name exec ldconfig":
		user    => 'root',
		group   => 'root',
		path    => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games',
		command => "ldconfig"
	}

	# Generate the keys if server
	if ( "server" != "no" ) {
		Exec {
			user  => 'root',
			group => 'root',
			path  => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games'
		}
		exec { "$module_name generate SSL private key":
			command => "openssl genrsa -out $sysconfdir/private.key",
			creates => "$sysconfdir/private.key"
		}
		exec { "$module_name generate SSL public key":
			command => "openssl rsa -in $sysconfdir/public.key -pubout -out $sysconfdir/public.key",
			creates => "$sysconfdir/public.key",
			require => Exec["$module_name generate SSL private key"]
		}
		# Correct permissions of the keys
		file { "$module_name permissions private SSL key":
			require => Exec["$module_name generate SSL private key"],
			mode    => '644',
			user    => 'root',
			group   => 'root'
		}
		file { "$module_name permissions public SSL key":
			require => Exec["$module_name generate SSL public key"],
			mode    => '644',
			user    => 'root'
			group   => 'root'
		}

		# put the public key somewhere the client can get it
		exec { "$module_name move public key to own module files":
			command => "cp -a $sysconfdir/public.key /etc/puppet/modules/$module_name/files",
			creates => "/etc/puppet/modules/$module_name/files"
		}
		# create slurm user on the DB, should have root access to mysql
		exec { "$module_name init slurm db":
			command => "mysql --user=\"$root_db_user\" --pass=\"$root_db_pass\" --host=localhost --execute=\"grant all on slurm_acct_db.* TO 'slurm'@'localhost' identified by '$slurmdbd_pass' with grant option;",
			# FIX: PERO ESTO NO CREA NADA... SE EJECUTARA CADA VEZ Y NO ES DESEABLE
		}
	}
}
