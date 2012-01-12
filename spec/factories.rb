require 'factory_girl'

FactoryGirl.define do
  factory :user do |u|
    u.sequence(:username) { |n| "person#{n}" }
    u.sequence(:email) { |n| "person#{n}@cucumber.com" }
    u.password  "greenandjuicy"
    u.password_confirmation "greenandjuicy"
  end

  factory :refinery_user, :parent => :user do |u|
    u.roles { [ Role[:refinery] ] }

    u.after_create do |user|
      Refinery::Plugins.registered.each_with_index do |plugin, index|
        user.plugins.create(:name => plugin.name, :position => index)
      end
    end
  end

  factory :refinery_translator, :parent => :user do |u|
    u.roles { [ Role[:refinery], Role[:translator] ] }

    u.after_create do |user|
      user.plugins.create(:name => 'refinery_pages', :position => 0)
    end
  end


  factory :refinery_image do |i|
    i.image File.new(File.expand_path("#{Rails.root}/spec/uploads/beach.jpeg", __FILE__))
  end
end