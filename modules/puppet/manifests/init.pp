class puppet ($minuteCron = "0",$hourCron = "0"){
	package { "puppet":
		ensure => latest,
	}
	group { "puppet":
		ensure  => present,
		system  => true,
		require => Package['puppet'],
	}
	user { "puppet":
		ensure  => present,
		gid     => 'puppet',
		system  => true,
		shell   => '/bin/false',
		home    => '/var/lib/puppet',
		require => Group['puppet'],
	}
	service {"puppet":
		ensure => stopped,
		enable => false,
	}
	file {'/etc/puppet/puppet.conf':
		ensure  => file,
		source  => 'puppet:///modules/puppet/puppet.conf',
		owner   => 'puppet',
		group   => 'puppet',
		mode    => '644',
		require => User['puppet']
	}
	file {'/etc/puppet/hiera.yaml':
		ensure  => file,
		source  => 'puppet:///modules/puppet/hiera.yaml',
		owner   => 'puppet',
		group   => 'puppet',
		mode    => '644',
		require => User['puppet']
	}
	cron {"puppetrun":
		ensure  => present,
		command => "/usr/bin/puppet apply /etc/puppet/manifests/ --logdest /var/log/puppet/apply.log",
		user    => 'root',
		minute  => $minuteCron,
		hour    => $hourCron,
	}
}
