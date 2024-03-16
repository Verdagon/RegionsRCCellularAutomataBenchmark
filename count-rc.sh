# Usage:
#   
# Example (for an M2 Mac)
#   ./count-rc.sh /Volumes/V/Vale/release-mac/valec ~/clang+llvm-16.0.4-arm64-apple-darwin22.0/bin/clang /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr

# `--print_mem_overhead true` instruments the final binary with global counters for how many RC operations there are, and prints them at the end of the run.
echo Building Vale program with RC backend...
# `--elide_checks_for_regions false` instructs the backend to ignore the regions information received from the frontend.
$1 build ca=src --clang_override $2 --libc_override $3 --no_std true --opt_level O3 --asm true --llvm_ir true --output_dir build_naive_rc --region_override naive-rc --elide_checks_for_regions false --print_mem_overhead true || exit 1
echo Building Vale program with RC+Regions backend...
$1 build ca=src --clang_override $2 --libc_override $3 --no_std true --opt_level O3 --asm true --llvm_ir true --output_dir build_rc_regions --region_override naive-rc --print_mem_overhead true || exit 1

echo
echo Running normal RC run...
./build_naive_rc/main || exit 1

echo
echo Running RC+regions run...
./build_rc_regions/main || exit 1

echo
echo Done!

# If you want to see the actual board, run one of these:
# ./build_naive_rc/main --display
# ./build_rc_regions/main --display
#
# Slightly different amounts are expected when displaying, because we incur
# some RC ops in the display function, which uses part of the stdlib that isn't
# region-optimized, specifically func print(str).
