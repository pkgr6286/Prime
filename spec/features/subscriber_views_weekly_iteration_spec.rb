require "rails_helper"

feature "subscriber views weekly iteration" do
  scenario "and sees relevant details on the page" do
    user = create(:subscriber)
    show = create(:show)
    published_video = create(:video, :published, watchable: show)
    video = create(:video, watchable: show)

    visit show_path(show, as: user)

    expect(page).to have_content(show.name)
    expect(page).to have_content(published_video.name)
    expect(page).not_to have_content(video.name)
    expect(page).not_to have_subscribe_cta
  end

  scenario "and marks the video complete" do
    show = create(:show, name: "The Weekly Iteration")
    video = create(:video, :published, watchable: show)

    visit show_path(show, as: create(:subscriber))
    expect(video_summary(video)).to have_video_status("unstarted")

    visit video_path(video)
    click_mark_as_complete_button

    expect(video_summary(video)).to have_video_status("complete")
  end

  def video_summary(video)
    find(".tile.weekly-iteration", text: video.name)
  end

  def have_subscribe_cta
    have_content(I18n.t("watchables.preview.subscribe_cta"))
  end

  def click_mark_as_complete_button
    click_on I18n.t("videos.show.mark-as-complete")
  end

  def preview_cta
    I18n.t("watchables.preview.cta", subscribe_url: join_path).html_safe
  end

  matcher :have_video_status do |status|
    match do |node|
      node[:class].include? "#{status}"
    end
  end
end
