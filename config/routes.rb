Gestorlcc::Application.routes.draw do

  #map.resources :asignacions

  resources :periodos,:peticionlabs,:solicitudlabs, :solicitudlabexas

  resources :dias, :horarios, :horasexas, :peticions, :solicitudrecursos

  resources :titulacions,:recursos, :laboratorios, :asignaturas,:usuarios
  resource :solicitar, :session, :inicio, :userinicio, :dato, :solicitudrecurso
  resources :solicitudrecursousuarios, :solicitudusuariolabs,:solicitudusuariolabexas

  #cambiar 'usuarios/:id/cambiar', :to => 'usuarios#cambiar'
  get 'usuarios/:id/cambiar', :to => 'usuarios#cambiar' 
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

get 'anonimo/new', :to=>'anonimo#new'
get 'anonimo/general', :to=>'anonimo#general'
get 'anonimo/labgeneral', :to=>'anonimo#labgeneral'
get 'estadisticas/periodo_lectivo', :to=>'estadisticas#periodo_lectivo'
get 'estadisticas/periodo_examenes', :to=>'estadisticas#periodo_examenes'
post 'estadisticas/estadisticas_lectivo', :to=>'estadisticas#estadisticas_lectivo'
post 'estadisticas/estadisticas_examenes', :to=>'estadisticas#estadisticas_examenes'
post 'estadisticas/borrar_historico_lectivo', :to=>'estadisticas#borrar_historico_lectivo'
post 'estadisticas/borrar_historico_examenes', :to=>'estadisticas#borrar_historico_examenes'
post 'periodos/cambia_admision', :to=>'periodos#cambia_admision'
post 'periodos/cambia_activo', :to=>'periodos#cambia_activo'
post 'periodos/enviar_correo_lectivo_on', :to=>'periodos#enviar_correo_lectivo_on'
post 'periodos/enviar_correo_activo_off', :to=>'periodos#enviar_correo_activo_off'
post 'periodos/enviar_correo_activo_on', :to=>'periodos#enviar_correo_activo_on'
post 'periodos/enviar_correo_lectivo_off', :to=>'periodos#enviar_correo_lectivo_off'
post 'periodos/grabar_historico', :to=>'periodos#grabar_historico'
post 'periodos/grabar_historico_examen', :to=>'periodos#grabar_historico_examen'
post 'solicitar/anadir', :to=>'solicitar#anadir'
get 'solicitar/eliminar', :to=>'solicitar#eliminar'
post 'asignaturas/combo_por_titulacion', :to => 'asignaturas#combo_por_titulacion'
post 'asignaturas/combo_por_descripcion', :to => 'recursos#combo_por_descripcion'
post 'asignaturas/combo_por_nivel', :to => 'asignaturas#combo_por_nivel'
post 'usuarios/listar', :to => 'usuarios#listar'
post 'asignaturas/listar', :to => 'asignaturas#listar'
post 'recursos/listar', :to => 'recursos#listar'
post 'solicitudlabs/listar', :to => 'solicitudlabs#listar'
post 'solicitudlabexas/listar', :to => 'solicitudlabexas#listar'
post 'solicitudusuariolabexas/listar', :to => 'solicitudusuariolabexas#listar'
post 'solicitudrecursos/listar', :to => 'solicitudrecursos#listar'
post 'solicitudrecursos/borrar_reservas', :to => 'solicitudrecursos#borrar_reservas'
post 'solicitudrecursousuarios/listar', :to => 'solicitudrecursousuarios#listar'
post 'solicitudrecursousuarios/buscar', :to => 'solicitudrecursousuarios#buscar'
post 'solicitudusuariolabs/listar', :to => 'solicitudusuariolabs#listar'
post 'solicitudusuariolabs/crear', :to => 'solicitudusuariolabs#create'
post 'solicitudusuariolabs/update', :to => 'solicitudusuariolabs#update'

post 'solicitudrecursos/buscar', :to => 'solicitudrecursos#buscar'
post 'solicitudrecursos/crear', :to => 'solicitudrecursos#create'
post 'solicitudrecursos/borra', :to => 'solicitudrecursos#borra'
post 'solicitudrecursousuarios/borra', :to => 'solicitudrecursousuarios#borra'
post 'solicitudrecursousuarios/crear', :to => 'solicitudrecursousuarios#create'

post 'solicitar/eliminar', :to => 'solicitar#eliminar'

post 'asignacions/mover', :to => 'asignacions#mover'
get 'asignacions/revisar', :to => 'asignacions#revisar'
get 'asignacions/asignar', :to => 'asignacions#asignar'
get 'asignacions/asignar_iniciar', :to => 'asignacions#asignar_iniciar'
get 'asignacions/asignar_continuar', :to => 'asignacions#asignar_continuar'
get 'asignacions/grabar_asignacion', :to => 'asignacions#grabar_asignacion'
get 'asignacions/consulta', :to => 'asignacions#consulta'
get 'asignacions/asigna_directa', :to => 'asignacions#asigna_directa'
post 'asignacions/graba', :to => 'asignacions#graba'
post 'asignacions/borradir', :to => 'asignacions#borradir'
post 'asignacions/borradirasignada', :to => 'asignacions#borradirasignada'
post 'asignacions/borranormal', :to => 'asignacions#borranormal'
post 'asignacions/borranormalasignada', :to => 'asignacions#borranormalasignada'
get 'listado/asignacion_lectivo_impresa', :to => 'listado#asignacion_lectivo_impresa'
get 'listado/asignacion_examenes_impresa', :to => 'listado#asignacion_examenes_impresa'
get 'listado/asignacion_lectivo_usuario_impresa', :to => 'listado#asignacion_lectivo_usuario_impresa'
get 'listado/asignacion_examenes_usuario_impresa', :to => 'listado#asignacion_examenes_usuario_impresa'

get 'consultasasig/porusuario', :to => 'consultasasig#porusuario'
get 'consultasasig/general', :to => 'consultasasig#general'
get 'consultasasig/labgeneral', :to => 'consultasasig#labgeneral'
get 'consultasasig/labporusuario', :to => 'consultasasig#labporusuario'
post 'consultasasig/listar', :to => 'consultasasig#listar'

post 'asignacionexas/mover', :to => 'asignacionexas#mover'
get 'asignacionexas/revisar', :to => 'asignacionexas#revisar'
get 'asignacionexas/asignar', :to => 'asignacionexas#asignar'
get 'asignacionexas/asignar_iniciar', :to => 'asignacionexas#asignar_iniciar'
get 'asignacionexas/asignar_continuar', :to => 'asignacionexas#asignar_continuar'
get 'asignacionexas/grabar_asignacion', :to => 'asignacionexas#grabar_asignacion'
get 'asignacionexas/consulta', :to => 'asignacionexas#consulta'
get 'asignacionexas/asigna_directa', :to => 'asignacionexas#asigna_directa'
post 'asignacionexas/graba', :to => 'asignacionexas#graba'
post 'asignacionexas/borradir', :to => 'asignacionexas#borradir'
post 'asignacionexas/borradirasignada', :to => 'asignacionexas#borradirasignada'
post 'asignacionexas/borranormal', :to => 'asignacionexas#borranormal'
post 'asignacionexas/borranormalasignada', :to => 'asignacionexas#borranormalasignada'
post 'asignacionexas/listar', :to => 'asignacionexas#listar'
delete 'sessions/destroy', :to => 'sessions#destroy'


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
