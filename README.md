# Overbite Palm

Overbite Palm is a Gopher client for classic Palm PDAs and mobiles running at least PalmOS 3.5 with at least 4MB of RAM and a network connection. It has not been tested in webOS under Classic.

Overbite Palm is (C) 2009, 2012, 2015, 2022, 2023 Cameron Kaiser. All rights reserved.

Overbite Palm is furnished to you under the BSD 3-clause license. The most current release is available from [the releases tab](https://github.com/classilla/overbitepalm/releases).

## Usage

Install `OverbitePalm.prc`, plus `Plua2RT.prc` and `MathLib.prc` on your device (if not already done so - you can use them if they are already installed on your device for another app). The `pilot-xfer` utility can do this if you are on a system that does not have Palm Desktop (such as `pilot-xfer -p usb: -i OverbitePalm.prc Plua2RT.prc MathLib.prc`).

Start Overbite by tapping it in the launcher. It will automatically start your default network connection and access the Floodgap gopher menu. You can change the initial "home gopher" with the analogous option in the app menu.

The Overbite Palm display has a field for the URL (minus the `gopher://` portion), and buttons for Go (goes to the entered URL), Back (goes to the previous entry on the history stack), Reload (refreshes the current menu or document) and, when a menu is displayed, Wordwrap (toggles wrapping of long lines in menus). Below the URL field and the control buttons is a scrolling area where the current document or menu is displayed.

Menus are displayed using a scrolling list control. Item types appear at left (such as `1>`, which depicts another menu, `0>` for a text file, or `7>` for a search server). If an item type does not appear for a particular menu item, then it is simply informational text.

While displaying a menu, the Wordwrap button is enabled. Wordwrapping defaults to on or off depending on available memory (as it can necessarily generate a longer list). When wordwrapping is off, long lines are truncated, but each line corresponds to exactly one menu item; when it is turned on, long lines are flowed into multiple lines instead of being truncated, but each menu item may thus take up several lines. You can toggle it on or off by tapping the Wordwrap button. This setting is stored as a preference. On systems with low memory, you may be required to restart the application when the setting is changed.

When a line in the menu list box is tapped, Overbite Palm displays a dialogue box with the entire line (as screen size permits) and, if it is a link to another item or menu, displays the destination, and asks if you want to go there. If you decline, navigation is cancelled. If it is merely informational text, just tap OK when done reading it.

Text files are displayed using a scrolling text widget. Text is automatically wrapped by the operating system.

If you navigate to an item pointing to a search server or other interactive service, Overbite Palm will ask you for a parameter or command to send.

You can change and visit the home gopher or one of three built-in bookmarks using the corresponding choices in the app menu. Shortcuts are available for quickly visiting them.

On Fossil and Abacus Wrist PDAs, the rocker, up/down and back buttons are live. If you press back on the root menu, it will return you to the Launcher. You will need to install networking software; [read this blog post](https://oldvcr.blogspot.com/2023/09/the-fossil-wrist-pda-becomes-tiny.html) for more information.

## Limitations

Menus and text files may be truncated if you have insufficient dynamic heap. This is mostly an issue for 68K Palms, where only a few hundred kilobytes total may be available (ARM Palms with Palm OS 5 should have no issues), and Palms with less than 4MB of RAM will not have enough dynamic heap to run Overbite Palm at all. To see how much memory Overbite Palm thinks is available, select `About Overbite Palm` from the app menu and scroll to the bottom. It will display the OS version and free and total heap space.

There is a hard limit on the amount of text that can be shown in the scrolling text widget; empirically this appears to be 32K, regardless of the amount of heap.

Overbite Palm does not currently support CSO/ph, images, HTML (displayed as text), Telnet/TN3270, hURLs or downloads (either to internal RAM or to the SD card).

## Building

Overbite Palm is written in [Plua 2](http://www.floodgap.com/retrotech/plua/). You will need [the `plua2c` cross compiler](https://github.com/classilla/plua2c) to build it. With the compiler installed, just type `make` and the `.prc` will be generated.

`make run` will run it within an instance of your preferred Palm emulator. You may need to edit the `Makefile` to point it to your emulator or use a different command line (the default is to run POSE through QEMU).

Remember that your device or emulator must have `Plua2RT.prc` and `MathLib.prc` to run the generated client.

## License

Overbite Palm is (C) 2009, 2012, 2015, 2022 Cameron Kaiser. All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF/SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
