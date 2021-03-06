defmodule Plex.Compiler.Node.List do
  @moduledoc "List data type"

  alias __MODULE__
  alias Plex.Compiler

  @type t :: %__MODULE__{
            line: integer,
            elements: list,
        }

  defstruct [
    :line,
    :elements
  ]

  defimpl Plex.Compiler.Node do
    def eval(%List{elements: elems}, env) do
      Enum.map(elems, &(Compiler.eval(&1, env)))
    end
  end
end
