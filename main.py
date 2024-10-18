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
from datetime import datetime
from classes import my_classes
import time
import os


def get_ssm_parameter(param_name):
    """Retrieve the parameter from SSM Parameter Store."""
    ssm = boto3.client('ssm', region_name='us-west-2')
    try:
        response = ssm.get_parameter(Name=param_name, WithDecryption=True)
        return response['Parameter']['Value']
    except (NoCredentialsError, PartialCredentialsError):
        print('Error fetching parameters.')
        return None


def setup_selenium():
    """Set up the Selenium WebDriver (Chrome in headless mode)."""
    chrome_options = Options()
    # chrome_options.add_argument('--headless')
    chrome_options.add_argument('--no-sandbox')
    chrome_options.add_argument('--disable-dev-shm-usage')
    chromedriver_path = os.path.join(
        os.path.dirname(__file__), 'bin', 'chromedriver'
    )
    service = Service(chromedriver_path)
    driver = webdriver.Chrome(service=service, options=chrome_options)
    return driver


def login_iclicker(driver, email, password):
    """Login to iClicker using Selenium."""
    driver.get('https://student.iclicker.com/#/login')

    # Enter the email and password
    WebDriverWait(driver, 15).until(EC.presence_of_element_located(
        (By.ID, 'input-email'))).send_keys(email)
    driver.find_element(By.ID, 'input-email').submit()

    WebDriverWait(driver, 10).until(EC.presence_of_element_located(
        (By.ID, 'input-password'))).send_keys(password)
    driver.find_element(By.ID, 'input-password').submit()

    # Click sign-in button
    WebDriverWait(driver, 10).until(
        EC.element_to_be_clickable((By.ID, 'sign-in-button'))).click()
    print('Signed in to iClicker.')


def join_class(driver, class_name):
    """Join the class using Selenium by partial matching of the class name."""
    # Use XPath to find elements where the text contains the class name
    WebDriverWait(driver, 10).until(
        EC.presence_of_element_located(
            (By.XPATH, f'//*[contains(text(), "{class_name}")]')
        )
    ).click()
    print(f'Joined class containing "{class_name}".')


def wait_for_join_button(driver, end_time, wait_time=30):
    """Wait until the 'Join' button appears, or exit if class ends."""
    button_found = False
    while not button_found:
        if datetime.now() > end_time:
            print('Class time is over, exiting polling loop...')
            print(end_time)
            print(datetime.now())
            break

        try:
            WebDriverWait(driver, wait_time).until(
                EC.element_to_be_clickable((By.XPATH, '//*[@id="btnJoin"]'))
            ).click()
            button_found = True
            print('Clicked Join button.')
        except Exception:
            print('Join button not found, retrying...')
            time.sleep(5)  # Wait 5 seconds before retrying

    return button_found


def check_poll_status(driver):
    """Check if the quiz (poll) is active."""
    try:
        # Polling URL typically contains '/poll'
        return '/poll' in driver.current_url
    except Exception as e:
        print(f'An error occurred while checking poll status: {str(e)}')
        return False


def submit_attendance(driver):
    """Submit the quiz answer for attendance (click on Multiple Choice A)."""
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
    # Retrieve iClicker credentials from SSM Parameter Store
    email = get_ssm_parameter('/iclicker/email')
    password = get_ssm_parameter('/iclicker/password')

    # Get today's date
    today = datetime.now().date()

    class_name = my_classes[0]['class_name']

    end_time: datetime = datetime.combine(
        today, datetime.strptime(my_classes[0]['end_time'], '%H:%M').time()
    )

    # Initialize Selenium
    driver = setup_selenium()

    # Login to iClicker
    login_iclicker(driver, email, password)
    join_class(driver, class_name)

    # Wait until the "Join" button appears
    join_clicked = wait_for_join_button(driver, end_time)

    # Polling loop to check for active quizzes and submit attendance
    if join_clicked:
        poll_active = False
        while datetime.now() < end_time:
            if check_poll_status(driver):
                if not poll_active:
                    submit_attendance(driver)
                    poll_active = True
            else:
                poll_active = False  # Reset if not on a poll page
            time.sleep(30)  # Poll every 30 seconds

    # Close the browser after completion
    driver.quit()


if __name__ == '__main__':
    main()
