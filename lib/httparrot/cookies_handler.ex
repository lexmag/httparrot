defmodule HTTParrot.CookiesHandler do
  @moduledoc """
  Returns cookie data.
  """

  def init(_transport, _req, _opts) do
    {:upgrade, :protocol, :cowboy_rest}
  end

  def allowed_methods(req, state) do
    {["GET"], req, state}
  end

  def content_types_provided(req, state) do
    {[{{"application", "json", []}, :get_json}], req, state}
  end

  def get_json(req, state) do
    {cookies, req} = :cowboy_req.cookies(req)
    if cookies == [], do: cookies = [{}]
    {response(cookies), req, state}
  end

  defp response(cookies) do
    [cookies: cookies] |> JSEX.encode!
  end

  def terminate(_, _, _), do: :ok
end
