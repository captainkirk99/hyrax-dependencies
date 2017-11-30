#
# Handwritten Makefile for the hyrax dependencies. Each dependency must be
# configured, compiled and installed. Some support testing. Some do
# not support parallel builds, with 'install' being particularly
# problematic. 
#
# This Makefile assumes that the environment variable 'prefix' has
# been set and that the directory $prefix/deps is the destination for
# these packages.
#
# Note that you can pass in extra flags for the configure scripts 
# using CONFIGURE_FLAGS=...opts on the command line.

.PHONY: $(deps)
deps = cmake bison jpeg openjpeg gdal2 gridfields hdf4 hdfeos hdf5 netcdf4 fits icu

# The 'all-static-deps' are the deps we need when all of the handlers are
# to be statically linked to the dependencies contained in this project - 
# and when we are not going to use _any_ RPMs. This makes for a bigger bes
# rpm distribution, but also one that is easier to install because it does
# not require any non-stock yum repo.
.PHONY: $(all_static_deps)
all_static_deps = cmake bison jpeg openjpeg gdal2 gridfields hdf4 hdfeos hdf5 netcdf4 fits

# Build the dependencies for the Travis CI system. Travis uses Ubuntu 12
# as of 9/4/15 and while that distribution has many of the deps, it also
# lacks some key ones. It's easier to reuse this dependencies project than
# roll a new one. jhrg 9/4/15
.PHONY: $(travis_deps)
travis_deps = bison jpeg openjpeg gdal2 gridfields hdf4 hdfeos hdf5 netcdf4 fits

deps_clean = $(deps:%=%-clean)
deps_really_clean = $(deps:%=%-really-clean)

all: prefix-set
	for d in $(deps); do $(MAKE) $(MFLAGS) $$d; done

.PHONY: prefix-set
prefix-set:
	@if test -z "$$prefix"; then \
	echo "The env variable 'prefix' must be set. See README"; exit 1; fi

# Build everything but ICU, as static. Whwen the BES is built and
# linked against these, the resulting modules will not need their
# dependencies installed since they will be statically linked to them.
#
# Another difference between this and 'all' is that icu is not built.
# I want to avoid statically linking with that. Also, this does
# not yet work - netcdf4 and hdf5 need to have their builds 
# tweaked still. jhrg 4/7/15
# Done. This now works. Don't forget CONFIGURE_FLAGS. jhrg 5/6/15
# CONFIGURE_FLAGS now set by this target - no need to remember to do
# it. jhrg 11/29/17.
for-static-rpm: prefix-set
	for d in $(all_static_deps); do CONFIGURE_FLAGS=--disable-shared $(MAKE) $(MFLAGS) $$d; done

for-travis: prefix-set
	for d in $(travis_deps); do $(MAKE) $(MFLAGS) $$d; done

clean: $(deps_clean)

really-clean: $(deps_really_clean)

