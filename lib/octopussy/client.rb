require 'cgi'
module Octopussy
  class Client
    include HTTParty
    format :json
    base_uri "http://github.com/api/v2/json"
    
    attr_reader :login, :token
    
    # :login => 'pengwynn', :token => 'your_github_api_key'
    def initialize(auth={})
      @login = auth[:login]
      @token = auth[:token]
    end
    
    def search_users(q)
      q = CGI.escape(q)
      response = self.class.get("/user/search/#{q}")
      handle_response(response)
      Hashie::Mash.new(response).users
    end
    
    def user(login=self.login)
      response = self.class.get("/user/show/#{login}", :query => auth_params)
      handle_response(response)
      Hashie::Mash.new(response).user
    end
    

    def update_user(values={})
      response = self.class.post("/user/show/#{self.login}", :query => auth_params, :body => {:values => values})
      handle_response(response)
      Hashie::Mash.new(response).user
    end
    
    def followers(login=self.login)
      response = self.class.get("/user/show/#{login}/followers")
      handle_response(response)
      Hashie::Mash.new(response).users
    end
    
    def following(login=self.login)
      response = self.class.get("/user/show/#{login}/following")
      handle_response(response)
      Hashie::Mash.new(response).users
    end
    
    def follow!(username)
      response = self.class.post("/user/follow/#{username}")
      handle_response(response)
      Hashie::Mash.new(response).users
    end
    
    def unfollow!(username)
      response = self.class.post("/user/unfollow/#{username}")
      handle_response(response)
      Hashie::Mash.new(response).users
    end
    
    def watched(login=self.login)
      response = self.class.get("/repos/watched/#{login}")
      handle_response(response)
      Hashie::Mash.new(response).repositories
    end
    
    def emails
      response = self.class.get("/user/emails", :query => auth_params)
      handle_response(response)
      Hashie::Mash.new(response).emails
    end
    
    def add_email(email)
      response = self.class.post("/user/email/add", :query => auth_params, :body => {:email => email})
      handle_response(response)
      Hashie::Mash.new(response).emails
    end
    
    def remove_email(email)
      response = self.class.post("/user/email/remove", :query => auth_params, :body => {:email => email})
      handle_response(response)
      Hashie::Mash.new(response).emails
    end
    
    def keys
      response = self.class.get("/user/keys", :query => auth_params)
      handle_response(response)
      Hashie::Mash.new(response).public_keys
    end
    
    def add_key(title, key)
      response = self.class.post("/user/key/add", :query => auth_params, :body => {:title => title, :key => key})
      handle_response(response)
      Hashie::Mash.new(response).public_keys
    end
    
    def remove_key(id)
      response = self.class.post("/user/key/remove", :query => auth_params, :body => {:id => id})
      handle_response(response)
      Hashie::Mash.new(response).public_keys
    end

    # Issues
    
    # :username, :repo, :state, :q
    def search_issues(options)
      response = self.class.get("/issues/search/#{options[:username]}/#{options[:repo]}/#{options[:state]}/#{options[:q]}")
      handle_response(response)
      Hashie::Mash.new(response).issues
    end
    
    # :username, :repo, :state
    def issues(options)
      response = self.class.get("/issues/list/#{options[:username]}/#{options[:repo]}/#{options[:state]}")
      handle_response(response)
      Hashie::Mash.new(response).issues
    end
    
    # :issue, :repo, :id
    def issue(options)
      response = self.class.get("/issues/show/#{options[:username]}/#{options[:repo]}/#{options[:id]}")
      handle_response(response)
      Hashie::Mash.new(response).issue
    end
    
    # :username, :repo, :title, :body
    def open_issue(options)
      username = options.delete(:username)
      repo = options.delete(:repo)
      response = self.class.post("/issues/open/#{username}/#{repo}", :body => options)
      handle_response(response)
      Hashie::Mash.new(response).issue
    end
    
    # :username, :repo, :number
    def close_issue(options)
      response = self.class.post("/issues/close/#{options[:username]}/#{options[:repo]}/#{options[:number]}")
      handle_response(response)
      Hashie::Mash.new(response).issue
    end
    
    # :username, :repo, :number
    def reopen_issue(options)
      response = self.class.post("/issues/reopen/#{options[:username]}/#{options[:repo]}/#{options[:number]}")
      handle_response(response)
      Hashie::Mash.new(response).issue
    end
    
    # :username, :repo, :title, :body
    def update_issue(options)
      username, repo, number = options.delete(:username), options.delete(:repo), options.delete(:number)
      response = self.class.post("/issues/edit/#{username}/#{repo}/#{number}", :body => options)
      handle_response(response)
      Hashie::Mash.new(response).issue
    end
    
    # :username, :repo
    def labels(options)
      response = self.class.get("/issues/labels/#{options[:username]}/#{options[:repo]}")
      handle_response(response)
      Hashie::Mash.new(response).labels
    end
    
    # :username, :repo, :number, :label
    def add_label(options)
      response = self.class.post("/issues/label/add/#{options[:username]}/#{options[:repo]}/#{options[:label]}/#{options[:number]}")
      handle_response(response)
      Hashie::Mash.new(response).labels
    end
    
    # :username, :repo, :number, :label
    def remove_label(options)
      response = self.class.post("/issues/label/remove/#{options[:username]}/#{options[:repo]}/#{options[:label]}/#{options[:number]}")
      handle_response(response)
      Hashie::Mash.new(response).labels
    end

    # :username, :repo, :number, :comment
    def add_comment(options)
      response = self.class.post("/issues/comment/#{options[:username]}/#{options[:repo]}/#{options[:number]}", :body => {:comment => options[:comment]})
      handle_response(response)
      Hashie::Mash.new(response).comment
    end
    
    # Repos
    
    def search_repos(q)
      q = CGI.escape(q)
      response = self.class.get("/repos/search/#{q}")
      handle_response(response)
      Hashie::Mash.new(response).repositories
    end
    
    def watch(username, repo)
      response = self.class.post("/repos/watch/#{username}/#{repo}", :query => auth_params)
      handle_response(response)
      Hashie::Mash.new(response).repository
    end
    
    def unwatch(username, repo)
      response = self.class.post("/repos/unwatch/#{username}/#{repo}", :query => auth_params)
      handle_response(response)
      Hashie::Mash.new(response).repository
    end
    
    def fork(username, repo)
      response = self.class.post("/repos/fork/#{username}/#{repo}", :query => auth_params)
      handle_response(response)
      Hashie::Mash.new(response).repository
    end
    
    # :name, :description, :homepage, :public
    def create(options)
      response = self.class.post("/repos/create", :query => auth_params, :body => options)
      handle_response(response)
      Hashie::Mash.new(response).repository
    end
    
    def delete(name, delete_token={})
      response = self.class.post("/repos/delete/#{name}", :query => auth_params, :body => {:delete_token => delete_token})
      handle_response(response)
      Hashie::Mash.new(response).repository
    end
    
    def confirm_delete(name, delete_token)
      delete(name, delete_token)
    end
    
    def set_private(name)
      response = self.class.post("/repos/set/private/#{name}", :query => auth_params)
      handle_response(response)
      Hashie::Mash.new(response).repository
    end
    
    def set_public(name)
      response = self.class.post("/repos/set/public/#{name}", :query => auth_params)
      handle_response(response)
      Hashie::Mash.new(response).repository
    end
    
    def deploy_keys(name)
      response = self.class.get("/repos/keys/#{name}", :query => auth_params)
      handle_response(response)
      Hashie::Mash.new(response).public_keys
    end
    
    def add_deploy_key(title, key, repo_name)
      response = self.class.post("/repos/key/#{repo_name}/add", :query => auth_params, :body => {:title => title, :key => key})
      handle_response(response)
      Hashie::Mash.new(response).public_keys
    end
    
    def remove_deploy_key(id, repo_name)
      response = self.class.post("/repos/key/#{repo_name}/remove", :query => auth_params, :body => {:id => id})
      handle_response(response)
      Hashie::Mash.new(response).public_keys
    end
    
    def collaborators(options)
      username = options[:username]
      repo = options[:repo]
      response = self.class.post("/repos/show/#{username}/#{repo}/collaborators", :query => auth_params)
      handle_response(response)
      Hashie::Mash.new(response).collaborators
    end
    
    
    # :username, :repo
    def repo(options)
      response = self.class.get("/repos/show/#{options[:username]}/#{options[:repo]}")
      handle_response(response)
      Hashie::Mash.new(response).repository
    end
    
    def list_repos(username)
      response = self.class.get("/repos/show/#{username}")
      handle_response(response)
      Hashie::Mash.new(response).repositories
    end
    
    def add_collaborator(options)
      collaborator = options[:collaborator]
      repo = options[:repo]
      response = self.class.post("/repos/collaborators/#{repo}/add/#{collaborator}", :query => auth_params)
      handle_response(response)
      Hashie::Mash.new(response).collaborators
    end
    
    def remove_collaborator(options)
      collaborator = options[:collaborator]
      repo = options[:repo]
      response = self.class.post("/repos/collaborators/#{repo}/remove/#{collaborator}", :query => auth_params)
      handle_response(response)
      Hashie::Mash.new(response).collaborators
    end
    
    def network(options)
      username = options[:username]
      repo = options[:repo]
      response = self.class.get("/repos/show/#{username}/#{repo}/network")
      handle_response(response)
      Hashie::Mash.new(response).network
    end
    
    def languages(options)
      username = options[:username]
      repo = options[:repo]
      response = self.class.get("/repos/show/#{username}/#{repo}/languages")
      handle_response(response)
      Hashie::Mash.new(response).languages
    end
    
    def tags(options)
      username = options[:username]
      repo = options[:repo]
      response = self.class.get("/repos/show/#{username}/#{repo}/tags")
      handle_response(response)
      Hashie::Mash.new(response).tags
    end
    
    def branches(options)
      username = options[:username]
      repo = options[:repo]
      response = self.class.get("/repos/show/#{username}/#{repo}/branches")
      handle_response(response)
      Hashie::Mash.new(response).branches
    end
    
    # Network
    
    def network_meta(options)
      username = options.delete(:username)
      repo = options.delete(:repo)
      response = self.class.get("http://github.com/#{username}/#{repo}/network_meta")
      handle_response(response)
      Hashie::Mash.new(response)
    end
    
    def network_data(options)
      username = options.delete(:username)
      repo = options.delete(:repo)
      nethash = options[:nethash]
      response = self.class.get("http://github.com/#{username}/#{repo}/network_data_chunk", :query => {:nethash => nethash})
      handle_response(response)
      Hashie::Mash.new(response).commits
    end
    
    private
    
      def auth_params
        @login.nil? ? {} : {:login => @login, :token => @token}
      end
    
      def handle_response(response)
        case response.code
        when 403
          raise RateLimitExceeded.new
        when 401
          raise Unauthorized.new
        when 404
          raise NotFound.new
        end
      end
    
  end
end