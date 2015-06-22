module State
  ( State
  , run
  , new
  , get
  , put
  , modify
  , map
  , andMap
  , andThen
  , sequence
  ) where


type State s a =
  State (s -> (a, s))


run : State s a -> s -> (a, s)
run state startVal =
  case state of
    State f -> f startVal


new : a -> State s a
new val =
  State <| \state -> (val, state)


get : State s s
get =
  State <| \state -> (state, state)


put : s -> State s ()
put newState =
  modify (always newState)


modify : (s -> s) -> State s ()
modify modifier =
  State <| \oldState -> ((), modifier oldState)


map : (a -> b) -> State s a -> State s b
map f state =
  State <| \s ->
    let
      (a, s') = run state s
    in
      (f a, s')


andThen : State s a -> (a -> State s b) -> State s b
andThen state f =
  State <| \s ->
    let
      (a, s') = run state s
    in
      run (f a) s'


andMap : State s (a -> b) -> State s a -> State s b
andMap sf sa =
  State <| \s ->
    let
      (f, s') = run sf s
      (a, s'') = run sa s'
    in
      (f a, s'')


sequence : List (State s a) -> State s (List a)
sequence states =
  case states of
    [] -> new []
    state :: states' ->
      new (::) `andMap` state `andMap` (sequence states')
