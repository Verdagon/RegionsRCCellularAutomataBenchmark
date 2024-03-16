
echo Building Vale programs with various backends...

# For these, we don't tell it to print memory overhead, we'll just be measuring the performance.
# This variant (dir build_unsafe_no_bounds) is equivalent to C: normal malloc/free, and no bounds checking.
$1 build ca=src --clang_override $2 --libc_override $3 --no_std true --opt_level O3 --asm true --llvm_ir true --output_dir build_unsafe_no_bounds --region_override unsafe-fast --include_bounds_checks false || exit 1
# All the variants below here use bounds checking.
# This variant (dir build_unsafe_with_bounds) is like C (normal malloc/free) with bounds checking added. Similar to Zig, maybe?
$1 build ca=src --clang_override $2 --libc_override $3 --no_std true --opt_level O3 --asm true --llvm_ir true --output_dir build_unsafe_with_bounds --region_override unsafe-fast || exit 1
# This variant (dir build_naive_rc) uses nonatomic reference counting for all objects.
$1 build ca=src --clang_override $2 --libc_override $3 --no_std true --opt_level O3 --asm true --llvm_ir true --output_dir build_naive_rc --region_override naive-rc --elide_checks_for_regions false || exit 1
# This variant (dir build_naive_atomic_rc) uses atomic reference counting for all objects.
$1 build ca=src --clang_override $2 --libc_override $3 --no_std true --opt_level O3 --asm true --llvm_ir true --output_dir build_naive_atomic_rc --region_override naive-rc --elide_checks_for_regions false --use_atomic_rc true || exit 1
# This variant (dir build_rc_regions) uses nonatomic reference counting for all objects, plus regions to know when we can skip an RC increment or decrement.
$1 build ca=src --clang_override $2 --libc_override $3 --no_std true --opt_level O3 --asm true --llvm_ir true --output_dir build_rc_regions --region_override naive-rc || exit 1

echo Test-running unsafe variant...
./build_unsafe_no_bounds/main || exit 1
echo Test-running unsafe + bounds checking variant...
./build_unsafe_with_bounds/main || exit 1
echo Test-running nonatomic RC variant...
./build_naive_rc/main || exit 1
echo Test-running atomic RC variant...
./build_naive_atomic_rc/main || exit 1
echo Test-running nonatomic RC + regions variant...
./build_rc_regions/main || exit 1

echo All variants built and ready for benchmarking!
