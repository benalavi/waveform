require "./lib/waveform"

Gem::Specification.new do |s|
  s.name              = "waveform"
  s.version           = Waveform::VERSION
  s.summary           = "Generate waveform images from WAV and MP3 files"
  s.description       = "Generate waveform images from WAV and MP3 files -- in your code or via included CLI."
  s.authors           = ["Ben Alavi"]
  s.email             = ["benalavi@gmail.com"]
  s.homepage          = "http://github.com/benalavi/waveform"

  s.files = Dir[
    "LICENSE",
    "README.md",
    "Rakefile",
    "lib/**/*.rb",
    "*.gemspec",
    "test/**/*.rb",
    "bin/*"
  ]

  s.executables = "waveform"

  s.add_dependency "ruby-audio"
  s.add_dependency "chunky_png"
  
  s.add_development_dependency "contest"
end
