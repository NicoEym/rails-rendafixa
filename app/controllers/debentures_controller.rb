class DebenturesController < ApplicationController

  def index
    @debentures = Debenture.all
  end

  def show
    @debenture = Debenture.find(params[:id])
    # we get the last date
    @date = get_last_date(@debenture)
    @dates = get_dates
    @chart_prices = get_prices(@debenture, @dates)
  end

  private

  def get_prices(debenture, dates)
    historical_array = []
    debentures_historical_data = []
    dates.each do |date|
      data = DebentureMarketDatum.find_by(calendar: date, debenture: debenture)
      debentures_historical_data << { date: data.calendar.day, price: data.price, price_min: data.price_min, price_max: data.price_max }
    end
      historical_array << { name: "Preço", data: debentures_historical_data.map {|t| [t[:date].strftime("%Y-%m-%d"), t[:price]]} }
      historical_array << { name: "Preço minimo", data: debentures_historical_data.map {|t| [t[:date].strftime("%Y-%m-%d"), t[:price_min]] } }
      historical_array << { name: "Preço maximo", data: debentures_historical_data.map {|t| [t[:date].strftime("%Y-%m-%d"), t[:price_max]] } }
  end

end
