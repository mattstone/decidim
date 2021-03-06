# frozen_string_literal: true

require "spec_helper"

module Decidim::Budgets
  describe RemoveLineItem do
    subject { described_class.new(order, project) }

    let(:user) { create(:user) }

    let(:component) do
      create(:budget_component,
             organization: user.organization,
             settings: { "total_budget" => 100_000, "vote_threshold_percent": 50 })
    end

    let(:project) { create(:project, component: component, budget: 50_000) }

    let(:order) do
      order = create(:order, user: user, component: component)
      order.projects << project
      order.save!
      order
    end

    context "when everything is ok" do
      it "broadcasts ok" do
        expect { subject.call }.to broadcast(:ok)
      end

      it "removes a line item from the order" do
        subject.call
        last_order = Order.last
        expect(last_order.line_items.collect(&:project)).to be_empty
      end
    end

    context "when the order is checked out" do
      before do
        order.update!(checked_out_at: Time.current)
      end

      it "broadcasts invalid" do
        expect { subject.call }.to broadcast(:invalid)
      end
    end
  end
end
