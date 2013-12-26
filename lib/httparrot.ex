defmodule HTTParrot do
  use Application.Behaviour

  def start(_type, _args) do
    dispatch = :cowboy_router.compile([
      {:_, [ {'/ip', HTTParrot.IPHandler, []},
             {'/user-agent', HTTParrot.UserAgentHandler, []},
             {'/headers', HTTParrot.HeadersHandler, []},
             {'/get', HTTParrot.GetHandler, []},
             {'/status/:code', HTTParrot.StatusCodeHandler, []} ] }
    ])
    {:ok, port} = :application.get_env(:httparrot, :port)
    {:ok, _} = :cowboy.start_http(:http, 100, [port: port], [env: [dispatch: dispatch], onresponse: &prettify_json/4])
    IO.puts "Starting HTTParrot using on port #{port}"
    HTTParrot.Supervisor.start_link
  end

  def stop(_State), do: :ok

  def prettify_json(status, headers, body, req) do
    if JSEX.is_json? body do
      body = JSEX.prettify!(body)
      headers = ListDict.put(headers, "content-length", integer_to_list(String.length(body)))
    end
    {:ok, req} = :cowboy_req.reply(status, headers, body, req)
    req
  end
end