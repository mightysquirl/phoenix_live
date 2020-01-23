defmodule Hello.Emitter do
    # use GenServer
    use WebSockex

    @doc """
    Starts the server
    """
    def start_link(_opts) do
        # IO.puts "Emitter Start Link"
        # {:ok, storeInterface} = Hello.StoreInterface.start_link(%{})
        WebSockex.start_link("wss://gorilla.com/ws/ru?thresholdTimeout=100&threshold=2", __MODULE__, {})
    end

    @doc """
    Sends join message with given `name` and `ids` list
    """
    def subscribe(name, ids) when is_list(ids) do
        {:ok, msg} = Jason.encode(["join", name, ids])
        # IO.puts "SUBSCRIBe"
        # IO.inspect name
        message = {:text, msg}
        WebSockex.cast(self(), {:send, message})
    end

    def handle_frame({:text, msg}, state) do
        Hello.Emitter.parseMessage(msg);
        {:ok, state}
    end

    def handle_connect(_conn, state) do
        Hello.Emitter.subscribe("line", ["1","2","3"])
        {:ok, state}
    end

    def handle_disconnect(connection_status_map, state) do
        IO.puts "DiSCONNECT"
        IO.inspect connection_status_map 
        {:ok, state}
    end
    
    def handle_cast({:send, {_type, _msg} = frame}, state) do
        {:reply, frame, state}
    end

    # Data parsing
    def parseMessage(message) do
        {:ok, msgDecoded} = Jason.decode(message)
        case msgDecoded do
            ["batch" | [tail]] ->
                Enum.each(tail, fn data -> Hello.Emitter.parseAndSubscribe(data) end)
            _ ->
                # IO.puts "not tail"
        end
    end

    def parseAndSubscribe(message) do
        [table, id, action, data] = message
        # IO.puts "MESSAGE"
        # IO.inspect message
        table = String.to_atom(table)
        case action do
            1 -> 
                # IO.puts "ACTION 1"
                Hello.Emitter.addSubs(message)
                Hello.StoreInterface.add(table, id, data)
            2 ->
                # IO.puts "ACTION 2"
                Hello.Emitter.addSubs(message)
                Hello.StoreInterface.add(table, id, data)
            3 ->
                # IO.puts "ACTION 3"
                Hello.StoreInterface.delete(table, id)
            _ ->
                # IO.puts "action undefined"
        end
    end

    def addSubs([table, _id, _action, data]) do
        model = %{
            "line" => "disciplineIds",
            "discipline" => "tournamentIds",
            "tournament" => "eventIds",
            # "event" => "marketIds",
            "event" => "mainMarketIds",
            # "event" => "matchWinnerId",
        }
        names = %{
            "disciplineIds" => "discipline",
            "tournamentIds" => "tournament",
            "eventIds" => "event",
            "marketIds" => "market",
            "mainMarketIds" => "market",
            "matchWinnerId" => "market",
        }
        if (Map.has_key?(model, table)) do
            key = Map.get(model, table)
            name = Map.get(names, key)
            ids = Map.get(data, key)
            if (is_list(ids)) do
                Hello.Emitter.subscribe(name, ids)
            end
        end
    end

    def terminate(reason, state) do 
        IO.puts "Emitter Terminated"
        IO.inspect reason
    end
end