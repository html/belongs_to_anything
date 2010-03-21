require 'test_helper'

class BelongsToAnythingTest < ActiveSupport::TestCase
  # Replace this with your real tests.

  class TestModel1 < ActiveRecord::Base
    set_table_name 'test_table'
  end

  class TestModelWithBTA < ActiveRecord::Base
    set_table_name 'test_table'
    belongs_to_anything
  end

  context "ActiveRecord::Base" do
    should "have belongs_to_anything method" do
      assert_respond_to ActiveRecord::Base, :belongs_to_anything
    end

    context "after applying belongs_to_anything method" do
      should "have correct methods" do
        assert_respond_to TestModelWithBTA, :create_record_for
        assert_respond_to TestModelWithBTA, :new_record_for
        assert_respond_to TestModelWithBTA, :record_for
      end
    end
  end

  context "Matchers" do
    context "active_record_matcher" do
      should "not raise exception and return nil if ActiveRecord::Base not defined" do
        base = ActiveRecord::Base
        ActiveRecord.send(:remove_const, 'Base')

        assert_nothing_raised do
          assert_nil BelongsToAnything::Matchers::active_record_matcher('xx')
        end

        ActiveRecord::const_set('Base', base)
      end

      should "return correct id when correct object specified" do
        record = TestModel1.create!

        assert_equal ["TestModel1", record.id], BelongsToAnything::Matchers::active_record_matcher(record)
      end

      should "raise ActiveRecordMatcherNewRecord when record is not saved" do
        record = TestModel1.new

        assert_raise BelongsToAnything::ActiveRecordMatcherNewRecord do
          BelongsToAnything::Matchers::active_record_matcher(record)
        end
      end

      context "new_record_for" do
        should "create that record" do
          rec = TestModel1.create!
          record = TestModelWithBTA.new_record_for(rec)
          assert record.new_record?
          assert_equal "TestModel1-#{rec.id}", record.name

          assert_nil TestModelWithBTA.record_for(rec)
        end
      end

      context "create_record_for" do
        should "create that record" do
          rec = TestModel1.create!
          record = TestModelWithBTA.create_record_for(rec)
          assert !record.new_record?
          assert_equal "TestModel1-#{rec.id}", record.name

          assert_equal record, TestModelWithBTA.record_for(rec)
        end
      end
    end

    context "string matcher" do
      should "return array containing single string" do
        assert_equal ['test'], BelongsToAnything::Matchers::string_matcher('test')
      end

      should "return nil when object is not string" do
        assert_nil BelongsToAnything::Matchers::string_matcher(Class)
      end
    end
  end

  context "MatcherManager" do
    should "raise error when there is no match" do
      assert_raise BelongsToAnything::ObjectDoesNotMatch do
        BelongsToAnything::MatcherManager::match(Object)
      end
    end
  end

  context "Adapters" do
    context "UniqueStringIdAdapter" do
      should "have parameter column" do
        class TestModel2 < ActiveRecord::Base
          belongs_to_anything :column => :page_id
          set_table_name :test_table2
        end

        assert_equal "XXX", TestModel2.create_record_for("XXX").page_id
      end
    end
  end
end
