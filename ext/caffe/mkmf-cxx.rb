require 'mkmf-rice'

$CXXFLAGS = ''

TRY_LINK.sub!(/^#{Regexp.quote($CXX)}/, '$(CXX)')
$LDSHARED_CXX.sub!(/^#{Regexp.quote($CXX)}/, '$(CXX)')
$CXX = '$(CXX)'

if CONFIG['target_os'] == 'mswin32' && $RICE_USING_MINGW32
    init_rice_mkmf_cross_compile_mingw2_for_vc6
end

def configuration(srcdir)
  configuration = configuration_orig(srcdir)
  configuration.each do |config|
    # Make sure we link the extension using the C++ compiler
    config.gsub!(/^LDSHARED\s*=.*$/, "LDSHARED = #{$LDSHARED_CXX}")

    # Make sure set the C++ flags correctly
    config.gsub!(/^CXXFLAGS\s*=.*$/, "CXXFLAGS = $(CFLAGS) #{$CXXFLAGS}")
  end
  return configuration
end

RbConfig::CONFIG['CXXPP'] = RbConfig::CONFIG['CXX'] + ' -E'
CONFTEST_CC = "#{CONFTEST}.cc"

def create_tmpsrc_cxx(src)
  src = "#{COMMON_HEADERS}\n#{src}"
  src = yield(src) if block_given?
  src.gsub!(/[ \t]+$/, '')
  src.gsub!(/\A\n+|^\n+$/, '')
  src.sub!(/[^\n]\z/, "\\&\n")
  count = 0
  begin
    open(CONFTEST_CC, "wb") do |cfile|
      cfile.print src
    end
  rescue Errno::EACCES
    if (count += 1) < 5
      sleep 0.2
      retry
    end
  end
  src
end

def try_do_cxx(src, command, *opts, &b)
  unless have_devel?
    raise <<MSG
The compiler failed to generate an executable file.
You have to install development tools first.
MSG
  end
  begin
    src = create_tmpsrc_cxx(src, &b)
    xsystem(command, *opts)
  ensure
    log_src(src)
    MakeMakefile.rm_rf "#{CONFTEST}.dSYM"
  end
end

def link_command(ldflags, opt="", libpath=$DEFLIBPATH|$LIBPATH)
  librubyarg = $extmk ? $LIBRUBYARG_STATIC : "$(LIBRUBYARG)"
  conf = RbConfig::CONFIG.merge('hdrdir' => $hdrdir.quote,
                                'src' => "#{CONFTEST_CC}",
                                'arch_hdrdir' => $arch_hdrdir.quote,
                                'top_srcdir' => $top_srcdir.quote,
                                'INCFLAGS' => "#$INCFLAGS",
                                'CPPFLAGS' => "#$CPPFLAGS",
                                'CXXFLAGS' => "#$CXXFLAGS",
                                'CFLAGS' => "#$CFLAGS",
                                'ARCH_FLAG' => "#$ARCH_FLAG",
                                'LDFLAGS' => "#$LDFLAGS #{ldflags}",
                                'LOCAL_LIBS' => "#$LOCAL_LIBS #$libs",
                                'LIBS' => "#{librubyarg} #{opt} #$LIBS")
  conf['LIBPATH'] = libpathflag(libpath.map {|s| RbConfig::expand(s.dup, conf)})
  RbConfig::expand(TRY_LINK.dup, conf)
end

def try_link0(src, opt="", *opts, &b) # :nodoc:
  cmd = link_command("", opt)
  if $universal
    require 'tmpdir'
    Dir.mktmpdir("mkmf_", oldtmpdir = ENV["TMPDIR"]) do |tmpdir|
      begin
        ENV["TMPDIR"] = tmpdir
        try_do_cxx(src, cmd, *opts, &b)
      ensure
        ENV["TMPDIR"] = oldtmpdir
      end
    end
  else
    try_do_cxx(src, cmd, *opts, &b)
  end and File.executable?(CONFTEST+$EXEEXT)
end

def cxxpp_command(outfile, opt="")
  conf = RbConfig::CONFIG.merge('hdrdir' => $hdrdir.quote, 'srcdir' => $srcdir.quote,
                                'arch_hdrdir' => $arch_hdrdir.quote,
                                'top_srcdir' => $top_srcdir.quote)
  if $universal and (arch_flag = conf['ARCH_FLAG']) and !arch_flag.empty?
    conf['ARCH_FLAG'] = arch_flag.gsub(/(?:\G|\s)-arch\s+\S+/, '')
  end
  RbConfig::expand("$(CXXPP) #$INCFLAGS #$CPPFLAGS #$CFLAGS #{opt} #{CONFTEST_CC} #{outfile}",
                   conf)
end

def try_cxxpp(src, opt="", *opts, &b)
  try_do_cxx(src, cxxpp_command(CPPOUTFILE, opt), *opts, &b) and
    File.file?("conftest.i")
ensure
  MakeMakefile.rm_f "conftest*"
end

def trans_opt opt
  [[:to_str], [:join, " "], [:to_s]].each do |meth, *args|
    if opt.respond_to?(meth)
      return opt.send(meth, *args)
    end
  end
end

def have_header_cxx(header, preheaders = nil, opt = "", &b)
  opt = "#{trans_opt opt} #{trans_opt $defs}"
  checking_for header do
    if try_cxxpp(cpp_include(preheaders)+cpp_include(header), opt, &b)
      $defs.push(format("-DHAVE_%s", header.tr_cpp))
      true
    else
      false
    end
  end
end

def try_library(libs, opt = "", &b)
  opt = "#{trans_opt opt} #{libs}"
  try_link(MAIN_DOES_NOTHING, opt, &b)
end

def have_library_empty(lib, opt = "", &b)
  lib = with_config(lib+'lib', lib)
  checking_for LIBARG%lib do
    if COMMON_LIBS.include?(lib)
      true
    else
      libs = append_library($libs, lib)
      if try_library(libs, opt, &b)
        $libs = libs
        true
      else
        false
      end
    end
  end
end
