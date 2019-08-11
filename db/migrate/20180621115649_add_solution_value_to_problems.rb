class AddSolutionValueToProblems < ActiveRecord::Migration[5.0]
  def change
    add_column :problems, :value_solution, :string, after: :value
    rename_column :problems, :solved_by, :solved_by_id
  end
end
