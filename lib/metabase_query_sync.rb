require 'zeitwerk'

loader = Zeitwerk::Loader.for_gem
loader.inflector.inflect("ir" => "IR")
loader.inflector.inflect("read_ir" => "ReadIR")
loader.setup

module MetabaseQuerySync

end