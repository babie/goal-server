defmodule GoalServer.Goal do
  use GoalServer.Web, :model

  schema "goals" do
    field :title, :string
    field :body, :string
    field :status, :string
    field :position, :integer
    belongs_to :parent, GoalServer.Goal
    has_many :chidren_goal_trees, GoalServer.GoalTree, foreign_key: :ancestor_id
    has_many :children, through: [:chidren_goal_trees, :descendant]
    belongs_to :owner, GoalServer.User, foreign_key: :owned_by
    belongs_to :creator, GoalServer.User, foreign_key: :inserted_by
    belongs_to :updater, GoalServer.User, foreign_key: :updated_by

    timestamps
  end

  @required_fields ~w(title status owned_by inserted_by updated_by)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end
end
