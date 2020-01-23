defmodule Hello.StoreInterface do
    use GenServer

    def start_link(store) do
        {:ok, reg} = GenServer.start_link(__MODULE__, store)
        Enum.map(
            [:line, :discipline, :tournament, :event, :market, :tree],
            fn table ->
                Hello.StoreInterface.init_table(table)
            end
        )
        Hello.Updater.start_link
        {:ok, reg}
    end

    def init_table(table) do
        case :ets.whereis table do
            :undefined ->
                :ets.new(table, [:public, :named_table, read_concurrency: true])
            _ ->
                # IO.puts "Table #{table} already created"
        end
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
                                            # lineEvents
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
        :ets.insert(:tree, {"data_tree", tree})
    end

    def add(table, key, value) do
        ins = :ets.insert(table, {key, value})
        Hello.Updater.inc
    end

    def delete(table, key) do
        :ets.delete(table, key)
        Hello.Updater.inc
    end

    @impl true
    def init(store) do
        # IO.puts "Store Interface INIT"
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
end