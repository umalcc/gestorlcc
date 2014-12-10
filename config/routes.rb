Gestorlcc::Application.routes.draw do

  #map.resources :asignacions

  resources :periodos,:peticionlabs,:solicitudlabs, :solicitudlabexas

  resources :dias, :horarios, :horasexas, :peticions, :solicitudrecursos

  resources :titulacions,:recursos, :laboratorios, :asignaturas,:usuarios
  resource :solicitar, :session, :inicio, :userinicio, :dato, :solicitudrecurso
  resources :solicitudrecursousuarios, :solicitudusuariolabs,:solicitudusuariolabexas

  #cambiar 'usuarios/:id/cambiar', :to => 'usuarios#cambiar'
  match 'usuarios/:id/cambiar', :to => 'usuarios#cambiar' 
  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller
  
  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
root :to => 'sessions#index'

match 'anonimo/new', :to=>'anonimo#new'
match 'anonimo/general', :to=>'anonimo#general'
match 'anonimo/labgeneral', :to=>'anonimo#labgeneral'
match 'estadisticas/periodo_lectivo', :to=>'estadisticas#periodo_lectivo'
match 'estadisticas/periodo_examenes', :to=>'estadisticas#periodo_examenes'
match 'estadisticas/estadisticas_lectivo', :to=>'estadisticas#estadisticas_lectivo'
match 'estadisticas/estadisticas_examenes', :to=>'estadisticas#estadisticas_examenes'
match 'estadisticas/borrar_historico_lectivo', :to=>'estadisticas#borrar_historico_lectivo'
match 'estadisticas/borrar_historico_examenes', :to=>'estadisticas#borrar_historico_examenes'
match 'periodos/cambia_admision', :to=>'periodos#cambia_admision'
match 'periodos/cambia_activo', :to=>'periodos#cambia_activo'
match 'periodos/enviar_correo_lectivo_on', :to=>'periodos#enviar_correo_lectivo_on'
match 'periodos/enviar_correo_activo_off', :to=>'periodos#enviar_correo_activo_off'
match 'periodos/enviar_correo_activo_on', :to=>'periodos#enviar_correo_activo_on'
match 'periodos/enviar_correo_lectivo_off', :to=>'periodos#enviar_correo_lectivo_off'
match 'periodos/grabar_historico', :to=>'periodos#grabar_historico'
match 'periodos/grabar_historico_examen', :to=>'periodos#grabar_historico_examen'
match 'solicitar/anadir', :to=>'solicitar#anadir'
match 'solicitar/eliminar', :to=>'solicitar#eliminar'
match 'asignaturas/combo_por_titulacion', :to => 'asignaturas#combo_por_titulacion'
match 'asignaturas/combo_por_descripcion', :to => 'recursos#combo_por_descripcion'
match 'asignaturas/combo_por_nivel', :to => 'asignaturas#combo_por_nivel'
match 'usuarios/listar', :to => 'usuarios#listar'
match 'asignaturas/listar', :to => 'asignaturas#listar'
match 'recursos/listar', :to => 'recursos#listar'
match 'solicitudlabs/listar', :to => 'solicitudlabs#listar'
match 'solicitudlabexas/listar', :to => 'solicitudlabexas#listar'
match 'solicitudusuariolabexas/listar', :to => 'solicitudusuariolabexas#listar'
match 'solicitudrecursos/listar', :to => 'solicitudrecursos#listar'
match 'solicitudrecursos/borrar_reservas', :to => 'solicitudrecursos#borrar_reservas'
match 'solicitudrecursousuarios/listar', :to => 'solicitudrecursousuarios#listar'
match 'solicitudrecursousuarios/buscar', :to => 'solicitudrecursousuarios#buscar'
match 'solicitudusuariolabs/listar', :to => 'solicitudusuariolabs#listar'
match 'solicitudusuariolabs/crear', :to => 'solicitudusuariolabs#create'
match 'solicitudusuariolabs/update', :to => 'solicitudusuariolabs#update'

