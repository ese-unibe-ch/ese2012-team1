include Models
include Helpers

##
#
# This controller handles search requests
#
##
module Controllers
  class Search < Sinatra::Application

      set :views, "#{absolute_path('../views', __FILE__)}"

      before do
        before_for_user_authenticated
      end

      ##
      #
      # Searches for a specific pattern in the item-, user- and organisationnames
      #
      # Exprected:
      # params[:pattern] : the part that will be searched in the names
      #
      ##
      get "/search.?" do

        results = System.instance.search.find(params[:pattern])

        haml :search, :locals => { :results => results, :pattern => params[:pattern], :script => 'search_result.js' }
      end
  end
end