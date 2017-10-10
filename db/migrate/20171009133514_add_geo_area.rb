class AddGeoArea < ActiveRecord::Migration[5.1]
  def change
    create_table :geo_areas do |t|
      t.string :name
      t.string :short_name

      t.timestamps
    end    
    
    create_join_table :countries, :geo_areas do |t|
      t.index [:country_id, :geo_area_id]
      t.index [:geo_area_id, :country_id]
    end
    
    create_join_table :districts, :geo_areas do |t|
      t.index [:district_id, :geo_area_id]
      t.index [:geo_area_id, :district_id]
    end

    add_column :funds, :geo_area_id, :integer
    add_foreign_key :funds, :geo_areas

    reversible do |dir|
      dir.up do

        sql = "SELECT cs, ds, array_agg(fund_id) AS fund_ids
          FROM (
            SELECT f.id AS fund_id,
              array_agg(DISTINCT df.district_id) AS ds, 
              array_agg(DISTINCT cf.country_id) AS cs
            FROM funds f
              LEFT OUTER JOIN districts_funds df
                ON f.id = df.fund_id
              LEFT OUTER JOIN countries_funds cf
                ON f.id = cf.fund_id
            GROUP BY f.id
          ) AS a
          GROUP BY cs, ds"
        records_array = ActiveRecord::Base.connection.execute(sql)
        records_array.each_with_index do |record, index|
          districts = District.where(id: record["ds"][1..-2].split(",").map(&:to_i))
          countries = Country.where(id: record["cs"][1..-2].split(",").map(&:to_i))
          name = "Area"

          if countries.size == 1
            if districts.size == 0
              name = countries.first.name
            if districts.size < 6
              name = districts.pluck(:name).uniq.join(", ")
            elsif districts.pluck(:region).uniq.count < 4
              name = districts.pluck(:region).uniq.join(", ")
            elsif districts.pluck(:sub_country).uniq.count < 3
              name = districts.pluck(:sub_country).uniq.join(", ")
            end
          end


          g = GeoArea.new(name: "#{name} #{index}")
          g.districts = districts
          g.countries = countries
          g.save!

          record["fund_ids"][1..-2].split(",").map(&:to_i).each do |fund_id|
            Fund.find(fund_id).update_column(:geo_area_id, g.id)
          end
        end
      end
      dir.down do
      end
    end

  end
end
