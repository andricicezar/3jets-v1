class RegistrationsController < Devise::RegistrationsController

  def guest
    return redirect_to home_url if current_user
    session.delete(:guest_user_id)
    render "devise/registrations/guest"
  end

  def create_guest_user
    expired_guests = User.where("is_guest=true AND last_sign_in_at < (now() - interval '5 minutes')")
    Game.where("(fst_user in (?) or scd_user in (?)) and finished=false", expired_guests, expired_guests).delete_all
    Notification.where("user_id in (?) or friend_id in (?)", expired_guests, expired_guests).delete_all
    Relation.where("user_id in (?) or friend_id in (?)", expired_guests, expired_guests).delete_all
    expired_guests.delete_all
    return redirect_to login_like_guest_url, :notice => "This nickname is already taken!" if User.where(:nickname => params[:user][:nickname]).count > 0
    return redirect_to login_like_guest_url if params[:user][:nickname].length < 5 || params[:user][:nickname].length > 20
    u = User.create(:nickname => params[:user][:nickname], 
                    :is_guest => true,
                    :last_sign_in_at => Time.now)
    u.save(:validate => false)
    session[:guest_user_id] = u.id
    redirect_to home_url
  end

  def new
    if cookies[:nr_afisari]
      cookies[:nr_afisari] = cookies[:nr_afisari].to_i + 1
    else
      cookies[:nr_afisari] = {:value => 1, :expires => 1.hour.from_now }
    end

#    if cookies[:nr_afisari].to_i > 7
 #     redirect_to "http://google.com"
  #    return
  #  end
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
