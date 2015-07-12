class RedirectController < ActionController::Base
  def group_subdomain
    @resource = Group.find_by(subdomain: request.subdomain)
    redirect_to_resource_or_dashboard
  end

  def group_key
    @resource = Group.find_by_key!(params[:id])
    redirect_to_resource_or_dashboard
  end

  def discussion_key
    @resource = Discussion.find_by_key!(params[:id])
    redirect_to_resource_or_dashboard
  end

  def motion_key
    @resource = Motion.find_by_key!(params[:id])
    redirect_to_resource_or_dashboard
  end

  def group_id
    @resource = Group.where(id: params[:id]).where('id <  11500').first
    redirect_to_resource_or_dashboard
  end

  def discussion_id
    @resource = Discussion.where(id: params[:id]).where('id < 11500').first
    redirect_to_resource_or_dashboard
  end

  def motion_id
    @resource = Motion.where(id: params[:id]).where('id < 7300').first
    redirect_to_resource_or_dashboard
  end

  private
  def redirect_to_resource_or_dashboard
    if @resource
      redirect_to @resource, status: :moved_permanently
    else
      redirect_to dashboard_path
    end
  end
end
