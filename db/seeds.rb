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
require 'nokogiri'

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

def get_report_date(date)

  new_date = avoid_brazilian_holidays(date)

  new_date = avoid_weekend(new_date)
  new_date = avoid_brazilian_holidays(new_date)

end

def avoid_brazilian_holidays(date)
  holidays_string = ["2020-11-02", "2020-11-15", "2020-12-25", "2020-10-30"]
  holidays_date =  []
  holidays_string.each do |holiday|
    holidays_date << get_date(holiday)
  end

  date.in?(holidays_date) ? date - 1 : date
end

def avoid_weekend(date)
  (date.saturday?) ? date - 1 : (date.sunday?) ? date - 2 : date
end



######################GET THE CSV LIST of DEBENTURES ##############


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

##################GET DEBENTURES DAILY DATA ###########################
def download_debentures_data(date_report)

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

      data.update(bid_rate: debenture_array[4], ask_rate: debenture_array[5]) if debenture_array[4] != "--" && debenture_array[5] != "--"
      data.update(credit_spread: debenture_array[6]) if debenture_array[3][0..3] == "DI +"
      convert_rate_percent_CDI_to_CDI_Spread(debenture_array[6]) if debenture_array[3][-5..-1] == "do DI"
      convert_rate_IPCA_Spread_to_CDI_Spread(debenture_array[6]) if debenture_array[3][0..5] == "IPCA +"
      puts debenture.code
      puts data.calendar.day
      puts data.rate
      puts data.price
      puts data.days_to_maturity
    end
    i += 1
  end
end
###########################################################


####################GET CURVE########################################

def download_curve_PRE(date_report, curve)
  calendar = Calendar.find_by(day: date_report)

  url_PRE = "http://www2.bmf.com.br/pages/portal/bmfbovespa/lumis/lum-taxas-referenciais-bmf-ptBR.asp"
  doc = Nokogiri::HTML(open(url_PRE).read)
  curve_array = []
  day_array = []

  doc.xpath("//td").each do |element|

    if day_array.size < 3
      day_array << element.text.strip
    elsif day_array.size == 3
      curve_array << day_array
      day_array = []
      day_array << element.text.strip
    end

  end

  curve_array.each do |day_array|
   puts "Day #{day_array[0]}  - rate #{day_array[2]}"
   CurveTerm.create(curve: curve, calendar: calendar, day: day_array[0], value: day_array[2])
  end

end

############################################################################################

def download_debentures_secondary_market_data(start_date, end_date)

  formatted_start_date = start_date.strftime("%Y%m%d")
  puts formatted_start_date
  formatted_end_date = end_date.strftime("%Y%m%d")
  puts formatted_end_date
  url_debentures_secondary = "http://www.debentures.com.br/exploreosnd/consultaadados/mercadosecundario/precosdenegociacao_e.asp?op_exc=False&isin=&ativo=&dt_ini=#{formatted_start_date}&dt_fim=#{formatted_end_date}"
  puts url_debentures_secondary

  # file = open(url_debentures_secondary)

  download = open(url_debentures_secondary)
  IO.copy_stream(download, 'db/csv_repos/Debentures.com.xls')

  file = 'db/csv_repos/Debentures.com.xls'

  book = Roo::Spreadsheet.open(file, extension: :xls)
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
end


def convert_rate_percent_CDI_to_CDI_Spread(spread)

  rate_1 = PRE_1_day * Entry_rate
  rate_2 = PRE_1_day

  final_Rate = (( 1 +  rate_1) / (1 + rate_2)) ^(252) - 1
end

def convert_rate_IPCA_Spread_to_CDI_spread(spread)

  rate_1 = (1 + Entry_rate) * (1 + IPCA_1_day)
  rate_2 = PRE_1_day

  final_Rate = (( 1 +  rate_1) / (1 + rate_2)) ^(252) - 1
end


def calculate_daily_PRE



end


def calculate_daily_IPCA



end



yesterday = Date.today - 1
date_report = get_report_date(yesterday)
puts "Report date is #{date_report}"

end_date = get_report_date(Date.today - 1)
puts "End of period date is #{end_date}"

start_date = get_report_date(Date.today - 2)
puts "Start of period date is #{start_date}"

# download_debentures_data(date_report)
download_debentures_secondary_market_data(start_date, end_date)

curve_PRE = Curve.create(name: "PRE") if Curve.find_by(name: "PRE").nil?

# download_curve_PRE(date_report, curve_PRE)
