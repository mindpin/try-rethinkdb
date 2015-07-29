class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def weibo
    provider = :weibo
    if !User.omniauth_providers.index(provider).nil?
      omniauth = env["omniauth.auth"]

      if current_user
        authentication = current_user.user_tokens.where(provitder: omniauth['provider']).last
        authentication = current_user.user_tokens.where(provider: omniauth['provider'], uid: omniauth['uid']).first_or_create unless authentication
        authentication.update_attributes({token: omniauth['credentials']['token'], expires_at: omniauth['credentials']['expires_at']}) unless omniauth['credentials'].blank?
        redirect_to after_sign_in_path_for(authentication.user)
      else

        authentication = UserToken.where(provider: omniauth['provider'], uid: omniauth['uid']).first

        if authentication
          flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => omniauth['provider']
          authentication.update_attributes({token: omniauth['credentials']['token'], expires_at: omniauth['credentials']['expires_at']}) unless omniauth['credentials'].blank?
          authentication.user.update_attribute :avatar_url, omniauth.extra.try(:raw_info).try(:avatar_hd) if omniauth.extra.try(:raw_info).try(:avatar_hd)
          sign_in_and_redirect(authentication.user)
        else
          unless omniauth.uid.blank?
            user = User.new(:nickname => omniauth.info.nickname)
            user.avatar_url = omniauth.extra.try(:raw_info).try(:avatar_hd)
          else
            user = User.new
          end

          user_token = user.apply_omniauth(omniauth)

          if user.save
            user_token.save
            flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => omniauth['provider'] 
            sign_in_and_redirect(:user, user)
          else
            session[:omniauth] = omniauth.except('extra')
            redirect_to new_user_registration_url
          end
        end
      end
    end
  end
end
