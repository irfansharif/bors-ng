defmodule Aelita2.GitHub do

  @moduledoc """
  Wrappers around the GitHub REST API.
  """

  @typedoc """
  An authentication token;
  this may be a raw token (as on oAuth)
  or an installation xref (in which case the server will look it up).
  """
  @type ttoken :: {:installation, number} | {:raw, binary}

  @typedoc """
  A repository connection;
  it packages a repository with the permissions to access it.
  """
  @type tconn :: {ttoken, number} | {ttoken, number}

  @type tuser :: Aelita2.GitHub.User.t
  @type trepo :: Aelita2.GitHub.Repo.t
  @type tpr :: Aelita2.GitHub.Pr.t
  @type tstatus :: :ok | :running | :error

  @spec get_pr!(tconn, integer | bitstring) :: Aelita2.GitHub.Pr.t
  def get_pr!(repo_conn, pr_xref) do
    {:ok, pr} = GenServer.call(Aelita2.GitHub, {:get_pr, repo_conn, {pr_xref}})
    pr
  end

  @spec get_open_prs!(tconn) :: [tpr]
  def get_open_prs!(repo_conn) do
    {:ok, prs} = GenServer.call(
      Aelita2.GitHub,
      {:get_open_prs, repo_conn, {}})
    prs
  end

  @spec push!(tconn, binary, binary) :: binary
  def push!(repo_conn, sha, to) do
    {:ok, sha} = GenServer.call(Aelita2.GitHub, {:push, repo_conn, {sha, to}})
    sha
  end

  @spec get_branch!(tconn, binary) :: %{commit: bitstring, tree: bitstring}
  def get_branch!(repo_conn, from) do
    {:ok, commit} = GenServer.call(
      Aelita2.GitHub,
      {:get_branch, repo_conn, {from}})
    commit
  end

  @spec delete_branch!(tconn, binary) :: :ok
  def delete_branch!(repo_conn, branch) do
    :ok = GenServer.call(
      Aelita2.GitHub,
      {:delete_branch, repo_conn, {branch}})
    :ok
  end

  @spec merge_branch!(tconn, %{
    from: bitstring,
    to: bitstring,
    commit_message: bitstring,
    }) :: %{commit: bitstring, tree: binary} | :conflict
  def merge_branch!(repo_conn, info) do
    {:ok, commit} = GenServer.call(
      Aelita2.GitHub,
      {:merge_branch, repo_conn, {info}})
    commit
  end

  @spec synthesize_commit!(tconn, %{
    branch: bitstring,
    tree: bitstring,
    parents: [bitstring],
    commit_message: bitstring}) :: binary
  def synthesize_commit!(repo_conn, info) do
    {:ok, sha} = GenServer.call(
      Aelita2.GitHub,
      {:synthesize_commit, repo_conn, {info}})
    sha
  end

  @spec force_push!(tconn, binary, binary) :: binary
  def force_push!(repo_conn, sha, to) do
    {:ok, sha} = GenServer.call(
      Aelita2.GitHub,
      {:force_push, repo_conn, {sha, to}})
    sha
  end

  @spec get_commit_status!(tconn, binary) :: %{
    binary => tstatus}
  def get_commit_status!(repo_conn, sha) do
    {:ok, status} = GenServer.call(
      Aelita2.GitHub,
      {:get_commit_status, repo_conn, {sha}})
    status
  end

  @spec get_labels!(tconn, integer | bitstring) :: [bitstring]
  def get_labels!(repo_conn, issue_xref) do
    {:ok, labels} = GenServer.call(
      Aelita2.GitHub,
      {:get_labels, repo_conn, {issue_xref}})
    labels
  end

  @spec get_file!(tconn, binary, binary) :: binary | nil
  def get_file!(repo_conn, branch, path) do
    {:ok, file} = GenServer.call(
      Aelita2.GitHub,
      {:get_file, repo_conn, {branch, path}})
    file
  end

  @spec post_comment!(tconn, number, binary) :: :ok
  def post_comment!(repo_conn, number, body) do
    :ok = GenServer.call(
      Aelita2.GitHub,
      {:post_comment, repo_conn, {number, body}})
    :ok
  end

  @spec post_commit_status!(tconn, binary, tstatus, binary) :: :ok
  def post_commit_status!(repo_conn, sha, status, msg) do
    :ok = GenServer.call(
      Aelita2.GitHub,
      {:post_commit_status, repo_conn, {sha, status, msg}})
    :ok
  end

  @spec get_user_by_login!(ttoken, binary) :: {:ok, tuser} | :error | nil
  def get_user_by_login!(token, login) do
    {:ok, user} = GenServer.call(
      Aelita2.GitHub,
      {:get_user_by_login, token, {login}})
    user
  end

  @spec get_installation_repos!(ttoken) :: [trepo]
  def get_installation_repos!(token) do
    {:ok, repos} = GenServer.call(
      Aelita2.GitHub,
      {:get_installation_repos, token, {}})
    repos
  end

  @spec map_state_to_status(binary) :: tstatus
  def map_state_to_status(state) do
    case state do
      "pending" -> :running
      "success" -> :ok
      "failure" -> :error
      "error" -> :error
    end
  end

  @spec map_status_to_state(tstatus) :: binary
  def map_status_to_state(state) do
    case state do
      :running -> "pending"
      :ok -> "success"
      :error -> "failure"
    end
  end
end
