require 'test_helper'

class AsignaturaTest < ActiveSupport::TestCase
 test "Crear una nueva asignatura'" do
    @asignatura=Asignatura.new
   
    assert  @asignatura.save
  end
end
