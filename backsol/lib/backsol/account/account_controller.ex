defmodule Backsol.AccountController do

  use Joken.Config

  alias Backsol.AccountServer

  def get_id(id) do
    case Backsol.Account |> Backsol.Repo.get_by(id: id) do
      nil -> response("error", "no data")
      data -> response(
        "success",
        [data]
        |> struct_to_map
        |> Enum.map(fn x -> %{
          :id => x.id,
          :userId => x.user,
          :userAuth => x.authority,
          :name => x.name,
          :mobile => x.mobile
        }end)
      )
    end
  end

  def get_all() do
    response(
      "success",
      Backsol.Account
      |> Backsol.Repo.all
      |> struct_to_map
      |> Enum.sort_by(&Map.fetch(&1, :id))
    )
  end

  def get_summary() do
    data = Backsol.Account
      |> Backsol.Repo.all
      |> struct_to_map
      |> Enum.sort_by(&Map.fetch(&1, :id))
      |> Enum.map(fn x -> %{
          :id => x.id,
          :userId => x.user,
          :userAuth => x.authority
        }end)
    response("success", data)
  end



  def check() do
    IO.puts "/api/authentication/check"
    {status, result} = case Backsol.Account |> Backsol.Repo.all |> length do
     0 -> {"error", "no user"}
     _ -> {"success", "ok"}
    end
    response(status, result)
  end

  def add(params) do
    IO.puts "/api/authentication/add"
    authority = if Backsol.Account |> Backsol.Repo.all |> length == 0, do: "admin", else: "user"
    params = string_to_atom(params) |> Map.put(:authority, authority)
    {status, result} = case Backsol.Account |> Backsol.Repo.get_by(user: params.user) do
      nil ->
        Map.merge(%Backsol.Account{}, params) |> Backsol.Repo.insert
        {"success", "ok"}
      _ ->
        {"error", "duplicated id"}
    end
    response(status, result)
  end

  def edit(id, params) do
    account = Backsol.Account |> Backsol.Repo.get_by(id: id)
    {status, result} = case account do
      nil -> {"error", "no data"}
      _ ->
        Backsol.Account.changeset(account, string_to_atom(params))
        |> Backsol.Repo.update
        {"success", "ok"}
    end
    response(status, result)
  end

  def delete(id) do
    account = Backsol.Account |> Backsol.Repo.get_by(id: id)
    {status, result} = case account do
      nil -> {"error", "no data"}
      _ ->
        account |> Backsol.Repo.delete
        {"success", "ok"}
    end
    response(status, result)
  end


  def login(params) do
    IO.puts "/api/authentication/login"
    account = Backsol.Account |> Backsol.Repo.get_by(user: params["user"], password: params["password"])
    result = account != nil
    {status, result} = case result do
      true ->
        token = make_token(params["user"], account.authority)
        AccountServer.add_token(token)
        {"success", token}
      _ -> {"error", "invalid id or password"}
    end
    response(status, result)
  end


  def logout(token) do
    AccountServer.delete_token(token)
    response("success", "ok")
  end

  def make_token(id, authority) do
    token_config = Map.put(%{}, "scope", %Joken.Claim{})
    {:ok, claims} = Joken.generate_claims(token_config, %{"id"=> id, "authority" => authority})
    {:ok, jwt, _claims} = Joken.encode_and_sign(claims, Joken.Signer.create("HS256", :rand.uniform(1000) |> inspect))
    # Joken.peek_claims(jwt)
    # Joken.peek_claims("eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdXRob3JpdHkiOiJhZG1pbiIsImlkIjoiMjIyIn0.A7Ig0eeJX_472GJXdjJRnqCVYwwd0piEW-PEromerYo")
    jwt
  end

  defp string_to_atom(data) do
    data |> Map.new(fn {k, v} -> {String.to_atom(k), v} end)
  end

  defp response(status, result) do
    {200, %{status: status, result: result} |> Jason.encode!}
  end

  defp struct_to_map(data) do
    data |> Enum.map(fn x -> x |> Map.from_struct |> Map.delete(:__meta__) end)
  end

end
