require "rails_helper"

describe "Video status" do
  before { sign_in }

  describe "when user started the video" do
    it "creates an In Progress status object" do
      video = create(:video)

      post api_v1_video_status_path(video.wistia_id), state: "In Progress"

      expect(response).to be_success

      status = video.statuses.first
      expect(status).not_to be_nil
      expect(status).to be_in_progress
      expect(status.user).to eq @current_user
    end

    it "sends data to analytics backend" do
      video = create(:video)

      post api_v1_video_status_path(video.wistia_id), state: "In Progress"

      expect(analytics).to have_tracked("Started video").
        with_properties(name: video.name)
    end
  end

  describe "when user finish the video" do
    it "updates the status project to Complete" do
      video = create(:video)
      video.statuses.create(user: @current_user, state: Status::IN_PROGRESS)

      post api_v1_video_status_path(video.wistia_id), state: "Complete"

      video.reload
      expect(video.statuses.most_recent).to be_complete
    end

    it "sends data to analytics backend" do
      video = create(:video)
      video.statuses.create(user: @current_user, state: Status::IN_PROGRESS)

      post api_v1_video_status_path(video.wistia_id), state: "Complete"

      expect(analytics).to have_tracked("Finished video").
        with_properties(
          name: video.name,
          watchable_name: video.watchable_name,
        )
    end
  end

  def sign_in
    @current_user = create(:user)
    sign_in_as(@current_user)
  end
end
