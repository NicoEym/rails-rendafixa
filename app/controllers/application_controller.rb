class ApplicationController < ActionController::Base

    def get_last_date(debenture)
    # the goal is the find the most recent date for which the fund has data
    # we choose the last five days in the data base
    today = Date.today
    last_dates = []
    (1..10).each do |number_of_day|
      previous_day = today - number_of_day
      existing_date = Calendar.find_by(day: previous_day)
      last_dates << existing_date unless existing_date.nil?
    end

    # for each date we check if the fund has data
    last_dates.each do |last_date|
      data = DebentureMarketDatum.find_by(debenture: debenture, calendar: last_date)
      # when the number of DailyDatum for that date == the number of funds then we return the date
      return last_date if !data.nil?
    end
  end
end
