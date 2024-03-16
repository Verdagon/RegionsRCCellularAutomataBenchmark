# Regions + RC Experiment

This is a sample regions-enabled Vale program, plus a few scripts to compile it using Vale's super-secret reference-counting mode, to see how much [immutable region borrowing](https://verdagon.dev/blog/zero-cost-borrowing-regions-part-1-immutable-borrowing) can benefit reference counting approaches.

Normally, Vale uses [generational references](https://verdagon.dev/blog/generational-references) for its memory safety, and is designed to use regions to eliminate their overhead. The [prototype](https://verdagon.dev/blog/first-regions-prototype) showed us that with the right coding technique (linear style) we can even reduce generation checks down to zero.

A fascinating fact about regions: they don't just help generational references, they would help reference counting too! But we didn't know how much.

Vale will always use generational references, but I figured it would be easy to make a reference-counting backend and measure how much regions help, for those making reference-counted languages, considering whether to add regions or not.

So, I added a secret reference-counting mode, enabled with `--region_override naive-rc`. We can also use `--elide_checks_for_regions false` to turn off regions.

# The Program

This repository contains only one program; the below results only reflect how regions affect this one program. Results would be different for different programs, and also depend on how the coder decides to structure their program.

This program is a "cellular automata" level generation algorithm for a roguelike game. Example output of a smaller level (the actual program produces much larger ones for benchmarking):



# Results

For this program, `count-rc.sh` reports:

 * 358287712 RC increments/decrements without regions.
 * 96027012 RC increments/decrements with regions.

In other words, *regions eliminate 73% of RC increments/decrements.*

And `benchmark-run.sh` reports:

 * 148.0ms when using no memory safety.
 * 158.5ms when using no memory safety, but with bounds checking.
 * 171.4ms when using nonatomic reference counting with regions.
 * 216.5ms when using nonatomic reference counting (similar to Python's or Nim's approach)
 * 962.4ms when using atomic reference counting (similar to Swift's approach)

The relevant numbers are:

 * Compared to no memory safety (148.0ms), nonatomic reference counting (216.5ms) adds 68.5ms overhead.
 * Compared to no memory safety (148.0ms), nonatomic reference counting with regions (171.4ms) adds 23.4ms overhead.

In other words, regions bring reference counting overhead down from 68.5ms to 23.4ms, which is a *66% reduction in reference counting overhead*.

I also included atomic RC for fun. Nonatomic and regions removes 97% (!) of the overhead compared to atomic RC. I should also mention that regions also prevent the data races that atomicity is introduced to fix.

# Reproducing

 * Clone my personal Vale fork's [regions branch](https://github.com/Verdagon/Vale/tree/regions).
 * Build the compiler. This might be tricky depending on your machine, I recommend using Ubuntu.
 * Run `count-rc.sh`, for example on an M2 mac `./count-rc.sh /Volumes/V/Vale/release-mac/valec ~/clang+llvm-16.0.4-arm64-apple-darwin22.0/bin/clang /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr` The arguments are:
    * Path to the valec compiler, built in previous step.
    * Path to clang.
    * Path to the libc headers. Hopefully this flag will be optional soon.
 * Look for the `RC adjustments:` lines in the outputs.
 * Run `benchmark-build.sh`, for example on an M2 mac `./benchmark-build.sh /Volumes/V/Vale/release-mac/valec ~/clang+llvm-16.0.4-arm64-apple-darwin22.0/bin/clang /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr` The arguments are the same as count-rc.sh.
 * Run `./benchmark-run.sh`, or if you're on linux, run it inside a cset shield.

If you have trouble with these steps, **please do not open a GitHub issue on the Verdagon/Vale repo,** I often ignore those for weeks for my own mental health and sanity. [Emailing me](verdagon_epsa@verdagon.dev) or messaging me on Discord (Verdagon) is often more successful.
