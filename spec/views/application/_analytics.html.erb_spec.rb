require "rails_helper"

describe "application/_analytics.html.erb" do
  include AnalyticsHelper

  context "when signed out" do
    before do
      view_stub_with_return(signed_in?: false)
    end

    it "loads the Segment JavaScript library" do
      segment_load_line = %{window.analytics.load("#{ENV["SEGMENT_KEY"]}");}

      render

      expect(rendered).to include(segment_load_line)
    end

    it 'records a pageview' do
      record_pageview_line = "window.analytics.page"

      render

      expect(rendered).to include(record_pageview_line)
    end
  end

  context 'when signed in' do
    around(:each) do |example|
      ClimateControl.modify INTERCOM_API_SECRET: secret do
        example.run
      end
    end

    it 'identifies the user' do
      user = build_stubbed(:user)
      view_stub_with_return(
        current_user: user,
        signed_in?: true
      )
      identify_line = "analytics.identify"

      render

      expect(rendered).to include(identify_line)
    end

    it 'sends user data' do
      user = build_stubbed(:user)
      view_stub_with_return(current_user: user, signed_in?: true)

      render

      expect(rendered).to include(identify_hash(user).to_json)
    end

    it 'uses Intercom secure mode' do
      user = build_stubbed(:user)
      view_stub_with_return(
        current_user: user,
        signed_in?: true
      )
      intercom_secure_mode = {
        'Intercom' => {
          userHash: OpenSSL::HMAC.hexdigest("sha256", secret, user.id.to_s)
        }
      }.to_json

      render

      expect(rendered).to include(intercom_secure_mode)
    end

    def secret
      'secret'
    end
  end
end
