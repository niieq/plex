defprotocol Plex.Compiler.Node do
  @moduledoc "Protocol for node evaluation"

  alias Plex.Compiler.Node.{
            If, For, BlockComment,
            BinaryOp, UnaryOp, App, Case, Deref, For, Function,
            Interpolate, Project, Let, List, Tuple, Range,
            Record, While, UpdateRef
  }

  @type t :: If.t
            | For.t
            | BlockComment.t
            | BinaryOp.t
            | UnaryOp
            | App
            | Case
            | Deref
            | For
            | Function
            | Interpolate
            | Project
            | Let
            | List
            | Tuple
            | Range
            | Record
            | While
            | UpdateRef


  @type env :: map

  @doc "Evaluates the node"
  @spec eval(Plex.Compiler.Node.t, env) :: env
  def eval(node, env)

  @doc "Formats the node for pretty display"
  @spec format(Plex.Compiler.Node.t) :: env
  def format(node)
end