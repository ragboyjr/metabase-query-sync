require 'zeitwerk'

loader = Zeitwerk::Loader.for_gem
loader.inflector.inflect("ir" => "IR")
loader.inflector.inflect("read_ir" => "ReadIR")
loader.inflector.inflect("cli" => "CLI")
loader.setup

module MetabaseQuerySync

end