defmodule Phxcrd.Auth.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias Phxcrd.Auth.Permission
  alias Phxcrd.Auth.UserPermission
  alias Phxcrd.Auth.Authority

  schema "users" do
    field :am, :string
    field :am_phxcrd, :string
    field :dsn, :string
    field :email, :string
    field :extra, :string
    field :first_name, :string
    field :kind, :string
    field :last_name, :string
    field :name, :string
    field :obj_cls, :string
    field :username, :string
    field :password_hash, :string
    field :password, :string, virtual: true
    field :last_login, :utc_datetime

    many_to_many(
      :permissions,
      Permission,
      join_through: UserPermission,
      on_replace: :delete
    )

    belongs_to :authority, Authority

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [
      :username,
      :name,
      :first_name,
      :last_name,
      :email,
      :am,
      :am_phxcrd,
      :dsn,
      :kind,
      :extra,
      :obj_cls,
      :last_login
    ])
    |> validate_required([
      :username,
      :name,
      :first_name,
      :last_name,
      :email,
      :dsn,
      :kind,
      :last_login
    ])
  end

  @doc false
  def db_user_changeset(user, attrs) do
    user
    |> cast(attrs, [
      :username,
      :name,
      :first_name,
      :last_name,
      :email,
      :password
    ])
    |> validate_required([
      :username,
      :name,
      :first_name,
      :last_name,
      :email,
      :password
    ])
    |> validate_length(:password, min: 3, max: 16)
    |> put_pass_hash
  end

  defp put_pass_hash(%Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset) do
    change(changeset, Argon2.add_hash(password))
  end

  defp put_pass_hash(changeset), do: changeset
end
