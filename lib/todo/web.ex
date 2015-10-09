defmodule Todo.Web do
  use Plug.Router

  plug :match
  plug :dispatch

  def start_server do
    Plug.Adapters.Cowboy.http(__MODULE__, nil, port: 5454)
  end

  get "/entries" do
    conn
    |> Plug.Conn.fetch_params
    |> entries
    |> respond
  end

  post "/add_entry" do
    conn
    |> Plug.Conn.fetch_params
    |> add_entry
    |> respond
  end

  defp entries(conn) do
    entries = conn.params["list"]
    |> Todo.Cache.server_process
    |> Todo.Server.entries(parse_date(conn.params["date"]))
    Plug.Conn.assign(conn, :response, format_entries(entries))
  end

  defp add_entry(conn) do
    conn.params["list"]
    |> Todo.Cache.server_process
    |> Todo.Server.add_entry(
        %{
          date: parse_date(conn.params["date"]),
          title: conn.params["title"]
        }
      )
    Plug.Conn.assign(conn, :response, "OK")
  end

  defp respond(conn) do
    conn
    |> Plug.Conn.put_resp_content_type("text/plain")
    |> Plug.Conn.send_resp(200, conn.assigns[:response])
  end

  defp format_entries(entries) do
    for entry <- entries do
      {y,m,d} = entry.date
      "#{y}-#{m}-#{d}    #{entry.title}"
    end
    |> Enum.join("\n")
  end

  defp parse_date(date) do
    {get_year(date), get_month(date), get_day(date)}
  end

  defp get_year(date) do
    String.slice(date, 0..3)
  end

  defp get_month(date) do
    String.slice(date, 4..5)
  end

  defp get_day(date) do
    String.slice(date, 6..7)
  end
end