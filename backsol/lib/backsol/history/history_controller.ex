defmodule Backsol.HistoryController do

  require Ecto.Query

  # 히스토리 사용 정의
  # 1. 라이센스 추가 license_add
  # 2. 라이센스 어플라이 license_apply
  # 3. 라이센스 리셋 license_apply_reset
  # 4. 라이센스 정보 수정 license_edit
  # 5. 라이센스 삭제 license_delete
  # 6. 히스토리 코멘트 수정 history_comment_edit

  def license_add({license, source}) do
    IO.inspect "license_add"
    data = %{
      company: license.company,
      site: license.site,
      action: "라이센스 등록",
      result: "Success",
      licenseId: license.id,
      source: source
    }
    Map.merge(%Backsol.History{}, data) |> Backsol.Repo.insert
  end

  def license_apply({license, action, source}) do
    IO.inspect "license_apply"
    data = case action do
      "invalid license" ->
        %{
          company: nil,
          site: nil,
          licenseId: 0,
          source: source
        }
      _ ->
        %{
          company: license.company,
          site: license.site,
          licenseId: license.id,
          source: source
        }
    end

    data = case action do
      "invalid license" ->
          data
          |> Map.put(:action, "잘못된 라이센스 승인 요청")
          |> Map.put(:result, "Error")
      "already used" ->
          data
          |> Map.put(:action, "이미 사용중인 라이센스 승인 요청")
          |> Map.put(:result, "Error")
        _ ->
          data
          |> Map.put(:action, "라이센스 승인 요청")
          |> Map.put(:result, "Success")
    end
    Map.merge(%Backsol.History{}, data) |> Backsol.Repo.insert
  end

  def license_apply_reset({license, source}) do
    IO.inspect "license_apply_reset"
    data = %{
      company: license.company,
      site: license.site,
      action: "라이센스 승인 초기화",
      result: "Success",
      licenseId: license.id,
      source: source
    }
    Map.merge(%Backsol.History{}, data) |> Backsol.Repo.insert
  end

  def license_edit({license, source}) do
    IO.inspect "license_edit"
    data = %{
      company: license.company,
      site: license.site,
      action: "라이센스 정보 수정",
      result: "Success",
      licenseId: license.id,
      source: source
    }
    Map.merge(%Backsol.History{}, data) |> Backsol.Repo.insert
  end

  def license_delete({license, source}) do
    IO.inspect "license_delete"
    data = %{
      company: license.company,
      site: license.site,
      action: "라이센스 삭제",
      result: "Success",
      licenseId: license.id,
      source: source
    }
    Map.merge(%Backsol.History{}, data) |> Backsol.Repo.insert
  end


  def history_comment_edit({comment, id, user}) do
    IO.inspect "history_comment_edit"
    history = Backsol.History |> Backsol.Repo.get_by(id: id)
    comment = "#{comment} (by #{user})"
    Backsol.History.changeset(history, %{comment: comment})
    |> Backsol.Repo.update
    response("success", "ok")
  end

  def get_all() do
    response(
      "success",
      Backsol.History
      |> Backsol.Repo.all
      |> struct_to_map
      |> Enum.sort_by(&Map.fetch(&1, :id))
      |> Enum.reverse
    )
  end

  def get_id(id) do
    IO.puts "/api/histoty/get/#{id}"
    case Backsol.History |> Ecto.Query.where(licenseId: ^id) |> Backsol.Repo.all do
      nil -> response("error", "no data")
      data ->
        response(
          "success",
          data
          |> struct_to_map
          |> Enum.sort_by(&Map.fetch(&1, :id))
          |> Enum.reverse
        )
    end
  end

  defp response(status, result) do
    {200, %{status: status, result: result} |> Jason.encode!}
  end

  defp struct_to_map(data) do
    data |> Enum.map(fn x -> x |> Map.from_struct |> Map.delete(:__meta__) end)
  end
end
