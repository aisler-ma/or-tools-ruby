require "mkmf-rice"

$CXXFLAGS << " -std=c++17 $(optflags) -DUSE_CBC -DOR_PROTO_DLL="

# show warnings
$CXXFLAGS << " -Wall -Wextra"

# hide or-tools warnings
$CXXFLAGS << " -Wno-sign-compare -Wno-ignored-qualifiers -Wno-unused-parameter -Wno-missing-field-initializers"

# hide Rice warnings
$CXXFLAGS << " -Wno-unused-private-field -Wno-implicit-fallthrough"

inc, lib = dir_config("or-tools")
if inc || lib
  puts "Using external OR-Tools"
  inc ||= "/usr/local/include"
  lib ||= "/usr/local/lib"
  lib64 ||= "/usr/local/lib64"
  rpath = lib
else
  puts "Downloading OR-Tools"
  # download
  require_relative "vendor"

  inc = "#{$vendor_path}/include"
  lib = "#{$vendor_path}/lib"
  lib64 = "#{$vendor_path}/lib64"

  # make rpath relative
  # use double dollar sign and single quotes to escape properly
  rpath_prefix = RbConfig::CONFIG["host_os"].match?(/darwin/) ? "@loader_path" : "$$ORIGIN"
  rpath = "'#{rpath_prefix}/../../tmp/or-tools/lib'"
  rpath64 = "'#{rpath_prefix}/../../tmp/or-tools/lib64'"
end

# find_header and find_library first check without adding path
# which can cause them to find system library
$INCFLAGS << " -I#{inc}"
$LDFLAGS.prepend("-Wl,-rpath,#{rpath} -Wl,-rpath,#{rpath64} -L#{lib} -L#{lib64} ")
raise "OR-Tools not found" unless have_library("ortools")

create_makefile("or_tools/ext")
