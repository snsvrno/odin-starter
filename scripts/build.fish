#!/usr/bin/fish

# odin project build script
function main
	# checks that required things are available in path
	check_exists odin; if test $status -eq 1; return 1; end
	check_exists jq; if test $status -eq 1; return 1; end

	# some variables that will be project specific
	set -l SRC_PATH src
	set -l OUT_PATH bin
	set -l EXE_NAME game
	set -l EXE_FULL_PATH ""

	argparse \
		'r/release' 'd/dev' 'l/lib' 'a/assets' \
		'b/bundled' \
		'x/run' \
		'h/help' \
		-- $argv

	# man
	if set -q _flag_help
		man_heading "builds"
		man_line "r/release" "builds release version of project"
		man_line "d/dev" "builds full dev version of project"
		man_line "l/lib" "builds the library of the dev project"
		man_line "a/assets" "builds the res/asset package"
		echo ""
		man_heading "other"
		man_line "h/help" "this display"
		man_line "x/run" "run the project after building"
		man_line "b/bundled" "will build the project with embedded libraries instead of external linked"
	end

	#####################################
	# setting up the build parameters and options

	set -l build_options \
		-json-errors

	# things that must be set in order to get the hot reload working properly
	set -l dev_only_options \
		-define:RAYLIB_SHARED=true

	# checks if we are 100% commited, or if there is some un tracked stuff
	set -l git_status "*"; if test -z "$(git status --porcelain)"; set git_status ""; end
	set -l build_vars \
		-define:GAME_VERSION="$(git describe --abbrev=0)" \
		-define:BUILD_ARTIFACT=\""$(git rev-parse --short HEAD)$git_status"\" \
		-define:BUILD_TIME="$(date +%y-%j-%H%M)"

	# tools and other build things
	set -l tool_res "tools/res" "tools/res/run.fish" -src=res -target=src/res.odin -d

	############################
	if set -q _flag_release

		# if we want a bundled release, we can only check this here
		# because DEV needs things to be separated in order to do 
		# the hot reloading
		if set -q _flag_bundled
			# nothing here now
		else
			set build_options $build_options \
				-define:RAYLIB_SHARED=true
		end

		mkdir -p $OUT_PATH/tools
		odin_build_thing $tool_res
		if test $status -eq 1
			return 1
		end

		mkdir -p $OUT_PATH/release
		set EXE_FULL_PATH $OUT_PATH/release/$EXE_NAME
		odin_build_thing "release" build runner/release -out:$EXE_FULL_PATH $build_options $build_vars
		if test $status -eq 1
			return 1
		end
	
	end
	############################
	if set -q _flag_dev && not set -q _flag_release

		set _flag_lib 1 # always building library if we are building the dev runner

		mkdir -p $OUT_PATH/tools
		run_thing $tool_res
		if test $status -eq 1
			return 1
		end

		mkdir -p $OUT_PATH/dev
		set EXE_FULL_PATH $OUT_PATH/dev/$EXE_NAME
		odin_build_thing "dev/runner" build runner/dev -out:$OUT_PATH/dev/game \
			-debug $dev_only_options $build_options $build_vars
		if test $status -eq 1
			return 1
		end

	end
	###########################
	if set -q _flag_lib && not set -q _flag_release

		mkdir -p $OUT_PATH/dev

		odin_build_thing "dev/library" build src -out:$OUT_PATH/dev/game.so \
			-debug -build-mode:dll $dev_only_options $build_options $build_vars
		if test $status -eq 1
			return 1
		end
	
	end
	###########################

	# other things
	if set -q _flag_run
		if set -q _flag_dev
			fish $(dirname (status --current-filename))/dev-watcher.fish &
		end
		$EXE_FULL_PATH
	end

	return 0
end

