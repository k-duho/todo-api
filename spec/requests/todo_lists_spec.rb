require 'rails_helper'

RSpec.describe "/todo_lists", type: :request do

  let(:valid_headers) { { Authorization: user_a.token } }

  let!(:user_a) { FactoryBot.create(:user, name: "user-a", email: "user-a@aa.aa") }
  let!(:user_b) { FactoryBot.create(:user, name: "user-b", email: "user-b@bb.bb") }
  let!(:todo_list_a) { FactoryBot.create(:todo_list, title: "title-a", user_id: user_a.id) }
  let!(:todo_list_b) { FactoryBot.create(:todo_list, title: "title-b", user_id: user_a.id) }
  let!(:todo_list_c) { FactoryBot.create(:todo_list, title: "title-c", user_id: user_b.id) }

  describe "GET /todo_lists" do
    context "when login user is user_a and Authoriztion token is valid" do
      it "returns user_a's todo_lists collection" do
        get todo_lists_url, headers: valid_headers, as: :json
        expect(response).to be_successful
        parsed_json = JSON.parse(response.body)["todo_lists"]

        expect(parsed_json[0]).to include({ "id" => 1, "title" => "title-a", "finished" => false, "user_id" => user_a.id })
        expect(parsed_json[1]).to include({ "id" => 2, "title" => "title-b", "finished" => false, "user_id" => user_a.id })
      end
    end
  end

  # describe "GET /todo_lists/:id" do
  #   it "renders a successful response" do
  #     todo_list = TodoList.create! valid_attributes
  #     get todo_list_url(todo_list), as: :json
  #     expect(response).to be_successful

  #     parsed_json = JSON.parse(response.body)["todo_lists"]
  #   end
  # end

  # describe "POST /create" do
  #   context "with valid parameters" do
  #     it "creates a new TodoList" do
  #       expect {
  #         post todo_lists_url,
  #              params: { todo_list: valid_attributes }, headers: valid_headers, as: :json
  #       }.to change(TodoList, :count).by(1)
  #     end

  #     it "renders a JSON response with the new todo_list" do
  #       post todo_lists_url,
  #            params: { todo_list: valid_attributes }, headers: valid_headers, as: :json
  #       expect(response).to have_http_status(:created)
  #       expect(response.content_type).to match(a_string_including("application/json"))
  #     end
  #   end

  #   context "with invalid parameters" do
  #     it "does not create a new TodoList" do
  #       expect {
  #         post todo_lists_url,
  #              params: { todo_list: invalid_attributes }, as: :json
  #       }.to change(TodoList, :count).by(0)
  #     end

  #     it "renders a JSON response with errors for the new todo_list" do
  #       post todo_lists_url,
  #            params: { todo_list: invalid_attributes }, headers: valid_headers, as: :json
  #       expect(response).to have_http_status(:unprocessable_entity)
  #       expect(response.content_type).to match(a_string_including("application/json"))
  #     end
  #   end
  # end

  # describe "PATCH /update" do
  #   context "with valid parameters" do
  #     let(:new_attributes) {
  #       skip("Add a hash of attributes valid for your model")
  #     }

  #     it "updates the requested todo_list" do
  #       todo_list = TodoList.create! valid_attributes
  #       patch todo_list_url(todo_list),
  #             params: { todo_list: new_attributes }, headers: valid_headers, as: :json
  #       todo_list.reload
  #       skip("Add assertions for updated state")
  #     end

  #     it "renders a JSON response with the todo_list" do
  #       todo_list = TodoList.create! valid_attributes
  #       patch todo_list_url(todo_list),
  #             params: { todo_list: new_attributes }, headers: valid_headers, as: :json
  #       expect(response).to have_http_status(:ok)
  #       expect(response.content_type).to match(a_string_including("application/json"))
  #     end
  #   end

  #   context "with invalid parameters" do
  #     it "renders a JSON response with errors for the todo_list" do
  #       todo_list = TodoList.create! valid_attributes
  #       patch todo_list_url(todo_list),
  #             params: { todo_list: invalid_attributes }, headers: valid_headers, as: :json
  #       expect(response).to have_http_status(:unprocessable_entity)
  #       expect(response.content_type).to match(a_string_including("application/json"))
  #     end
  #   end
  # end

  # describe "DELETE /destroy" do
  #   it "destroys the requested todo_list" do
  #     todo_list = TodoList.create! valid_attributes
  #     expect {
  #       delete todo_list_url(todo_list), headers: valid_headers, as: :json
  #     }.to change(TodoList, :count).by(-1)
  #   end
  # end
end
