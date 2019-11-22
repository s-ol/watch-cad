watch-cad
=========

this is a testbed/toy implementation of a new way to interact with graphical editors, such as CAD or vector software,
combining the speed and ease of use of direct manipulation (using mouse and drawing tablets) with the expressivity, accuracy and reusability of code.

With watch-cad, you edit a piece of code at the same time as you work on your document.
The code defines the tool you use in the document.
It is constantly error-checked, parsed and run.
The API that is made available to the code lets you easily define direct manipulation interactions,
allowing you to effortlessy string together custom tools as you go along.

With this flexibility, creating custom tools and using them blend together into a single workflow that powers `watch-cad`.

status
------

Currently this repo contains a [LÖVE](https://love2d.org) implementation of the concept.
The engine only supports a few shapes, and documents can't be saved, so you have to start from scratch every time.
To run it, you need to install love2d, and then `moonscript` and `luafilesystem`, e.g. using [luarocks](https://luarocks.org/).
Then the project can be run from the project folder using `love .`, which should bring up a mostly-black window.

To do something, you can create or open a Lua or Moonscript file in `library/`, and tell `watch-cad` about it using `:run <filename>`.
For example to run the 'place' example, enter `:run place.moon` (and confirm with enter).
Now you can place objects by clicking and dragging the mouse and confirm their creation with the spacebar. 

When `:run`-ing a script file, the script is reloaded whenever the file is saved on disk.

***

Clearly this implementation is lacking many features.
This is because this project is more about testing *the principles* (see below), rather than creating a fully featured application.
In fact I am currently looking for a suitable 'host' application that the principles could be implemented into.
I am considering KiCAD, Inkscape and Blender at the moment, but I am unsure which to go with.
If you have any ideas, suggestions or opinions I would be very happy to hear them :)

three principles
----------------

### combine direct manipulation and code
There are great arguments for the use of both direct manipulation and code.
Code allows to abstract away tedious, repetitive tasks and helps with precision for geometric shapes.

But editing code is not always the most natural way to interact with things, especially when a graphical representation already exists.
Direct manipulation is much more intuitive for making adjustments to freehand shapes, fine-tuning parameters and many other tasks.

That's why `watch-cad` makes it as easy as possible to combine the two, by offering primitives such as draggable points, object-selection etc. to be used in code.

### don't worry, preview
Because `watch-cad` shifts a lot of the work into creating ad-hoc programs, it's very important to make this process as fast and reliable as possible.
Part of that is making sure that unfinished or buggy code doesn't cause problems.
That's why code you write in `watch-cad` never changes anything in the document directly.
All changes are instead previewed in the document itself, as code is edited and interacted with.

Whenever you are happy with the results, you can apply the changes instantly.
This makes sure you can freely experiment with the code without fearing to lose anything,
and be sure that what happens when you *do* commit is exactly what you wanted.

### immediate feedback, always
A big part of programming is figuring out what's going wrong.
As a consequence of it's design, `watch-cad` constantly parses and runs your code (or the last parse-able version of it).
This means that it can give constant feedback for errors as you work on the code.

It's also easy to spot problems in your logic, since any changes you apply in your code are previewed in realtime on the canvas.
The drawing API also makes it easy to add more debug visualisations, right in the graphical context.

`watch-cad` versus regular scripting APIs
-----------------------------------------
Many applications already ship with a scripting interface,
for example KiCAD, Inkscape and Blender all support extensions written in Python.

While this is great to have, in an effort to keep the interface more aligned (presumably),
however all of these applications are optimized for using such extensions, not for creating them (especially on-the-fly),
and even when running them the user-experience is severly limited.

For example in Inkscape python plugins can be added only as importers, exporters or 'filters'.
Filters are the most general of the cases here, but even they come with a severe limitation:
They cannot be controlled by user input other than the state of the document and a popup window that can be optionally defined.
This means that extensions are completely cut-off from defining their own (or even re-using existing) direct manipulation operations.

The editing experience makes this a lot worse.
To add new functionality, a script has to be created in a specific place on the disk and filled with python code.
When a new extension is added for the first time, Inkscape has to be restarted.
While the code is edited, there is no feedback at all,
and to check whether progress has been made while working on a new filter,
it has to be run manually every once in a while.
Because a work-in-progress extension may corrupt the document it is tested in,
either care must be taken to immediately undo anything the extension did between tests,
or to work in a copy of the original file or a new test document.

All of this constitutes an exeperience that is simply too annoying to routinely use for small improvements in workflow.
