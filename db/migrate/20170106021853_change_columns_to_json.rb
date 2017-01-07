class ChangeColumnsToJson < ActiveRecord::Migration
  def up
    enable_extension 'citext'

    # metrics
    # remove_index :metrics, :name
    remove_column :metrics, :name
    add_column :metrics, :name, :jsonb, default: {}

    # questions
    remove_column :questions, :title
    add_column :questions, :title, :jsonb, default: {}

    # options
    remove_column :options, :title
    add_column :options, :title, :jsonb, default: {}

    # indices
    add_index :metrics, :name, using: :gin
    add_index :questions, :title, using: :gin
    add_index :options, :title, using: :gin
  end

  def down
    change_column :metrics, :name, :text, null: false, default: ""
    change_column :questions, :title, :text, null: false, default: ""
    change_column :options, :title, :text, null: false, default: ""
  end
end
