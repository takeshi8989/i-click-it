from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from log_utils import print_log
from datetime import datetime
import time


def login_iclicker(driver, email, password):
    """Log in to iClicker."""
    print_log('Logging in to iClicker...')
    driver.get('https://student.iclicker.com/#/login')

    # Enter email
    WebDriverWait(driver, 30).until(EC.presence_of_element_located(
        (By.ID, 'input-email'))).send_keys(email)
    driver.find_element(By.ID, 'input-email').submit()

    # Enter password
    WebDriverWait(driver, 30).until(EC.presence_of_element_located(
        (By.ID, 'input-password'))).send_keys(password)
    driver.find_element(By.ID, 'input-password').submit()

    # Click the sign-in button
    sign_in_button = WebDriverWait(driver, 30).until(
        EC.element_to_be_clickable((By.ID, 'sign-in-button'))
    )
    driver.execute_script("arguments[0].click();", sign_in_button)
    print_log('Logged in to iClicker.')


def click_class_section(driver, class_name):
    """Join the class using Selenium by partial matching of the class name."""
    print_log(f'Joining class containing "{class_name}"...')
    WebDriverWait(driver, 30).until(
        EC.presence_of_element_located(
            (By.XPATH, f'//*[contains(text(), "{class_name}")]')
        )
    ).click()
    print_log(f'Joined class containing "{class_name}".')


def wait_for_join_button(driver, end_time, wait_time=30):
    """Wait until the 'Join' button appears, or exit if the class ends."""
    print_log('Waiting for join button...')
    button_found = False
    while not button_found:
        if datetime.now().timestamp() > end_time.timestamp():
            print_log('Class has ended, exiting...')
            return False
        try:
            join_button = WebDriverWait(driver, wait_time).until(
                EC.element_to_be_clickable((By.XPATH, '//*[@id="btnJoin"]'))
            )
            driver.execute_script("arguments[0].click();", join_button)
            button_found = True
            print_log('Clicked Join button.')
        except Exception:
            time.sleep(5)
    return button_found


def check_poll_status(driver):
    """Check if the poll (quiz) is active."""
    try:
        return '/poll' in driver.current_url
    except Exception as e:
        print_log(f'Error checking poll status: {e}')
        return False


def submit_attendance(driver):
    """Submit attendance by selecting the 'Multiple Choice A' option."""
    print_log('Poll detected, attempting to submit attendance...')
    try:
        clicked = False
        while not clicked:
            try:
                multiple_choice_a = WebDriverWait(driver, 10).until(
                    EC.element_to_be_clickable((By.ID, 'multiple-choice-a'))
                )
                multiple_choice_a.click()
                clicked = True
                print_log(
                    'Attendance submitted successfully (Multiple Choice A).')
            except Exception as e:
                print_log(f'Failed to submit attendance: {e}, retrying...')
                time.sleep(1)
    except Exception as e:
        print_log(f'Error during attendance submission: {e}')
