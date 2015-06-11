#mountPoints is a hash where keys are the mountPoints and values are the path of the server
class nfs ($server,$mountPoints){
	define mountNFS($server,$mountPoints){
		$remote = $mountPoints[$title]
		mount{$title:
			device  => "${server}:${remote}",
			fstype  => 'nfs',
			ensure  => mounted,
			options => 'rw,hard,intr,vers=3,nolock,_netdev',
			require => Package['nfs-common'],
		}
		file{$title:
			ensure => directory,
			mode   => '755',
		}
	}
	include stdlib
	package {"nfs-common":
		ensure => installed,
	}
	$mounts = keys($mountPoints)
	mountNFS{$mounts:
		server      => $server,
		mountPoints => $mountPoints
	}
}

