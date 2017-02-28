defmodule Aelita2.Batcher.BorsToml do
  @moduledoc """
  The format for `bors.toml`. It looks like this:

      status = [
        "continuous-integration/travis-ci/push",
        "continuous-integration/appveyor/branch"]

      block_labels = [ "S-do-not-merge-yet" ]
  """

  defstruct status: [], block_labels: [], timeout_sec: (60 * 60)

  @type t :: %Aelita2.Batcher.BorsToml{
    status: bitstring,
    timeout_sec: integer}

  def new(str) when is_binary(str) do
    case :etoml.parse(str) do
      {:ok, toml} ->
        toml = Map.new(toml)
        toml = %Aelita2.Batcher.BorsToml{
          status: Map.get(toml, "status", []),
          block_labels: Map.get(toml, "block_labels", []),
          timeout_sec: Map.get(toml, "timeout_sec", 60 * 60)}
        case toml do
          %{status: status} when not is_list status ->
            {:error, :status}
          %{block_labels: block_labels} when not is_list block_labels ->
            {:error, :block_labels}
          %{timeout_sec: timeout_sec} when not is_integer timeout_sec ->
            {:error, :timeout_sec}
          toml -> {:ok, toml}
        end
      {:error, _error} -> {:error, :parse_failed}
    end
  end

end
