#require "./lib/waveform"

Gem::Specification.new do |s|
  s.name              = "waveform"
  s.version           = "0.0.5"
  s.summary           = "Generate waveform images from WAV, MP3, etc... files"
  s.description       = "Generate waveform images from WAV, MP3, etc... files - as a gem or via CLI."
  s.authors           = ["Ben Alavi", "Izoria Vladislav"]
  s.email             = ["benalavi@gmail.com"]
  s.homepage          = "http://github.com/izzm/waveform"

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
