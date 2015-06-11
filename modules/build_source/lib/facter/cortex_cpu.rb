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
