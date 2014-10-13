#
# Endpoint serializer returning only basic information.
#
class BasicEndpointSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :endpoint_type, :url

  def url
    atmosphere.descriptor_api_v1_endpoint_url(object.id)
  end
end