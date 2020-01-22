defmodule HelloWeb.ThermostatController do
    use HelloWeb, :controller
    import Phoenix.LiveView.Controller
  
    def line(conn, assigns) do
      {:ok, emitter} = Hello.Emitter.start_link([])
      # Phoenix.View.render(HelloWeb.LineView, "line.html", assigns)
      live_render(conn, HelloWeb.ThermostatLive)
    end
  end