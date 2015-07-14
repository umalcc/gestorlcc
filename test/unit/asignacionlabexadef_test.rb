require 'test_helper'

class AsignacionlabexadefTest < ActiveSupport::TestCase
 test "Crear una nueva asignacion de laboratorio para exámenes definitivo'" do
    @asignacion=Asignacionlabexadef.new
   
    assert  @asignacion.save
  end
end
