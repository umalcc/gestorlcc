require 'test_helper'

class UsuarioTest < ActiveSupport::TestCase
  test "Crear un nuevo usuario" do
    @usuario=Usuario.new
    assert  @usuario.save
  end
end
