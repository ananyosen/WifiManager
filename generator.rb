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
ui_files = []
ui_vala_files = []
object_files_release = []
object_files_debug = []

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
	_path.gsub!(" ", "\ ")
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


#write ressource xml
_res_xml = build_opts["res_xml"] || "res.xml"
res_xml = path_format(_res_xml, false)
res_file = File.open(res_xml, "w")
res_file.write(
	"<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<gresources>\n"
	)
ui_files.each {|_ui_file|
	_rindex = _ui_file.rindex("/")
	_prefix = _ui_file[0.._rindex]
	_file_name = _ui_file[_rindex + 1.._ui_file.length - 1]
	res_file.write(
		"	<gresource prefix=\"#{_prefix}\">
    <file compressed=\"true\" preprocess=\"xml-stripblanks\">#{_file_name}</file>
  </gresource>\n"
		)
}
res_file.write(
	"</gresources>"
	)
res_file.close()
#done

#write makefile
make_file = File.open(makefile, "w")
#release block
if do_release
	_deps_list = dev_deps.reduce {|a,b| a + " " + b}
	_deps_params = "`pkg-config --cflags #{_deps_list} gmodule-export-2.0`"

	make_file.write(
		"release: compile_vala compile_res
	[ -d \"#{release_path}\" ] || mkdir -p \"#{release_path}\"
	cd \"#{release_path}\" && $(MAKE) -f \"#{makefile}\" #{release_exec}\n\n"
	)

	vala_files.each {|_vala_file|
		_vala_file_name = _vala_file[_vala_file.rindex("/")+1.._vala_file.length - 1]
		make_file.write(
		"#{release_path}#{_vala_file_name}.o: #{c_path}#{_vala_file_name}.c
	gcc -o $@ -c $< -Wall #{_deps_params}\n\n"
		)
		object_files_release.push("#{release_path}#{_vala_file_name}.o")
	}

	_res_file_name = res_xml[res_xml.rindex("/")+1..res_xml.length - 1]
	make_file.write(
		"#{release_path}#{_res_file_name}.o: #{c_path}#{_res_file_name}.c
	gcc -o $@ -c $< -Wall #{_deps_params}\n\n"
		)		
	object_files_release.push("#{release_path}#{_res_file_name}.o")

	_object_files_all = object_files_release.reduce { |a, b| a + " " + b}
	#p _object_files_all

	#final exec
	make_file.write(
		"#{release_exec}: #{_object_files_all}
	gcc -o #{release_path}#{release_exec}  $^ #{_deps_params}\n\n"
		)
end


#do debug part, maybe i should invest in a function
if do_debug
	_deps_list = dev_deps.reduce {|a,b| a + " " + b}
	_deps_params = "`pkg-config --cflags #{_deps_list} gmodule-export-2.0`"

	make_file.write(
		"debug: compile_vala compile_res
	[ -d \"#{debug_path}\" ] || mkdir -p \"#{debug_path}\"
	cd \"#{debug_path}\" && $(MAKE) -f \"#{makefile}\" #{debug_exec}\n\n"
	)

	vala_files.each {|_vala_file|
		_vala_file_name = _vala_file[_vala_file.rindex("/")+1.._vala_file.length - 1]
		make_file.write(
		"#{debug_path}#{_vala_file_name}.o: #{c_path}#{_vala_file_name}.c
	gcc -o $@ -g -c $< -Wall #{_deps_params}\n\n"
		)
		object_files_debug.push("#{debug_path}#{_vala_file_name}.o")
	}

	_res_file_name = res_xml[res_xml.rindex("/")+1..res_xml.length - 1]
	make_file.write(
		"#{debug_path}#{_res_file_name}.o: #{c_path}#{_res_file_name}.c
	gcc -o $@ -g -c $< -Wall #{_deps_params}\n\n"
		)		
	object_files_debug.push("#{debug_path}#{_res_file_name}.o")

	_object_files_all = object_files_debug.reduce { |a, b| a + " " + b}
	#p _object_files_all

	#final exec
	make_file.write(
		"#{debug_exec}: #{_object_files_all}
	gcc -o #{debug_path}#{debug_exec} $^ -g #{_deps_params}\n\n"
		)
end

#do compile vala

_pkg = dev_deps.reduce {|a, b| a + " --pkg " + b}
_valas = vala_files.reduce {|a,b| a + " " + b}
make_file.write(
	"compile_vala:
	[ -d \"#{c_path}\"] || mkdir -p \"#{c_path}\"
	valac --pkg #{_pkg} #{_valas}  --target-glib=2.38 --gresources #{res_xml} -C -d #{c_path}\n\n"
	)

#do compile red

_uis = ui_files.reduce {|a,b| a + " " + b}
_res_file_name = res_xml[res_xml.rindex("/")+1..res_xml.length - 1]
make_file.write(
	"compile_res: #{res_xml} #{_uis}
	[ -d \"#{c_path}\"] || mkdir -p \"#{c_path}\"
	glib-compile-resources #{res_xml} --target=#{c_path}#{_res_file_name}.c --sourcedir=$(srcdir) --c-name _ap --generate-source\n\n"
	)

#do cleanup

make_file.write(
	"clean:
	rm -rfv #{release_path}
	rm -rfv #{debug_path}
	rm -rfv #{c_path}\n\n"
	)

#do all

make_file.write(
	"all: debug release"
	)

make_file.close()

# p vala_files
# p ui_files
# p c_path
# p debug_path
# p release_path
# p makefile