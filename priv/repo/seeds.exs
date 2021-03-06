# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Phxcrd.Repo.insert!(%Phxcrd.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
import Ecto.Query, only: [from: 2]
alias Phxcrd.Auth.{AuthorityKind, Permission, UserPermission, User}
alias Phxcrd.Repo
alias Phxcrd.Auth

authority_kind_data = [
  %Phxcrd.Auth.AuthorityKind{
    name: "ΚΛ"
  },
  %Phxcrd.Auth.AuthorityKind{
    name: "ΛΧ"
  }
]

case Repo.one(from p in AuthorityKind, select: count(p.id)) do
  0 ->
    IO.puts("** Seeding AuthorityKind")

    Enum.each(authority_kind_data, fn data ->
      Phxcrd.Repo.insert!(data)
    end)

  _ ->
    IO.puts("** Will not seed AuthorityKind")
end

permission_data = [
  %Phxcrd.Auth.Permission{
    name: "superuser",
    verbose_name: "Υπερχρήστης"
  },
  %Phxcrd.Auth.Permission{
    name: "admin",
    verbose_name: "Διαχειριστής"
  }
]

user_data = %{
  name: "root",
  username: "root",
  password: "toor",
  email: "r@r.gr"
}

case Repo.one(from p in Permission, select: count(p.id)) do
  0 ->
    IO.puts("** Seeding Permissions")

    Enum.each(permission_data, fn data ->
      Repo.insert!(data)
    end)

  _ ->
    IO.puts("** Will not seed Permission")
end

case Repo.one(from u in User, select: count(u.id)) do
  0 ->
    IO.puts("** Seeding User")
    {:ok, user} = Phxcrd.Auth.create_db_user(user_data)

    {:ok, user} =
      Phxcrd.Auth.update_user_password(user, %{
        password: user_data.password,
        password_confirmation: user_data.password
      })

  _ ->
    IO.puts("** Will not seed User")
end

case Repo.one(from p in UserPermission, select: count(p.id)) do
  0 ->
    user = Repo.one(from u in User, where: u.username == "root")
    perm = Repo.one(from u in Permission, where: u.name == "superuser")

    if user && perm do
      IO.puts("** Seeding UserPermission")
      Auth.update_user_and_perms(user, %{"permissions" => [perm.id]})
    else
      IO.puts("** Will not seed UserPermission; user or perm not found")
    end

  _ ->
    IO.puts("** Will not seed UserPermission")
end
