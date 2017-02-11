# Ruby Caffe #

A ruby wrapper for the deep learning framework

## Linking caffe ##

There is a linking problem since `caffe` doesn't provide an official installation plan, but everything in its build path / distribute path instead of somewhere like `/usr` or `/usr/local`

Now `extconf.rb` only checks for `cblas.h` (or `mkl.h` if you are using Intel MKL), `-lcaffe` and `caffe/caffe.hpp`, other dependent headers of `caffe` (such as `leveldb`) should be installed in default search path (`/usr/include` or `/usr/local/include`), or you can use `pkg-config` to add additional options in `LDFLAGS` & `CFLAGS` directly (see below)

There are three options to specify the path of the libraries & headers:

### `pkg-config` ###

Ruby `mkmf` provide convenient use of `pkg-config`, which is included in `extconf.rb`. It will search for `caffe.pc` in `pkg-config` search paths (typically `/usr/lib/pkgconfig` and `/usr/local/lib/pkgconfig`)

However `caffe` doesn't provide a `.pc` file, but you can write one yourself, here is an example:

```
prefix=/usr/local/caffe
libdir=${prefix}/lib
includedir=${prefix}/include
blasinclude=/usr/local/openblas/include
otherflags=-DCPU_ONLY

Name: caffe
Description: caffe C++ lib
Version: 1.0.0-rc4
Libs: -L${libdir} -lcaffe
CFlags: ${otherflags} -I${includedir} -I${blasinclude}
```

Note that `pkg-config` directly adds `LDFLAGS` & `CFLAGS`, so you can add flags other than what `extconf.rb` specifies

### Build Flags ###

Build flags can be passed to `extconf.rb` to specify the `caffe` path and other configuration:

- `--with-caffe-dir=<path>`: specify the caffe path, in which `<path>/include` contains the headers and `<path>/lib` contains the library
- `--with-caffe-include` & `--with-caffe-lib`: specify the caffe header and lib path separately
- `--with-blas-include=<path>`: specify the path that contains the blas headers
- `--with-blas-dir=<path>`: the same as `--with-blas-include=<path>/include`
- `--enable-gpu` & `--disable-gpu`: specify GPU mode of caffe, enabled by default
- `--enable-mkl` & `--disable-mkl`: specify if Intel MKL is used as blas library, if neither flags are set `exconf.rb` will search for `cblas.h` first and then `mkl.h` if fails

If `rake` is used to build the extension, use:

```shell
$ rake compile -- <build flags>
```

If installing from `gem`, use:

```shell
$ gem install caffe -- <build flags>
```

If installing from `bundler`, use:

```shell
$ bundle config build.caffe <build flags>

$ bundle install
```

### Put everything in search path ###

If you put all the headers and libs required in default search path (like `/usr/local` & `/usr`), and uses the default setting (with GPU mode) then everything should be ok

## Build ##

Now the project is not a gem project, so it can be built by `rake`

First, use `bundler` to install all the dependencies:

```shell
$ bundle install
```

Then, use `rake` to build:

```shell
$ rake compile -- <build flags>
```

Test with:

```shell
$ rake test
```

or after compilation:

```shell
$ rake spec
```

require the lib with:

```ruby
require './lib/caffe'
```

## Author ##

Tiny Tiny

## License ##

MIT
