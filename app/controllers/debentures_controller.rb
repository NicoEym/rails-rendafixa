class DebenturesController < ApplicationController

  def index
    @debentures = Debenture.all
  end

  def show
    @debenture = Debenture.find(params[:id])
    # we get the last date
    @date = get_last_date(@debenture)
    @chart_prices = get_prices(@debenture)
  end

  private

  def get_prices(debenture)
    historical_array = []

    debenture_data = DebentureMarketDatum.where(debenture: debenture)

    historical_array << { name: "Preço", data: debenture_data.map {|t| [t.calendar.day.strftime("%Y-%m"), t.price.round(2)] } }
    historical_array << { name: "Preço minimo", data: debenture_data.map {|t| [t.calendar.day.strftime("%Y-%m"), t.price_min.round(2)] } }
    historical_array << { name: "Preço maximo", data: debenture_data.map {|t| [t.calendar.day.strftime("%Y-%m"), t.price_max.round(2)] } }
  end
end
