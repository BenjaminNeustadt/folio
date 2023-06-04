
module FollowsController

  # before_action :set_followee, :set_follower
  # rescue_from ActiveRecord::RecordInvalid, with: :handle_error

  # def handle_error error
  #   render json: { error: error.message }, status: :unprocessable_entity
  # end

  # POST users/:user_id/follow/:user_id
  def follow
    @follower.followees << @followee
    # response.body = { status: 'success - user followed'}.to_json
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

