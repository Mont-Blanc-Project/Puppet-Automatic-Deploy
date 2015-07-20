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

# cortex_cpu.rb

map = Hash.new

map["0xc05"]="cortex-a5"
map["0xc07"]="cortex-a7"
map["0xc08"]="cortex-a8"
map["0xc09"]="cortex-a9"
map["0xc0c"]="cortex-a12"
map["0xc0f"]="cortex-a15"
map["0xc11"]="cortex-a17"
map["0xc07\n0xc0f"]="cortex-a15.cortex-a7"
map["0xc0f\n0xc07"]="cortex-a15.cortex-a7"
map["0xc07\n0xc11"]="cortex-a17.cortex-a7"
map["0xc11\n0xc07"]="cortex-a17.cortex-a7"

Facter.add('cortex_cpu') do
	confine :kernel => 'Linux'
	confine :architecture => 'armv7l'
	setcode do
		part = Facter::Util::Resolution.exec('cat /proc/cpuinfo | grep "CPU part" | uniq | awk \'{print $4}\'')
		if map.has_key?(part)
			answer = map[part]
		else
			answer = "Not a cortex-a CPU"
		end
	end
end
