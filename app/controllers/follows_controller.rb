
module FollowsController

  # POST users/:user_id/follow/:user_id
  def follow
    @follower.followees << @followee
  end

  # POST users/:user_id/unfollow/:user_id
  def unfollow
    @follower.followees.delete(@followee)
  end

  private

    def set_follower(user_id)
      @follower = User.find(user_id)
    end
    
  def set_followee(followee_id)
    @followee = User.find(followee_id)
  end

end
