require "contest"
require "fileutils"
require File.expand_path(File.join(File.dirname(__FILE__), "..", "lib", "waveform"))

class WaveformTest < Test::Unit::TestCase
  def self.fixture(file)
    File.join(File.dirname(__FILE__), "fixtures", file)
  end
  def fixture(file);self.class.fixture(file);end;
  
  def self.output(file)
    File.join(File.dirname(__FILE__), "output", file)
  end
  def output(file);self.class.output(file);end;
  
  def open_png(file)
    ChunkyPNG::Image.from_datastream(ChunkyPNG::Datastream.from_file(file))
  end
  
  puts "Removing existing testing artifacts..."
  FileUtils.rm_rf(output("")) if File.exists?(output(""))
  FileUtils.mkdir(output(""))
  sample_wav = fixture("sample_mp3.wav")
  FileUtils.rm(sample_wav) if File.exists?(sample_wav)
  
  context "generating waveform" do
    setup do
      @waveform = Waveform.new(fixture("sample.wav"))
    end
    
    should "generate waveform from audio source" do
      @waveform.generate(output("waveform_from_audio_source.png"))
      assert File.exists?(output("waveform_from_audio_source.png"))
      
      image = open_png(output("waveform_from_audio_source.png"))
      assert_equal ChunkyPNG::Color.from_hex(Waveform::DefaultOptions[:color]), image[60, 120]
      assert_equal ChunkyPNG::Color.from_hex(Waveform::DefaultOptions[:background_color]), image[0, 0]
    end
    
    should "convert non-wav audio source before generation" do
      Waveform.new(fixture("sample_mp3.mp3")).generate(output("from_mp3.png"))

      assert File.exists?(output("from_mp3.png"))
    end

    should "log to given io" do
      File.open(output("waveform.log"), "w") do |io|
        Waveform.new(fixture("sample.wav"), io).generate(output("logged.png"))
      end
      
      assert_match /Generated waveform/, File.read(output("waveform.log"))
    end
            
    should "generate waveform using rms method instead of peak" do
      @waveform.generate(output("peak.png"))
      @waveform.generate(output("rms.png"), :method => :rms)
      rms = open_png(output("rms.png"))
      peak = open_png(output("peak.png"))
      
      assert_equal ChunkyPNG::Color.from_hex(Waveform::DefaultOptions[:color]), peak[44, 43]
      assert_equal ChunkyPNG::Color.from_hex(Waveform::DefaultOptions[:background_color]), rms[44, 43]
      assert_equal ChunkyPNG::Color.from_hex(Waveform::DefaultOptions[:color]), rms[60, 120]
    end

    should 'generate waveform from a mono file' do
      Waveform.new(fixture("mono_sample.wav")).generate(output("mono.png"))

      assert File.exists?(output("mono.png"))
    end

    should 'generate waveform from a mono file using rms' do
      Waveform.new(fixture("mono_sample.wav")).generate(output("mono_rms.png"), :method => :rms)

      assert File.exists?(output("mono.png"))
    end

    should "generate waveform 900px wide" do
      @waveform.generate(output("width-900.png"), :width => 900)
      image = open_png(output("width-900.png"))
      
      assert_equal 900, image.width
    end
    
    should "generate waveform 100px tall" do
      @waveform.generate(output("height-100.png"), :height => 100)
      image = open_png(output("height-100.png"))
      
      assert_equal 100, image.height
    end
    
    should "generate waveform on red background color" do
      @waveform.generate(output("background_color-#ff0000.png"), :background_color => "#ff0000")
      image = open_png(output("background_color-#ff0000.png"))
      
      assert_equal ChunkyPNG::Color.from_hex("#ff0000"), image[0, 0]
    end
    
    should "generate waveform on transparent background color" do
      @waveform.generate(output("background_color-transparent.png"), :background_color => :transparent)
      image = open_png(output("background_color-transparent.png"))
      
      assert_equal ChunkyPNG::Color::TRANSPARENT, image[0, 0]
    end
    
    should "generate waveform in black foreground color" do
      @waveform.generate(output("color-#000000.png"), :color => "#000000")
      image = open_png(output("color-#000000.png"))
      
      assert_equal ChunkyPNG::Color.from_hex("#000000"), image[60, 120]
    end
    
    should "generate waveform on red background color with transparent foreground cut-out" do
      @waveform.generate(output("background_color-#ff0000+color-transparent.png"), :background_color => "#ff0000", :color => :transparent)
      image = open_png(output("background_color-#ff0000+color-transparent.png"))
      
      assert_equal ChunkyPNG::Color.from_hex("#ff0000"), image[0, 0]
      assert_equal ChunkyPNG::Color::TRANSPARENT, image[60, 120]
    end
    
    # Bright green is our transparency mask color, so this test ensures that we
    # don't destroy the image if the background also uses the transparency mask
    # color
    should "generate waveform with transparent foreground on bright green background" do
      @waveform.generate(output("background_color-#00ff00+color-transparent.png"), :background_color => "#00ff00", :color => :transparent)
      image = open_png(output("background_color-#00ff00+color-transparent.png"))
      
      assert_equal ChunkyPNG::Color.from_hex("#00ff00"), image[0, 0]
      assert_equal ChunkyPNG::Color::TRANSPARENT, image[60, 120]
    end

    # Not sure how to best test this as it's totally dependent on the ruby and
    # system GC when the tempfiles are removed (as we're not explicitly
    # unlinking them).
    # should "use a tempfile when generating a temporary wav" do
    #   tempfiles = Dir[File.join(Dir.tmpdir(), "sample_mp3*")].size
    #   Waveform.new(fixture("sample_mp3.mp3")).generate(output("cleanup_temporary_wav.png"))
    #   assert_equal tempfiles + 1, Dir[File.join(Dir.tmpdir(), "sample_mp3*")].size
    # end
    
    should "not delete source wav file if one was given" do
      assert File.exists?(fixture("sample.wav"))
      Waveform.new(fixture("sample.wav")).generate(output("keep_source_wav.png"))
      assert File.exists?(fixture("sample.wav"))
    end
    
    should "raise an error if unable to decode to wav" do
      assert_raise(Waveform::RuntimeError) do
        Waveform.new(fixture("sample.txt")).generate(output("shouldnt_exist.png"))
      end
    end

    context "with existing PNG files" do
      setup do
        @existing = output("existing.png")
        FileUtils.touch @existing
      end

      should "generate waveform if :force is true and PNG exists" do
        @waveform.generate(@existing, :force => true)
      end

      should "raise an exception if PNG exists and :force is false" do
        assert_raises Waveform::RuntimeError do
          @waveform.generate(@existing, :force => false)
        end
      end
    end

    context "with existing WAV files" do
      setup do
        @existing = output("existing.wav")
        FileUtils.touch @existing
      end

      should "generate waveform if :force is true and WAV exists" do
        @waveform.generate(@existing, :force => true)
      end

      should "raise an exception if WAV exists and :force is false" do
        assert_raises Waveform::RuntimeError do
          @waveform.generate(@existing, :force => false)
        end
      end
    end
  end
end
