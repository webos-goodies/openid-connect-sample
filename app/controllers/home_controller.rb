class HomeController < ApplicationController

  def index
    config = YAML.load_file(File.join(Rails.root, 'config/openid_config.yml'))
    if config['key'] == 'Client ID' || config['secret'] == 'Client secret'
      render :howto
    end
  end

end
