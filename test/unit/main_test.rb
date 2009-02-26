require File.join(File.dirname(__FILE__), *%w[.. test_helper])

class MainTest < Test::Unit::TestCase
  include Drunit
  RemoteApp(:fake_app, FAKE_APP_PATH + "/fake_app.rb")
  def InApp(*args, &block)
    in_app(:fake_app, *args, &block)
  end

  def test_should_not_raise_in_a_basic_case
    InApp do
      assert true
    end
  end

  def test_should_raise_an_exception
    assert_raise(RuntimeError) { InApp{ raise "Fail" } }
  end

  def test_should_raise_an_exception_faking_its_class_name_if_we_have_never_heard_of_it
    InApp{ raise SomeException, "Fooo" }
    flunk "Should have raised."
  rescue => e
    assert_equal "SomeException", e.class.name
  end

  def test_should_inject_the_fact_we_are_in_a_remote_app_into_the_backtrace
    e = assert_raise(RuntimeError) { InApp{ raise "Fail" } }
    assert_equal 1, e.backtrace.grep("RemoteApp<fake_app>").size
  end

  def test_should_raise_the_assertion_count_when_we_assert
    original_count = @_result.assertion_count
    InApp{ assert true}
    assert_equal original_count + 1, @_result.assertion_count
  end

  def test_should_be_able_to_pass_in_simple_params
    assert_equal 12, InApp(2,6){|a,b| SomeFoo.new.multiply(a, b)}
  end
end