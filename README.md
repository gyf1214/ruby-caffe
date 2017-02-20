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
- `--enable-mkl` & `--disable-mkl`: specify if Intel MKL is used as blas library, if neither flags are set `extconf.rb` will search for `cblas.h` first and then `mkl.h` if fails

If `rake` is used to build the extension, use:

```
$ rake compile -- <build flags>
```

If installing from `gem`, use:

```
$ gem install caffe -- <build flags>
```

If installing from `bundler`, use:

```
$ bundle config build.caffe <build flags>
$ bundle install
```

### Put everything in search path ###

If you put all the headers and libs required in default search path (like `/usr/local` & `/usr`), and use the default setting (with GPU mode) then everything should be ok

## Installation ##

```
$ gem install caffe -- <build flags>
```

Using bundler:

```
$ bundle config build.caffe <build flags>
$ bundle install
```

Require everything with:

```ruby
require 'caffe'
```

## Development ##

First clone this repository:

```
$ git clone git://github.com/gyf1214/ruby-caffe
```

Then build all prerequisites for gem & test (proto files & test net):

```
$ rake build:pre
```

When building proto files, the caffe path (which contains `proto/caffe.proto`) can be specified by `ENV['CAFFE']`, i.e.

```
$ CAFFE=/path/to/caffe rake build:pre
```

Or by default the path is `.`, so you can just copy / link your `caffe.proto` to `proto/`

Compile C++ extension with:

```
$ rake compile -- <build flags>
```

Build flags & other methods to link caffe are described above

Test the code with (which include the rubocop code style check):

```
$ rake test
```

Build the gem with:

```
$ rake build
```

Which will run all tests and build the gem in `pkg/caffe-<version>.gem`

Install the gem locally with:

```
$ rake install
```

### Other rake tasks ###

```
$ rake rubocop
```

Run the rubocop code style check, you can also run auto correct with `rake rubocop:auto_correct`

```
$ rake spec
```

Run rspec only, without checking the dependencies, note that `build:pre` & `compile` must be completed before

```
$ rake build:proto
$ rake build:test
```

The two tasks build the proto file and trained model for testing respectively. `ENV['CAFFE']` can be specified when building proto

```
$ rake clean
$ rake clobber
```

The first cleans the temporary files and the second cleans all generated files

```
$ rake release[remote]
```

Create a version tag, and push to both git remote & <rubygems.org>

## Author ##

Tiny Tiny

## License ##

MIT
