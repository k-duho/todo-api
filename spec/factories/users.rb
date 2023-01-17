FactoryBot.define do
  factory :user, class: User do
    name { "user-name" }
    email { "duho@duho.ho" }
    password { "password" }
    token { SecureRandom.hex }
    token_expired_at { Time.current }
  end
end
