require "rails_helper"

describe Api::V1::UsersController do
  describe "#show" do
    context "authenticated" do
      it "serializes the user" do
        user = stub_oauth_authenticated_user
        expected_json = { "expected" => "result" }
        serializer = double("serializer", as_json: expected_json)
        allow(UserSerializer).to receive(:new).with(user).and_return(serializer)

        get :show, format: :json

        expect(controller).to respond_with(:success)
        expect(JSON.parse(response.body)).to eq(expected_json)
      end
    end

    context "unauthenticated" do
      it "returns a 401" do
        get :show
        expect(response.code).to eq "401"
      end
    end
  end
end
