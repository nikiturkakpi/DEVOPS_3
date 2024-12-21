#!/bin/bash

# Функція для ініціалізації контейнера
initialize_container() {
    if sudo docker ps -a --format "{{.Names}}" | grep -q "^$1$"; then
        echo "Контейнер $1 вже існує. Видаляю його..."
        sudo docker rm -f "$1"
    fi
    echo "Створюю контейнер $1 на CPU ядрі #$2"
    sudo docker run --name "$1" --cpuset-cpus="$2" --network bridge -d nikiturkakpi/myprogram
}

# Функція для завершення роботи контейнера
shutdown_container() {
    echo "Зупинка контейнера $1"
    sudo docker kill "$1" && sudo docker rm "$1"
}

# Функція для перевірки завантаження CPU контейнера
retrieve_cpu_usage() {
    sudo docker stats --no-stream --format "{{.Name}} {{.CPUPerc}}" | grep "$1" | awk '{print $2}' | sed 's/%//'
}

# Функція для визначення ядра CPU для контейнера
determine_cpu_core() {
    case $1 in
        main_service) echo "0" ;;
        secondary_service) echo "1" ;;
        auxiliary_service) echo "2" ;;
        *) echo "0" ;;
    esac
}

# Функція для оновлення контейнерів у разі наявності нового образу
refresh_container_images() {
    echo "Перевірка доступності нових образів..."
    pull_result=$(sudo docker pull nikiturkakpi/myprogram | grep "Downloaded newer image")
    if [ -n "$pull_result" ]; then
        echo "Знайдено новий образ. Оновлюю контейнери..."
        for container in main_service secondary_service auxiliary_service; do
            if sudo docker ps --format "{{.Names}}" | grep -q "^$container$"; then
                echo "Оновлення $container..."
                temp_container="${container}_temp"
                initialize_container "$temp_container" "$(determine_cpu_core "$container")"
                shutdown_container "$container"
                sudo docker rename "$temp_container" "$container"
                echo "$container оновлено."
            fi
        done
    else
        echo "Нові образи відсутні."
    fi
}

# Функція для моніторингу контейнерів та динамічного управління
supervise_containers() {
    while true; do
        # Перевірка та запуск основного контейнера
        if sudo docker ps --format "{{.Names}}" | grep -q "main_service"; then
            cpu_main=$(retrieve_cpu_usage "main_service")
            if (( $(echo "$cpu_main > 30.0" | bc -l) )); then
                echo "main_service перевантажений. Запуск secondary_service..."
                if ! sudo docker ps --format "{{.Names}}" | grep -q "secondary_service"; then
                    initialize_container "secondary_service" 1
                fi
            fi
        else
            initialize_container "main_service" 0
        fi

        # Перевірка та запуск резервного контейнера
        if sudo docker ps --format "{{.Names}}" | grep -q "secondary_service"; then
            cpu_secondary=$(retrieve_cpu_usage "secondary_service")
            if (( $(echo "$cpu_secondary > 30.0" | bc -l) )); then
                echo "secondary_service перевантажений. Запуск auxiliary_service..."
                if ! sudo docker ps --format "{{.Names}}" | grep -q "auxiliary_service"; then
                    initialize_container "auxiliary_service" 2
                fi
            fi
        fi

        # Зупинка простоюючих контейнерів
        for container in auxiliary_service secondary_service; do
            if sudo docker ps --format "{{.Names}}" | grep -q "$container"; then
                cpu=$(retrieve_cpu_usage "$container")
                if (( $(echo "$cpu < 1.0" | bc -l) )); then
                    echo "$container простоює. Зупинка..."
                    shutdown_container "$container"
                fi
            fi
        done

        # Оновлення контейнерів
        refresh_container_images
        sleep 120
    done
}

# Запуск моніторингу
supervise_containers