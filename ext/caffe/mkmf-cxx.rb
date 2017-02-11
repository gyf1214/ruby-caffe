require 'mkmf-rice'

RbConfig::CONFIG['CXXPP'] = RbConfig::CONFIG['CXX'] + ' -E'

def cxx_command(opt="")
  conf = RbConfig::CONFIG.merge('hdrdir' => $hdrdir.quote, 'srcdir' => $srcdir.quote,
                                'arch_hdrdir' => $arch_hdrdir.quote,
                                'top_srcdir' => $top_srcdir.quote)
  RbConfig::expand("$(CXX) #$INCFLAGS #$CPPFLAGS #$CFLAGS #$ARCH_FLAG #{opt} -c #{CONFTEST_C}",
                   conf)
end

def cxxpp_command(outfile, opt="")
  conf = RbConfig::CONFIG.merge('hdrdir' => $hdrdir.quote, 'srcdir' => $srcdir.quote,
                                'arch_hdrdir' => $arch_hdrdir.quote,
                                'top_srcdir' => $top_srcdir.quote)
  if $universal and (arch_flag = conf['ARCH_FLAG']) and !arch_flag.empty?
    conf['ARCH_FLAG'] = arch_flag.gsub(/(?:\G|\s)-arch\s+\S+/, '')
  end
  RbConfig::expand("$(CXXPP) #$INCFLAGS #$CPPFLAGS #$CFLAGS #{opt} #{CONFTEST_C} #{outfile}",
                   conf)
end

def try_cxxpp(src, opt="", *opts, &b)
  try_do(src, cxxpp_command(CPPOUTFILE, opt), *opts, &b) and
    File.file?("conftest.i")
ensure
  MakeMakefile.rm_f "conftest*"
end

def have_header_cxx(header, preheaders = nil, opt = "", &b)
  checking_for header do
    if try_cxxpp(cpp_include(preheaders)+cpp_include(header), opt, &b)
      $defs.push(format("-DHAVE_%s", header.tr_cpp))
      true
    else
      false
    end
  end
end

def have_library_empty(lib, headers = nil, opt = "", &b)
  lib = with_config(lib+'lib', lib)
  checking_for LIBARG%lib do
    if COMMON_LIBS.include?(lib)
      true
    else
      libs = append_library($libs, lib)
      if try_link(MAIN_DOES_NOTHING)
        $libs = libs
        true
      else
        false
      end
    end
  end
end
