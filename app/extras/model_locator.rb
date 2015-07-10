ModelLocator = Struct.new(:model, :params) do

  def locate
    if id_param = params[:"#{model}_id"]
      resource_class.find id_param
    elsif key_param = params[:"#{model}_key"]
      resource_class.find_by_key key_param
    elsif resource_class.respond_to? :friendly
      resource_class.friendly.find params[:id]
    else
      resource_class.find params[:id]
    end
  end

  private

  def resource_class
    @resource_class ||= model.to_s.camelize.constantize
  end
end
