defmodule Hello.Emitter do
    # use GenServer
    use WebSockex

    @doc """
    Starts the server
    """
    def start_link(_opts) do
        {:ok, storeInterface} = Hello.StoreInterface.start_link(%{})
        WebSockex.start_link("wss://ceh9.bet/ws/ru?thresholdTimeout=100&threshold=2", __MODULE__, {:storeInterface, storeInterface})
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
        {:storeInterface, pid} = state
        Hello.Emitter.parseMessage(msg, pid);
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
    def parseMessage(message, pid) do
        {:ok, msgDecoded} = Jason.decode(message)
        case msgDecoded do
            ["batch" | [tail]] ->
                Enum.each(tail, fn data -> Hello.Emitter.parseAndSubscribe(data, pid) end)
            _ ->
                IO.puts "not tail"
        end
    end

    def parseAndSubscribe(message, pid) do
        [table, id, action, data] = message
        # IO.puts "MESSAGE"
        # IO.inspect message
        case action do
            1 -> 
                # IO.puts "ACTION 1"
                Hello.Emitter.addSubs(message)
                Hello.StoreInterface.add(pid, table, id, data)
            2 ->
                # IO.puts "ACTION 2"
                Hello.Emitter.addSubs(message)
                Hello.StoreInterface.add(pid, table, id, data)
            3 ->
                # IO.puts "ACTION 3"
                Hello.StoreInterface.delete(table, id)
            _ ->
                IO.puts "action undefined"
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
end