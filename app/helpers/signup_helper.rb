module SignupHelper
  def grants_chart_data
    ((Date.today - 7)..Date.today).map do |date|
      {
        approved_on: date,
        amount_awarded: Grant.where("date(approved_on) = ?", date).sum(:amount_awarded)
      }
    end
  end
end
