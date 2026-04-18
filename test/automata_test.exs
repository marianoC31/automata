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

    assert dfa = Automata.determinize(nfa)
  end


  test "determinize simple NFA with full powerset" do
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

    assert length(dfa.states) == 16

    assert dfa.start == MapSet.new([:q0])

    expected_accept =
      dfa.states
      |> Enum.filter(fn set ->
        not MapSet.disjoint?(set, MapSet.new([:q3]))
      end)
      |> MapSet.new()

    assert dfa.accept == expected_accept

    empty = MapSet.new()

    assert dfa.delta[{empty, :a}] == empty
    assert dfa.delta[{empty, :b}] == empty


    s0 = MapSet.new([:q0])
    s1 = MapSet.new([:q0, :q1])
    s2 = MapSet.new([:q0, :q2])
    s3 = MapSet.new([:q0, :q3])

    assert dfa.delta[{s0, :a}] == s1
    assert dfa.delta[{s0, :b}] == s0

    assert dfa.delta[{s1, :b}] == s2
    assert dfa.delta[{s2, :b}] == s3

    for state <- dfa.states,
        symbol <- nfa.alphabet do
      assert Map.has_key?(dfa.delta, {state, symbol})
    end
  end
  test "e_closure con ciclos y múltiples ramas" do
    nfa = %{
      states: MapSet.new([:q0, :q1, :q2, :q3]),
      delta: %{
        {:q0, :epsilon} => MapSet.new([:q1, :q2]),
        {:q1, :epsilon} => MapSet.new([:q2]),
        {:q2, :epsilon} => MapSet.new([:q0, :q3]),
        {:q3, :epsilon} => MapSet.new([])
      }
    }

    result =
      Automata.e_closure(nfa, MapSet.new([:q0]))

    assert result == MapSet.new([:q0, :q1, :q2, :q3])
  end
  test "e_determinize simple ε-NFA" do
    nfa = %NFA{
    states: MapSet.new([:q0, :q1, :q2]),
    alphabet: [:a, :b],
    start: :q0,
    accept: MapSet.new([:q2]),
    delta: %{
      {:q0, :epsilon} => MapSet.new([:q1]),
      {:q1, :a} => MapSet.new([:q1]),
      {:q1, :b} => MapSet.new([:q2])
    }
  }
  dfa = Automata.e_determinize(nfa)

  s0 = MapSet.new([:q0, :q1])
  s1 = MapSet.new([:q1])
  s2 = MapSet.new([:q2])

  assert MapSet.member?(dfa.states, s0)
  assert MapSet.member?(dfa.states, s1)
  assert MapSet.member?(dfa.states, s2)

  assert dfa.delta[{s0, :a}] == s1
  assert dfa.delta[{s0, :b}] == s2
  assert dfa.delta[{s1, :a}] == s1
  assert dfa.delta[{s1, :b}] == s2

  assert MapSet.member?(dfa.accept, s2)
end
end
