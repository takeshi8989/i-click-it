from datetime import datetime
import pytz


def print_log(message, tz='America/Vancouver'):
    """Log a message with a timestamp in the specified timezone."""
    print(f"{datetime.now(pytz.timezone(tz))}: {message}")
