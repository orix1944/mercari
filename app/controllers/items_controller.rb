class ItemsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]

  before_action :set_item, only: [:show, :edit, :update, :destroy]
  before_action :set_category, only: [:edit, :show]
  before_action :set_category_parent, only: [:index, :show]


  def index
    @women_child = Category.where(parent_id: "1").pluck(:id)
    @women_g_child = Category.where(parent_id: @women_child).pluck(:id)
    @women_items = Item.where(category_id: @women_g_child).recent

    @men_child = Category.where(parent_id: "78").pluck(:id)
    @men_g_child = Category.where(parent_id: @men_child).pluck(:id)
    @men_items = Item.where(category_id: @men_g_child).recent
  end

  def show
  end

  def new
    @item = Item.new
    @category = Category.where(parent_id: "0")
  end

  def create
    @category = Category.where(parent_id: "0")
    @item = Item.new(item_params)
    if @item.save
      redirect_to root_path, notice: "商品を出品しました"
    else
      flash.now[:alert] = "商品出品に失敗しました"
      render :new
    end
  end

  def edit
    @category = Category.where(parent_id: "0")
  end

  def update
    @item.images.detach
    if @item.update(item_params)
      redirect_to item_path(params[:id])
      flash.now[:success] = "商品情報の編集が完了しました"
    else
      flash.now[:alert] = "商品編集に失敗しました"
      render :edit
    end
  end

  def destroy
    # if item.user_id == current_user.id
    if @item.destroy
      redirect_to root_path, notice: '商品を削除しました'
    else
      flash.now[:alert] = "商品削除に失敗しました"
      render :show
    end
  end

  def upload_image
    @image_blob = create_blob(params[:image])
    respond_to do |format|
      format.json { @image_blob.id }
    end
  end

  def get_category_id
    @category_parent = Category.find(params[:category_id])
    @category_children =  @category_parent.children
    respond_to do |format|
      format.json { @category_children }
    end
  end

  private
    def set_item
      @item = Item.with_attached_images.find(params[:id])
    end

    def item_params
      params.require(:item).permit(:name, :description, :size, :condition, :delivery_fee, :delivery_date, :delivery_area, :delivery_way, :price, :status, :category_id).merge(user_id: current_user.id, images: uploaded_images)
    end

    def set_category
      @category_present = Category.find(@item.category_id)
      @category_present_all = Category.where(parent_id: @category_present.parent_id)
      @category_parent = @category_present.parent
      @category_parent_all = Category.where(parent_id: @category_parent.parent_id)
      @category_root = @category_parent.parent
    end

    def create_blob(uploading_file)
      ActiveStorage::Blob.create_after_upload! \
        io: uploading_file.open,
        filename: uploading_file.original_filename,
        content_type: uploading_file.content_type
    end

    def uploaded_images
      params[:item][:images].map{|id| ActiveStorage::Blob.find(id)} if params[:item][:images]
    end

    def set_category_parent
      @category_parents = Category.where(parent_id: "0")
    end

end
