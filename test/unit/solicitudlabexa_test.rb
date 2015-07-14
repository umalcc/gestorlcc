require 'test_helper'

class SolicitudlabexaTest < ActiveSupport::TestCase
  test "Crear un nueva solicitud de laboratorio para examenes" do
    @solicitudlabexa=Solicitudlabexa.new
    assert  @solicitudlabexa.save
  end
end
