Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  scope '', format: 'json' do
    get '/api/lounge', to: 'lounge#get'
    post '/api/lounge', to: 'lounge#create'
    post '/api/lounge/member', to: 'lounge#create_member'
    get '/api/lounge/members', to: 'lounge#get_members'
    post '/api/lounge/members/fix', to: 'lounge#fix_members'
    post '/api/pref', to: 'lounge#register_preference'
    get '/api/result', to: 'lounge#match_result'
  end
end
