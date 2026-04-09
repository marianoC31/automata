defmodule AutomataTest do
  use ExUnit.Case

  alias Automata.{NFA, DFA}

  test "determinize simple NFA" do
    nfa = %NFA{
      states: MapSet.new([:q0, :q1, :q2, :q3]),
      alphabet: MapSet.new([:a, :b]),
      start: :q0,
      accept: MapSet.new([:q3]),
      delta: %{
        {:q0, :a} => MapSet.new([:q0, :q1]),
        {:q0, :b} => MapSet.new([:q0]),
        {:q1, :b} => MapSet.new([:q2]),
        {:q2, :b} => MapSet.new([:q3])
      }
    }

    dfa = Automata.determinize(nfa)




  end
end
