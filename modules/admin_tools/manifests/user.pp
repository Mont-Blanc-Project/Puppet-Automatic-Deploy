define admin_tools::user($key) {
	user {$title:
		ensure     => present,
		forcelocal => true,
		expiry     => absent,
		managehome => true,
		shell      => '/bin/bash',
	}
	ssh_authorized_key {"$title key as root":
		ensure => present,
		user   => 'root',
		type   => 'ssh-rsa',
		key    => $key
	}
	ssh_authorized_key {"$title key":
		ensure => present,
		user   => $title,
		type   => 'ssh-rsa',
		key    => $key
	}
	file{"/etc/sudoers.d/$title":
		ensure  => file,
		mode    => '440',
		owner   => 'root',
		group   => 'root',
		content => "$title ALL=(ALL) NOPASSWD:ALL"
	}
}
