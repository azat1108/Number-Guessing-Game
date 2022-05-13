#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

GAME(){
  # variable with number of guesses
  GUESSES_NUMBER=$(($GUESSES_NUMBER+1))
  # loop until GUESS is equal SECRET_NUMBER
  while [[ ! $GUESS = $SECRET_NUMBER ]]
  do
    # ask for an input until it is a number
    while [[ ! $GUESS =~ ^[0-9]+$ ]]
    do
      echo -e "That is not an integer, guess again:"
      read GUESS
    done
    
    if [[ $GUESS > $SECRET_NUMBER ]]
    then
      echo -e "It's lower than that, guess again:"
      read GUESS
    elif [[ $GUESS < $SECRET_NUMBER ]]
    then
      echo -e "It's higher than that, guess again:"
      read GUESS
    fi

    GUESSES_NUMBER=$(($GUESSES_NUMBER+1))
  done

  echo "You guessed it in $GUESSES_NUMBER tries. The secret number was $SECRET_NUMBER. Nice job!"
  INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(secret_number,user_id,number_of_guesses) VALUES($SECRET_NUMBER,(SELECT user_id FROM users WHERE username ='$USERNAME'),$GUESSES_NUMBER)")
}

# get usename
echo -e "\nEnter your username:"
read INPUT
# check if username is in database
USERNAME=$($PSQL "SELECT username FROM users WHERE username='$INPUT'")
if [[ -z $USERNAME ]]
then
  # insert new username
  INSERT_USERNAME_RESULT=$($PSQL "INSERT INTO users(username) VALUES('$INPUT')")
  USERNAME=$($PSQL "SELECT username FROM users WHERE username='$INPUT'")
  # message for new username
  echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."
else
  # message for existing username
  GAMES_PLAYED=$($PSQL "SELECT COUNT(game_id) FROM games WHERE user_id=(SELECT user_id FROM users WHERE username='$USERNAME')")
  BEST_GAME=$($PSQL "SELECT number_of_guesses FROM games WHERE user_id=(SELECT user_id FROM users WHERE username='$USERNAME') ORDER BY number_of_guesses LIMIT 1")
  echo -e "\nWelcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

SECRET_NUMBER=$((1 + $RANDOM % 1000))

echo -e "\nGuess the secret number between 1 and 1000:"
read GUESS
GAME
