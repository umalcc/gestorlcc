require 'test_helper'

class SolicitudrecursoTest < ActiveSupport::TestCase
  test "Crear una solicitud de recurso" do
    @solicitudrecurso=Solicitudrecurso.new
    assert  @solicitudrecurso.save
  end
end
