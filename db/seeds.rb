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
require 'roo-xls'

# DebentureMarketDatum.delete_all

# Debenture.delete_all
# Issuer.delete_all
# Sector.delete_all

# source_file  = 'db/csv_repos/debentures.csv'
# csv_options = { col_sep:  ";", quote_char: '"', headers: :first_row }


def get_date(date)
  year = date[0,4].to_i
  month = date[5,7].to_i
  day = date[8,10].to_i

  date = Date.new(year, month, day)
end

# if Debenture.all.count == 0
#   CSV.foreach(source_file, csv_options) do |row|
#     code = row['Codigo']
#     puts code
#     issuance_date = get_date(row["Data de emissão"])
#     puts issuance_date
#     maturity_date = get_date(row["Vencimento/Repactuação"])
#     puts maturity_date
#     rate_type = row['Índice de correção']
#     puts rate_type
#     indice = row['Tipo de Debênture']
#     puts indice

#     sector = Sector.find_by(name: row["Setor"])
#     sector = Sector.create(name: row["Setor"]) if sector.nil?
#     puts sector

#     emissor = Issuer.find_by(name: row["Emissor"])
#     emissor = Issuer.create(name: row["Emissor"], sector: sector) if emissor.nil?
#     puts emissor

#     debenture = Debenture.find_by(code: code)
#     debenture = Debenture.create(code: code, maturity_date: maturity_date,
#                                   issuance_date: issuance_date, rate_type: rate_type,
#                                   index: indice, issuer: emissor) if debenture.nil?
#     puts debenture
#   end
# end


date_report = Date.today - 1
calendar = Calendar.create(day: date_report)
formatted_date = date_report.strftime("%y%m%d")

url_debentures_Anbima = "https://www.anbima.com.br/informacoes/merc-sec-debentures/arqs/db#{formatted_date}.txt"
file = open(url_debentures_Anbima)
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
    puts data.calendar.day
    puts data.rate
    puts data.price
    puts data.days_to_maturity
  end
  i += 1
end



end_date = Date.today
start_date = Date.today - 1
formatted_start_date = start_date.strftime("%Y%m%d")
puts formatted_start_date
formatted_end_date = end_date.strftime("%Y%m%d")
puts formatted_end_date
url_debentures_secondary = "http://www.debentures.com.br/exploreosnd/consultaadados/mercadosecundario/precosdenegociacao_e.asp?op_exc=False&isin=&ativo=&dt_ini=#{formatted_start_date}&dt_fim=#{formatted_end_date}"
puts url_debentures_secondary

#file = open(url_debentures_secondary)
file = 'db/csv_repos/Debentures.com.xls'


book =  Roo::Spreadsheet.open(file, extension: :xls)
sheet1 = book.sheet(0)
puts sheet1.row(1)
i = 1
 # can use an index or worksheet name
sheet1.each do |row|
  if i > 4
    debenture = Debenture.find_by(code: row[2])
    puts debenture.id unless debenture.nil?

    unless debenture.nil?
      calendar = Calendar.find_by(day: date_report)
      puts calendar.id
      debenture_data = DebentureMarketDatum.find_by(calendar: calendar, debenture: debenture)
      puts debenture_data
      unless debenture_data.nil?
        debenture_data.update(price_min: row[6], price_max: row[8], negociated_quantity: row[4])
        debenture_data.debenture.code
     end
    end


  end
  i += 1
end

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
