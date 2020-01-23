defmodule HelloWeb.LineController do
  use HelloWeb, :controller

  def index(conn, _params) do
    # {:ok, emitter} = Hello.Emitter.start_link([])
    # IO.inspect(emitter)

    # tableExist = :ets.whereis :market
    # tableExist = :ets.whereis :tree
    # case tableExist do
    #     :undefined ->
    #       render(conn, "index.html", message: "Line table doesn't exist", lines: [], tree: [])
    #     _ -> 
    #       # tree = Hello.StoreInterface.getTree();
    #       tree = :ets.lookup(:tree, "data_tree")
    #       case tree do
    #         [{"data_tree", data}] ->
    #           render(conn, "index.html", message: "Line Exists", tree: data)
    #         _ -> 
    #           render(conn, "index.html", message: "Line table doesn't exist", tree: [])
    #       end
    #       # line = :ets.tab2list(:line)
    #       # IO.puts "LINE"
    #       # IO.inspect line
    #       # render(conn, "index.html", message: "Line Exists", lines: line, tree: tree)
    #       # render(conn, "index.html", message: "Line Exists", lines: [], tree: [])
    #       # "Line exist"
    # end
    render(conn, "index.html", message: "Line Exists", lines: [], tree: [])
  end
end
