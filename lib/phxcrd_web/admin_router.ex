defmodule PhxcrdWeb.AdminRouter do
  use PhxcrdWeb, :router

  scope "/", PhxcrdWeb do
    resources "/authorities", AuthorityController, except: [:delete]
    resources "/permissions", PermissionController
    resources "/versions", VersionController, only: [:index, :show]
    resources "/users", UserController, except: [:delete]
    get "/users/:id/change-password", UserController, :change_password_get
    put "/users/:id/change-password", UserController, :change_password_post
  end
end
