defmodule Automata do
  defmodule NFA do
  defstruct states: MapSet.new(),
            alphabet: MapSet.new(),
            delta: %{},
            start: nil,
            accept: MapSet.new()
  end
  defmodule DFA do
  defstruct states: MapSet.new(),
            alphabet: MapSet.new(),
            delta: %{},
            start: nil,
            accept: MapSet.new()
end
  def powerset([]), do: [MapSet.new()]
  def powerset([h|t])do
    sub = powerset(t)
    sub ++ Enum.map(sub, fn s -> MapSet.put(s,h) end)
  end
  def determinize(%NFA{states: states,alphabet: a, start: start} = nfa) do
  start_dfa = MapSet.new([start])

  states_dfa = powerset(MapSet.to_list(states))
  accept =
    states_dfa
    |> Enum.filter(fn set ->
      not MapSet.disjoint?(set, nfa.accept)
    end)
    |> MapSet.new()

  delta_dfa = Enum.reduce(states_dfa,%{}, fn state, acc ->
    Enum.reduce(a,acc,fn symbol, acc2 ->
     Map.put(acc2,{state,symbol},move(nfa,state,symbol))
    end)
  end)
  %DFA{
    states: states_dfa,
    alphabet: a,
    delta: delta_dfa,
    start: start_dfa,
    accept: accept
  }
end
def move(nfa,state,symbol) do
    state
    |>
    Enum.flat_map(fn s->
      Map.get(nfa.delta,{s,symbol},MapSet.new())
    end)
    |> MapSet.new()
  end
def e_closure(nfa,state) do
    dfs(nfa,MapSet.new(),MapSet.to_list(state))
end
def dfs(_nfa,visited,[]), do: visited
def dfs(nfa,visited, [h|t]) do
  if !MapSet.member?(visited,h) do
    new_visited = MapSet.put(visited,h)
    new_states = Map.get(nfa.delta,{h,:epsilon},MapSet.new())
    dfs(nfa,new_visited,Enum.sort(MapSet.to_list(new_states)++t))
  else
    dfs(nfa,visited,t)
  end
end
  def e_determinize(%NFA{alphabet: a, start: start} = nfa) do
  start_dfa = e_closure(nfa,MapSet.new([start]))
  IO.inspect([start_dfa], label: "lista inicial")
  IO.inspect(start_dfa, label: "start_dfa")
  {states_dfa, delta_dfa} = prune(nfa,MapSet.new(),%{},[start_dfa])
  accept =
    states_dfa
    |> Enum.filter(fn set ->
      not MapSet.disjoint?(set, nfa.accept)
    end)
    |> MapSet.new()

  %DFA{
    states: states_dfa,
    alphabet: a,
    delta: delta_dfa,
    start: start_dfa,
    accept: accept
  }
end
def prune(_nfa,states_dfa,delta_dfa,[]), do: {states_dfa,delta_dfa}
def prune(%NFA{alphabet: a, delta: delta} = nfa,states_dfa,delta_dfa,[h|t]) do
  r = h
  new_states_dfa = MapSet.put(states_dfa,r)
  {new_states,new_delta_dfa} = Enum.reduce(a,{MapSet.new(),delta_dfa},fn sym,{acc_states,acc_delta} ->
    move_result =
      r
      |>
      Enum.flat_map(fn state->
        Map.get(delta,{state,sym},MapSet.new())
      end)
      |> MapSet.new()
    new_s = e_closure(nfa,move_result)
    if(MapSet.size(new_s)!=0) do
      new_acc_delta = Map.put(acc_delta,{r,sym},new_s)
      new_acc_states=
        if !MapSet.member?(MapSet.union(new_states_dfa, acc_states),new_s)do
          MapSet.put(acc_states,new_s)
        else
          acc_states
        end
      {new_acc_states,new_acc_delta}
    else
      {acc_states,acc_delta}
    end

  end)

  prune(nfa,MapSet.union(new_states_dfa, new_states),new_delta_dfa,MapSet.to_list(new_states) ++ t)

end
end
