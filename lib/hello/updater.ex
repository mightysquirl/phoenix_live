defmodule Hello.Updater do
    use Agent

    @doc """
    Starts bucket with given `state`
    """
    def start_link do
        IO.puts "Starting Uptater"
        Agent.start_link(fn -> %{"last_update" => 0, "last_message" => 0} end, name: __MODULE__)
    end

    @doc """
    Gets `value` from `bucket` by `key`
    """
    def get(key) do
        Agent.get(__MODULE__, &Map.get(&1, key))
    end

    @doc """
    Puts `value` for the given `key` in the `bucket`
    """
    def put(key, value) do
        Agent.update(__MODULE__, &Map.put(&1, key, value))
    end

    @doc """
    Deletes `key` from the `bucket`
    """
    def delete(key) do
        Agent.update(__MODULE__, &Map.pop(&1, key))
    end

    @doc """
    Increments "last_message" state by 1
    """
    def inc do
        msg = Hello.Updater.get("last_message")
        msg = msg + 1
        Hello.Updater.put("last_message", msg)
    end

    @doc """
    Checks if there is new messages. If there is - stores new line tree in :ets
    """
    def check do
        IO.puts "Update check"
        upd = Hello.Updater.get("last_update")
        msg = Hello.Updater.get("last_message")
        if (msg > upd) do
            Hello.Updater.put("last_update", msg)
            Hello.StoreInterface.getTree()
        end
    end
end