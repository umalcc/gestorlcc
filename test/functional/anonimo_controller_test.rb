require 'test_helper'
gem 'test-unit'
require 'test/unit'
class AnonimoControllerTest < ActionController::TestCase
  # Replace this with your real tests.
  #test "the truth" do
        #assert("test"=="test","SSS")
        #assert_response :success("true"=="true")
        expect(nil).to receive(:create)
  #end
end
