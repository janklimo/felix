class AddTimingToQuestions < ActiveRecord::Migration
  def change
    add_column :questions, :timing, :integer, default: 0, null: false
  end
end
