require "rails_helper"

feature "User creates a team subscription" do
  background do
    create(:plan, :team, :featured)
    sign_in
  end

  scenario "creates a team subscription with a valid credit card" do
    subscribe_with_valid_credit_card

    expect(current_path).to eq after_sign_up_path
    expect(page).
      to have_content(I18n.t("checkout.flashes.success"))
    expect(settings_page).to have_subscription_to(plan.name)
    expect(FakeStripe.customer_plan_quantity).to eq plan.minimum_quantity.to_s
  end

  scenario "sees that the subscription is per month" do
    visit_team_plan_checkout_page

    expect_submit_button_to_contain("per month")
  end

  scenario "creates a subscription with a valid amount off coupon" do
    create(:coupon, code: "5OFF", duration: "once", amount_off: 500)

    visit coupon_path("5OFF")
    visit_team_plan_checkout_page

    expect_submit_button_to_contain_default_text

    expect_submit_button_to_contain discount_text("$262.00", "$267")

    fill_out_credit_card_form_with_valid_credit_card

    expect(current_path).to eq after_sign_up_path
    expect(FakeStripe.last_coupon_used).to eq "5OFF"
    expect(FakeStripe.customer_plan_quantity).to eq plan.minimum_quantity.to_s
  end

  def subscribe_with_valid_credit_card
    visit_team_plan_checkout_page
    fill_out_credit_card_form_with_valid_credit_card
  end

  def plan
    Plan.team.first
  end

  def discount_text(new, original)
    I18n.t(
      "subscriptions.discount.once",
      final_price: new,
      full_price: original,
    )
  end

  def after_sign_up_path
    edit_team_path
  end

  def expect_submit_button_to_contain_default_text
    expect_submit_button_to_contain("$267 per month")
  end

  def visit_team_plan_checkout_page
    visit teams_path
    click_link "Get your team started today"
  end
end
