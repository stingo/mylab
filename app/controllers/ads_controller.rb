class AdsController < ApplicationController
  before_action :authenticate_user!, except: %i[index show save_currency]
  before_action :set_ad, only: %i[show edit update destroy]
  before_action :set_currency, only: %i[index show create new]
  before_action :update_currency_rate, only: [:index, :show]

  # GET /ads
  # GET /ads.json
  def index
    @ads = Ad.all
  end

  # GET /ads/1
  # GET /ads/1.json
  def show
    @currency = Currency.find_by(iso_code: @ad.price_currency)
  end

  # GET /ads/new
  def new
    @ad = Ad.new
  end

  # GET /ads/1/edit
  def edit
    @ad = Ad.friendly.find(params[:id])
  end

  # POST /ads
  # POST /ads.json
  def create
    @ad = current_user.ads.build(ad_params)
    @ad.delivery_currency = ad_params["price_currency"]

    respond_to do |format|
      if @ad.save
        format.html { redirect_to @ad, notice: "Ad was successfully created." }
        format.json { render :show, status: :created, location: @ad }
      else
        format.html { render :new }
        format.json { render json: @ad.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /ads/1
  # PATCH/PUT /ads/1.json
  def update
    @ad = Ad.friendly.find(params[:id])

    respond_to do |format|
      if @ad.update(ad_params)
        format.html { redirect_to @ad, notice: "Ad was successfully updated." }
        format.json { render :show, status: :ok, location: @ad }
      else
        format.html { render :edit }
        format.json { render json: @ad.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /ads/1
  # DELETE /ads/1.json
  def destroy
    @ad.destroy
    respond_to do |format|
      format.html { redirect_to ads_url, notice: "Ad was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def save_currency
    session[:set_currency] = params[:currency]
    current_user.update(currency: params[:currency])

    respond_to do |format|
      format.html { redirect_back fallback_location: root_path }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_ad
    @ad = Ad.friendly.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def ad_params
    params.require(:ad).permit(:title, :description, :price, :price_currency, :delivery, :slug)
  end
end
