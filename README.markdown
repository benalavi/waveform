Waveformer
==========

Generates waveform images from MP3 files. Combine it with jPlayer to make a soundcloud.com style MP3 player.

Usage
=====

    $ ruby waveformer.rb song.mp3 waveform.png

Requirements
============

Some pretty heavy requirements:

* ruby 1.8 (see note below)
* icanhasaudio -- for converting MP3 to WAV
  * i couldn't get icanhasaudio to compile using ruby 1.9.1, so for now this requires ruby 1.8
* ruby-audio
  * the gem version, *not* the old outdated library listed on RAA
  * http://github.com/warhammerkid/ruby-audio
* rmagick
  * ...and therefore ImageMagick or GraphicsMagick
  
References
==========

* http://pscode.org/javadoc/src-html/org/pscode/ui/audiotrace/AudioPlotPanel.html#line.996
* http://github.com/pangdudu/rude/blob/master/lib/waveform_narray_testing.rb
* http://stackoverflow.com/questions/1931952/asp-net-create-waveform-image-from-mp3
* http://codeidol.com/java/swing/Audio/Build-an-Audio-Waveform-Display

License
=======

Copyright (c) 2010 Ben Alavi

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
