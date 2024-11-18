import json
from datetime import date, datetime
import pytz

# Define Vancouver and UTC time zones
vancouver_tz = pytz.timezone("America/Vancouver")
utc_tz = pytz.utc

# Load class schedules
with open("class_schedules.json", "r") as f:
    class_schedules = json.load(f)

utc_schedules = []

for schedule in class_schedules:
    classname = schedule["classname"]
    start_time = schedule["start_time"]
    end_time = schedule["end_time"]
    days = schedule["days"]

    # Parse start time and convert to UTC
    start_dt = vancouver_tz.localize(datetime.combine(
        date.today(), datetime.strptime(start_time, "%H:%M").time()))
    start_utc = start_dt.astimezone(utc_tz)
    start_hour = start_utc.hour
    start_minute = start_utc.minute

    # Parse end time and convert to UTC
    end_dt = vancouver_tz.localize(datetime.combine(
        date.today(), datetime.strptime(end_time, "%H:%M").time()))
    end_utc = end_dt.astimezone(utc_tz)
    end_hour = end_utc.hour
    end_minute = end_utc.minute

    # Define a mapping of days of the week to their index and vice versa
    days_of_week = ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"]

    # Handle day shifts for end time if needed
    if end_utc.day > start_utc.day:
        # Shift each day to the next day in the week
        shifted_days = [
            days_of_week[(days_of_week.index(day) + 1) % 7] for day in days]
        print("Shifted days for", classname, ":", shifted_days, days)
    else:
        shifted_days = days

    # Create cron expressions
    start_cron = f"cron({start_minute} {start_hour} ? * {','.join(days)} *)"
    end_cron = f"cron({end_minute} {end_hour} ? * {','.join(shifted_days)} *)"

    utc_schedules.append({
        "classname": classname,
        "start_time": start_cron,
        "end_time": end_cron
    })

# Save the UTC schedules
with open("class_schedules_utc.json", "w") as f:
    json.dump(utc_schedules, f, indent=2)

print("Conversion complete! Check 'class_schedules_utc.json'.")
