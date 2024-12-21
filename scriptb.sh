#!/bin/bash

ENDPOINT="http://localhost"

# Енергійно асинхронні HTTP-запити
while true; do
    delay=$((RANDOM % 6 + 5)) # Випадкова затримка в межах від 5 до 10 секунд
    (
        response=$(curl -s -o /dev/null -w "Запит до $ENDPOINT повернув статус %{http_code}\n" $ENDPOINT)
        echo "$response"
    ) &
    echo "Наступний запит через $delay секунд... Готуємося!"
    sleep $delay
done

