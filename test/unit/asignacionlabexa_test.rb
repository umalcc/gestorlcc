require 'test_helper'

class AsignacionlabexaTest < ActiveSupport::TestCase
  # Replace this with your real tests.
    test "Create a new 'asignacionlabexa'" do
    #assert true
    @asignacion=Asignacionlabexa.new
   
    assert  @asignacion.save
  end
end
