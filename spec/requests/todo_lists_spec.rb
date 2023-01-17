require 'rails_helper'

RSpec.describe "/todo_lists", type: :request do
  let!(:user_a) { FactoryBot.create(:user, name: "user-a", email: "user-a@aa.aa", token_expired_at: token_expired_date) }
  let!(:user_b) { FactoryBot.create(:user, name: "user-b", email: "user-b@bb.bb") }
  let!(:todo_list_a) { FactoryBot.create(:todo_list, title: "title-a", user_id: user_a.id) }
  let!(:todo_list_b) { FactoryBot.create(:todo_list, title: "title-b", user_id: user_a.id) }
  let!(:todo_list_c) { FactoryBot.create(:todo_list, title: "title-c", user_id: user_b.id) }

  shared_examples "return 401 error" do
    it "returns 401 error" do
      request
      expect(response.status).to eq(401)
    end
  end

  shared_examples "returns error" do |error_status|
    it "returns error" do
      request
      expect(response.status).to eq(error_status)
    end
  end

  shared_examples "update refresh token" do
    it "update refresh token" do
      request
      expect { user_a.reload }.to change(user_a, :token)
    end
  end

  describe "GET /todo_lists" do
    subject(:request) { get todo_lists_url, headers: headers, as: :json }

    let(:headers) { { Authorization: token } }
    let(:token_expired_date) { Time.current.tomorrow }

    context "when Authorization token is invalid" do
      let(:token) { "invalid token" }

      it_behaves_like "returns error", 401
    end

    context "when token is expired" do
      let(:token) { user_a.token }
      let(:token_expired_date) { Time.current.yesterday }

      it_behaves_like "returns error", 401
    end

    context "when token is valid" do
      let(:token) { user_a.token }

      context "when login user is user_a" do
        it "returns user_a's todo_lists collection" do
          request
          expect(response).to be_successful
          parsed_json = JSON.parse(response.body)["todo_lists"]

          expect(parsed_json[0]).to include({ "id" => 1, "title" => "title-a", "finished" => false, "user_id" => user_a.id })
          expect(parsed_json[1]).to include({ "id" => 2, "title" => "title-b", "finished" => false, "user_id" => user_a.id })
        end
      end

      context "When the token expiration date is 5 minutes" do
        let(:token_expired_date) { Time.current + 4.minutes }

        it_behaves_like "update refresh token"
      end
    end
  end

  describe "GET /todo_lists/:id" do
    subject(:request) { get todo_list_url(todo_list_a), headers: headers, as: :json }

    let(:headers) { { Authorization: token } }
    let(:token_expired_date) { Time.current.tomorrow }

    context "when Authorization token is invalid" do
      let(:token) { "invalid token" }

      it_behaves_like "returns error", 401
    end

    context "when token is expired" do
      let(:token) { user_a.token }
      let(:token_expired_date) { Time.current.yesterday }

      it_behaves_like "returns error", 401
    end

    context "when login user is user_a" do
      let(:token) { user_a.token }

      context "when todo_list_a's owner is user_a" do
        it "returns todo_list_a's info" do
          request
          expect(response).to be_successful
          parsed_json = JSON.parse(response.body)["todo_list"]

          expect(parsed_json).to include({ "id" => 1, "title" => "title-a", "finished" => false, "user_id" => user_a.id })
        end
      end

      context "when todo_list_a's owner is not user_a" do
        before do
          todo_list_a.update(user_id: user_b.id)
        end

        it_behaves_like "returns error", 404
      end

      context "When the token expiration date is 5 minutes" do
        let(:token_expired_date) { Time.current + 4.minutes }

        it_behaves_like "update refresh token"
      end
    end
  end

  describe "POST /create" do
    subject(:request) { post todo_lists_url, params: params, headers: headers, as: :json }

    let(:headers) { { Authorization: token } }
    let(:token_expired_date) { Time.current.tomorrow }
    let(:params) { { title: "" } }

    context "when Authorization token is invalid" do
      let(:token) { "invalid token" }

      it_behaves_like "returns error", 401
    end

    context "when token is expired" do
      let(:token) { user_a.token }
      let(:token_expired_date) { Time.current.yesterday }

      it_behaves_like "returns error", 401
    end

    context "when login user is user_a" do
      let(:token) { user_a.token }
      let(:params) { { title: "valid title" } }

      it "creates user_a's new todo_list." do
        expect { request }.to change(TodoList, :count).by(1)
      end
    end

    context "with valid parameters" do
      let(:token) { user_a.token }
      let(:params) { { title: "new title" } }

      it "creates a new todo_list" do
        expect { request }.to change(TodoList, :count).by(1)
      end

      it "returns a new todo_list info" do
        request
        expect(response).to have_http_status :created
        parsed_json = JSON.parse(response.body)["todo_list"]

        expect(parsed_json).to include({ "title" => "new title", "finished" => false, "user_id" => user_a.id })
      end
    end

    context "with invalid parameters" do
      let(:token) { user_a.token }
      let(:params) { { title: "" } }

      it "does not create a new TodoList" do
        expect { request }.to change(TodoList, :count).by(0)
      end

      it "returns a new todo_list info" do
        request
        expect(response).to have_http_status :unprocessable_entity
        parsed_json = JSON.parse(response.body)

        expect(parsed_json).to eq(["Title can't be blank"])
      end
    end
  end

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
