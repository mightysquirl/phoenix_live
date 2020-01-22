defmodule Hello.StoreInterface do
    use GenServer

    def start_link(store) do
        {:ok, reg} = GenServer.start_link(__MODULE__, store)
        Hello.Updater.start_link
        {:ok, reg}
    end

    def getTree() do
        lines = :ets.tab2list(:line)
        disciplines = :ets.tab2list(:discipline)
        tournaments = :ets.tab2list(:tournament)
        events = :ets.tab2list(:event)
        markets = :ets.tab2list(:market)
        tree = Enum.map(
            lines,
            fn {_, data} ->
                lineDisciplines = Enum.map(
                    data["disciplineIds"],
                    fn disciplineId ->
                        Enum.find(disciplines, fn {did, _} -> did === disciplineId end)
                    end
                )
                lineDisciplines = Enum.filter(lineDisciplines, fn x -> x !== nil end)
                data = Map.put(
                    data,
                    "disciplines",
                    Enum.map(
                        lineDisciplines,
                        fn {_, data} ->
                            lineTournaments = Enum.map(
                                data["tournamentIds"],
                                fn tournamentId ->
                                    Enum.find(tournaments, fn {tid, _} -> tid === tournamentId end)
                                end
                            )
                            lineTournaments = Enum.filter(lineTournaments, fn x -> x !== nil end)
                            data = Map.put(
                                data,
                                "tournaments",
                                Enum.map(
                                    lineTournaments,
                                    fn {_, data} ->
                                        lineEvents = Enum.map(
                                            data["eventIds"],
                                            fn eventId ->
                                                Enum.find(events, fn {eid, _} -> eid === eventId end)
                                            end
                                        )
                                        lineEvents = Enum.filter(lineEvents, fn x -> x !== nil end)
                                        data = Map.put(
                                            data,
                                            "events",
                                            Enum.map(
                                                lineEvents,
                                                fn {_, data} ->
                                                    lineMarkets = Enum.map(
                                                        data["marketIds"],
                                                        fn marketId ->
                                                            Enum.find(markets, fn {mid, _} -> mid === marketId end)
                                                        end
                                                    )
                                                    lineMarkets = [Enum.at(lineMarkets, 0)]
                                                    lineMarkets = Enum.filter(lineMarkets, fn x -> x !== nil end)
                                                    data = Map.put(
                                                        data,
                                                        "markets",
                                                        Enum.map(
                                                            lineMarkets,
                                                            fn {_, data} ->
                                                                data
                                                            end
                                                        )
                                                    )
                                                end
                                            )
                                        )
                                    end
                                )
                            )
                        end
                    )
                )
            end
        )
        tableExist = :ets.whereis :tree
        case tableExist do
            :undefined ->
                :ets.new(:tree, [:public, :named_table, read_concurrency: true])
                :ets.insert(:tree, {"data_tree", tree})
            _ ->
                :ets.insert(:tree, {"data_tree", tree})
        end
    end

    def add(pid, table, key, value) do
        {:ok, state} = Hello.StoreInterface.create(pid, table)
        ins = :ets.insert(String.to_atom(table), {key, value})
        Hello.Updater.inc
    end

    def delete(table, key) do
        :ets.delete(table, key)
        Hello.Updater.inc
    end

    @doc """
    Ensures there is a table created in the ETS with given `name`
    """
    def create(server, name) do
        state = GenServer.call(server, {:create, name})
        {:ok, state}
    end

    @impl true
    def init(store) do
        schedule_check
        {:ok, store}
    end

    defp schedule_check do
        Process.send_after(self(), :check, 1000)
    end

    @impl true
    def handle_info(msg, state) do
        Hello.Updater.check
        schedule_check
        {:noreply, state}
    end

    @impl true
    def handle_call({:create, store}, _from, state) do
        tableExist = :ets.whereis String.to_atom(store)
        case tableExist do
            :undefined ->
                :ets.new(String.to_atom(store), [:public, :named_table, read_concurrency: true])
                {:reply, Map.put(state, store, String.to_atom(store)), Map.put(state, store, String.to_atom(store))}
            _ -> 
                {:reply, state, state}
        end
    end
end