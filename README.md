# THIS IS NOT A GOOD SOLUTION, ITS A PERSONAL SOLUTION
Zero optimizations done to make it faster, every other solution is just that slow to start up

A large amount of strokes will use a considerable amount of cpu

It does not compile into a native wayland version as raylib-odin doesnt support it, though you can recompile the raylib odin vendor package to support wayland instead

# Dependencies
`wl-clipboard`

optional

`grim`

`slurp`

# Usage
Place it in your path and use the command

`grim -g "$(slurp)" - | sannity`

# Hotkeys

`ctrl-c` copy

`ctrl-s` save (closes on save)

`esc` exit

`ctrl-z` undo

`1` Change Color Red

`2` Change Color Green

`3` Change Color Blue

