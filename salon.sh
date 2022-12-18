#! /bin/bash

PSQL="psql --tuples-only --username=freecodecamp --dbname=salon -c "

echo -e "\n~~~~~ MY SALON ~~~~~"
echo -e "\nWelcome to My Salon, how can I help you?\n"

# Get services from the db
SERVICES=$($PSQL "SELECT service_id, name FROM services")
# Print the services
PRINT_SERVICES_FUNCTION () {
  if [[ ! -z $1 ]]
  then
    echo -e "\n$1"
  fi
  echo "$SERVICES" | while read SERVICE_IDS BAR SERVICE_NAMES
  do
    echo -e "$SERVICE_IDS) $SERVICE_NAMES"
  done
}
PRINT_SERVICES_FUNCTION

# Get the service_id from the user
read SERVICE_ID_SELECTED
# Check if the id is valid
SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
# if not
while [[ -z $SERVICE_NAME ]]
do
  PRINT_SERVICES_FUNCTION "I could not find that service. What would you like today?"
  read SERVICE_ID_SELECTED
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
done

# ask for a phone number to figure out if it is already a customer number
echo -e "\nWhat's your phone number?"
read CUSTOMER_PHONE
# Check the db for if the phone number already exists
CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
# if not
if [[ -z $CUSTOMER_NAME ]]
then
  echo -e "\nI don't have a record for that phone number, what's your name?"
  # read the new customer's name
  read CUSTOMER_NAME
  # insert the new customer into the DB
  INSERT_NEW_CUSTOMER=$($PSQL "INSERT INTO customers(name,phone) VALUES('$CUSTOMER_NAME','$CUSTOMER_PHONE')")
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
fi
# if yes
echo -e "\nWhat time would you like your"$SERVICE_NAME","$CUSTOMER_NAME"?"
# read the appointment time
read SERVICE_TIME
# insert the new data into the DB
CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
INSERT_NEW_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
echo -e "\nI have put you down for a"$SERVICE_NAME" at "$SERVICE_TIME","$CUSTOMER_NAME".\n"
