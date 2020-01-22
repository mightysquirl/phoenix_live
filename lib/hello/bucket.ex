defmodule Hello.Bucket do
    use Agent

    @doc """
    Starts bucket with given `state`
    """
    def start_link(state, name) do
        Agent.start_link(fn -> state end, name: name)
        table = :ets.new(:store, [:set, :protected])
    end

    @doc """
    Gets `value` from `bucket` by `key`
    """
    def get(bucket, key) do
        Agent.get(bucket, &Map.get(&1, key))
    end

    @doc """
    Puts `value` for the given `key` in the `bucket`
    """
    def put(bucket, key, value) do
        Agent.update(bucket, &Map.put(&1, key, value))
    end

    @doc """
    Deletes `key` from the `bucket`
    """
    def delete(bucket, key) do
        Agent.update(bucket, &Map.pop(&1, key))
    end
end