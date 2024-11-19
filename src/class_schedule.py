import os
import json
import re
from datetime import datetime, timedelta
import pytz
from log_utils import print_log


def load_class_schedules_utc():
    """Load class schedules from a JSON file."""
    current_dir = os.path.dirname(os.path.abspath(__file__))
    json_file = os.path.join(current_dir, "../class_schedules_utc.json")
    with open(json_file, "r") as file:
        return json.load(file)


def extract_days_from_cron(cron_expression):
    """Extract the days from a cron expression."""
    days_match = re.search(r"\* ([A-Z,]+) \*", cron_expression)
    if days_match:
        return days_match.group(1).split(",")
    return []


def parse_cron_time(cron_expression):
    """Extract minute and hour from a cron expression."""
    match = re.search(r"cron\((\d+)\s+(\d+)\s+", cron_expression)
    if match:
        minute = int(match.group(1))
        hour = int(match.group(2))
        return minute, hour
    else:
        raise ValueError(f"Invalid cron expression: {cron_expression}")


def get_current_class():
    """Determine the current class based on UTC time."""
    class_schedules = load_class_schedules_utc()
    now_utc = datetime.now(pytz.utc)
    current_weekday = now_utc.strftime("%a").upper()

    for schedule in class_schedules:
        classname = schedule["iclicker_classname"]
        start_cron = schedule["start_time"]
        end_cron = schedule["end_time"]

        start_days = extract_days_from_cron(start_cron)

        if current_weekday not in start_days:
            print_log(
                f"Skipping {classname} because it is not scheduled today.")
            continue

        start_minute, start_hour = parse_cron_time(start_cron)
        end_minute, end_hour = parse_cron_time(end_cron)

        start_time = now_utc.replace(
            hour=start_hour, minute=start_minute, second=0, microsecond=0)
        end_time = now_utc.replace(
            hour=end_hour, minute=end_minute, second=0, microsecond=0)

        if end_time < start_time:
            end_time += timedelta(days=1)

        if start_time <= now_utc <= end_time:
            return {
                "classname": classname,
                "start_time": start_time,
                "end_time": end_time - timedelta(minutes=10)
            }
    return None
