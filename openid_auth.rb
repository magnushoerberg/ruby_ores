# An example for an OpenID consumer using Sinatra

require 'rubygems'
require 'sinatra/base'
gem 'ruby-openid', '>=2.1.2'
require 'openid'
require 'openid_dm_store'


class OpenIDAuth < Sinatra::Base
  
  def openid_consumer
	store = OpenIDDataMapper::DataMapperStore.new
	consumer = OpenID::Consumer.new(session, store)
    @openid_consumer ||= consumer 
  end

  def root_url
    request.url.match(/(^.*\/{2}[^\/]*)/)[1]
  end

  # In a real app, you might want to do something like this 
  
  enable :sessions 
 
  #Returns true if somebody is logged in  
   def logged_in?
     !session[:user].nil?
   end
  
  #Visit /logout to log out
   get '/logout' do
     session[:user] = nil
     redirect '/login'
   end

  # Send everything else to the super app
  not_found do
    if @app
      @app.call(env)
    end
  end
    
  get '/login' do    
    erb :login
  end

  post '/login/openid' do
    openid = params[:openid_identifier]
    begin
      oidreq = openid_consumer.begin(openid)
    rescue OpenID::DiscoveryFailure => why
      "Sorry, we couldn't find your identifier '#{openid}'"
    else
      # You could request additional information here - see specs:
      # http://openid.net/specs/openid-simple-registration-extension-1_0.html
      # oidreq.add_extension_arg('sreg','required','nickname')
      # oidreq.add_extension_arg('sreg','optional','fullname, email')
      
      # Send request - first parameter: Trusted Site,
      # second parameter: redirect target
      redirect oidreq.redirect_url(root_url, root_url + "/login/openid/complete")
    end
  end

  get '/login/openid/complete' do
    oidresp = openid_consumer.complete(params, request.url)

    case oidresp.status
      when OpenID::Consumer::FAILURE
        "Sorry, we could not authenticate you with the identifier '{openid}'."

      when OpenID::Consumer::SETUP_NEEDED
        "Immediate request failed - Setup Needed"

      when OpenID::Consumer::CANCEL
        "Login cancelled."

      when OpenID::Consumer::SUCCESS
        # Access additional informations:
        # puts params['openid.sreg.nickname']
        # puts params['openid.sreg.fullname']   
        
        # Startup something
        "Login successfull."  
        # Maybe something like
        session[:user] = User.find_by_openid(oidresp.display_identifier)
    end
  end
end

