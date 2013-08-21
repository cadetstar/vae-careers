# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "pdf-forms"
  s.version = "0.3.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.3.6") if s.respond_to? :required_rubygems_version=
  s.authors = ["Jens Kr\u{c3}\u{a4}mer"]
  s.date = "2012-04-23"
  s.description = "Fill out PDF forms with pdftk (http://www.accesspdf.com/pdftk/)."
  s.email = ["jk@jkraemer.net"]
  s.homepage = "http://github.com/jkraemer/pdf-forms"
  s.require_paths = ["lib"]
  s.rubyforge_project = "pdf-forms"
  s.rubygems_version = "1.8.24"
  s.summary = "Fill out PDF forms with pdftk (http://www.accesspdf.com/pdftk/)."

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
