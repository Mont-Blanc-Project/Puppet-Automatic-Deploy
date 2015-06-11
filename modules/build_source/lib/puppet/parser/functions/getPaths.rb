module Puppet::Parser::Functions
	newfunction(:getPaths, :type => :rvalue, :doc => "\
	Generate a list of paths from the one given
	")\
	do |args|
		if args.length != 1
	    		self.fail("getPaths(): wrong number of arguments" +
		      " (#{args.length} for 1)")
		end
		dir = args[0]
		arr = dir.split("/")
		paths = ""
		files = []
		arr.each do |path|
        		if path != ""
                		paths = paths + "/" + path
        			files.push(paths)
        		end
		end
		return files
	end
end
