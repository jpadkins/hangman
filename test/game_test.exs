defmodule GameTest do
  use ExUnit.Case

  alias Hangman.Game

  describe "word access functions" do

    setup do
      [ game: Game.new_game("wibble") ]
    end

    test "return the length", t do
      assert Game.word_length(t.game) == 6
    end

    test "return the revealed string", t do
      assert Game.word_as_string(t.game, true) == "w i b b l e"
    end

    test "return the hidden string", t do
      assert Game.word_as_string(t.game) == "_ _ _ _ _ _"
    end
  end


  describe "initial values of " do
    setup do
      [ game: Game.new_game("wibble") ]
    end

    test "letters used is []", t do
      assert Game.letters_used_so_far(t.game) == []
    end

    test "turns left is 10", t do
      assert Game.turns_left(t.game) == 10
    end
  end

  describe "correct guess" do
    setup do
      game = Game.new_game("wibble")
      {game, status, guess} = Game.make_move(game, "b")
      [ game: game, status: status, guess: guess ]
    end

    test "returns :good_guess status", t do
      assert :good_guess == t.status
    end

    test "returns a new game state with the letters filled in", t do
      assert Game.word_as_string(t.game) == "_ _ b b _ _"
    end

    test "appears in letters used", t do
      assert Game.letters_used_so_far(t.game) == [ "b" ]
    end

    test "doesn't change 'turns left'", t do
      assert Game.turns_left(t.game) == 10
    end

  end


  describe "incorrect guess" do
    setup do
      game = Game.new_game("wibble")
      {game, status, guess} = Game.make_move(game, "a")
      [ game: game, status: status, guess: guess ]
    end

    test "returns :bad_guess status", t do
      assert :bad_guess == t.status
    end

    test "returns a new game state with no letters filled in", t do
      assert Game.word_as_string(t.game) == "_ _ _ _ _ _"
    end

    test "appears in letters used", t do
      assert Game.letters_used_so_far(t.game) == [ "a" ]
    end

    test "reduces 'turns left'", t do
      assert Game.turns_left(t.game) == 9
    end

  end

  @winning_states [
    { "a", "_ _ _ _ _ _", :bad_guess,  9, [ "a" ] },
    { "b", "_ _ b b _ _", :good_guess, 9, [ "a", "b" ] },
    { "w", "w _ b b _ _", :good_guess, 9, [ "a", "b", "w" ] },
    { "i", "w i b b _ _", :good_guess, 9, [ "a", "b", "i", "w" ] },
    { "l", "w i b b l _", :good_guess, 9, [ "a", "b", "i", "l", "w" ] },
    { "x", "w i b b l _", :bad_guess,  8, [ "a", "b", "i", "l", "w", "x" ] },
    { "e", "w i b b l e", :won,        8, [ "a", "b", "e", "i", "l", "w", "x" ] },
  ]

  describe "a winning game" do

    test "progresses through the states" do
      game = Game.new_game("wibble")

      Enum.reduce(@winning_states, game, fn ({ guess, was, stat, left, used }, game) ->
        { game, status, _guess } = Game.make_move(game, guess)

        assert status == stat
        assert Game.word_as_string(game) == was
        assert (Game.letters_used_so_far(game) |> Enum.sort) == used
        assert Game.turns_left(game) == left
        game
      end)
    end

  end

  @losing_states [
    { "a", "_ _ _ _ _ _", :bad_guess,  9, [ "a" ] },
    { "b", "_ _ b b _ _", :good_guess, 9, [ "a", "b" ] },
    { "c", "_ _ b b _ _", :bad_guess,  8, [ "a", "b", "c" ] },
    { "d", "_ _ b b _ _", :bad_guess,  7, [ "a", "b", "c", "d" ] },
    { "e", "_ _ b b _ e", :good_guess, 7, [ "a", "b", "c", "d", "e" ] },
    { "f", "_ _ b b _ e", :bad_guess,  6, [ "a", "b", "c", "d", "e", "f" ] },
    { "g", "_ _ b b _ e", :bad_guess,  5, [ "a", "b", "c", "d", "e", "f", "g" ] },
    { "h", "_ _ b b _ e", :bad_guess,  4, [ "a", "b", "c", "d", "e", "f", "g", "h" ] },
    { "j", "_ _ b b _ e", :bad_guess,  3, [ "a", "b", "c", "d", "e", "f", "g", "h", "j" ] },
    { "k", "_ _ b b _ e", :bad_guess,  2, [ "a", "b", "c", "d", "e", "f", "g", "h", "j", "k" ] },
    { "m", "_ _ b b _ e", :bad_guess,  1, [ "a", "b", "c", "d", "e", "f", "g", "h", "j", "k", "m" ] },
    { "n", "_ _ b b _ e", :lost,       0, [ "a", "b", "c", "d", "e", "f", "g", "h", "j", "k", "m", "n" ] },
  ]

  describe "a losing game" do

    test "progresses through the states" do
      game = Game.new_game("wibble")

      Enum.reduce(@losing_states, game, fn ({ guess, was, stat, left, used }, game) ->
        { game, status, _guess } = Game.make_move(game, guess)

        assert status == stat
        assert Game.word_as_string(game) == was
        assert (Game.letters_used_so_far(game) |> Enum.sort) == used
        assert Game.turns_left(game) == left
        game
      end)
    end

  end

  
end
