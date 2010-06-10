require "rubygems"
require "icanhasaudio"
require "ruby-audio"
require "fileutils"
require "rmagick"

# pixel width of final waveform image
Width  = 1800
# pixel height of final waveform image
Height = 280

# returns an array of the peak of each channel for the given collection of
# frames -- the peak is individual to the channel, and the returned collection
# of peaks are not (necessarily) from the same frame(s)
def peak(frames, channels=1)
  peak_frame = []
  (0..channels-1).each do |channel|
    peak_frame << channel_peak(frames, channel)
  end
  peak_frame
end

# returns the peak voltage reached on the given channel in the given collection
# of frames
def channel_peak(frames, channel=0)
  peak = 0.0
  frames.each do |frame|
    next if frame.nil?
    peak = frame[channel] if frame[channel] > peak
  end
  peak
end

# returns an array of rms values for the given frameset where each rms value is
# the rms value for that channel
def rms(frames, channels=1)
  rms_frame = []
  (0..channels-1).each do |channel|
    rms_frame << channel_rms(frames, channel)
  end
  rms_frame
end

# returns the rms value across the given collection of frames for the given
# channel
# the RMS calculation might be wrong...
# refactored this from: http://pscode.org/javadoc/src-html/org/pscode/ui/audiotrace/AudioPlotPanel.html#line.996
def channel_rms(frames, channel=0)
  avg = frames.inject(0.0){ |sum, frame| sum += frame ? frame[channel] : 0 }/frames.size.to_f
  Math.sqrt(frames.inject(0.0){ |sum, frame| sum += frame ? (frame[channel]-avg)**2 : 0 }/frames.size.to_f)
end

# returns a sampling of frames from the given wave file using the given method
# the sample size is determined by the given pixel width -- we want one sample
# frame per horizontal pixel
def frames(wave, width, method = :peak)
  frames = []
  
  RubyAudio::Sound.open(wave) do |snd|
    frames_read       = 0
    frames_per_sample = (snd.info.frames.to_f / Width.to_f).to_i
    sample            = RubyAudio::Buffer.new("float", frames_per_sample, snd.info.channels)

    while(frames_read = snd.read(sample)) > 0
      frames << send(method, sample, snd.info.channels)
    end
  end
  
  frames
end

# draws a waveform for the given set of sample frames to the given filename
# supports a 2-dimensional array of samples representing multiple channels of
# audio
def draw(samples, filename)
  canvas = Magick::Image.new(Width, Height) { self.background_color = "#ffffff" }
  gc     = Magick::Draw.new
  colors = %w( 000000 000000 )
  
  samples.each_with_index do |sample, x|
    sample.each_with_index do |value, channel|
      scaled = value*Height.to_f
      bottom = (Height-scaled)/2
      
      gc.stroke("##{colors[channel]}")
      gc.stroke_antialias(false)
      gc.stroke_width(1)
      gc.line(x, bottom, x, bottom+scaled)
    end
  end
    
  gc.draw(canvas)
  canvas.transparent("#000000", Magick::TransparentOpacity).write(filename)
end

# decode MP3 to WAV ===========================================================
wave = File.join(File.dirname(__FILE__), "temp.wav")
FileUtils.rm(wave) if File.exists?(wave)

reader = Audio::MPEG::Decoder.new
reader.decode(File.open(ARGV[0], "rb"), File.open(wave, "wb"))

draw(frames(wave, Width, :peak), ARGV[1])

