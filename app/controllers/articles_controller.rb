class ArticlesController < ApplicationController
  before_action :set_article, only: %i[show edit update destroy]
  before_action :not_nil, only: %i[show edit update destroy]
  before_action :require_user, except: %i[show index]
  before_action :require_same_user, only: %i[edit update destroy]

  def show
  end

  def index
    @articles = Article.paginate(page: params[:page], per_page: 5)
  end

  def new
    @article = Article.new
  end

  def edit
  end

  def create
    @article = Article.new(article_params)
    @article.user = current_user
    if @article.save
      flash[:notice] = "Article was created succesfully."
      redirect_to @article
    else
      render "new"
    end
  end

  def update
    if @article.update(article_params)
      flash[:notice] = "Article was edited succesfully."
      redirect_to @article
    else
      render "edit"
    end
  end

  def destroy
    @article.destroy

    redirect_to articles_path
  end

  private

  def article_params
    params.require(:article).permit(:title, :description, category_ids: [])
  end

  def set_article
    # @article = Article.find(params[:id])
    begin
      @article = Article.find params[:id]
    rescue ActiveRecord::RecordNotFound => e
      @article = nil
    end
  end

  def not_nil
    if @article.nil?
      flash[:alert] = "Article not found"
      redirect_to articles_path
    end
  end

  def require_same_user
    if current_user != @article.user && !current_user.admin?
      flash[:alert] = "You can only edit or delete your own article"
      redirect_to @article
    end
  end
end
