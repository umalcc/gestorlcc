require 'test_helper'

class AsignaciondefTest < ActiveSupport::TestCase
  # Replace this with your real tests.
   test "Create a new 'asignacion definitiva'" do
    #assert true
    @asignacion=Asignaciondef.new
   
    assert  @asignacion.save
  end
end
