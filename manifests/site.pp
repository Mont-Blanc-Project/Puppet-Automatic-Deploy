class all {
	include apt
	include ntp
	include puppet
	#class{"nfs":
	#	server      => '10.0.2.15',
	#	mountPoints => {'/tmp/ma' => '/tmp/a','/tmp/mb' => '/tmp/b'},
	#}
	include scientific_libraries
	include tools
	include compilers_runtime
	include admin_tools
	admin_tools::user{"uriviba":
		key => 'AAAAB3NzaC1yc2EAAAADAQABAAABAQCungLuYMIsB7RX3iKVabIWUjW5gmMmtgt7L3Q70O5BHJWrxKjx/ejnIoRvsrd3FdMQSdOKA9NmPFN+ihx1GUvkR8ekKJg4YOgnI5YiUZUs9+clfNB3SfvpR2cpzAmmzIZvngEYPsA3wGTbn4XYDEZZkmFU73+DccYI9pMh4jITieleYpjspMIyQ4F3cieqGvCAttf0yVArg4Te0vQthATuzXpj9KV3R7lsDax7kt3g1GgBbeyPER4xLt/ntGGGvZS4uI78GVewmZg+mqPq5nQku7cyRk1nHD6RL/l7L3yYtEUcAZG1i23v/zm5tGULQiVGp0u6iHpgBksWoDYtfDHJ'
	}
	admin_tools::user{"test":
		key => 'AAAAB3NzaC1yc2EAAAADAQABAAABAQCWyY7Qc/a5eReRRZV6T5fQSpEqvkWE0AK3rsA6I/s6klOXKKzODbb3Pe5chxcmKgJk6e6MHBUwaNHqYPkfuuJQ8Y8mvUGq5rtXPeF7+mK1B3iu7J4aRmGl+pnvimEG6Jm7lL0JpvKtj8eleikOkYhM3rnX57jKl4HsC9GXVfurNhNtVuXEB24n3RCY/vKqkqyOLfVXC7cNUaFh9V4m8uJ2jgxxoGJUuTNksE+DVoAZjSfJ1y/mie/C8pxhzCnUzG97xsaVf6fl9he0du1EM5LsOF2SG80UVyl7hLhYf6sysQFVNJHpCXlzrK6KaPE5ta6iFvwtloMpLdY18q5NHfdt'
	}
}
node default {
	include all
}
node 'xubuntu-1404' {
	include all
}
node 'laptop' {
	include all
}
node 'davm' {
	include slurm_client
}
