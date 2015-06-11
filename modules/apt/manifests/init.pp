class apt {
        exec{'apt-update':
                command => "/usr/bin/apt-get update",
                user    => 'root',
                group   => 'root',
                onlyif  => "/bin/sh -c '[ ! -f /var/cache/apt/pkgcache.bin ] || /usr/bin/find /etc/apt/* -cnewer /var/cache/apt/pkgcache.bin | /bin/grep . > /dev/null'"
        }
        Exec['apt-update'] -> Package<| |>
}
