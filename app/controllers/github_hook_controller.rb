require 'json'

class GithubHookController < ApplicationController
  
  skip_before_filter :verify_authenticity_token, :check_if_login_required

  def index
    
    payload = JSON.parse(params[:payload])
    logger.debug { "Received from Github: #{payload.inspect}" }
    
    Repository.all.each do |repository|
      if repository.is_a?(Repository::Git)
        puts repository.url
        command = "cd '#{repository.url}' && git fetch origin && git reset --soft refs/remotes/origin/master"
        exec(command)
      end
    end
    
    # Fetch the new changesets into Redmine
    repository.fetch_changesets

    render(:text => 'OK')
  end

  private
  
  def exec(command)
    logger.info { "GithubHook: Executing command: '#{command}'" }
    output = `#{command}`
    logger.info { "GithubHook: Shell returned '#{output}'" }
  end

end
