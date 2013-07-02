class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  before_filter :authenticate_user!
  def all
    auth = request.env["omniauth.auth"]
    if user_signed_in?

      aux = auth.provider + "_uid"
      aux2 = auth.provider + "_img"
      if current_user[aux] == auth.uid.to_s
        current_user[aux] = '0'
      else
        current_user[aux] = auth.uid.to_s
        if auth.info.image
          UserMeta.where(:user_id => current_user.id, :key => aux2).first_or_create do |meta|
            meta.value = auth.info.image
          end
        end
      end
      current_user.save

      if auth
        redirect_to edit_user_registration_url
        return
      end
    end
    user = User.from_omniauth(auth)
    if user.persisted?
      sign_in_and_redirect user
    else
      session["devise.user_attributes"] = user.attributes
      redirect_to new_user_registration_url
    end
  end

  alias_method :twitter, :all
  alias_method :facebook, :all
  alias_method :google, :all
end
