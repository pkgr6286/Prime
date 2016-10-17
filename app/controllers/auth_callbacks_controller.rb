class AuthCallbacksController < ApplicationController
  def create
    sign_in user_from_auth_hash
    track_authed_to_access
    track_authenticated_on_checkout
    redirect_to_desired_path
    clear_used_session_values
  end

  private

  def track_authed_to_access
    auth_to_access_video.present do |video|
      analytics.track_authed_to_access(
        video_name: video.name,
        watchable_name: video.watchable_name,
      )
    end
  end

  def track_authenticated_on_checkout
    if session[:authenticated_on_checkout]
      analytics.track_authenticated_on_checkout
    end
  end

  def redirect_to_desired_path
    if accepting_invitation?
      redirect_to new_invitation_acceptance_path(invitation)
    elsif auth_to_access_video.present?
      redirect_to_auth_to_access_video
    else
      redirect_to url_after_auth
    end
  end

  def url_after_auth
    if originated_from_sign_in_or_sign_up?
      custom_return_path_or_default(practice_path)
    else
      auth_origin
    end
  end

  def user_from_auth_hash
    AuthHashService.new(auth_hash).find_or_create_user_from_auth_hash
  end

  def originated_from_sign_in_or_sign_up?
    auth_origin =~ /^#{sign_in_url}/ || auth_origin =~ /^#{sign_up_url}/
  end

  def custom_return_path_or_default(default_path)
    ReturnPathFinder.new(auth_origin).return_path || default_path
  end

  def auth_to_access_slug
    session[:auth_to_access_video_slug]
  end

  def auth_to_access_video
    @_auth_to_access_video ||= Video.find_by(slug: auth_to_access_slug).wrapped
  end

  def auth_hash
    request.env["omniauth.auth"]
  end

  def auth_origin
    session[:return_to] || request.env["omniauth.origin"] || practice_url
  end

  def clear_used_session_values
    [
      :return_to,
      :auth_to_access_video_slug,
      :authenticated_on_checkout,
      :invitation_id,
    ].each do |key|
      session.delete(key)
    end
  end

  def accepting_invitation?
    session[:invitation_id].present?
  end

  def invitation
    Invitation.find(session[:invitation_id])
  end

  def redirect_to_auth_to_access_video
    redirect_to(
      url_after_auth,
      notice: t("authenticating.auth_to_access_success"),
    )
  end
end
