# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

require "date"
require "open-uri"
require "csv"

# Debenture.delete_all
# Issuer.delete_all
# Sector.delete_all

source_file  = 'db/csv_repos/debentures.csv'
csv_options = { col_sep:  ";", quote_char: '"', headers: :first_row }


def get_date(date)
  year = date[0,4].to_i
  month = date[5,7].to_i
  day = date[8,10].to_i

  date = Date.new(year, month, day)
end

if Debenture.all.count == 0
  CSV.foreach(source_file, csv_options) do |row|
    code = row['Codigo']
    puts code
    issuance_date = get_date(row["Data de emissão"])
    puts issuance_date
    maturity_date = get_date(row["Vencimento/Repactuação"])
    puts maturity_date
    rate_type = row['Índice de correção']
    puts rate_type
    indice = row['Tipo de Debênture']
    puts indice

    sector = Sector.find_by(name: row["Setor"])
    sector = Sector.create(name: row["Setor"]) if sector.nil?
    puts sector

    emissor = Issuer.find_by(name: row["Emissor"])
    emissor = Issuer.create(name: row["Emissor"], sector: sector) if emissor.nil?
    puts emissor

    debenture = Debenture.find_by(code: code)
    debenture = Debenture.create(code: code, maturity_date: maturity_date,
                                  issuance_date: issuance_date, rate_type: rate_type,
                                  index: indice, issuer: emissor) if debenture.nil?
    puts debenture
  end
end


date_report = Date.today - 1
calendar = Calendar.create(day: date_report)
formatted_date = date_report.strftime("%y%m%d")

url = "https://www.anbima.com.br/informacoes/merc-sec-debentures/arqs/db#{formatted_date}.txt"
file = open(url)
i = 1

File.open(file).each do |row|
  encoded_row = row.force_encoding("ISO-8859-1")
  debenture_array = encoded_row.split("@")
  if i > 3
    debenture = Debenture.find_by(code: debenture_array[0])
    debenture = Debenture.create(code: debenture_array[0], maturity_date: debenture_array[2] ) if debenture.nil?

    data = DebentureMarketDatum.create(debenture: debenture, calendar: calendar, rate: debenture_array[6], price: debenture_array[10],
                                days_to_maturity: debenture_array[12])
    puts debenture.code
    puts data.rate
    puts data.price
    puts data.days_to_maturity

  end
  i += 1
end
  # encoded_file = File.read(file).force_encoding("ISO-8859-1")

  # File.open(encoded_file).each do |row|
  #   puts row.split("@")
  # end

    # puts row
    # i += 1


# def write_daily_data_fund


#   urls.each do |url|

#     download = open(url)
#     csv = CSV.parse(download, encoding:'utf-8',:headers=>true)

#     csv.each do |row|

#       codigo = row['Ativo'][0,6].to_i
#       fund = Fund.find_by(codigo_economatica: codigo)
#       puts fund

#       date = get_date(row['Date'])
#       puts date.day

#       datas = DailyDatum.find_by(fund: fund, calendar: date)

#       puts row['Spread Bench daily return']
#       puts row['Spread Bench weekly return']
#       puts row['Spread Bench monthly return']
#       puts row['Spread Bench quarterly return']
#       puts row['Spread Bench annual return']

#       if datas.nil?
#         puts "nil"
#         DailyDatum.create(aum: row['PL'], share_price:row['Cota'], return_daily_value: row['Daily return'],
#                           return_weekly_value: row['Weekly return'], return_monthly_value: row['Monthly return'],
#                           return_quarterly_value: row['Quarterly return'], return_annual_value: row['Yearly return'],
#                           return_over_benchmark_daily_value: row['Spread Bench daily return'], return_over_benchmark_weekly_value: row['Spread Bench weekly return'],
#                           return_over_benchmark_monthly_value: row['Spread Bench monthly return'], return_over_benchmark_quarterly_value: row['Spread Bench quarterly return'],
#                           return_over_benchmark_annual_value: row['Spread Bench annual return'], volatility: row['Vol EWMA 97%'],
#                           sharpe_ratio: row["Sharpe ratio"], tracking_error: row['Tracking error'],
#                           application_weekly_net_value: row['Weekly Net Captation'],
#                           application_monthly_net_value: row['Monthly Net Captation'],
#                           application_quarterly_net_value: row['Quarterly Net Captation'],
#                           application_annual_net_value: row['Yearly Net Captation'],fund: fund, calendar: date)
#       else
#         puts datas.fund.name
#         puts datas.calendar.day
#         datas.update(aum: row['PL'], share_price:row['Cota'], return_daily_value: row['Daily return'],
#                           return_weekly_value: row['Weekly return'], return_monthly_value: row['Monthly return'],
#                           return_quarterly_value: row['Quarterly return'], return_annual_value: row['Yearly return'],
#                           return_over_benchmark_daily_value: row['Spread Bench daily return'], return_over_benchmark_weekly_value: row['Spread Bench weekly return'],
#                           return_over_benchmark_monthly_value: row['Spread Bench monthly return'], return_over_benchmark_quarterly_value: row['Spread Bench quarterly return'],
#                           return_over_benchmark_annual_value: row['Spread Bench annual return'], volatility: row['Vol EWMA 97%'],
#                           sharpe_ratio: row["Sharpe ratio"], tracking_error: row['Tracking error'],
#                           application_weekly_net_value: row['Weekly Net Captation'],
#                           application_monthly_net_value: row['Monthly Net Captation'],
#                           application_quarterly_net_value: row['Quarterly Net Captation'],
#                           application_annual_net_value: row['Yearly Net Captation'],fund: fund, calendar: date)
#       end

#     end
#   end
# end
