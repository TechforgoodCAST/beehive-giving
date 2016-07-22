class CreateFunds < ActiveRecord::Migration
  def change
    create_table :funds do |t|
      t.references :funder, index: true
      t.string :type_of_fund, :name, required: true
      t.integer :year_of_fund, required: true
      t.text :description, required: true
      t.string :slug, index: true, unique: true
      t.boolean :open_call, :active, required: true
      t.boolean :key_criteria_known, required: true
      t.string :key_criteria
      t.string :currency, required: true

      t.boolean :amount_known, required: true
      t.boolean :amount_min_limited, required: true
      t.boolean :amount_max_limited, required: true
      t.integer :amount_min
      t.integer :amount_max
      t.text :amount_notes

      t.boolean :duration_months_known, required: true
      t.boolean :duration_months_min_limited, required: true
      t.boolean :duration_months_max_limited, required: true
      t.integer :duration_months_min
      t.integer :duration_months_max
      t.text :duration_months_notes

      t.boolean :deadlines_known, required: true
      t.boolean :deadlines_limited, required: true
      t.integer :decision_in_months
      # references deadlines

      t.boolean :stages_known, required: true
      t.integer :stages_count
      # references stages
      # habtm funding_types

      t.text :match_funding_restrictions
      t.text :payment_procedure

      t.boolean :accepts_calls_known, required: true
      t.boolean :accepts_calls
      t.string :contact_number
      t.string :contact_email

      t.integer :geographic_scale, required: true
      t.boolean :geographic_scale_limited, required: true
      # habtm countries
      # habtm districts

      t.boolean :restrictions_known, required: true
      # habtm restrictions

      t.boolean :outcomes_known, required: true
      # habtm outcomes

      t.boolean :documents_known, required: true
      # habtm documents

      t.boolean :decision_makers_known, required: true
      # habtm decision_makers

      t.timestamps null: false
    end

    create_table :deadlines do |t|
      t.references :fund, index: true, foreign_key: true
      t.datetime :deadline, required: true

      t.timestamps null: false
    end

    create_table :stages do |t|
      t.references :fund, index: true, foreign_key: true
      t.string :name, unique: true, required: true
      t.integer :position, unique: true, required: true
      t.boolean :feedback_provided, required: true
      t.string :link

      t.timestamps null: false
    end

    add_index :funding_types, :label, unique: true

    create_table :funding_types_funds do |t|
      t.references :funding_type, index: true, required: true
      t.references :fund, index: true, required: true

      t.timestamps null: false
    end

    add_index :countries, [:name, :alpha2], unique: true

    create_table :countries_funds do |t|
      t.references :country, index: true, required: true
      t.references :fund, index: true, required: true

      t.timestamps null: false
    end

    create_table :districts_funds do |t|
      t.references :district, index: true, required: true
      t.references :fund, index: true, required: true

      t.timestamps null: false
    end

    create_table :funds_restrictions do |t|
      t.references :fund, index: true, required: true
      t.references :restriction, index: true, required: true

      t.timestamps null: false
    end

    create_table :documents do |t|
      t.string :name, unique: true, required: true
      t.string :link

      t.timestamps null: false
    end

    create_table :documents_funds do |t|
      t.references :document, index: true, required: true
      t.references :fund, index: true, required: true

      t.timestamps null: false
    end

    create_table :outcomes do |t|
      t.string :outcome, unique: true, required: true
      t.string :link

      t.timestamps null: false
    end

    create_table :funds_outcomes do |t|
      t.references :fund, index: true, required: true
      t.references :outcome, index: true, required: true

      t.timestamps null: false
    end

    create_table :decision_makers do |t|
      t.string :name, unique: true, required: true

      t.timestamps null: false
    end

    create_table :decision_makers_funds do |t|
      t.references :decision_maker, index: true, required: true
      t.references :fund, index: true, required: true

      t.timestamps null: false
    end

  end
end
