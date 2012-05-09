require "./lib/waveform/version"

Gem::Specification.new do |s|
  s.name              = "waveform"
  s.version           = Waveform::VERSION
  s.summary           = "Generate waveform images from WAV, MP3, etc... files"
  s.description       = "Generate waveform images from WAV, MP3, etc... files - as a gem or via CLI."
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
