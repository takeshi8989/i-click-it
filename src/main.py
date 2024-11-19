from log_utils import print_log
from ssm_utils import get_ssm_parameter
from selenium_utils import setup_selenium
from class_schedule import get_current_class
from iclicker_automation import (
    login_iclicker,
    click_class_section,
    wait_for_join_button,
    check_poll_status,
    submit_attendance
)
import time


def main():
    """Execute the main iClicker automation process."""
    print_log('Starting iClicker automation...')

    # Retrieve iClicker credentials from SSM Parameter Store
    print_log('Retrieving iClicker credentials from SSM Parameter Store...')
    email = get_ssm_parameter('/iclicker/email')
    password = get_ssm_parameter('/iclicker/password')

    # Determine the current class based on the schedule
    current_class = get_current_class()

    if current_class is None:
        print_log('No class is currently in session.')
        return

    class_name = current_class["classname"]
    end_time = current_class["end_time"]
    print_log(f"Class in session: {class_name}")

    # Set up Selenium WebDriver
    driver = setup_selenium()

    try:
        # Log in to iClicker
        login_iclicker(driver, email, password)

        # Join the class section
        click_class_section(driver, class_name)

        # Wait for the "Join" button to appear and click it
        join_clicked = wait_for_join_button(driver, end_time)

        # Polling loop to check for active quizzes and submit attendance
        if join_clicked:
            print_log('Waiting for polls...')
            poll_active = False
            while True:
                if check_poll_status(driver):
                    if not poll_active:
                        submit_attendance(driver)
                        poll_active = True
                else:
                    poll_active = False  # Reset if not on a poll page

                # Exit if the class has ended
                if time.time() > end_time.timestamp():
                    print_log('Class has ended.')
                    break

                time.sleep(30)  # Poll every 30 seconds

    finally:
        # Close the browser after the session ends
        driver.quit()
        print_log('iClicker automation completed.')


if __name__ == '__main__':
    main()
