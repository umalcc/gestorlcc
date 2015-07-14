require 'test_helper'

class TitulacionTest < ActiveSupport::TestCase
  test "Crear una nueva titulacion" do
    @titulacion=Titulacion.new
    assert  @titulacion.save
  end
end
