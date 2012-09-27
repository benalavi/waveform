require "./lib/waveform/version"

Gem::Specification.new do |s|
  s.name              = "waveform"
  s.version           = Waveform::VERSION
  s.summary           = "Generate waveform images from audio files"
  s.description       = "Generate waveform images from audio files"
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
end
