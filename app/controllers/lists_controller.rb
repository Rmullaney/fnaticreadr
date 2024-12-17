class ListsController < ApplicationController
    
    
    def index # just for user_lists (show all lists? do i want this?)
        if params[:user_id] # a user's list (user_lists)
            user = User.find(params[:user_id])
            @lists = user.lists.order(updated_at: :desc)
        elsif params[:book_id] # lists a book has been added to (book_lists) - no route currently
            book = Book.find(params[:book_id])
            @lists = book.lists
        else # (lists) - no route currently
            @lists = List.all
        end
    end

    def new
        @list = List.new
    end

    def create
        if !current_user.nil?
            @list = List.new(create_update_params)
            @list.user = current_user
      
            if @list.save
              redirect_to profile_path, notice: 'List created successfully'
            end
          else
            flash[:alert] = 'Review could not be created'
            render :new, status: :unprocessable_content # FIXME START HERE
          end
    end

    def edit
        
    end

    def show
        @list = List.find(params[:list_id])
    end

    def update
        
    end
    
    def destroy
        
    end

    private
    def create_update_params
        params.require(:list).permit(:title)
    end
end