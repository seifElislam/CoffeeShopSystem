class ProductsController < ApplicationController
  before_action :set_product, only: [:show, :edit, :update, :destroy]

  # GET /products
  # GET /products.json
  def index
    @products = Product.all
  end

  # GET /products/1
  # GET /products/1.json
  def show
  end

  # GET /products/new
  def new
    @categories=Category.all
    @product = Product.new
  end

  # GET /products/1/edit
  def edit
  end

  # POST /products
  # POST /products.json
  def create
    @product = Product.new(product_params)

    respond_to do |format|
      if @product.save
        ActionCable.server.broadcast 'products',
                                     product: @product.to_json,
                                     action: 'create'
        format.html { redirect_to @product, notice: 'Product was successfully created.' }
        format.json { render :show, status: :created, location: @product }
      else
        format.html { render :new }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /products/1
  # PATCH/PUT /products/1.json
  def update
    respond_to do |format|
      if @product.update(product_params)
        ActionCable.server.broadcast 'products',
                                     product: @product.to_json,
                                     action: 'update'
        format.html { redirect_to @product, notice: 'Product was successfully updated.' }
        format.json { render :show, status: :ok, location: @product }
      else
        format.html { render :edit }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /products/1
  # PATCH/PUT /products/1.json
  def is_available
    @product = Product.find(params[:id])
    if @product.is_available==true
      @product.update_attributes(is_available: false)
    else
      @product.update_attributes(is_available: true)
    end
    ActionCable.server.broadcast 'products',
                                 product: @product.to_json,
                                 action: 'status'
    redirect_to products_path
  end

  # DELETE /products/1
  # DELETE /products/1.json
  def destroy
    @product.destroy
    ActionCable.server.broadcast 'products',
                                 product: @product.to_json,
                                 action: 'delete'
    respond_to do |format|
      format.html { redirect_to products_url, notice: 'Product was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_product
      @product = Product.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def product_params
      params.require(:product).permit(:name, :image, :price, :is_available, :category_id)
    end
end
