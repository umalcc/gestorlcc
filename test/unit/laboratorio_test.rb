require 'test_helper'

class LaboratorioTest < ActiveSupport::TestCase
  test "Crear un nuevo laboratorio" do
    @laboratorio=Laboratorio.new
    assert  @laboratorio.save
  end
end
