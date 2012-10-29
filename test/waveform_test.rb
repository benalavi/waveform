require File.expand_path(File.join(File.dirname(__FILE__), "..", "lib", "waveform"))

require "test/unit"
require "fileutils"

module Helpers
  def fixture(file)
    File.join(File.dirname(__FILE__), "fixtures", file)
  end
  
  def output(file)
    File.join(File.dirname(__FILE__), "output", file)
  end
  
  def open_png(file)
    ChunkyPNG::Image.from_datastream(ChunkyPNG::Datastream.from_file(file))
  end
end

class WaveformTest < Test::Unit::TestCase
  include Helpers
  extend Helpers

  def self.cleanup
    puts "Removing existing testing artifacts..."
    Dir[output("*.*")].each{ |f| FileUtils.rm(f) }
    FileUtils.mkdir_p(output(""))
  end
  
  def test_generates_waveform
    Waveform.generate(fixture("sample.wav"), output("waveform_from_audio_source.png"))
    assert File.exists?(output("waveform_from_audio_source.png"))
      
    image = open_png(output("waveform_from_audio_source.png"))
    assert_equal ChunkyPNG::Color.from_hex(Waveform::DefaultOptions[:color]), image[60, 120]
    assert_equal ChunkyPNG::Color.from_hex(Waveform::DefaultOptions[:background_color]), image[0, 0]
  end
    
  def test_generates_waveform_from_mono_audio_source_via_peak
    Waveform.generate(fixture("mono_sample.wav"), output("waveform_from_mono_audio_source_via_peak.png"))
    assert File.exists?(output("waveform_from_mono_audio_source_via_peak.png"))

    image = open_png(output("waveform_from_mono_audio_source_via_peak.png"))
    assert_equal ChunkyPNG::Color.from_hex(Waveform::DefaultOptions[:color]), image[60, 120]
    assert_equal ChunkyPNG::Color.from_hex(Waveform::DefaultOptions[:background_color]), image[0, 0]
  end

  def test_generates_waveform_from_mono_audio_source_via_rms
    Waveform.generate(fixture("mono_sample.wav"), output("waveform_from_mono_audio_source_via_rms.png"), :method => :rms)
    assert File.exists?(output("waveform_from_mono_audio_source_via_rms.png"))

    image = open_png(output("waveform_from_mono_audio_source_via_rms.png"))
    assert_equal ChunkyPNG::Color.from_hex(Waveform::DefaultOptions[:color]), image[60, 120]
    assert_equal ChunkyPNG::Color.from_hex(Waveform::DefaultOptions[:background_color]), image[0, 0]
  end
        
  def test_logs_to_given_io
    File.open(output("waveform.log"), "w") do |io|
      Waveform.generate(fixture("sample.wav"), output("logged.png"), :logger => io)
    end
    
    assert_match /Generated waveform/, File.read(output("waveform.log"))
  end
  
  def test_uses_rms_instead_of_peak
    Waveform.generate(fixture("sample.wav"), output("peak.png"))
    Waveform.generate(fixture("sample.wav"), output("rms.png"), :method => :rms)

    rms = open_png(output("rms.png"))
    peak = open_png(output("peak.png"))
    
    assert_equal ChunkyPNG::Color.from_hex(Waveform::DefaultOptions[:color]), peak[44, 43]
    assert_equal ChunkyPNG::Color.from_hex(Waveform::DefaultOptions[:background_color]), rms[44, 43]
    assert_equal ChunkyPNG::Color.from_hex(Waveform::DefaultOptions[:color]), rms[60, 120]
  end
  
  def test_is_900px_wide
    Waveform.generate(fixture("sample.wav"), output("width-900.png"), :width => 900)
    
    image = open_png(output("width-900.png"))
    
    assert_equal 900, image.width
  end
  
  def test_is_100px_tall
    Waveform.generate(fixture("sample.wav"), output("height-100.png"), :height => 100)
    
    image = open_png(output("height-100.png"))
    
    assert_equal 100, image.height
  end
  
  def test_has_red_background_color
    Waveform.generate(fixture("sample.wav"), output("background_color-#ff0000.png"), :background_color => "#ff0000")
    
    image = open_png(output("background_color-#ff0000.png"))
    
    assert_equal ChunkyPNG::Color.from_hex("#ff0000"), image[0, 0]
  end
  
  def test_has_transparent_background_color
    Waveform.generate(fixture("sample.wav"), output("background_color-transparent.png"), :background_color => :transparent)
    
    image = open_png(output("background_color-transparent.png"))
    
    assert_equal ChunkyPNG::Color::TRANSPARENT, image[0, 0]
  end
  
  def test_has_black_foreground_color
    Waveform.generate(fixture("sample.wav"), output("color-#000000.png"), :color => "#000000")
    
    image = open_png(output("color-#000000.png"))
    
    assert_equal ChunkyPNG::Color.from_hex("#000000"), image[60, 120]
  end
  
  def test_has_red_background_color_with_transparent_foreground_cutout
    Waveform.generate(fixture("sample.wav"), output("background_color-#ff0000+color-transparent.png"), :background_color => "#ff0000", :color => :transparent)
    
    image = open_png(output("background_color-#ff0000+color-transparent.png"))
    
    assert_equal ChunkyPNG::Color.from_hex("#ff0000"), image[0, 0]
    assert_equal ChunkyPNG::Color::TRANSPARENT, image[60, 120]
  end
  
  # Bright green is our transparency mask color, so this test ensures that we
  # don't destroy the image if the background also uses the transparency mask
  # color
  def test_has_transparent_foreground_on_bright_green_background
    Waveform.generate(fixture("sample.wav"), output("background_color-#00ff00+color-transparent.png"), :background_color => "#00ff00", :color => :transparent)
    
    image = open_png(output("background_color-#00ff00+color-transparent.png"))
    
    assert_equal ChunkyPNG::Color.from_hex("#00ff00"), image[0, 0]
    assert_equal ChunkyPNG::Color::TRANSPARENT, image[60, 120]
  end
  
  def test_raises_error_if_not_given_readable_audio_source
    assert_raise(Waveform::RuntimeError) do
      Waveform.generate(fixture("sample.txt"), output("shouldnt_exist.png"))
    end
  end
  
  def test_overwrites_existing_waveform_if_force_is_true_and_file_exists
    FileUtils.touch output("overwritten.png")

    Waveform.generate(fixture("sample.wav"), output("overwritten.png"), :force => true)
  end

  def test_raises_exception_if_waveform_exists_and_force_is_false
    FileUtils.touch output("wont_be_overwritten.png")
    
    assert_raises Waveform::RuntimeError do
      Waveform.generate(fixture("sample.wav"), output("wont_be_overwritten.png"), :force => false)
    end
  end
  
  def test_raises_exception_if_waveform_exists
    FileUtils.touch output("wont_be_overwritten_by_default.png")
    
    assert_raises Waveform::RuntimeError do
      Waveform.generate(fixture("sample.wav"), output("wont_be_overwritten_by_default.png"))
    end
  end
  
  def test_raises_deprecation_exception_if_ruby_audio_fails_to_read_source_file
    begin
      Waveform.generate(fixture("sample.txt"), output("shouldnt_exist.png"))
    rescue Waveform::RuntimeError => e
      assert_match /Hint: non-WAV files are no longer supported, convert to WAV first using something like ffmpeg/, e.message
    end
  end
end

WaveformTest.cleanup