match 'solicitudrecursos/buscar', :to => 'solicitudrecursos#buscar'
match 'solicitudrecursos/crear', :to => 'solicitudrecursos#create'
match 'solicitudrecursos/borra', :to => 'solicitudrecursos#borra'
match 'solicitudrecursousuarios/borra', :to => 'solicitudrecursousuarios#borra'
match 'solicitudrecursousuarios/crear', :to => 'solicitudrecursousuarios#create'

match 'solicitar/eliminar', :to => 'solicitar#eliminar'

match 'asignacions/mover', :to => 'asignacions#mover'
match 'asignacions/revisar', :to => 'asignacions#revisar'
match 'asignacions/asignar', :to => 'asignacions#asignar'
match 'asignacions/asignar_iniciar', :to => 'asignacions#asignar_iniciar'
match 'asignacions/asignar_continuar', :to => 'asignacions#asignar_continuar'
match 'asignacions/grabar_parcial', :to => 'asignacions#grabar_parcial'
match 'asignacions/grabar_asignacion', :to => 'asignacions#grabar_asignacion'
match 'asignacions/index', :to => 'asignacions#index'
match 'asignacions/consulta', :to => 'asignacions#consulta'
match 'asignacions/asigna_directa', :to => 'asignacions#asigna_directa'
match 'asignacions/graba', :to => 'asignacions#graba'
match 'asignacions/borradir', :to => 'asignacions#borradir'
match 'asignacions/borradirasignada', :to => 'asignacions#borradirasignada'
match 'asignacions/borranormal', :to => 'asignacions#borranormal'
match 'asignacions/borranormalasignada', :to => 'asignacions#borranormalasignada'
match 'listado/asignacion_lectivo_impresa', :to => 'listado#asignacion_lectivo_impresa'
match 'listado/asignacion_examenes_impresa', :to => 'listado#asignacion_examenes_impresa'
match 'listado/asignacion_lectivo_usuario_impresa', :to => 'listado#asignacion_lectivo_usuario_impresa'
match 'listado/asignacion_examenes_usuario_impresa', :to => 'listado#asignacion_examenes_usuario_impresa'

match 'consultasasig/asignar', :to => 'consultasasig#asignar'
match 'consultasasig/porusuario', :to => 'consultasasig#porusuario'
match 'consultasasig/general', :to => 'consultasasig#general'
match 'consultasasig/labgeneral', :to => 'consultasasig#labgeneral'
match 'consultasasig/labporusuario', :to => 'consultasasig#labporusuario'
match 'consultasasig/listar', :to => 'consultasasig#listar'

match 'asignacionexas/mover', :to => 'asignacionexas#mover'
match 'asignacionexas/revisar', :to => 'asignacionexas#revisar'
match 'asignacionexas/asignar', :to => 'asignacionexas#asignar'
match 'asignacionexas/asignar_iniciar', :to => 'asignacionexas#asignar_iniciar'
match 'asignacionexas/asignar_continuar', :to => 'asignacionexas#asignar_continuar'
match 'asignacionexas/grabar_parcial', :to => 'asignacionexas#grabar_parcial'
match 'asignacionexas/grabar_asignacion', :to => 'asignacionexas#grabar_asignacion'
match 'asignacionexas/index', :to => 'asignacionexas#index'
match 'asignacionexas/consulta', :to => 'asignacionexas#consulta'
match 'asignacionexas/asigna_directa', :to => 'asignacionexas#asigna_directa'
match 'asignacionexas/graba', :to => 'asignacionexas#graba'
match 'asignacionexas/borradir', :to => 'asignacionexas#borradir'
match 'asignacionexas/borradirasignada', :to => 'asignacionexas#borradirasignada'
match 'asignacionexas/borranormal', :to => 'asignacionexas#borranormal'
match 'asignacionexas/borranormalasignada', :to => 'asignacionexas#borranormalasignada'
match 'asignacionexas/listar', :to => 'asignacionexas#listar'
match 'consultasasigexa/asignar', :to => 'consultasasigexa#asignar'
match 'consultasasigexa/porusuario', :to => 'consultasasigexa#porusuario'
match 'consultasasigexa/general', :to => 'consultasasigexa#general'


  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing the them or commenting them out if you're using named routes and resources.

 # match ':controller/:action/:id'
 # match ':controller/:action/:id.:format'


  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => "welcome#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
