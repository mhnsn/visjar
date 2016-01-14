begin
  require 'safely'
rescue LoadError
  $stderr.puts "Missing safely gem. Please run 'bundle install'."
  exit 1
end
