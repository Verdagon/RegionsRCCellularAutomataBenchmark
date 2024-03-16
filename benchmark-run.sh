# I recommend running this script multiple times, and paying more attention to the last run.
# Hyperfine's warmup is fine, but it doesn't interleave the variants like I would hope.
#
# If on linux, I also recommend running this inside a cset shield to reserve a core for this benchmark
# so other programs don't interfere.

hyperfine --warmup 30 --runs 500 "./build_unsafe_no_bounds/main" "./build_unsafe_with_bounds/main" "./build_rc_regions/main" "./build_naive_rc/main" "./build_naive_atomic_rc/main"
