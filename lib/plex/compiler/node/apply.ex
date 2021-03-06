defmodule Plex.Compiler.Node.Apply do
  @moduledoc "Function application"

  alias __MODULE__
  alias Plex.{Compiler, Env}
  alias Plex.Compiler.Closure
  alias Plex.Compiler.Node.{Function, ValueFunc, Project}

  @type t :: %__MODULE__{
            line: integer,
            applicant: Plex.Compiler.Node.t,
            args: Plex.Compiler.Node.t
        }

  defstruct [
    :line,
    :applicant,
    :args
  ]

  defimpl Plex.Compiler.Node do
    # HACK: runtime `eval` logic moved here as work around allowing optional env
    def eval(%Apply{applicant: {:identifier, _line, :eval}, args: [{:string,_, code}]}, env) do
      local_scope = Env.new(env)

      Env.get!(env, :eval)
      |> apply([code, local_scope])
    end

    def eval(%Apply{applicant: {:identifier, _line, :eval}, args: [{:string,_, code}|opt_env]}, env) do
      opt_env = Compiler.eval(opt_env, env)
      local_scope = Env.new(env)
      Env.merge(local_scope, opt_env)

      Env.get!(env, :eval)
      |> apply([code, local_scope])
    end

    def eval(%Apply{applicant: {:identifier, _line, name}, args: args}, env) do
      term = Env.get!(env, name)
      args = Enum.map(args, &(Compiler.eval(&1, env)))

      case term do
        # TODO: check for correct arity
        %Closure{value: closure} ->
          apply(closure, [args])
        %ValueFunc{function: %Closure{value: closure}} ->
          apply(closure, [args])
        _ ->
          apply(term, args)
      end
    end

    def eval(%Apply{applicant: %Project{object: object} = term, args: args}, env) do
      object = Env.get!(env, Plex.Utils.unwrap(object))
      %Closure{value: closure} = Compiler.eval(term, env)
      args = Enum.map(args, &(Compiler.eval(&1, env)))
      # HACK: Passes current object as `self`. See Function eval for
      # implementation details. CHANGE: Passe `self` as a Ref type
      apply(closure, [{args, %{self: object}}])
    end

    def eval(%Apply{applicant: %Function{body: body, params: params}, args: args}, env) do
      args = Enum.map(args, &(Compiler.eval(&1, env)))
      apply_function(body, params, args, env)
    end

    defp apply_function(body, params, args, env) do
      bindings = Enum.zip(params, args) |> Enum.into(%{})
      local_scope = Env.new(env, bindings)
      Compiler.eval(body, local_scope)
    end
  end
end
