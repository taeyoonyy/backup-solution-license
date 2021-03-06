defmodule Backsol.LicenseController do

  alias Backsol.HistoryController

  def add(data, user) do
    IO.puts "/api/license/add"
    data = string_to_atom(data)
    data = case data.type do
      "offline" -> data |> Map.put(:status, "approved")
      _ -> data |> Map.put(:status, "ready")
    end
    key = generate_license(data)
    data = data |> Map.put(:key, key)
    Map.merge(%Backsol.License{}, data) |> Backsol.Repo.insert
    HistoryController.license_add({
      Backsol.License |> Backsol.Repo.get_by(key: key),
      user})
    response("success", "ok")
  end

  def get_summary() do
    IO.puts "/api/license/get/summary"
    data = Backsol.License
      |> Backsol.Repo.all
      |> struct_to_map
      |> Enum.sort_by(&Map.fetch(&1, :id))
      |> Enum.reverse
      |> Enum.map(fn x -> %{
          :id => x.id,
          :company => x.company,
          :site => x.site,
          :type => x.type,
          :status => x.status, # 로직 추가 필요
          :createdAt => x.createdAt
        }end)
    response("success", data)
  end

  def get_all() do
    response("success", Backsol.License |> Backsol.Repo.all |> struct_to_map)
  end


  def get_id(id) do
    IO.puts "/api/license/get/#{id}"
    case Backsol.License |> Backsol.Repo.get_by(id: id) do
      nil -> response("error", "no data")
      data -> response("success", [data] |> struct_to_map)
    end
  end

  def delete(id, user) do
    IO.puts "/api/license/delete/#{id}"
    license = Backsol.License |> Backsol.Repo.get_by(id: id)
    {status, result} = case license do
      nil ->  {"error", "no data"}
      _ ->
        license |> Backsol.Repo.delete
        HistoryController.license_delete({license, user})
        {"success", "ok"}
    end
    response(status, result)
  end

  def edit(id, params, user) do
    IO.puts "/api/license/edit/#{id}"
    license = Backsol.License |> Backsol.Repo.get_by(id: id)
    {status, result} = case license do
      nil -> {"error", "no data"}
      _ ->
        Backsol.License.changeset(license, string_to_atom(params))
        |> Backsol.Repo.update
        HistoryController.license_edit({license, user})
        {"success", "ok"}
    end
    response(status, result)
  end

  def approve_reset(id, user) do
    IO.puts "/api/license/approve/reset/#{id}"
    license = Backsol.License |> Backsol.Repo.get_by(id: id)
    {status, result} = case license do
      nil -> {"error", "no data"}
      _ ->
          Backsol.License.changeset(license, %{status: "ready"})
          |> Backsol.Repo.update
          HistoryController.license_apply_reset({license, user})
          {"success", "ok"}
    end
    response(status, result)
  end

  def backsol_license_apply(data, ip) do
    license = Backsol.License |> Backsol.Repo.get_by(key: data["key"])
    {status, result} = case license do
      nil ->
        HistoryController.license_apply({license, "invalid license", ip})
        {"error", "invalid license"}
      _ ->
        if data["type"] == license.type do
          case license.status do
            "ready" ->
              Backsol.License.changeset(license, %{status: "approved"})
              |> Backsol.Repo.update
              HistoryController.license_apply({license, "ok", ip})
              {"success", "ok"}
            _ ->
              HistoryController.license_apply({license, "already used", ip})
              {"error", "already used"}
          end
        else
          HistoryController.license_apply({license, "invalid license", ip})
          {"error", "invalid license"}
        end
    end
    response(status, result)
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

  defp generate_license(data) do
    case data.type do
      "offline" ->
        offHwData = decryption_license(data.offlineKey, "OFFLINEKEY") |> Jason.decode!()
        encryption_license(data |> Map.merge(%{host: offHwData["host"], mac: offHwData["mac"]}) |> Map.delete(:offKey))
      _ -> encryption_license(data)
      end
  end

  defp encryption_license(data) do
    expirationDate = if data.type == "limited", do: data.expirationDate, else: "unlimited"
    info = case data.type do
      "offline" ->
        %{
          type: data.type,
          tag: data.tagCount,
          user: data.userCount,
          date: expirationDate,
          host: data.host,
          mac: data.mac
        }
      _ ->
        %{
          type: data.type,
          tag: data.tagCount,
          user: data.userCount,
          date: expirationDate
        }
    end
    # msg = :erlang.term_to_binary(info)
    # k = :crypto.strong_rand_bytes(32)
    # {ct, tag} = :crypto.block_encrypt(:aes_gcm, k, k, {"EDGEHUB1290", msg})

    # edgehub version
    # {ct, tag} = :crypto.crypto_one_time_aead(:aes_256_gcm, k, k, msg, "EDGEHUB1290", true)
    # Base.encode16(k<> tag <> ct)

    # psy version
    key = "ID/RwsnZ3UhfScbnuZlVNW9BxjDeQne84T9fXOnEFOA=" |> Base.decode64!()
    aad = "BACKUPSOLUTION"
    message = info |> Jason.encode!()
    iv = :crypto.strong_rand_bytes(16)
    {cipher_text, auth_tag} = :crypto.crypto_one_time_aead(:aes_256_gcm, key, iv, message, aad, true)
    iv_64 = Base.encode64(iv)
    cipher_text_64 = Base.encode64(cipher_text)
    auth_tag_64 = Base.encode64(auth_tag)
    iv_64 <> auth_tag_64 <> cipher_text_64

  end

  defp decryption_license(message, aad) do
    IO.puts "good1"
    key = "ID/RwsnZ3UhfScbnuZlVNW9BxjDeQne84T9fXOnEFOA=" |> Base.decode64!()
    iv = message |> String.slice(0, 24) |> Base.decode64!()
    IO.puts "good2"
    auth_tag = message |> String.slice(24, 24) |> Base.decode64!()
    IO.puts "good3"
    cipher_text = message |> String.slice(48, String.length(message) - 48) |> Base.decode64!()
    IO.puts "good4"
    :crypto.crypto_one_time_aead(:aes_256_gcm, key, iv, cipher_text, aad, auth_tag, false)
  end
end
