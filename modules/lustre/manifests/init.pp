#mountPoints is a hash where keys are the mountPoints and values are the path of the server
class lustre ($server,$mountPoints){
	define mountLustre($server,$mountPoints){
		$remote = $mountPoints[$title]
		mount{$title:
			device  => "${server}:${remote}",
			fstype  => 'lustre',
			ensure  => mounted,
			options => 'rw,hard,intr,vers=3,nolock,_netdev',
		}
		file{$title:
			ensure => directory,
			mode   => '755',
		}
	}
	include stdlib
	$mounts = keys($mountPoints)
	mountNFS{$mounts:
		server      => $server,
		mountPoints => $mountPoints
	}
}

