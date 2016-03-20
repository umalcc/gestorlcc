require 'test_helper'

class SolicitudlabTest < ActiveSupport::TestCase
  test "Crear un nueva solicitud de laboratorio" do
    @solicitudlab=Solicitudlab.new
    assert  @solicitudlab.save
  end
end
