class TodoListsController < ApplicationController
  before_action :authenticate_user
  before_action :set_todo_list, only: %i[ show update destroy ]

  # GET /todo_lists
  def index
    @todo_lists = current_user.todo_lists.where(search_params)

    render json: { todo_lists: @todo_lists }
  end

  # GET /todo_lists/:id
  def show
    render json: { todo_list: @todo_list }
  end

  # POST /todo_lists
  def create
    @todo_list = current_user.todo_lists.build(todo_list_params)

    if @todo_list.save
      render json: { todo_list: @todo_list }, status: :created
    else
      render json: @todo_list.errors.full_messages, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /todo_lists/:id
  def update
    if @todo_list.update(todo_list_params)
      render json: { todo_list: @todo_list }
    else
      render json: @todo_list.errors.full_messages, status: :unprocessable_entity
    end
  end

  # DELETE /todo_lists/:id
  def destroy
    @todo_list.destroy
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_todo_list
    @todo_list = TodoList.find_by!(id: params[:id], user_id: current_user.id)
  end

  # Only allow a list of trusted parameters through.
  def todo_list_params
    params.require(:todo_list).permit(:title, :finished)
  end

  def search_params
    params.permit(:finished).compact
  end
end
