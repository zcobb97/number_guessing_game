#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess --tuples-only -c"

echo -e "\nEnter your username:\n"

read ENTERED_USERNAME

USER_DATA=$($PSQL "SELECT * FROM users WHERE username = '$ENTERED_USERNAME'")

if [[ -z $USER_DATA ]]
then
  echo -e "\nWelcome, $ENTERED_USERNAME! It looks like this is your first time here.\n"
  NEW_USER_DATA=$($PSQL "INSERT INTO users(username, games_played, best_game) VALUES('$ENTERED_USERNAME', 0, 0)")
else
  echo "$USER_DATA" | while read USERNAME BAR GAMES_PLAYED BAR BEST_GAME
  do
    echo -e  "\nWelcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses.\n"
  done
fi

MYSTERY_NUMBER=$(( RANDOM % 1000 + 1 ))

GUESS_COUNT=0

ANSWER=0

while [[ $ANSWER -ne 1 ]]
do
  echo -e "\nGuess the secret number between 1 and 1000:\n"

  read GUESS

  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    echo -e "That is not an integer, guess again:\n"
    continue
  fi

  if [[ $GUESS -eq $MYSTERY_NUMBER ]]
  then
    ANSWER=1
  elif [[ $GUESS -lt $MYSTERY_NUMBER ]]
  then
    echo -e "It's higher than that, guess again:\n"
    (( GUESS_COUNT++ ))

  elif [[ $GUESS -gt $MYSTERY_NUMBER ]]
  then
    echo -e "\nIt's lower than that, guess again:\n"
    (( GUESS_COUNT++ ))
  fi
done
MY_GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE username = '$ENTERED_USERNAME'")
MY_BEST_GUESS=$($PSQL "SELECT best_game FROM users WHERE username = '$ENTERED_USERNAME'")
(( MY_GAMES_PLAYED++ ))
MY_GAMES_PLAYED_UPDATED=$($PSQL "UPDATE users SET games_played = $MY_GAMES_PLAYED WHERE username = '$ENTERED_USERNAME'")
if [[ $GUESS_COUNT -lt $MY_BEST_GUESS ]]
then
  MY_BEST_GUESS_UPDATED=$($PSQL "UPDATE users SET best_game = $GUESS_COUNT WHERE username = '$ENTERED_USERNAME'")
elif [[ $MY_BEST_GUESS -eq 0 ]]
then
  MY_BEST_GUESS_UPDATED=$($PSQL "UPDATE users SET best_game = $GUESS_COUNT WHERE username = '$ENTERED_USERNAME'")
fi

echo -e  "\nYou guessed it in $GUESS_COUNT tries. The secret number was $MYSTERY_NUMBER. Nice job!\n"
