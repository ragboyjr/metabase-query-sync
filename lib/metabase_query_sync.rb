require 'zeitwerk'

loader = Zeitwerk::Loader.for_gem
loader.inflector.inflect("ir" => "IR")
loader.setup

module MetabaseQuerySync

end