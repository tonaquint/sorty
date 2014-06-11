$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "sorty/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "sorty"
  s.version     = Sorty::VERSION
  s.authors     = ["Mark D Holmberg"]
  s.email       = ["mark.d.holmberg@gmail.com"]
  s.homepage    = "https://github.com/mark-d-holmberg/sorty"
  s.summary     = "Sorty allows sorting records using a whitelist."
  s.description = "Sorty allows sorting records using a whitelist."

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails", ">= 4.0.2"
end
