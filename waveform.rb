require "rubygems"
require "ruby-audio"
require "fileutils"
require "rmagick"

# TODO: set these with command line options
# pixel width of final waveform image
Width  = 1800
# pixel height of final waveform image
Height = 280

# A simple wrapper for logging + benchmarking, nice to have good feedback on a
# long batch operation
class Log
  class << self
    # Prints the given message to the log
    def out(msg)
      STDOUT.print(msg)
    end
    
    # Prints the given message to the log followed by the most recent benchmark
    # (note that it calls .end! which will stop the benchmark)
    def done!(msg="done")
      STDOUT.print("#{msg} (#{self.end!}s)\n")
    end
    
    # Starts a new benchmark clock and returns the index of the new clock.
    # 
    # If .start! is called again before .end! then the time returned will be
    # the elapsed time from the next call to start!, and calling .end! again
    # will return the time from *this* call to start! (that is, the clocks are
    # LIFO)
    def start!
      (@benchmarks ||= []) << Time.now
      @current = @benchmarks.size - 1
    end
    
    # Returns the elapsed time from the most recently started benchmark clock
    # and ends the benchmark, so that a subsequent call to .end! will return
    # the elapsed time from the previously started benchmark clock.
    def end!
      elapsed = (Time.now - @benchmarks[@current])
      @current -= 1
      elapsed
    end
    
    # Returns the elapsed time from the benchmark clock w/ the given index (as
    # returned from when .start! was called).
    def time?(index)
      Time.now - @benchmarks[index]
    end
  end
end

class Wave
  def initialize(wave)
    @wave = wave
  end
  
  # Returns a sampling of frames from the given wave file using the given method
  # the sample size is determined by the given pixel width -- we want one sample
  # frame per horizontal pixel.
  def frames(width, method = :peak)
    Log.start!
    Log.out("Analyzing waveform:\n")
  
    frames = []
  
    RubyAudio::Sound.open(@wave) do |snd|
      frames_read       = 0
      frames_per_sample = (snd.info.frames.to_f / Width.to_f).to_i
      sample            = RubyAudio::Buffer.new("float", frames_per_sample, snd.info.channels)

      Log.out("Sampling #{frames_per_sample} frames per sample:\n")
      while(frames_read = snd.read(sample)) > 0
        frames << send(method, sample, snd.info.channels)
        Log.out(".")      
      end
    end

    Log.out("\nRead #{frames.size} frames\n")
    Log.done!
  
    frames
  end
  
  private
  
  # Returns an array of the peak of each channel for the given collection of
  # frames -- the peak is individual to the channel, and the returned collection
  # of peaks are not (necessarily) from the same frame(s).
  def peak(frames, channels=1)
    peak_frame = []
    (0..channels-1).each do |channel|
      peak_frame << channel_peak(frames, channel)
    end
    peak_frame
  end

  # Returns an array of rms values for the given frameset where each rms value is
  # the rms value for that channel.
  def rms(frames, channels=1)
    rms_frame = []
    (0..channels-1).each do |channel|
      rms_frame << channel_rms(frames, channel)
    end
    rms_frame
  end
  
  # Returns the peak voltage reached on the given channel in the given collection
  # of frames.
  # 
  # TODO: Could lose some resolution and only sample every other frame, would
  # likely still generate the same waveform as the waveform is so comparitively
  # low resolution to the original input (in most cases), and would double the
  # analyzation speed
  def channel_peak(frames, channel=0)
    peak = 0.0
    frames.each do |frame|
      next if frame.nil?
      peak = frame[channel] if frame[channel] > peak
    end
    peak
  end

  # Returns the rms value across the given collection of frames for the given
  # channel.
  # 
  # FIXME: this RMS calculation might be wrong...
  # refactored this from: http://pscode.org/javadoc/src-html/org/pscode/ui/audiotrace/AudioPlotPanel.html#line.996
  def channel_rms(frames, channel=0)
    avg = frames.inject(0.0){ |sum, frame| sum += frame ? frame[channel] : 0 }/frames.size.to_f
    Math.sqrt(frames.inject(0.0){ |sum, frame| sum += frame ? (frame[channel]-avg)**2 : 0 }/frames.size.to_f)
  end
end

# Draws a waveform for the given set of sample frames to the given filename
# supports a 2-dimensional array of samples representing multiple channels of
# audio.
def draw(samples, filename)
  Log.start!
  Log.out("Drawing waveform graph:\n")
  
  canvas = Magick::Image.new(Width, Height) { self.background_color = "#ffffff" }
  gc     = Magick::Draw.new
  
  # TODO: set colors from command line options, support more than 2 colors, add
  # default colors per channel
  colors = %w( 000000 000000 )
  
  Log.out("#{samples.size} samples x #{samples[0].size} channels\n")
  
  samples.each_with_index do |sample, x|
    sample.each_with_index do |value, channel|
      scaled = value*Height.to_f
      bottom = (Height-scaled)/2
      
      gc.stroke("##{colors[channel]}")
      gc.stroke_antialias(false)
      gc.stroke_width(1)
      gc.line(x, bottom, x, bottom+scaled)
    end
    Log.out(".")
  end
  
  Log.out("\nDrawing...")
  gc.draw(canvas)
  Log.out("done\n")
  
  Log.out("Finalizing...")
  canvas.transparent("#000000", Magick::TransparentOpacity).write(filename)
  Log.out("done\n")

  Log.done!
end

# Decode given mp3 to a wav file, returns true if the decode succeeded or false
# otherwise.
def mp3_to_wav(mp3, wav)
  Log.start!
  Log.out("Decoding MP3...")
  
  FileUtils.rm(wav) if File.exists?(wav)
  
  system %Q{ffmpeg -i "#{ARGV[0]}" -f wav "#{wav}" > /dev/null 2>&1}
  Log.done!
  
  File.exists?(wav)
end

# =============================================================================

time = Time.now
wave = File.join(File.dirname(__FILE__), "temp.wav")
Log.start!

raise "Unable to decode source MP3 #{ARGV[0]}, quitting" unless mp3_to_wav(ARGV[0], wave)
draw(Wave.new(wave).frames(Width, :peak), ARGV[1])

puts "Generated #{ARGV[1]} in #{(Log.end!)}s"