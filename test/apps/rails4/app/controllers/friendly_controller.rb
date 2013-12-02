class FriendlyController
  some_helper_thing do
    @user = User.current_user
  end

  def find
    @user = User.friendly.find(params[:id])
    redirect_to @user
  end

  def some_user_thing
    redirect_to @user.url
  end

  def mass_assign_user
    # Should warn about permit!
    x = params.permit!
    @user = User.new(x)
  end

  def mass_assign_protected_model
    # Should not warn because Account uses attr_accessible
    params.permit!
    Account.new(params)
  end

  def permit_without_usage
    # Should not warn because there is no mass assignment
    params.permit!
  end

  def permit_after_usage
    # Should not warn because permit! is called after mass assignment
    User.new(params)
    params.permit!
  end
end
