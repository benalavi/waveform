require "./lib/waveform/version"

Gem::Specification.new do |s|
  s.name              = "waveform"
  s.version           = Waveform::VERSION
  s.summary           = "Generate waveform images from audio files"
  s.description       = "Generate waveform images from audio files. Includes a Waveform class for generating waveforms in your code as well as a simple command-line program called 'waveform' for generating on the command line."
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
