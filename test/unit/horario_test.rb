require 'test_helper'

class HorarioTest < ActiveSupport::TestCase
  test "Crear un nuevo horario'" do
    @horario=Horario.new
    assert  @horario.save
  end
end
