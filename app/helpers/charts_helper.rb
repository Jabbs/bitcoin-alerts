module ChartsHelper

  def add_params_to_url(url, params)
    if url.present? and params.present?
      uri = URI(url)
      query_hash = Rack::Utils.parse_query(uri.query)
      query_hash.merge!(params)
      #uri.query = Rack::Utils.build_query(query_hash) #cannot use to nest_hash
      uri.query = query_hash.to_param
      uri.to_s
    end
  end
end
