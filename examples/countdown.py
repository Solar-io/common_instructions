#!/usr/bin/env python3
import datetime
import subprocess
from typing import List
import json

DISCORD_WEBHOOK_URL = "https://discord.com/api/webhooks/1295034682798243951/YmbNW2ScSHsdcVFIkU-HzrIxmalbcLTlSaYMYkR9cYWwggIZK62Njc1BiHpON0joztDf"
AVATAR_URL = "https://drive.google.com/uc?export=download&id=11kkuvm4XI0--cNC6A9rvFzUNj03BXG23"

def calculate_working_days_until(target_date: datetime.date) -> dict:
    today = datetime.date.today()
    days_count = 0
    current_date = today + datetime.timedelta(days=1)
    
    while current_date < target_date:
        if current_date.weekday() < 5:
            days_count += 1
        current_date += datetime.timedelta(days=1)
    
    if days_count > 20:
        months = days_count // 22
        remaining_days = days_count % 22
        weeks = remaining_days // 5
        days = remaining_days % 5
        return {"months": months, "weeks": weeks, "days": days, "total_days": days_count}
    elif days_count > 10:
        weeks = days_count // 5
        days = days_count % 5
        return {"weeks": weeks, "days": days, "total_days": days_count}
    else:
        return {"days": days_count, "total_days": days_count}

def send_discord_message(title: str, description: str, color: int = 65280):
    payload = {
        "embeds": [
            {
                "title": title,
                "description": description,
                "color": color
            }
        ],
        "avatar_url": AVATAR_URL
    }
    json_payload = json.dumps(payload)
    subprocess.run([
        'curl', '-H', 'Content-Type: application/json', '-X', 'POST',
        '-d', json_payload, DISCORD_WEBHOOK_URL
    ], check=True)

def format_time_remaining(result: dict) -> str:
    if "months" in result:
        parts = []
        if result["months"] > 0:
            parts.append(f"{result['months']} month{'s' if result['months'] > 1 else ''}")
        if result["weeks"] > 0:
            parts.append(f"{result['weeks']} week{'s' if result['weeks'] > 1 else ''}")
        if result["days"] > 0:
            parts.append(f"{result['days']} day{'s' if result['days'] > 1 else ''}")
        return ", ".join(parts)
    elif "weeks" in result:
        return f"{result['weeks']} week{'s' if result['weeks'] > 1 else ''}, {result['days']} day{'s' if result['days'] > 1 else ''}"
    else:
        return f"{result['days']} working day{'s' if result['days'] > 1 else ''}"

def send_countdown(dates: List[str], names: List[str]):
    today = datetime.date.today()
    countdown_message = f"Countdown from {today}:\n"
    future_events = [
        (datetime.datetime.strptime(date_str, "%Y-%m-%d").date(), name)
        for date_str, name in zip(dates, names)
        if datetime.datetime.strptime(date_str, "%Y-%m-%d").date() > today
    ]
    
    # Sort future_events by date
    future_events.sort(key=lambda x: x[0])
    
    if not future_events:
        return  # Exit without sending any message if no future events
    
    for target_date, name in future_events:
        result = calculate_working_days_until(target_date)
        formatted_time = format_time_remaining(result)
        countdown_message += f"- {name}: {formatted_time} left (until {target_date})\n"
    
    send_discord_message(
        title="Working Days Countdown",
        description=countdown_message,
        color=65280
    )

if __name__ == "__main__":
    dates = ["2025-03-02", "2025-05-31", "2025-04-04"]  # Replace with your dates
    names = ["Picture Time", "Florida Vacation", "Fishing Trip"]  # Replace with corresponding names

    send_countdown(dates, names)
