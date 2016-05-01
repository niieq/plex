defmodule Plex.Compiler do
  @moduledoc """
  Parses text and transaltes into Elixir data structures
  """
  alias Plex.Env

  def lex(text) do
    {:ok, tokens, _} = text |> to_char_list |> :plex_scan.string
    tokens
  end

  def parse(tokens) do
    :plex_parse.parse(tokens)
  end

  def parse!(text) do
    tokens = lex(text)

    case tokens do
      [] -> {:ok, []}
      _  -> parse(tokens)
    end
  end

  def eval(ast, env) when is_list(ast) do
    Enum.map(ast, &(eval(&1, env)))
    |> Enum.at(-1)
  end

  def eval!(code, env) do
    with {:ok, ast} <- parse!(code) do
      Enum.map(ast, &(eval(&1, env)))
      |> Enum.at(-1)
    end
  end

  def eval({:integer, _, n}, _env) do
    n
  end

  def eval({:atom, _, val}, _env) do
    val
  end

  def eval({:string, _, str}, _env) do
    str
  end

  def eval({:identifier, _, name},env) do
    Env.get!(env, name)
  end

  def eval({:bool, _, val}, _env) do
    val
  end

  def eval(ast, env) do
    Plex.Compiler.Node.eval(ast, env)
  end
end
