IO.puts("Starting iex for Phxcrd")

alias Phxcrd.Auth.User
alias Phxcrd.Auth.Authority
alias Phxcrd.Auth.Permision
alias Phxcrd.Auth.Version
alias Phxcrd.Repo

import Ecto.Query, only: [from: 2, from: 1, where: 3]
