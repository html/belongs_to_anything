require 'belongs_to_anything'
if defined?(ActiveRecord)
  ActiveRecord::Base::send :extend, BelongsToAnything::ActiveRecordExtension
end
