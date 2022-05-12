defmodule Backsol.Router do
  use Plug.Router

  alias Backsol.LicenseController
  alias Backsol.AccountController
  alias Backsol.HistoryController
  alias Backsol.AccountServer

  plug(Plug.Static,
    at: "/",
    from: Path.expand("./dist"),
    only: ~w(css fonts images img js favicon.ico)
  )

  plug(:match)
  plug(Plug.Parsers, parsers: [:json], pass: ["application/json"], json_decoder: Jason)
  plug(:dispatch)

  post "/api/license/add" do
    with_valid_headers(conn, fn user ->
      {status, resp_body} = LicenseController.add(conn.body_params, user)
      send_resp(conn, status, resp_body)
    end)
  end

  get "/api/license/get/summary" do
    with_valid_headers(conn, fn _ ->
      {status, resp_body} = LicenseController.get_summary()
      send_resp(conn, status, resp_body)
    end)
  end

  get "/api/license/get" do
    with_valid_headers(conn, fn _ ->
      {status, resp_body} = LicenseController.get_all()
      send_resp(conn, status, resp_body)
    end)
  end

  get "/api/license/get/:id" do
    with_valid_headers(conn, fn _ ->
      {status, resp_body} = LicenseController.get_id(id)
      send_resp(conn, status, resp_body)
    end)
  end

  delete "/api/license/delete/:id" do
    with_valid_headers(conn, fn user ->
      {status, resp_body} = LicenseController.delete(id, user)
      send_resp(conn, status, resp_body)
    end)
  end

  put "/api/license/edit/:id" do
    with_valid_headers(conn, fn user ->
      {status, resp_body} = LicenseController.edit(id, conn.body_params, user)
      send_resp(conn, status, resp_body)
    end)
  end

  put "/api/license/approve/reset/:id" do
    with_valid_headers(conn, fn user ->
      {status, resp_body} = LicenseController.approve_reset(id, user)
      send_resp(conn, status, resp_body)
    end)
  end

  ## API Frontend
  ## History

  get "/api/history/get" do
    with_valid_headers(conn, fn _ ->
      {status, resp_body} = HistoryController.get_all()
      send_resp(conn, status, resp_body)
    end)
  end

  get "/api/history/get/:licenseId" do
    with_valid_headers(conn, fn _ ->
      {status, resp_body} = HistoryController.get_id(licenseId)
      send_resp(conn, status, resp_body)
    end)
  end

  put "/api/history/edit/:historyId" do
    with_valid_headers(conn, fn user ->
      {status, resp_body} =
        HistoryController.history_comment_edit({conn.body_params["comment"], historyId, user})

      send_resp(conn, status, resp_body)
    end)
  end

  ## API Frontend
  ## Authentication

  # FIRST USER CHECK
  get "/api/authentication/get/summary" do
    with_valid_headers(conn, fn _ ->
      {status, resp_body} = AccountController.get_summary()
      send_resp(conn, status, resp_body)
    end)
  end

  get "/api/authentication/get/:id" do
    with_valid_headers(conn, fn _ ->
      {status, resp_body} = AccountController.get_id(id)
      send_resp(conn, status, resp_body)
    end)
  end

  get "/api/authentication/get" do
    with_valid_headers(conn, fn _ ->
      {status, resp_body} = AccountController.get_all()
      send_resp(conn, status, resp_body)
    end)
  end

  get "/api/authentication/check" do
    {status, resp_body} = AccountController.check()
    send_resp(conn, status, resp_body)
  end

  # ADD ACCOUNT
  post "/api/authentication/add" do
    {status, resp_body} = AccountController.add(conn.body_params)
    send_resp(conn, status, resp_body)
  end

  # EDIT ACCOUNT
  put "/api/authentication/edit/:id" do
    with_valid_headers(conn, fn _ ->
      {status, resp_body} = AccountController.edit(id, conn.body_params)
      send_resp(conn, status, resp_body)
    end)
  end

  # DELETE ACCOUNT
  delete "/api/authentication/delete/:id" do
    with_valid_headers(conn, fn _ ->
      {status, resp_body} = AccountController.delete(id)
      send_resp(conn, status, resp_body)
    end)
  end

  post "/api/authentication/login" do
    {status, resp_body} = AccountController.login(conn.body_params)
    send_resp(conn, status, resp_body)
  end

  get "/api/authentication/logout" do
    {status, resp_body} =
      get_req_header(conn, "authorization")
      |> Enum.at(0)
      |> AccountController.logout()

    send_resp(conn, status, resp_body)
  end

  ## Backsol / License / Apply
  post "/api/dex/license/apply" do
    {status, resp_body} =
      LicenseController.backsol_license_apply(
        conn.body_params,
        to_string(:inet_parse.ntoa(conn.remote_ip))
      )

    send_resp(conn, status, resp_body)
  end

  # match _, do: send_resp(conn, 404, "404 error not found!")
  get "/management/*path" do
    serve_dist(conn)
  end

  match(_, do: send_resp(conn, 404, "404 error not found!"))

  defp with_valid_headers(conn, action) do
    token = get_req_header(conn, "authorization") |> Enum.at(0)
    is_token = token |> AccountServer.check_token()

    if is_token do
      user = Joken.peek_claims(token) |> elem(1) |> Map.get("id")
      action.(user)
    else
      send_resp(conn, 200, %{status: "error", result: "invalid token"} |> Jason.encode!())
    end
  end

  def serve_dist(conn) do
    path = File.cwd!() <> "/dist/index.html"
    {:ok, content} = path |> File.read()
    send_resp(conn, 200, content)
  end
end
