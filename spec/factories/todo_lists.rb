FactoryBot.define do
  factory :todo_list, class: TodoList do
    title { "title" }
    user_id { User.first.id || 1}
  end
end
