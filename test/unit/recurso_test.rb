require 'test_helper'

class RecursoTest < ActiveSupport::TestCase
  test "Crear un nuevo recurso" do
    @recurso=Recurso.new
    assert  @recurso.save
  end
end
