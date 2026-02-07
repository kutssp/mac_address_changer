#!/bin/bash

# Скрипт для автоматической смены MAC-адреса на macOS High Sierra
# Запускается от root через launchd, поэтому sudo не нужен

# Логирование
LOG_FILE="/var/log/mac_changer.log"

# Автоматическое определение Wi-Fi интерфейса
# Ищем интерфейс с типом Wi-Fi
INTERFACE=$(networksetup -listallhardwareports | awk '/Wi-Fi|AirPort/{getline; print $2}')

# Если не нашли автоматически, пробуем стандартные варианты
if [ -z "$INTERFACE" ]; then
    for iface in en0 en1 en2; do
        if ifconfig "$iface" 2>/dev/null | grep -q "status: active\|inet"; then
            INTERFACE="$iface"
            break
        fi
    done
fi

# Если всё равно не нашли - выходим с ошибкой
if [ -z "$INTERFACE" ]; then
    echo "$(date): ОШИБКА - Не удалось определить Wi-Fi интерфейс" >> "$LOG_FILE"
    exit 1
fi

# Функция для генерации случайного MAC-адреса
generate_random_mac() {
    # Генерируем случайный MAC-адрес с локально администрируемым битом
    # Первый октет: четный + бит 0x02 установлен (locally administered)
    printf '%02x' $((0x$(openssl rand -hex 1) & 0xfe | 0x02))
    openssl rand -hex 5 | sed 's/\(..\)/:\1/g'
}

echo "========================================" >> "$LOG_FILE"
echo "$(date): Запуск смены MAC-адреса" >> "$LOG_FILE"
echo "$(date): Используется интерфейс: $INTERFACE" >> "$LOG_FILE"

# Сохраняем старый MAC для логирования
OLD_MAC=$(ifconfig "$INTERFACE" | grep ether | awk '{print $2}')

# Отключаем Wi-Fi (проверяем оба возможных пути к airport)
if [ -f "/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport" ]; then
    /System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -z 2>/dev/null
else
    # Альтернативный метод через networksetup
    networksetup -setairportpower "$INTERFACE" off
fi

# Небольшая пауза
sleep 1

# Генерируем новый MAC-адрес
NEW_MAC=$(generate_random_mac)

echo "$(date): Старый MAC: $OLD_MAC" >> "$LOG_FILE"
echo "$(date): Новый MAC: $NEW_MAC" >> "$LOG_FILE"

# Меняем MAC-адрес (без sudo - скрипт уже запущен от root)
ifconfig "$INTERFACE" ether "$NEW_MAC"

if [ $? -eq 0 ]; then
    echo "$(date): MAC-адрес успешно изменен" >> "$LOG_FILE"
else
    echo "$(date): ОШИБКА при смене MAC-адреса" >> "$LOG_FILE"
fi

# Ждем немного
sleep 2

# Включаем Wi-Fi обратно
networksetup -setairportpower "$INTERFACE" on

echo "$(date): Wi-Fi включен обратно" >> "$LOG_FILE"
echo "========================================" >> "$LOG_FILE"
