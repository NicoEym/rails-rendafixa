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
    debenture_data = debenture_data.where.not(price: nil)


      historical_array << { name: "Preço", data: debenture_data.map {|t| [t.calendar.day.strftime("%Y-%m"), t.price] } }
      historical_array << { name: "Preço minimo", data: debenture_data.map {|t| [t.calendar.day.strftime("%Y-%m"), t.price_min] } }
      historical_array << { name: "Preço maximo", data: debenture_data.map {|t| [t.calendar.day.strftime("%Y-%m"), t.price_max] } }

  end
end
