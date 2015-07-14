require 'test_helper'

class PeticionTest < ActiveSupport::TestCase
 test "Crear una nueva peticion" do
    @peticion=Peticion.new
    assert  @peticion.save
  end
end
