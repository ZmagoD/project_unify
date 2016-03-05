class Api::V1::SessionsController < Devise::SessionsController
  skip_before_filter :verify_authenticity_token

  include SessionsDoc
  clear_respond_to
  respond_to :json

  def create
    self.resource = warden.authenticate!(auth_options)
    sign_in(resource_name, resource)
    yield resource if block_given?
    @resource = resource
    render '/api/v1/users/success'
  end

  def destroy
    resource_class = ActiveRecord::Base::User
    self.resource = resource_class.find_by_authentication_token(request.headers['X-USER-TOKEN'])
    if resource
      resource.reset_authentication_token
      render json: { message: 'Session deleted' }, status: 200
    else
      render json: { error: 'Invalid token' }, status: 401
    end
  end
end