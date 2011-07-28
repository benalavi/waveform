Waveform
========

Waveform is a class to generate waveform images from audio files. You can
combine it with jPlayer to make a soundcloud.com style MP3 player. It also
comes with a handy CLI you can use to generate waveform images on the command
line.

Installation
============

Build libsndfile (http://www.mega-nerd.com/libsndfile/), or install it via `apt`
(`sudo apt-get install libsndfile1-dev`), or `libsndfile` in macports.

    $ sudo gem install waveform

You might also want to, but don't have to:

    $ sudo gem install oily_png
    
to make things a bit faster, and:

    $ sudo apt-get install ffmpeg
    
if you want Waveform to convert non WAV audio for you.

_See Requirements below for more info_

CLI Usage
=========

    $ waveform song.mp3 waveform.png

There are some nifty options you can supply to switch things up:

    -W sets the width (in pixels) of the waveform image.
    -H sets the height (in pixels).
    -c sets the color used to draw the waveform (in hex, can also use
        'transparent').
    -b sets the background color to draw the waveform on (in hex, and can use
        'transparent' as well).
    -m sets the method used to sample the source audio file, it can either be
        'peak' or 'rms'. 'peak' is probably what you want because it looks
        cooler, but 'rms' is closer to what you actually hear.

There are also some less-nifty options:

    -q will generate your waveform without printing out a bunch of stuff.
    -h will print out a help screen with all this info.
    -F will automatically overwrite destination file.

Generating a small waveform "cut out" of a white background is pretty useful,
then you can overlay it on a web-gradient on the website for your new startup
and it will look really cool. To make it you could use:

    $ waveform -W900 -H140 -ctransparent -b#ffffff Motley\ Crüe/Kickstart\ my\ Heart.mp3 sweet_waveforms/Kickstart\ my\ Heart.png

Usage in code
=============

The CLI is really just a thin wrapper around the Waveform class, which you can
also use in your programs for reasons I haven't thought of. The Waveform class
takes pretty much the same options as the CLI when generating waveforms.

Requirements
============

`ruby-audio`

The gem version, *not* the old outdated library listed on RAA. `ruby-audio` is
a wrapper for `libsndfile`, on my Ubuntu 10.04LTS VM I installed the necessary
libs to build `ruby-audio` via: `sudo apt-get install libsndfile1-dev`.

`chunky_png`

`chunky_png` is a pure ruby (!) PNG manipulation library. Caveat to this
requirement is that if you also install `oily_png` you will get *better
performance* as it uses some C code, and C code is fast.

`ffmpeg` (sorta)

You only need `ffmpeg` if you plan to generate waveforms from files that aren't
already WAVs (like MP3, or M4A). On my same Ubuntu VM I installed it via `sudo
apt-get install ffmpeg` and it was able to convert MP3 and M4A files out of the
box. The formats you can convert depend on which decoders you have installed.

If you don't want to install ffmpeg, you could also use one of the many audio
format converters to convert your files to WAV before generating waveforms.

Or you could be all retro and use WAV audio for everything in the first place.

Tests
=====

Tests require `contest` gem & `ffmpeg` (to test conversion), run via:

    $ rake

Sample sound file is in Public Domain from soundbible.com.
<http://soundbible.com/1598-Electronic-Chime.html>

References
==========

<http://pscode.org/javadoc/src-html/org/pscode/ui/audiotrace/AudioPlotPanel.html#line.996>
<http://github.com/pangdudu/rude/blob/master/lib/waveform_narray_testing.rb>
<http://stackoverflow.com/questions/1931952/asp-net-create-waveform-image-from-mp3>
<http://codeidol.com/java/swing/Audio/Build-an-Audio-Waveform-Display>

License
=======

Copyright (c) 2010-2011 Ben Alavi

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