function output_build_errors
	# some options
	set -l leader ">>> "
	set -l tab_space "    "
	# how many extra lines to show when outputting the error context
	set -l line_range 1

	set -l count (echo $argv | jq '.error_count')

	for i in (seq $count)
		# gets the error out of the cluster of all the errors
		# so the parsing is easier
		set -l ii (math $i - 1)
		set -l err $(echo $argv | jq ".errors[$ii]")

		set -l file (echo $err | jq -r ".pos.file")
		set -l line (echo $err | jq -r ".pos.line")
		set -l column (echo $err | jq -r ".pos.column")
		set -l type (echo $err | jq -r ".type")
		set -l msg (echo $err | jq -r ".msgs[]")
		
		# outputs the file name
		set_color -d; echo -n $leader; set_color normal;
		set_color -o; echo "$file($line:$column) "; set_color normal;

		# outputs the file content
		# making sure the limits are ok
		set -l lower_number (math $line - $line_range)
		if test $lower_number -lt 1; set lower_number 1; end
		set -l upper_number (math $line + $line_range)
		if test $upper_number -gt (cat $file | count); set upper_number (cat $file | count); end

		for l in (seq $lower_number $upper_number)
			set_color -d; echo -n "$leader$tab_space"; set_color normal
			set_color -d; printf "%03d" $l; echo -n " | "; set_color normal
			set -l line_text (sed "$l!d" $file)
			echo $line_text
			if test $line -eq $l
				set -l space (spacer (math (string length $tab_space) + 3 + 3 + $column))
				set_color -d; echo -n $leader; set_color normal;
				echo -n $space; echo -n "^ "
				switch $type
					case "error"
						set_color brred; echo -n "Error: "; set_color normal
					case "*"
						echo -n "$type  "
				end
				set_color -d ; echo $msg; set_color normal
			end
		end
	end

end

function spacer -a size glyph
	if set -q glyph
		set glyph " "
	end

	set -l spaces ""
	while test (string length $spaces) -lt $size
		set spaces "$glyph$spaces"
	end
	echo "$spaces"
end

# used to check if the program exists, and outputs an error if it does not.
function check_exists -a func_name
	if not type -q $func_name
		set_color --background brred -o brwhite; echo -n " E "; set_color normal;
		set_color -o $fish_color_command; echo -n " $func_name "; set_color normal;
		set_color red; echo "not found, used for parsing errors"; set_color normal;
		return 1
	end
	return 0
end

function out
	set_color -o blue
	echo -n "build.fish "
	set_color normal
	echo $argv
end

function man_heading -a name

	echo -n "  "
	set_color -ou magenta
	echo $name
	set_color normal

end

function man_line -a option description
	echo -n "    "

	set -l parts (string split "/" $option)

	set_color -o cyan
	echo -n $parts[1]
	set_color normal

	set_color -d white
	echo -n "/"
	set_color normal

	set_color -o cyan
	echo -n $parts[2]
	set_color normal

	set -l spacer " "
	while test (string length $spacer) -lt (math 16 - (string length $option))
		set spacer "$spacer."
	end

	echo -n "$spacer "

	set_color -i yellow
	echo $description
	set_color normal
end

function run_thing
	out -n "running $argv[1]: "
	set -l output ($argv[2..] 2>&1)

	if test $status -eq 0
			set_color green; echo "done"; set_color normal
		return 0
	else
		# will output the errors nicely since we have the json-errors switch
		set_color red; echo "failed"; set_color normal
		for line in $output
			echo ">>> $line"
		end
		return 1
	end

end

function odin_build_thing
	out -n "building $argv[1]: "
	set -l output (odin $argv[2..] 2>&1)

	if test $status -eq 0
			set_color green; echo "done"; set_color normal
		return 0
	else
		# will output the errors nicely since we have the json-errors switch
		set_color red; echo "failed"; set_color normal
		if test "$output[1]" = "{"
			output_build_errors $output
		else
			for line in $output
				echo ">>> $line"
			end
		end
		return 1
	end

end

main $argv
return $status
