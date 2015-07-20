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
