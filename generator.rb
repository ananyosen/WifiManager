require 'yaml'
require 'fileutils'

build_opts = YAML.load_file("build_opt.yaml")
pwd = FileUtils.pwd()

if build_opts.key?("version")
	version = build_opts["version"];
end

run_deps = build_opts["run_deps"] || []
dev_deps = build_opts["dev_deps"] || []

vala_files = []

def path_format(_path, is_dir)
	_pwd = Dir.pwd()
	_home = Dir.home()
	if _path.start_with?("~/")
		_path.gsub!("~/", _home + "/")
	end
	_path = File.absolute_path(_path)
	if is_dir and (not _path.end_with?("/"))
		_path = _path + "/"
	end
	return _path
end

if build_opts.key?("vala_files")
	_tmp = build_opts["vala_files"]
	_tmp.each {|_x|
		if not _x.is_a?(Hash)
			vala_files.push(pwd + "/" + _x)
		else if _x.values()[0].key?("path")
				_path = _x.values()[0]["path"]
				path = path_format(_path, true)
				vala_files.push(path + _x.keys()[0])
			else
				puts "Invalid path for file #{_x.to_s()}"
			end
		end
	}
end

ui_files = []
ui_vala_files = []

if build_opts.key?("ui_files")
	_tmp = build_opts["ui_files"]
	_tmp.each {|_x|
		if not _x.is_a?(Hash)
			ui_files.push(pwd + "/" + _x)

		else if _x.values()[0].key?("path")
				_path = _x.values()[0]["path"]
				path = path_format(_path, true)
				# vala_path = path_format(_x, "vala_path")
				ui_files.push(path + _x.keys()[0])
			else
				puts "Invalid path for file #{_x.to_s()}"
			end
		end

	}
end

do_debug = build_opts["debug_build"] || false
do_release = build_opts["release_build"] || false

if do_debug
	debug_exec = build_opts["debug_executable"] || "debug_run"
end

if do_release
	release_exec = build_opts["release_executable"] || "run"
end

_c_path = build_opts["c_path"] || "./builds/"
c_path = path_format(_c_path, true)

if do_debug 
	_debug_path = build_opts["debug_path"] || "./builds/debug"
	debug_path = path_format(_debug_path, true)
end

if do_release 
	_release_path = build_opts["release_path"] || "./builds/release"
	release_path = path_format(_release_path, true)
end

_makefile = build_opts["makefile"] || "./Makefile"
makefile = path_format(_makefile, false)

p vala_files
p ui_files
p c_path
p debug_path
p release_path
p makefile