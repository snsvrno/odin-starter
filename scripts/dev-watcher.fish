#!/usr/bin/fish

# watches the build artifacts for dev and will trigger rebuilds when needed
# only runs when game is running

function main

	get_odin_files

	while true
		if test "$(pgrep -x "game")" = ""
			return 0
		end

		if changes
			get_odin_files

			build.fish -l
		end

		sleep 1s
	end

end

function changes

	for file in $odin_files
		if test (date -r $file) != (get_value odin_files $file)
			out $file has changed
			return 0
		end
	end

	return 1
end

function get_odin_files
	set -g odin_files
	set -l paths shared src runner/dev
	for p in $paths
		for file in (find ./$p -type f -name "*odin")
			set -ga odin_files $file
			set_value odin_files $file (date -r $file)
		end
	end
end

function set_value -a dict key value
	set -g $dict'__'$(normalize $key) $value
end

function get_value -a dict key
	eval echo \$$dict'__'$(normalize $key)
end

function normalize -a key
	set -l nkey (echo $key | sed 's/\.//g' | sed 's/\//_/g')
	echo $nkey
end

function out
	set_color -o yellow
	echo -n "dev-watch.fish "
	set_color normal
	echo $argv
end

main
