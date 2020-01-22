defmodule Hello.WsClient do
  use WebSockex

  def start_link(state) do
    IO.puts "client started"
    WebSockex.start_link("wss://ceh9.bet/ws/ru?thresholdTimeout=100&threshold=2", __MODULE__, state)
  end

  def handle_frame({:text, msg}, state) do
    IO.puts "Received a message: #{msg}"
    {:ok, state}
  end

  def handle_info({:text, msg}, state) do
    IO.puts "Received INFO message: #{msg}"
    {:ok, state}
  end

  def handle_cast({:send, {type, msg} = frame}, state) do
    IO.puts "message Casted"
    IO.puts "Sending #{type} frame with payload: #{msg}"
    {:reply, frame, state}
  end
end