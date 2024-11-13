"""
This module handles web scraping and automation tasks using Selenium WebDriver.

It interacts with AWS SSM Parameter Store for secure credential management.
"""

import boto3
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from botocore.exceptions import NoCredentialsError, PartialCredentialsError
from datetime import datetime, timezone, timedelta
import time
import os


def get_ssm_parameter(param_name):
    """Retrieve the parameter from SSM Parameter Store."""
    ssm = boto3.client('ssm', region_name='us-east-1')
    try:
        response = ssm.get_parameter(Name=param_name, WithDecryption=True)
        return response['Parameter']['Value']
    except (NoCredentialsError, PartialCredentialsError):
        print('Error fetching parameters.')
        return None


def setup_selenium():
    """Set up the Selenium WebDriver (Chrome in headless mode)."""
    print('Setting up Selenium...')
    chrome_options = Options()
    chrome_options.add_argument('--headless')
    chrome_options.add_argument('--no-sandbox')
    chrome_options.add_argument('--disable-dev-shm-usage')
    chrome_options.add_argument("--window-size=1920x1080")
    chromedriver_path = os.path.join(
        os.path.dirname(__file__), 'bin', 'chromedriver'
    )
    service = Service(chromedriver_path)
    driver = webdriver.Chrome(service=service, options=chrome_options)
    return driver


def login_iclicker(driver, email, password):
    print('Logging in to iClicker...')
    driver.get('https://student.iclicker.com/#/login')

    # Enter the email and password
    WebDriverWait(driver, 30).until(EC.presence_of_element_located(
        (By.ID, 'input-email'))).send_keys(email)
    driver.find_element(By.ID, 'input-email').submit()

    WebDriverWait(driver, 30).until(EC.presence_of_element_located(
        (By.ID, 'input-password'))).send_keys(password)
    driver.find_element(By.ID, 'input-password').submit()

    # Click sign-in button
    sign_in_button = WebDriverWait(driver, 30).until(
        EC.element_to_be_clickable((By.ID, 'sign-in-button'))
    )
    driver.execute_script("arguments[0].scrollIntoView();", sign_in_button)
    driver.execute_script("arguments[0].click();", sign_in_button)
    print('Signed in to iClicker.')


def click_class_section(driver, class_name):
    """Join the class using Selenium by partial matching of the class name."""
    print('Joining class...')
    # Use XPath to find elements where the text contains the class name
    WebDriverWait(driver, 30).until(
        EC.presence_of_element_located(
            (By.XPATH, f'//*[contains(text(), "{class_name}")]')
        )
    ).click()
    print(f'Joined class containing "{class_name}".')


def wait_for_join_button(driver, end_time, wait_time=30):
    """Wait until the 'Join' button appears, or exit if class ends."""
    print('Waiting for join button...')
    button_found = False
    while not button_found:
        if (datetime.now() > end_time):
            print('Class has ended, exiting...')
            return False
        try:
            join_button = WebDriverWait(driver, wait_time).until(
                EC.element_to_be_clickable((By.XPATH, '//*[@id="btnJoin"]'))
            )
            driver.execute_script("arguments[0].click();", join_button)
            button_found = True
            print('Clicked Join button.')
        except Exception:
            time.sleep(5)  # Wait 5 seconds before retrying

    return button_found


def check_poll_status(driver):
    """Check if the quiz (poll) is active."""
    print('Checking poll status...')
    try:
        # Polling URL typically contains '/poll'
        return '/poll' in driver.current_url
    except Exception as e:
        print(f'An error occurred while checking poll status: {str(e)}')
        return False


def submit_attendance(driver):
    """Submit the quiz answer for attendance (click on Multiple Choice A)."""
    print('Submitting attendance...')
    try:
        clicked = False
        print('Poll detected, attempting to submit attendance.')
        while not clicked:
            try:
                multiple_choice_a = WebDriverWait(driver, 10).until(
                    EC.element_to_be_clickable((By.ID, 'multiple-choice-a'))
                )
                multiple_choice_a.click()
                clicked = True
                print('Attendance submitted successfully (Multiple Choice A).')
            except Exception as e:
                print(f'Failed to click: {e}, retrying...')
                time.sleep(1)
    except Exception as e:
        print(f'An error occurred while submitting attendance: {str(e)}')


def main():
    """Execute the main iClicker automation process."""
    print('Starting iClicker automation...')
    print(datetime.now(timezone.utc))

    # Retrieve iClicker credentials from SSM Parameter Store
    print('Retrieving iClicker credentials from SSM Parameter Store...')
    email = get_ssm_parameter('/iclicker/email')
    password = get_ssm_parameter('/iclicker/password')

    # class_name = my_classes[0]['class_name']
    # if this is Monday, Wednesday, or Friday, use the first class

    class_name = 'CPSC 317'
    today = datetime.now().date()
    if today.weekday() in [1, 3]:
        class_name = 'PSYC_V 102'

    start_time = datetime.now()
    end_time = start_time + timedelta(minutes=90)

    # Initialize Selenium
    driver = setup_selenium()

    # Login to iClicker
    login_iclicker(driver, email, password)
    click_class_section(driver, class_name)

    # Wait until the "Join" button appears
    join_clicked = wait_for_join_button(driver, end_time)

    # Polling loop to check for active quizzes and submit attendance
    if join_clicked:
        poll_active = False
        while True:
            if check_poll_status(driver):
                if not poll_active:
                    submit_attendance(driver)
                    poll_active = True
            else:
                poll_active = False  # Reset if not on a poll page
            time.sleep(30)  # Poll every 30 seconds

    # Close the browser after completion
    driver.quit()
    print('iClicker automation completed.')


if __name__ == '__main__':
    main()
