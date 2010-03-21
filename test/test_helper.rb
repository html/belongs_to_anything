require 'rubygems'
require 'active_support'
require 'active_support/test_case'
require 'test/unit'
require 'shoulda'
require 'active_record'
require 'ruby-debug'
require File.dirname(__FILE__) + '/../init.rb'

ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")
old = $stdout
$stdout = StringIO.new

ActiveRecord::Schema.define(:version => 1) do
  create_table :test_table do |t|
    t.column :name, :string
  end

  create_table :test_table2 do |t|
    t.column :page_id, :string
  end
end


$stdout = old
