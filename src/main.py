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

    print_log('Retrieving iClicker credentials from SSM Parameter Store...')
    email = get_ssm_parameter('/iclicker/email')
    password = get_ssm_parameter('/iclicker/password')

    current_class = get_current_class()

    if current_class is None:
        print_log('No class is currently in session.')
        return

    class_name = current_class["classname"]
    end_time = current_class["end_time"]
    print_log(f"Class in session: {class_name}")

    driver = setup_selenium()

    try:
        login_iclicker(driver, email, password)

        click_class_section(driver, class_name)

        join_clicked = wait_for_join_button(driver, end_time)

        if join_clicked:
            print_log('Waiting for polls...')
            poll_active = False
            while True:
                if check_poll_status(driver):
                    if not poll_active:
                        submit_attendance(driver)
                        poll_active = True
                else:
                    poll_active = False

                # Exit if the class has ended
                if time.time() > end_time.timestamp():
                    print_log('Class has ended.')
                    break

                time.sleep(30)

    finally:
        driver.quit()
        print_log('iClicker automation completed.')


if __name__ == '__main__':
    main()
