starter template for odin

this is my starter template for odin projects, setup for use with raylib.

caveats (things you should know if you want to use this)
- i use linux (arch btw)
- i use [fish shell](https://fishshell.com/) so all the scripts and helper functions are fish based
- i use [gpu-screen-recorder](https://git.dec05eba.com/gpu-screen-recorder/about/) for capturing my screen 
- i use [direnv](https://direnv.net/) to setup my path

supported platforms:
- desktop
- _planned, not implemented_ mobile (android)
- _planned, not implemented_ web

## features

- script to screen record my main screen, 1fps (scripts/record.fish)
- build script that manages everything for me (scripts/build.fish), including auto-reload/building
- dev build that will automatically rebuild the game library + assets (`build.fish -d`)

## explainations

### files

- `commit-notes` is a scratch pad that i write things that i did / worked on that is automatically pulled onto my commit via a git-hook
- `post.fish` is a script used by my template script, executes these commands on a new project
- `scripts/builds.fish` contains all the varibles that define the various builds used in `build.fish`, that way you don't need to get lost in the build script but can just edit the params

### structure

there are three main packages: `src (package game)`, `runner (package main)`, `shared (package shared)`. the idea is that all the game logic is platform
agnostic (in the `src`) and all the platform specific things will be in `runner`.

- `src/` is the main game folder, all code should be in here
- `runner/` contains all the platform runner wrappers
    - `runner/release` is the main desktop release
    - `runner/dev` is the library based development build
- `shared/` has small things that i want to have access to in `src`, probably will be pulled out at points into libraries
