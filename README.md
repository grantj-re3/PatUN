# PatUN - A patience card game

For the time being, the program does *not* use a graphical user
interface (GUI). It uses plain text display and keyboard input.


## Requirements

I imagine this code should work in environments:

- ruby 2.x
- Linux, Mac, Windows

My test environment is:

- ruby 2.3.3p222 (2016-11-21 revision 56859) [x86_64-linux]
- Fedora release 25
- Linux 4.8.6-300.fc25.x86_64 #1 SMP Tue Nov 1 12:36:38 UTC 2016 x86_64 x86_64 x86_64 GNU/Linux


## How to run the main program

```
  $ ruby patun_main.rb
```

or under Linux/unix:
```
  $ ./patun_main.rb
```


## How to play this patience card game

- [Rules](rules.md)


## Technical info

A patience card game PatUN (pronounced "Pattern") written using the
Model-View-Controller design pattern from first principles (without
using a web framework or other framework library).

**Main:** patun_main.rb

Run this program. Initialises the MVC components then invokes the
controller input/event loop.

**Model:** patun.rb

Data storage and business/logic rules. Written without
knowing how data will be displayed or input/events acquired.

**View:** patun_view.rb

Display of output. Requires knowledge of model.

**Controller:** patun_controller.rb

Loop - acquire input/events; based on the input received, it typically
invokes the model then invokes the view.

References:

- [Wikipedia | Model–view–controller](https://en.wikipedia.org/wiki/Model%E2%80%93view%E2%80%93controller)
- [Applications Programming in Smalltalk-80 (TM): How to use Model-View-Controller (MVC)](http://www.dgp.toronto.edu/~dwigdor/teaching/csc2524/2012_F/papers/mvc.pdf) (1987, 1992) by Steve Burbeck, Ph.D.

