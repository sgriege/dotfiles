# sgriege's personal dotfiles

## What is this?

For many years (more than a decade?), I had a simple Perl script to distribute my basic
configuration files and some tools from my main machine to my other computers. The main machine's
files served as the reference, and the Perl script would pack the files into a shell script (kind of
like a shar archive) that I'd transfer to another machine and that would unpack the files and
perform some other basic stuff, like removing old files and directories. If you're interested in
this script, you can find it in the directory `legacy`, but I no longer maintain it for my own
dotfiles.

As I find the process of packing, transferring and unpacking too cumbersome and limiting, I manage
my dotfiles in this git repository now. It includes a bash script to set up symlinks in my home
directory to the files in the repository and to perform some other maintenance, like removing old
files and directories and compiling some basic tools written in C. I decided not to use tools like
GNU Stow, chezmoi, Dotbot or even the full-blown Nix Home Manager, but to continue using a
self-written script instead. I also don't like the idea of having a (bare) git repository right in
my home directory, hence the symlinking.

## Disclaimer

The configuration files and tools in this repository are representing my personal preferences and
requirements. While they might be interesting or useful to others, please use or apply them only if
you understand what they do and if you consent to those settings and tools. Use at your own risk!

## How to use

The entire set of dotfiles can be applied using the included `update-dotfiles` script, which needs
to be run from the top-level directory of the repository. It performs some cleanup and places
configuration files and tools in the home directory, as symlinks to the repository (with the
exception of the compiled tools, whose executables are directly placed in a `bin` folder in the home
directory). On updates of the files in the repository, as they are symlinked, the changes will apply
automatically. Re-running `update-dotfiles` is only required to install newly added files, to
perform cleanups that have been added, or to recompile the tools written in C after modifications to
the source files.

Of course, feel free to use only specific files in this repository or passages thereof instead of
using the update script, which removes or replaces your own configuration.
