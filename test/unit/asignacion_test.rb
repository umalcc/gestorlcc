require 'test_helper'

class AsignacionTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "Create a new asignacion" do
    #assert true
    @asignacion=Asignacion.new
   
    assert  @asignacion.save
  end
end
