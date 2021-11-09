---
title: "Maximising the insufferability of my setup"
---

Thanks to the time afforded to me by the pandemic and the long sabbatical, I have finally managed to produce an extremely insufferable and unusable computer setup. To encourage other into taking computer use to its logical end, making it as horrible as possible for everyone but the owner, here is a list of what I did.

# Install NixOS

Right from the start, this brings us a plethora of benefits:
 - a system specific language to configure everything, along with multiple CLI-only tools to interact with your computer.
 - the linker not being where a lot of binaries downloaded from the internet expect it to be. This one is great. Because NixOS doesn't have `/lib/` like other linux distros, executing a binary that expects it to be there produces a single mysterious error that will immediately throw everyone off the scent of getting anything useful done:

     $ ./foo
     bash: ./foo: No such file or directory
- the FHS does not exist on NixOS, so ever things  that do get past the above hurlde will most likely blow up later. That includes missing dynamic libraries or even assets like GTK themes.

# Use home-manager to manage everything user-related

Even when NixOS can do it, why not add another layer of indirection?

# Use a tiling WM

i3, awesome, sway, anything will do as long as menus are ripped out. It should be completely impossible to get an application menu or help window with the mouse.

# Change the keyboard bindings

Replace caps lock with control, make the language layout change with right control instead of alt-shift. There is a school of thought that using a completely different layout like Dvorak would be better here, but I firmly believe that the illusion of familiarity that is eventually shattered produces a much more intense frustration.

# Whenever anyone is near, use the terminal as much as possible

Or Emacs. It doesn't really have to be a terminal as long as it is something that looks like it doesn't have a GUI. This will add to the mystification onlookers feel around the system, making it even less likely they will want to touch it, never mind use it.

# Use a complex RSS setup

It is time to forego the earthly pleasures of "visiting websites". Use RSS for everything, gaming news, tracking releases on github, that one weird comedy/sex comic you read. Add an extra feed that is a local file. If someone asks, explain to them that whenever you find something you want to read later, you dump it into a text file. Then a small Rust daemon you wrote reads the text file, fetches some metadata about the article or video and produces an XML file which the RSS reader can use as a feed source, since did you know that URLs are not only HTTP URLs like you mostly see in the browser but can also point to local files?