uninstall: prefix-set
	-rm -rf $(prefix)/deps/*

dist: really-clean
	(cd ../ && tar --create --file hyrax-dependencies-1.16.tar \
	 --exclude='.*' --exclude='*~'  --exclude=extra_downloads \
	 --exclude=scripts --exclude=OSX_Resources hyrax-dependencies)

# The names of the source code distribution files and and the dirs
# they unpack to.

cmake=cmake-2.8.12.2
cmake_dist=cmake-2.8.12.2.tar.gz

bison=bison-3.0.4
bison_dist=$(bison).tar.gz

jpeg=jpeg-6b
jpeg_dist=jpegsrc.v6b.tar.gz

# Old version: openjpeg=openjpeg-2.0.0
openjpeg=openjpeg-2.1.1
openjpeg_dist=$(openjpeg).tar.gz

# The old version... jhrg 4/5/16
# if we drop back to a 1.x version of gdal, then we should go for
# 1.11.4 which is available on CentOS 7.1. jhrg 8/24/16
gdal=gdal-1.10.0
gdal_dist=$(gdal).tar.gz

# The new version. jhrg 8/24/16
gdal2=gdal-2.1.1
gdal2_dist=$(gdal2).tar.xz

gridfields=gridfields-1.0.5
gridfields_dist=$(gridfields).tar.gz

hdf4=hdf-4.2.10
hdf4_dist=$(hdf4).tar.gz

hdfeos=hdfeos
hdfeos_dist=HDF-EOS2.19v1.00.tar.Z

# The old version... jhrg 4/5/16
# hdf5=hdf5-1.8.6
# hdf5_dist=$(hdf5).tar.gz

hdf5=hdf5-1.8.16
hdf5_dist=$(hdf5).tar.bz2

# hdf5=hdf5-1.10.0
# hdf5_dist=$(hdf5).tar.bz2
# # Use this until we fix the handler...
# hdf5_configure_flags=--with-default-api-version=v18

netcdf4=netcdf-c-4.4.1.1
netcdf4_dist=$(netcdf4).tar.gz

fits=cfitsio
fits_dist=$(fits)3270.tar.gz

icu=icu-3.6
icu_dist=icu4c-3_6-src.tgz

# NB The environment variable $prefix is assumed to be set.
src = src

# Specific source packages below here

# JPEG
jpeg_src=$(src)/$(jpeg)
jpeg_prefix=$(prefix)/deps

# Why use a 'stamp' file here instead of the directory itself? The
# directory's modification time is updated by the comple target, which
# means that the configure and compilation will be repeated until the
# compilation makes no change in the directory. The -stamp file will
# not be modified by the compile target
$(jpeg_src)-stamp:
	tar -xzf downloads/$(jpeg_dist) -C $(src)
	echo timestamp > $(jpeg_src)-stamp

jpeg-configure-stamp:  $(jpeg_src)-stamp
	(cd $(jpeg_src) && ./configure $(CONFIGURE_FLAGS) --prefix=$(jpeg_prefix) CFLAGS="-O2 -fPIC")
	echo timestamp > jpeg-configure-stamp

jpeg-compile-stamp: jpeg-configure-stamp
	(cd $(jpeg_src) && $(MAKE) $(MFLAGS))
	echo timestamp > jpeg-compile-stamp

jpeg-install-stamp: jpeg-compile-stamp
	mkdir -p $(jpeg_prefix)/bin
	mkdir -p $(jpeg_prefix)/man/man1
	mkdir -p $(jpeg_prefix)/lib
	mkdir -p $(jpeg_prefix)/include
	(cd $(jpeg_src) && $(MAKE) $(MFLAGS) -j1 install \
	&& cp libjpeg.a $(jpeg_prefix)/lib \
	&&  cp *.h $(jpeg_prefix)/include)
	echo timestamp > jpeg-install-stamp

jpeg-clean:
	-rm jpeg-*-stamp
	-(cd  $(jpeg_src) && $(MAKE) $(MFLAGS) clean)


jpeg-really-clean: jpeg-clean
	-rm $(src)/jpeg-*-stamp
	-rm -rf $(jpeg_src)

#	-rm -rf $(jpeg_prefix)

.PHONY: jpeg
jpeg: jpeg-install-stamp

# CMake

cmake_src=$(src)/$(cmake)
cmake_prefix=$(prefix)/deps

$(cmake_src)-stamp:
	tar -xzf downloads/$(cmake_dist) -C $(src)
	echo timestamp > $(cmake_src)-stamp

cmake-configure-stamp:  $(cmake_src)-stamp
	(cd $(cmake_src) && ./configure --prefix=$(cmake_prefix))
	echo timestamp > cmake-configure-stamp

cmake-compile-stamp: cmake-configure-stamp
	(cd $(cmake_src) && $(MAKE) $(MFLAGS))
	echo timestamp > cmake-compile-stamp

cmake-install-stamp: cmake-compile-stamp
	(cd $(cmake_src) && $(MAKE) $(MFLAGS) -j1 install)
	echo timestamp > cmake-install-stamp

cmake-clean:
	-rm cmake-*-stamp
	-(cd  $(cmake_src) && $(MAKE) $(MFLAGS) clean)

cmake-really-clean: cmake-clean
	-rm $(src)/cmake-*-stamp	
	-rm -rf $(cmake_src)

#	-rm -rf $(cmake_prefix)

.PHONY: cmake
cmake: cmake-install-stamp

# Bison 3 (Needed by libdap)
bison_src=$(src)/$(bison)
bison_prefix=$(prefix)/deps

$(bison_src)-stamp:
	tar -xf downloads/$(bison_dist) -C $(src)
	echo timestamp > $(bison_src)-stamp

bison-configure-stamp:  $(bison_src)-stamp
	(cd $(bison_src) && ./configure --prefix=$(bison_prefix))
	echo timestamp > bison-configure-stamp

bison-compile-stamp: bison-configure-stamp
	(cd $(bison_src) && $(MAKE) $(MFLAGS))
	echo timestamp > bison-compile-stamp

bison-install-stamp: bison-compile-stamp
	(cd $(bison_src) && $(MAKE) $(MFLAGS) install)
	echo timestamp > bison-install-stamp

bison-clean:
	-rm bison-*-stamp
	-(cd  $(bison_src) && $(MAKE) $(MFLAGS) clean)

bison-really-clean: bison-clean
	-rm $(src)/bison-*-stamp	
	-rm -rf $(bison_src)

.PHONY: bison
bison: bison-install-stamp

# OpenJPEG
openjpeg_src=$(src)/$(openjpeg)
openjpeg_prefix=$(prefix)/deps

$(openjpeg_src)-stamp:
	tar -xzf downloads/$(openjpeg_dist) -C $(src)
	echo timestamp > $(openjpeg_src)-stamp

openjpeg-configure-stamp:  $(openjpeg_src)-stamp
	(cd $(openjpeg_src) && cmake -DCMAKE_INSTALL_PREFIX:PATH=$(prefix)/deps -DCMAKE_C_FLAGS="-fPIC -O2" -DBUILD_SHARED_LIBS:bool=off)
	echo timestamp > openjpeg-configure-stamp

openjpeg-compile-stamp: openjpeg-configure-stamp
	(cd $(openjpeg_src) && $(MAKE) $(MFLAGS))
	echo timestamp > openjpeg-compile-stamp

openjpeg-install-stamp: openjpeg-compile-stamp
	(cd $(openjpeg_src) && $(MAKE) $(MFLAGS) -j1 install)
	echo timestamp > openjpeg-install-stamp

openjpeg-clean:
	-rm openjpeg-*-stamp
	-(cd  $(openjpeg_src) && $(MAKE) $(MFLAGS) clean)

openjpeg-really-clean: openjpeg-clean
	-rm $(src)/openjpeg-*-stamp	
	-rm -rf $(openjpeg_src)

#	-rm -rf $(openjpeg_prefix)

.PHONY: openjpeg
openjpeg: openjpeg-install-stamp

# GDAL 
gdal_src=$(src)/$(gdal)
gdal_prefix=$(prefix)/deps

$(gdal_src)-stamp:
	tar -xzf downloads/$(gdal_dist) -C $(src)
	echo timestamp > $(gdal_src)-stamp

gdal-configure-stamp:  $(gdal_src)-stamp
	(cd $(gdal_src) && ./configure $(CONFIGURE_FLAGS) --with-pic	\
	--prefix=$(gdal_prefix) --with-openjpeg=$(openjpeg_prefix))
	echo timestamp > gdal-configure-stamp

gdal-compile-stamp: gdal-configure-stamp
	(cd $(gdal_src) && $(MAKE) $(MFLAGS))
	echo timestamp > gdal-compile-stamp

# Force -j1 for install
gdal-install-stamp: gdal-compile-stamp
	(cd $(gdal_src) && $(MAKE) $(MFLAGS) -j1 install)
	echo timestamp > gdal-install-stamp

gdal-clean:
	-rm gdal-*-stamp
	-(cd  $(gdal_src) && $(MAKE) $(MFLAGS) clean)

gdal-really-clean: gdal-clean
	-rm $(gdal_src)-stamp
	-rm -rf $(gdal_src)

#	-rm -rf $(gdal_prefix)

.PHONY: gdal
gdal: openjpeg gdal-install-stamp

# GDAL2
gdal2_src=$(src)/$(gdal2)
gdal2_prefix=$(prefix)/deps

$(gdal2_src)-stamp:
	tar -xJf downloads/$(gdal2_dist) -C $(src)
	echo timestamp > $(gdal2_src)-stamp

gdal2-configure-stamp:  $(gdal2_src)-stamp
	(cd $(gdal2_src) && ./configure $(CONFIGURE_FLAGS) --with-pic	\
	--prefix=$(gdal2_prefix) --with-openjpeg=$(openjpeg_prefix))
	echo timestamp > gdal2-configure-stamp

gdal2-compile-stamp: gdal2-configure-stamp
	(cd $(gdal2_src) && $(MAKE) $(MFLAGS))
	echo timestamp > gdal2-compile-stamp

# Force -j1 for install
gdal2-install-stamp: gdal2-compile-stamp
	(cd $(gdal2_src) && $(MAKE) $(MFLAGS) -j1 install)
	echo timestamp > gdal2-install-stamp

gdal2-clean:
	-rm gdal2-*-stamp
	-(cd  $(gdal2_src) && $(MAKE) $(MFLAGS) clean)

gdal2-really-clean: gdal2-clean
	-rm $(gdal2_src)-stamp
	-rm -rf $(gdal2_src)

.PHONY: gdal2
gdal2: openjpeg gdal2-install-stamp

# removed jhrg 12/28/12 openjpeg 

# Gridfields 
gridfields_src=$(src)/$(gridfields)
gridfields_prefix=$(prefix)/deps

$(gridfields_src)-stamp:
	tar -xzf downloads/$(gridfields_dist) -C $(src)
	echo timestamp > $(gridfields_src)-stamp

gridfields-configure-stamp:  $(gridfields_src)-stamp
	(cd $(gridfields_src) && ./configure $(CONFIGURE_FLAGS) --disable-netcdf \
	--prefix=$(gridfields_prefix) CXXFLAGS="-fPIC -O2")
	echo timestamp > gridfields-configure-stamp

gridfields-compile-stamp: gridfields-configure-stamp
	(cd $(gridfields_src) && $(MAKE) $(MFLAGS))
	echo timestamp > gridfields-compile-stamp

# Force -j1 for install
gridfields-install-stamp: gridfields-compile-stamp
	(cd $(gridfields_src) && $(MAKE) $(MFLAGS) -j1 install)
	echo timestamp > gridfields-install-stamp

gridfields-clean:
	-rm gridfields-*-stamp
	-(cd  $(gridfields_src) && $(MAKE) $(MFLAGS) clean)

gridfields-really-clean: gridfields-clean
	-rm $(gridfields_src)-stamp
	-rm -rf $(gridfields_src)

#	-rm -rf $(gridfields_prefix)

.PHONY: gridfields
gridfields: gridfields-install-stamp

# HDF4 
hdf4_src=$(src)/$(hdf4)
hdf4_prefix=$(prefix)/deps

$(hdf4_src)-stamp:
	tar -xzf downloads/$(hdf4_dist) -C $(src)
	echo timestamp > $(hdf4_src)-stamp

hdf4-configure-stamp:  $(hdf4_src)-stamp
	(cd $(hdf4_src) && ./configure $(CONFIGURE_FLAGS) CFLAGS=-w \
	--disable-fortran --enable-production --disable-netcdf		\
	--with-pic --with-jpeg=$(jpeg_prefix) --prefix=$(hdf4_prefix))
	echo timestamp > hdf4-configure-stamp

hdf4-compile-stamp: hdf4-configure-stamp
	(cd $(hdf4_src) && $(MAKE) $(MFLAGS))
	echo timestamp > hdf4-compile-stamp

# Force -j1 for install
# The copies of ncdump and ncgen installed by hdf4 are evil ;-)
# remove them to avoid in advertanly using them in tests (e.g.,
# fonc's tests. jhrg 4/10/15
hdf4-install-stamp: hdf4-compile-stamp
	(cd $(hdf4_src) && $(MAKE) $(MFLAGS) -j1 install)
	-rm $(hdf4_prefix)/bin/ncdump
	-rm $(hdf4_prefix)/bin/ncgen
	echo timestamp > hdf4-install-stamp

hdf4-clean:
	-rm hdf4-*-stamp
	-(cd  $(hdf4_src) && $(MAKE) $(MFLAGS) clean)

hdf4-really-clean: hdf4-clean
	-rm $(hdf4_src)-stamp
	-rm -rf $(hdf4_src)

.PHONY: hdf4
hdf4: jpeg 
	$(MAKE) $(MFLAGS) hdf4-install-stamp

# HDF EOS2 
hdfeos_src=$(src)/$(hdfeos)
hdfeos_prefix=$(prefix)/deps

$(hdfeos_src)-stamp:
	tar -xzf downloads/$(hdfeos_dist) -C $(src)
	echo timestamp > $(hdfeos_src)-stamp

hdfeos-configure-stamp:  $(hdfeos_src)-stamp
	(cd $(hdfeos_src) && ./configure CC=$(hdf4_prefix)/bin/h4cc	\
	$(CONFIGURE_FLAGS) --disable-fortran --enable-production	\
	--with-pic --enable-install-include --with-hdf4=$(hdf4_prefix)	\
	--prefix=$(hdfeos_prefix))
	echo timestamp > hdfeos-configure-stamp

hdfeos-compile-stamp: hdfeos-configure-stamp
	(cd $(hdfeos_src) && $(MAKE) $(MFLAGS))
	echo timestamp > hdfeos-compile-stamp

# Force -j1 for install
hdfeos-install-stamp: hdfeos-compile-stamp
	(cd $(hdfeos_src) && $(MAKE) $(MFLAGS) -j1 install)
	echo timestamp > hdfeos-install-stamp

hdfeos-clean:
	-rm hdfeos-*-stamp
	-(cd  $(hdfeos_src) && $(MAKE) $(MFLAGS) clean)

hdfeos-really-clean: hdfeos-clean
	-rm $(hdfeos_src)-stamp
	-rm -rf $(hdfeos_src)

#	-rm -rf $(hdfeos_prefix)

.PHONY: hdfeos
hdfeos: hdf4
	$(MAKE) $(MFLAGS) hdfeos-install-stamp

# HDF5 
hdf5_src=$(src)/$(hdf5)
hdf5_prefix=$(prefix)/deps

$(hdf5_src)-stamp:
	tar -xjf downloads/$(hdf5_dist) -C $(src)
	echo timestamp > $(hdf5_src)-stamp

hdf5-configure-stamp:  $(hdf5_src)-stamp
	(cd $(hdf5_src) && ./configure $(CONFIGURE_FLAGS) \
	 $(hdf5_configure_flags) --prefix=$(hdf5_prefix) \
	 CFLAGS="-fPIC -O2 -w")
	echo timestamp > hdf5-configure-stamp

hdf5-compile-stamp: hdf5-configure-stamp
	(cd $(hdf5_src) && $(MAKE) $(MFLAGS))
	echo timestamp > hdf5-compile-stamp

# Force -j1 for install
hdf5-install-stamp: hdf5-compile-stamp
	(cd $(hdf5_src) && $(MAKE) $(MFLAGS) -j1 install)
	echo timestamp > hdf5-install-stamp

hdf5-clean:
	-rm hdf5-*-stamp
	-(cd  $(hdf5_src) && $(MAKE) $(MFLAGS) clean)

hdf5-really-clean: hdf5-clean
	-rm $(hdf5_src)-stamp
	-rm -rf $(hdf5_src)

#	-rm -rf $(hdf5_prefix)

.PHONY: hdf5
hdf5: hdf5-install-stamp

# netcdf4 
netcdf4_src=$(src)/$(netcdf4)
netcdf4_prefix=$(prefix)/deps

$(netcdf4_src)-stamp:
	tar -xzf downloads/$(netcdf4_dist) -C $(src)
	echo timestamp > $(netcdf4_src)-stamp

netcdf4-configure-stamp:  $(netcdf4_src)-stamp
	(cd $(netcdf4_src) && ./configure $(CONFIGURE_FLAGS)		\
	--prefix=$(netcdf4_prefix) CPPFLAGS=-I$(hdf5_prefix)/include	\
	CFLAGS="-fPIC -O2" LDFLAGS=-L$(hdf5_prefix)/lib)
	echo timestamp > netcdf4-configure-stamp

netcdf4-compile-stamp: netcdf4-configure-stamp
	(cd $(netcdf4_src) && $(MAKE) $(MFLAGS))
	echo timestamp > netcdf4-compile-stamp

# Force -j1 for install
netcdf4-install-stamp: netcdf4-compile-stamp
	(cd $(netcdf4_src) && $(MAKE) $(MFLAGS) -j1 install)
	echo timestamp > netcdf4-install-stamp

netcdf4-clean:
	-rm netcdf4-*-stamp
	-(cd  $(netcdf4_src) && $(MAKE) $(MFLAGS) clean)

netcdf4-really-clean: netcdf4-clean
	-rm $(netcdf4_src)-stamp
	-rm -rf $(netcdf4_src)

#	-rm -rf $(netcdf4_prefix)

.PHONY: netcdf4
netcdf4: hdf5 netcdf4-install-stamp

# cfitsio 
fits_src=$(src)/$(fits)
fits_prefix=$(prefix)/deps

$(fits_src)-stamp:
	tar -xzf downloads/$(fits_dist) -C $(src)
	echo timestamp > $(fits_src)-stamp

fits-configure-stamp:  $(fits_src)-stamp
	(cd $(fits_src) && ./configure $(CONFIGURE_FLAGS) --prefix=$(fits_prefix))
	echo timestamp > fits-configure-stamp

fits-compile-stamp: fits-configure-stamp
	(cd $(fits_src) && $(MAKE) $(MFLAGS))
	echo timestamp > fits-compile-stamp

# Force -j1 for install
fits-install-stamp: fits-compile-stamp
	(cd $(fits_src) && $(MAKE) $(MFLAGS) -j1 install)
	echo timestamp > fits-install-stamp

fits-clean:
	-rm fits-*-stamp
	-(cd  $(fits_src) && $(MAKE) $(MFLAGS) clean)

fits-really-clean: fits-clean
	-rm $(fits_src)-stamp
	-rm -rf $(fits_src)

#	-rm -rf $(fits_prefix)

.PHONY: fits
fits: fits-install-stamp

# ICU 
icu_src=$(src)/$(icu)/source
icu_prefix=$(prefix)/deps

$(src)/$(icu)-stamp:
	tar -xzf downloads/$(icu_dist) -C $(src)
	echo timestamp > $(src)/$(icu)-stamp

icu-configure-stamp:  $(src)/$(icu)-stamp
	(cd $(icu_src) && \
	if uname -a | grep Darwin; then OS="osx"; \
	elif uname -a | grep Linux; then OS="linux"; \
	else OS="unknown"; fi && \
	if test "$OS" = "osx"; then ./runConfigureICU MacOSX --prefix=$(icu_prefix) --disable-layout --disable-samples; \
	elif test "$OS" = "linux"; then ./runConfigureICU Linux $(CONFIGURE_FLAGS) --prefix=$(icu_prefix) --disable-layout --disable-samples; \
	else ./configure $(CONFIGURE_FLAGS) --prefix=$(icu_prefix) --disable-layout --disable-samples; fi)
	echo timestamp > icu-configure-stamp

icu-compile-stamp: icu-configure-stamp
	(cd $(icu_src) && $(MAKE) $(MFLAGS))
	echo timestamp > icu-compile-stamp

# Force -j1 for install
icu-install-stamp: icu-compile-stamp
	(cd $(icu_src) && $(MAKE) $(MFLAGS) -j1 install)
	echo timestamp > icu-install-stamp

icu-clean:
	-rm icu-*-stamp
	-(cd  $(icu_src) && $(MAKE) $(MFLAGS) clean)

icu-really-clean: icu-clean
	-rm $(src)/$(icu)-stamp
	-rm -rf $(src)/$(icu)

#	-rm -rf $(icu_prefix)

.PHONY: icu
icu: icu-install-stamp


