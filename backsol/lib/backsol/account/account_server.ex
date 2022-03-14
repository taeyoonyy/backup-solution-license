defmodule Backsol.AccountServer do
  use GenServer

  @name Backsol.AccountServer
  @check_expired_interval :timer.minutes(60)

  def start_link() do
    IO.puts "Starting the account server"
    GenServer.start_link(@name, [], name: @name)
  end

  def init(_state) do
    token_expired_check()
    {:ok, []}
  end

  def get_token() do
    GenServer.call(@name, :get_token)
  end

  def handle_call(:get_token, _from, state) do
    {:reply, state, state}
  end

  # 유효하면 true, 없으면 false
  def check_token(token) do
    tokens = get_token()
    result = tokens |> Enum.find(fn x -> x.token == token end)
    if result != nil, do: true, else: false
  end

  def add_token(token) do
    GenServer.cast(@name, {:add_token, token})
  end

  def handle_cast({:add_token, token}, state) do
    token_map = %{token: token, date: DateTime.utc_now()}
    new_state = state ++ [token_map]
    {:noreply, new_state}
  end

  def delete_token(token) do
    GenServer.cast(@name, {:delete_token, token})
  end

  def handle_cast({:delete_token, token}, state) do
    new_state =
      state
      |> Enum.map(fn x -> if x.token != token, do: x end)
      |> Enum.filter(&!is_nil(&1))
    {:noreply, new_state}
  end

  defp token_expired_check do
    Process.send_after(self(), :refresh, @check_expired_interval)
  end

  def handle_info(:refresh, state) do
    IO.inspect "REFRESH: " <> inspect DateTime.utc_now()
    new_state =
      state
      |> Enum.map(fn x -> if (Time.diff(DateTime.utc_now(), x.date) < 3600), do: x end)
      |> Enum.filter(&!is_nil(&1))
    token_expired_check()
    {:noreply, new_state}
  end

  #  License.AccountServer.add_token("12345")
  #  bbb = DateTime.utc_now() |> NativeDateTime.add(3600)
  #  aaa = DateTime.utc_now()
  #  Time.diff(bbb, aaa)
  #  token |> Enum.map(fn x -> if (Time.diff(DateTime.utc_now(), x.date) < 3600), do: x.date  end) |> Enum.filter(&!is_nil(&1))
  #
end
