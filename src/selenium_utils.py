import os
from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.chrome.options import Options
from log_utils import print_log


def setup_selenium():
    """Set up the Selenium WebDriver (Chrome in headless mode)."""
    print_log('Setting up Selenium...')
    chrome_options = Options()
    chrome_options.add_argument('--headless')
    chrome_options.add_argument('--no-sandbox')
    chrome_options.add_argument('--disable-dev-shm-usage')
    chrome_options.add_argument("--window-size=1920x1080")

    chromedriver_path = os.path.join(
        os.path.dirname(os.path.abspath(__file__)),
        '..',
        'bin',
        'chromedriver'
    )
    service = Service(chromedriver_path)
    driver = webdriver.Chrome(service=service, options=chrome_options)
    return driver
