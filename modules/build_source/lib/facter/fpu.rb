# fpu.rb

Facter.add('fpu') do
	confine :kernel => 'Linux'
	confine :architecture => 'armv7l'
	setcode do
		res = Facter::Util::Resolution.exec('cat /proc/cpuinfo | grep "Features" | uniq')
		arr = res.split(" ")
		if arr.include?("vfpv4")
			answer = "vfpv4"
		elsif arr.include?("vfpv3")
			answer = "vfpv3"
		elsif arr.include?("vfp")
			answer = "vfp"
		else
			answer = "Not supported"
		end
	end
end
