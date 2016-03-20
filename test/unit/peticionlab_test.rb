require 'test_helper'

class PeticionlabTest < ActiveSupport::TestCase
  test "Crear un nueva peticion de laboratorio" do
    @peticionlab=Peticionlab.new
    assert  @peticionlab.save
  end
end
