#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"
echo -e "\n~~Salon Appointment~~\n"
MAIN_MENU() {
  # Main_Menu return meessage
  if [[ $1 ]]
  then
    echo -e "\n$1\n"
  fi
  # Create menu >> get service list from table
  SERVICE_LIST=$($PSQL "SELECT service_id, name FROM services")
  # Split
  echo "$SERVICE_LIST" | while read SERVICE_ID BAR MENU_SERVICE_NAME
  do
    echo "$SERVICE_ID) $MENU_SERVICE_NAME"
  done
  # Provide options and check if valid choice
  echo -e "\nPick a service we have to offer:"
  read SERVICE_ID_SELECTED 
  
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    MAIN_MENU "That's not a number choice, please try again!"
  else
    SERVICE_COUNT=$($PSQL "SELECT COUNT(service_id) FROM services")
    if [[ $SERVICE_ID_SELECTED = '0' || $SERVICE_ID_SELECTED -gt $SERVICE_COUNT ]]
    then
      MAIN_MENU "That's not a valid choice, please try again!"
    else
      # phone number
      echo -e "\nWhat's your phone number?"
      read CUSTOMER_PHONE

      CUSTOMER_PHONE_TEST=$($PSQL "SELECT phone FROM customers WHERE phone = '$CUSTOMER_PHONE';")
      if [[ -z $CUSTOMER_PHONE_TEST ]]
      then
        #don't have phone number in system, so add it, then ask for name?
        echo -e "\nI don't have a record for that phone number, what's your name?"
        read CUSTOMER_NAME
        ADD_CUSTOMER=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
        if [[ $ADD_CUSTOMER == 'INSERT 0 1' ]]
        then
          echo "added new customer with phone and number"
        fi
      fi
      # Ask for time
      SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED" | sed --regexp-extended 's/ //')
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'" | sed --regexp-extended 's/ //')
      echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
      read SERVICE_TIME
      # Insert time
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
      ADD_TIME=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
      if [[ $ADD_TIME == 'INSERT 0 1' ]]
      then
        echo "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
      fi
    fi
  fi
}
MAIN_MENU