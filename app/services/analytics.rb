class Analytics
  include AnalyticsHelper

  SAMPLER = "sampler".freeze
  SUBSCRIBED_EVENT_NAME = "Subscribed".freeze
  SUBSCRIBER = "subscriber".freeze
  TRACKERS = {
    "Video" => VideoTracker,
    "Exercise" => ExerciseTracker,
    "Trail" => TrailTracker,
  }.freeze

  class_attribute :backend
  self.backend = AnalyticsRuby

  def initialize(user)
    @user = user
  end

  def track_completeable_started(completeable)
    tracker_for(completeable).started_events.each do |name, properties|
      track(name, properties)
    end
  end

  def track_completeable_finished(completeable)
    tracker_for(completeable).finished_events.each do |name, properties|
      track(name, properties)
    end
  end

  def track_updated
    backend.identify(user_id: user.id, traits: identify_hash(user))
  end

  def track_account_created
    track("Account created")
  end

  def track_searched(query:, results_count:)
    track("Searched", query: query, results_count: results_count)
  end

  def track_collaborated(repository_name:)
    track("Created Collaboration", repository_name: repository_name)
  end

  def track_accessed_forum
    track("Logged into Forum")
  end

  def track_authenticated_on_checkout
    track("Authenticated on checkout")
  end

  def track_cancelled(reason:)
    track("Cancelled", reason: reason)
  end

  def track_subscribed(context:, plan:, revenue:)
    track(
      SUBSCRIBED_EVENT_NAME,
      context: context,
      plan: plan,
      revenue: revenue,
    )
  end

  def track_subscription_reactivated
    track("Subscription reactivated")
  end

  def track_resubscribe
    track("Resubscribe")
  end

  def track_flashcard_attempted(deck:, title:)
    track("Flashcard Attempted", deck: deck, title: title)
  end

  def track_downloaded(name:, watchable_name:, download_type:)
    track(
      "Downloaded Video",
      name: name,
      watchable_name: watchable_name,
      download_type: download_type,
    )
    track_touched_video(name: name, watchable_name: watchable_name)
    track_touched_step(
      name: name,
      watchable_name: watchable_name,
      type: "Video",
    )
  end

  def track_replied_to_beta_offer(name:, accepted:)
    track(
      "Replied to beta offer",
      name: name,
      accepted: accepted,
    )
  end

  def track_authed_to_access(video_name:, watchable_name:)
    track(
      "Authed to Access",
      video_name: video_name,
      watchable_name: watchable_name,
    )
  end

  private

  attr_reader :user

  def tracker_for(completeable)
    TRACKERS.fetch(completeable.class.name).new(completeable)
  end

  def user_type(user)
    if user.subscriber?
      SUBSCRIBER
    else
      SAMPLER
    end
  end

  def track_touched_video(name:, watchable_name:)
    track("Touched Video", name: name, watchable_name: watchable_name)
  end

  def track_touched_step(name:, watchable_name:, type:)
    track(
      "Touched Step",
      name: name,
      watchable_name: watchable_name,
      type: type,
    )
  end

  def track(event, properties = {})
    backend.track(
      event: event,
      user_id: user.id,
      properties: properties.merge(
        email: user.email,
        user_type: user_type(user),
      ),
    )
  end
end
