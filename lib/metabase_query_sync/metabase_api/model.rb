require 'dry-struct'
class MetabaseQuerySync::MetabaseApi::Model < Dry::Struct
  transform_keys &:to_sym
end