#Multi Threaded Python script to send emails when dry contact relay
#triggers pins 23 or 24 on GPIO of Raspberry Pi. 

#Used to trigger emails when two separate dry contact relays close 
#while connected to GPIO pins 23 and 24 of a Raspberry Pi, either 
#relay can close and trigger an email, I use these to trigger 
#alerts to VictorOps for a legacy system that is not connected 
#to the internet but we needed notifications when the system had
#issues. 

import smtplib
#import RPi.GPIO as GPIO
import time
import threading
from gpiozero import Button
from signal import pause
  
#Email Variables
SMTP_SERVER = 'smtpserver.yoursmtpserver.com' #enter your smtp server
SMTP_PORT = 587 
EMAIL_USERNAME = 'youremail@yoursmtpserver.com' #enter the email address you want the email to come from


alarm1 = Button(23)
alarm2 = Button(24)

#Set GPIO pins to use BCM pin numbers
#GPIO.setmode(GPIO.BCM)
 
#Set digital pin 17(BCM) to an input
#GPIO.setup(17, GPIO.IN)
 
#Set digital pin 17(BCM) to an input and enable the pullup 
#GPIO.setup(17, GPIO.IN, pull_up_down=GPIO.PUD_UP)
 
#Event to detect button press
#GPIO.add_event_detect(17, GPIO.FALLING)
 
  
class Emailer:
    def sendmail(self, recipient, subject, content):
          
        #Create Headers
        headers = ["From: " + EMAIL_USERNAME, "Subject: " + subject, "To: " + recipient,
                   "MIME-Version: 1.0", "Content-Type: text/html"]
        headers = "\r\n".join(headers)
  
        #Connect to Email Server
        session = smtplib.SMTP(SMTP_SERVER, SMTP_PORT)
        session.ehlo()
        session.starttls()
        session.ehlo()
		
        #Send Email & Exit
        session.sendmail(EMAIL_USERNAME, recipient, headers + "\r\n\r\n" + content)
        session.quit
  
sender = Emailer()

def alarmloop1():
    while True:
        if alarm1.is_pressed:
            sendTo = 'recepient@yoursmtpserver.com' #enter the email address where the email is going to
            emailSubject = "Email Subject" #emter email subject
            emailContent = "There is an alarm on system at: " + time.ctime() #emter the email body content
            sender.sendmail(sendTo, emailSubject, emailContent)
            print("Email Sent")
 
        time.sleep(0.1)

def alarmloop2():
    while True:
        if alarm2.is_pressed:
            sendTo = 'recepient@yoursmtpserver.com' #enter the email address where the email is going to
            emailSubject = "Email Subject" #emter email subject
            emailContent = "There is an alarm on system at: " + time.ctime() #emter the email body content
            sender.sendmail(sendTo, emailSubject, emailContent)
            print("Email Sent")
 
        time.sleep(0.1)

thread1 = threading.Thread(target=alarmloop1)
thread1.start()

thread2 = threading.Thread(target=alarmloop2)
thread2.start()