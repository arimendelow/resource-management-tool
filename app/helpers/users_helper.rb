module UsersHelper

  # Returns the Gravatar (see https://en.gravatar.com) for a given user
  def gravatar_for(user, size: 50)
    # Convert the user's email to lowercase, get rid of leading and trailing whitespace, and get the MD5 hash of it, as that's what Gravatar URL's are based on. See here: http://en.gravatar.com/site/implement/hash/
    gravatar_id = Digest::MD5::hexdigest(user.email.downcase.strip)
    # size = options[:size]
    gravatar_url = "https://secure.gravatar.com/avatar/#{gravatar_id}?s=#{size}"
    # Image tag for the Gravatar with a 'gravatar' CSS class and alt text equal to the user's name
    image_tag(gravatar_url, alt: user.name, class:"gravatar")
  end

  private

    # Confirms a logged in user
    def logged_in_user
      unless logged_in?
        store_location # This is defined in the sessions_helper
        flash[:danger] = "Please log in."
        redirect_to login_url
      end
    end
end
