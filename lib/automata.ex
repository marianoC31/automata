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
  delta_dfa = %{}

  states_dfa = powerset(MapSet.to_list(states))
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
  def e_determinize(%NFA{alphabet: a, delta: delta, start: start} = nfa) do
  start_dfa = MapSet.new([start])
  queue = :queue.from_list([start_dfa])
  visited = MapSet.new()
  delta_dfa = %{}

  {states_dfa, delta_dfa} = bfs(queue, visited, delta_dfa, a, delta)

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
  def bfs(queue,visited, delta_dfa,a,delta) do
    case :queue.out(queue) do
      {:empty,_} ->
        {visited, delta_dfa}
      {{:value,state},new_queue} ->
        {new_delta_dfa,new_visited,updated_queue} = Enum.reduce(a,{delta_dfa,visited,new_queue},fn sym, {delta_acc,visited_acc,queue_acc} ->
          T = move(state,sym,delta)
          delta_acc = Map.put(delta_acc,{state,sym},T)

          if(MapSet.member?(visited_acc, T)) do
            {delta_acc,visited_acc,queue_acc}
          else
            {
            delta_acc,
            MapSet.put(visited_acc,T),
            :queue.in(T,queue_acc)
            }
          end
          end)

        bfs(updated_queue,new_visited,new_delta_dfa,a,delta)
    end
  end
  def move(state,sym,delta) do
    Enum.reduce(state,MapSet.new(),fn s, acc ->
      MapSet.union(Map.get(delta,{s,sym},MapSet.new()),acc)
    end)
  end

end
