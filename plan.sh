pkg_origin=srb3
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_name=openjdk11
# NOTE: Retrieve download link and shasum from here: https://jdk.java.net/11/
pkg_version=11.0.4
pkg_minor_version=11
pkg_source=https://github.com/AdoptOpenJDK/openjdk11-upstream-binaries/releases/download/jdk-${pkg_version}%2B${pkg_minor_version}/OpenJDK11U-jdk_x64_linux_${pkg_version}_${pkg_minor_version}.tar.gz
pkg_shasum=3e937b259c77be2d9fe276afc266c974465c66f8fd77aabe9344267c182f4e17
pkg_filename=openjdk-${pkg_version}_linux-x64_bin.tar.gz
pkg_dirname="openjdk-${pkg_version}"
pkg_license=("GPL-2.0-only")
pkg_description=('OpenJDK is a free and open-source implementation of the Java Platform, Standard Edition.')
pkg_upstream_url=https://openjdk.java.net/
pkg_deps=(
  core/alsa-lib
  core/freetype
  core/gcc-libs
  core/glibc
  core/libxext
  core/libxi
  core/libxrender
  core/libxtst
  core/xlib
  core/zlib
)
pkg_build_deps=(core/patchelf core/rsync)
pkg_bin_dirs=(bin)
pkg_lib_dirs=(lib)
pkg_include_dirs=(include)

source_dir=${HAB_CACHE_SRC_PATH}/${pkg_dirname}

do_unpack() {
  mkdir ${source_dir}
  tar -xzf ${HAB_CACHE_SRC_PATH}/${pkg_filename} --no-same-owner -C ${source_dir} --strip-components=1
}

do_setup_environment() {
 set_runtime_env JAVA_HOME "$pkg_prefix"
}

do_build() {
  return 0
}

do_install() {
  pushd "${pkg_prefix}" || exit 1
  rsync -avz "${source_dir}/" .

  export LD_RUN_PATH="${LD_RUN_PATH}:${pkg_prefix}/lib/jli:${pkg_prefix}/lib/server:${pkg_prefix}/lib"

  build_line "Setting interpreter for all executables to '$(pkg_path_for glibc)/lib/ld-linux-x86-64.so.2'"
  build_line "Setting rpath for all libraries to '$LD_RUN_PATH'"

  find "$pkg_prefix"/bin -type f -executable \
    -exec sh -c 'file -i "$1" | grep -q "x-executable; charset=binary"' _ {} \; \
    -exec patchelf --interpreter "$(pkg_path_for glibc)/lib/ld-linux-x86-64.so.2" --set-rpath "${LD_RUN_PATH}" {} \;

  find "$pkg_prefix/lib" -type f -name "*.so" \
    -exec patchelf --set-rpath "${LD_RUN_PATH}" {} \;

  popd || exit 1
}

do_strip() {
  return 0
}
