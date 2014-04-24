require 'erb'
require 'securerandom'
require 'net/https'
require 'uri'
require 'json'

class OpenIDConnect
  class BaseError < StandardError; end
  class InvalidTokenError < BaseError; end
  class CancelError < BaseError; end
  class ExchangeError < BaseError; end
  class IdTokenError < BaseError; end

  def initialize(session, redirect_uri)
    @session      = session
    @redirect_uri = redirect_uri
  end

  def authentication_url(scope='', realm=nil)
    scope = [*(scope || '')].reject(&:blank?).map(&:to_s).join(' ')
    @session[:openid_state] = SecureRandom.urlsafe_base64
    p = ["state=#{@session[:openid_state]}",
         "redirect_uri=#{ERB::Util.u(@redirect_uri)}",
         "response_type=code",
         "client_id=#{ERB::Util.u(config['key'])}"]
    p << "scope=#{ERB::Util.u(scope)}" unless scope.empty?
    p << "openid.realm=#{ERB::Util.u(realm)}" unless realm.blank?
    "https://accounts.google.com/o/oauth2/auth?#{p.join('&')}"
  end

  def authentication_result(params)
    if !@session[:openid_state] || @session[:openid_state] != params[:state]
      raise InvalidTokenError
    elsif params[:error]
      raise CancelError
    end

    p = {
      code:          params[:code],
      client_id:     config['key'],
      client_secret: config['secret'],
      redirect_uri:  @redirect_uri,
      grant_type:    'authorization_code'
    }

    uri  = URI.parse('https://accounts.google.com/o/oauth2/token')
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.start do
      req = Net::HTTP::Post.new(uri.path)
      req.set_form_data(p)
      res = http.request(req)
      raise ExchangeError unless res.kind_of?(Net::HTTPSuccess)
      JSON.load(res.body)
    end
  end

  def parse_id_token(result)
    validator = GoogleIDToken::Validator.new
    payload = validator.check(result['id_token'], config['key'])
    raise IdTokenError unless payload
    raise IdTokenError unless payload['sub']
    payload
  end

  def retrieve_profile(result)
    uri  = URI.parse('https://www.googleapis.com/plus/v1/people/me/openIdConnect')
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.start do
      hdr = { 'Authorization' => "OAuth #{result['access_token']}" }
      res = http.get(uri.path, hdr)
      if res.kind_of?(Net::HTTPSuccess)
        JSON.load(res.body)
      else
        {}
      end
    end
  rescue
    {}
  end

  private

  @@config = nil
  def config
    unless @@config
      @@config = YAML.load_file(File.join(Rails.root, 'config/openid_config.yml'))
    end
    @@config
  end

end
