class OauthAuthorizationsController < ApplicationController

  skip_before_filter :require_login, :except => :destroy
  layout "oauth"
  include OmniAuthHelpers

  def create
    omniauth_params = extract_user_attributes(request.env['omniauth.auth'])
    auth = Authorization.find_from_omniauth_hash(omniauth_params)

    if current_user                                             # User session exists and a user could associate his omniauth account to his profile.
      if auth
        flash[:error] = "The #{omniauth_params[:provider]} account you chose to associate has already been used by a different user."
      else
        flash[:notice] = "Successfully added #{omniauth_params[:provider]} authentication."
        current_user.new_omniauth_authorizer(omniauth_params)
      end
      redirect_to edit_user_profile_path(current_user) and return
    end

    if auth and auth.user.verified?
      if session[:omniauth_params]                                                            # Yup, its a verified user
        if auth.user.omniauth_provider_exists?(session[:omniauth_params][:provider])
          flash[:error] = "You have already used a #{session[:omniauth_params][:provider]} account to authorize yourself."
        else
          auth.user.new_omniauth_authorizer(session[:omniauth_params])
        end
      end
      UserSession.create!(auth.user, true)
      flash[:notice] = "Welcome #{auth.user.user_name}"
      redirect_to user_path(auth.user)

    elsif auth and not(auth.user.verified?)
      flash[:error] =
        if session[:omniauth_params]
          "The account you to chose to associate with has not been verified, please verify to continue."
        else
          "The account you to chose to login has not been verified, please verify to continue."
        end
      redirect_to root_path

    else
      if session[:omniauth_params]
        flash.now[:error] = "The #{omniauth_params[:provider]} account you chose is not associated with any profile."
      else
        session[:omniauth_params] = omniauth_params
      end
    end
  end

  def failure
    flash[:notice] = "Sorry, you did not authorize"
    redirect_to root_path
  end

  def blank
    render :text => "Not Found", :status => 404
  end

  def destroy                                                   # User could disocociate his omniauth account with his profile
    authorization = current_user.authorizations.find_by_provider(params[:provider])
    flash[:notice] = "Your #{authorization.provider} authentication has been removed"
    authorization.destroy
    redirect_to edit_user_profile_path(current_user)
  end

end
