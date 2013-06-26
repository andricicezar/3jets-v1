class RegistrationsController < Devise::RegistrationsController

  def new
    if cookies[:nr_afisari]
      cookies[:nr_afisari] = cookies[:nr_afisari].to_i + 1
    else
      cookies[:nr_afisari] = {:value => 1, :expires => 1.hour.from_now }
    end

    if cookies[:nr_afisari].to_i > 7
      redirect_to "http://google.com"
      return
    end
    build_resource({})
    respond_with self.resource
  end

  def destroy
    resource.soft_delete
    Devise.sign_out_all_scopes ? sign_out(resource_name) : sign_out(resource_name)
    set_flash_message :notice, :destroyed if is_navigational_format?
    respond_with_navigational(resource) {
      redirect_to after_sign_out_path_for(resource_name)
    }
  end
end
