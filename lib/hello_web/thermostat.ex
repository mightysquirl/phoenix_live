defmodule HelloWeb.ThermostatLive do
    use Phoenix.LiveView
  
    def render(assets) do
        IO.puts "Render"
      Phoenix.View.render(HelloWeb.LineView, "line.html", assets)
    end


    def mount(assigns, socket) do
        IO.puts "Mount"
        if connected?(socket), do: :timer.send_interval(3000, self(), :update)

        tableExist = :ets.whereis :tree
        case tableExist do
            :undefined ->
                {:ok, assign(socket, message: "Line table doesn't exist", tree: [])}
            _ -> 
              # tree = Hello.StoreInterface.getTree();
              tree = :ets.lookup(:tree, "data_tree")
              case tree do
                [{"data_tree", data}] ->
                    {:ok, assign(socket, message: "Line table exist", tree: data)}
                _ -> 
                    {:ok, assign(socket,  message: "Line table doesn't exist", tree: [])}
              end
              # line = :ets.tab2list(:line)
              # IO.puts "LINE"
              # IO.inspect line
              # render(conn, "index.html", message: "Line Exists", lines: line, tree: tree)
              # render(conn, "index.html", message: "Line Exists", lines: [], tree: [])
              # "Line exist"
        end


        # assign(socket, temperature: temperature, user_id: user_id)
        # case Thermostat.get_user_reading(user_id) do
        #   {:ok, temperature} ->
        #     {:ok, assign(socket, temperature: temperature, user_id: user_id)}
    
        #   {:error, reason} ->
        #     {:error, reason}
        # end
      end
    
      def handle_info(:update, socket) do
        IO.puts "Handling Info"
        tree = :ets.lookup(:tree, "data_tree")
        {:noreply, assign(socket, :tree, tree)}
      end
  end