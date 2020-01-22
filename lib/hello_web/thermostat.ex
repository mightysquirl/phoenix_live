defmodule HelloWeb.ThermostatLive do
    use Phoenix.LiveView
  
    def render(assigns) do
        IO.puts "Render"
        Phoenix.View.render(HelloWeb.LineView, "line.html", assigns)
    end

    def mount(assigns, socket) do
        IO.puts "Mount"
        if connected?(socket), do: :timer.send_interval(3000, self(), :update)

        tableExist = :ets.whereis :tree
        case tableExist do
            :undefined ->
                {:ok, assign(socket, message: "Line table doesn't exist", tree: [])}
            _ -> 
              tree = :ets.lookup(:tree, "data_tree")
              case tree do
                [{"data_tree", data}] ->
                    {:ok, assign(socket, message: "Line table exist", tree: data)}
                _ -> 
                    {:ok, assign(socket,  message: "Line table doesn't exist", tree: [])}
              end
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
              case tree do
                [{"data_tree", data}] ->
                    {:noreply, assign(socket, :tree, data)}
                _ -> 
                    {:noreply, assign(socket, :tree, [])}
              end
        # {:noreply, assign(socket, :tree, data)}
      end
  end