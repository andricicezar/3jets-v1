class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  before_filter :authenticate_user!
  def all
    auth = request.env["omniauth.auth"]
    # doar o modificare
    if auth.provider == "google_oauth2"
      auth.provider = "google"
    end

    # verificam daca exista deja un user logat
    # daca da, conectam contul cu a lui
    if user_signed_in?
      provider = auth.provider + "_uid"
      img = auth.provider + "_img"

      # daca deja este conectat contul, 
      # inseamna ca userul vrea sa-l deconecteze
      if current_user[ provider ] == auth.uid.to_s
        current_user[ provider ] = '0'
      else
        # conectam contul
        current_user[ provider ] = auth.uid.to_s

        # salvam imaginea
        if auth.info.image
          UserMeta.where(:user_id => current_user.id, :key => img).first_or_create do |meta|
            meta.value = auth.info.image
          end
        end

        # salvam adresa de email
        if current_user.email == "" && auth.info.email
          current_user["email"] = auth.info.email
        end
      end
      current_user.save
      if auth.provider == "facebook"
        UserMeta.where(:user_id => current_user.id, :key => "facebook_token").first_or_create do |meta|
          meta.value = auth["credentials"]["token"]
        end
      end


      if auth
        redirect_to edit_user_registration_url
        return
      end
    end
    user = User.from_omniauth(auth)
    if auth.provider == "facebook"
      UserMeta.where(:user_id => user.id, :key => "facebook_token").first_or_create do |meta|
        meta.value = auth["credentials"]["token"]
      end
    end

    if user.persisted?
      sign_in_and_redirect user
    else
      session["devise.user_attributes"] = user.attributes
      redirect_to new_user_registration_url
    end
  end

  alias_method :twitter, :all
  alias_method :facebook, :all
  alias_method :google_oauth2, :all
end
