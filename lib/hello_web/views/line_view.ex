defmodule HelloWeb.LineView do
  use HelloWeb, :view
  # def getLine do
  #   # line = :ets.tab2list(:line)
  #   "Line Table"
  #   # IO.inspect line
  #   tableExist = :ets.whereis :line
  #   case tableExist do
  #       :undefined ->
  #         "Line table doesn't exist"
  #       _ -> 
  #         line = :ets.tab2list(:line)
  #         IO.puts "LINE"
  #         IO.inspect line
  #         line
  #         # "Line exist"
  #   end
  # end
end
