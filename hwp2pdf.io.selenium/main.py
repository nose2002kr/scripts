import os.path
import time
from shutil import rmtree
from zipfile import ZipFile as zip

from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support import expected_conditions
from selenium.webdriver.support.wait import WebDriverWait

def download_wait(directory, timeout, nfiles=None):
    """
    Wait for downloads to finish with a specified timeout.

    Args
    ----
    directory : str
        The path to the folder where the files will be downloaded.
    timeout : int
        How many seconds to wait until timing out.
    nfiles : int, defaults to None
        If provided, also wait for the expected number of files.

    """
    seconds = 0
    dl_wait = True
    while dl_wait and seconds < timeout:
        time.sleep(1)
        dl_wait = False
        files = os.listdir(directory)
        if nfiles and len(files) != nfiles:
            dl_wait = True

        for fname in files:
            if fname.endswith('.crdownload'):
                dl_wait = True

        seconds += 1
    return seconds

def hwp2pdf(directory, fileName):
    opt = webdriver.ChromeOptions()

    downloadDir = os.path.dirname(os.path.realpath(__file__)) + '\\downloads'
    if os.path.exists(downloadDir):
        rmtree(downloadDir)
    os.mkdir(downloadDir)

    prefs = {'download.default_directory': downloadDir}
    opt.add_experimental_option('prefs', prefs)
    driver = webdriver.Chrome('chromedriver.exe', options=opt)
    driver.get('https://hwp2pdf.io/')

    WebDriverWait(driver, 5).until(expected_conditions.presence_of_element_located(
        (By.ID, 'convert-select')
    ))

    convert = driver.find_element(value='convert-select')
    convert.send_keys(directory + '/' + fileName)

    convertBtn = driver.find_element(value='convertBtn')
    convertBtn.click()

    WebDriverWait(driver, 60).until(expected_conditions.visibility_of_element_located(
        (By.ID, 'downloadBtn')
    ))

    downloadBtn = driver.find_element(value='downloadBtn')
    downloadBtn.click()

    download_wait(downloadDir, 60)

    driver.quit()

    with zip(downloadDir  + '/preview_hwp2pdf.zip') as zip_ref:
        zip_ref.extractall(directory)

    os.remove(downloadDir + '/preview_hwp2pdf.zip')

if __name__ == '__main__':
    directory = 'C:/_work/etc/20221027_foxit,polaris/OneDrive_2022-10-27/SmartOffice test(Streamdocs Vu)/test_files_hwp'
    files = [
        # '01.hwp',
        # '02.hwp',
        # '03.hwp',
        # '04.hwp',
          # '05.hwp',
        # '06.hwp',
        # '07.hwp',
        # '08.hwp',
        # '09.hwp',
          # '10.hwp',
          #'11.hwp',
        '12.hwp',
        '13.hwp',
        '14.hwp',
        '15.hwp',
    ]
    for file in files:
        hwp2pdf(directory, file)

