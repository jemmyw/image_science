require 'bundler'
Bundler::GemHelper.install_tasks

task :build => [:compile, :chmod]

task :compile do
  `ruby ext/image_science/extconf.rb`
  `make`

  if File.exists?("extension.so")
    `mv extension.so lib/image_science/extension.so`
  elsif File.exists?("extension.bundle")
    `mv extension.bundle lib/image_science/extension.bundle`
  else
    raise "No extension file build"
  end
end

task :chmod do
  Dir["lib/image_science/extension.{so,bundle}"].each do |file|
    File.chmod(0775, file)
  end
end

