#################################################################
# This module fetches the file in the url and extracts it into  #
# the destination folder.					#
# Params:							#
# url     => The url of the file to fetch, it accepts http(s)	# 
#  	     and ftp urls, other strings will be interpreted    #
#	     as puppet files with the prefix puppet:///modules/ #
# dest    => (defaults to /usr/src/$title) destination folder	#
# creates => (defaults to configure) a file/folder that exists	#
#	     when the package is extracted			#
#################################################################
define build_source::archive(
	$url,
	$dest="/usr/src/$title", 
	$creates='configure',
) {
	include stdlib
	ensure_resource('file','/usr/local/bin/extract.pl',{'ensure' => 'file','owner'  => 'root','group'  => 'root', 'mode'   => '755','source' => "puppet:///modules/build_source/extract.pl"})
	$filename = inline_template('<%= File.basename(@url) %>')
	Exec {
		user    => 'root',
		timeout => $timeout,
		path    => '/usr/bin:/bin',
	}
	$pathComplet = getPaths($dest)
	ensure_resource('file',$pathComplet,{'ensure' => 'directory','owner' => 'root', 'group' => 'root'})
	
	if ($url =~ /^http(s)?:\/\// or $url =~ /^ftp:\/\//) {
		exec { "Download $title":
			command => "wget $url -O $filename",
			cwd     => "/tmp",
			creates => "/tmp/$filename",
			before  => Exec["Extract $title"]
		}
	}
	else{
		file {"/tmp/$filename":
			ensure => file,
			source => "puppet:///modules/$url",
			owner  => 'root',
			group  => 'root',
			before => Exec["Extract $title"]
		}
	}
	exec { "Extract $title":
       		command => "/usr/local/bin/extract.pl /tmp/$filename",
		cwd     => "$dest",
		creates => "$dest/$creates",
		require => [File['/usr/local/bin/extract.pl'],File[$dest]]
	}
}
