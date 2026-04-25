from selenium import webdriver
from selenium.webdriver.firefox.options import Options
import time

options = Options()
options.add_argument("--headless") # شغّله بدون واجهة رسومية ليكون خفياً
options.set_preference("network.proxy.type", 1)
options.set_preference("network.proxy.http", "127.0.0.1")
options.set_preference("network.proxy.http_port", 8080) # عبر Burp Suite
options.set_preference("network.proxy.ssl", "127.0.0.1")
options.set_preference("network.proxy.ssl_port", 8080)

driver = webdriver.Firefox(options=options)
driver.get("https://yemenexam.net:44444/remote/login")
time.sleep(3)
print(driver.page_source) # اطبع الكود المصدري لتحليله
driver.quit()