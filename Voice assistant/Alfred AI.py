import pyttsx3 
import speech_recognition as sr 
import pywhatkit 
import datetime 
import wikipedia 
import pyjokes 
from googlesearch import search 
import requests 
from bs4 import BeautifulSoup 
import time
import serial

#ser = serial.Serial('/dev/ttyACM0', 115200)
ser = serial.Serial('COM5', 115600)

# Initialize the text-to-speech engine 
engine = pyttsx3.init() 
engine.setProperty('rate', 144)

# Initialize the speech recognition engine 
recognizer = sr.Recognizer() 

# Flag to indicate if listening is active 
listening = False 

# Adjust the energy threshold for noisy environments 
energy_threshold = 500

engine.say("Your companion Alfred is awake")
time.sleep(1)  # Wait for 2 seconds
engine.say("How can I help you")

# Define a function to check if audio energy is above the threshold 
def is_above_threshold(audio): 
    energy = sum(abs(sample) for sample in audio) 
    return energy > energy_threshold 

def get_user_response(engine, recognizer): 
    # Use the microphone as the audio source with adjusted energy threshold 
    with sr.Microphone() as source: 
        recognizer.adjust_for_ambient_noise(source)  # Perform noise reduction 
        recognizer.energy_threshold = energy_threshold  # Set the adjusted threshold 
        print("Listening for your response...") 
        try: 
            audio = recognizer.listen(source, timeout=2) 
            # Convert speech to text 
            text = recognizer.recognize_google(audio, show_all=False, language="en_US") 
            print("You said:", text) 
            return text 
        except sr.UnknownValueError: 
            print("Sorry, I couldn't understand.") 
        except sr.RequestError as e: 
            print("Could not request results from Google Speech Recognition service; {0}".format(e)) 
    return "" 

#google search stuff
def search_google(query):
    try:
        # Perform the Google search and get the HTML content of the results page
        url = f"https://www.google.com/search?q={query}&num=1"
        headers = {"User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.3"}
        response = requests.get(url, headers=headers)
        soup = BeautifulSoup(response.content, "html.parser")
        # Extract the abstract from the search result
        abstract = soup.find("div", class_="BNeawe s3v9rd AP7Wnd").get_text()
        # Speak the abstract using the text-to-speech engine
        print(abstract)
        engine.say(abstract)
        engine.runAndWait()
    except Exception as e:
        print(f"Error: {e}")
        engine.say("Sorry, I couldn't perform the Google search.")
        engine.runAndWait()

# Define a function to handle Wikipedia searches 
def search_wikipedia(query): 
    try: 
        info = wikipedia.summary(query, sentences=2, auto_suggest=False) 
        print(info) 
        engine.say(info) 
        engine.runAndWait() 
    except (wikipedia.exceptions.DisambiguationError, wikipedia.exceptions.PageError): 
        engine.say("I'm sorry, I couldn't find a specific result for that query.") 
        engine.runAndWait() 

# Define a function to handle playing songs on YouTube 
def play_song(song): 
    engine.say(f"Playing {song}") 
    engine.runAndWait() 
    pywhatkit.playonyt(song) 

# Define a function to get the current time 
def get_time(): 
    current_time = datetime.datetime.now().strftime('%I:%M %p') 
    engine.say(f'The current time is {current_time}') 
    engine.runAndWait() 

def move_forward():
    command = "F"
    ser.write(command.encode())
    time.sleep(1)    

def move_backward():
    command = "B"
    ser.write(command.encode())
    time.sleep(1)    

def turn_right():
    command = "R"
    ser.write(command.encode())
    time.sleep(1)    

def turn_left():
    command = "L"
    ser.write(command.encode())
    time.sleep(1)

def stop_moving():
    command = "S"
    ser.write(command.encode())
    time.sleep(1)

def spin():
    command = "E"
    ser.write(command.encode())
    time.sleep(1)

def med():
    command = "M"
    ser.write(command.encode())
    time.sleep(1)
# Define a function to handle commands 
def handle_command(command): 
    if "who is" in command: 
        try: 
            person = command.split("who is")[1].strip() 
            info = wikipedia.summary(person , sentences=2) 
            print(info) 
            engine.say(info) 
            engine.runAndWait() 
        except (wikipedia.exceptions.DisambiguationError, wikipedia.exceptions.PageError): 
            engine.say("I'm sorry, I couldn't find a specific result for that query.") 
            engine.runAndWait() 
    elif "play" in command: 
        song = command.replace("play", "").strip() 
        play_song(song)
    elif "about you" in command:
        engine.say("Hi i am Alfred your health care companion, Designed to help patients those who need assistant, i can dispense medicine , can be your personal companion ,can provide entertainment and much more")
    elif "about yourself" in command:
        engine.say("Hi i am Alfred your health care companion, Designed to help patients those who need assistant, i can dispense medicine , can be your personal companion ,can provide entertainment and much more")
    elif "time" in command: 
        get_time()
    elif "move forward" in command: 
        move_forward() 
    elif "move backward" in command: 
        move_backward()
    elif "turn right" in command: 
        turn_right()
    elif "turn left" in command: 
        turn_left()
    elif "stop" in command: 
        stop_moving() 
    elif "spin" in command: 
        spin() 
    elif "time" in command: 
        get_time() 
    elif "dispense" in command:
        med()
    elif "search Google about" in command: 
        query = command.replace("search Google about", "").strip() 
        search_google(query) 
    elif "what is" in command: 
        query = command.replace("search Google about", "").strip() 
        search_google(query)     
    elif "joke" in command: 
        joke = pyjokes.get_joke() 
        engine.say(joke) 
        engine.runAndWait() 

# Start an infinite loop to listen for commands 
while True: 
    if not listening: 
        # Use the microphone as the audio source with adjusted energy threshold 
        with sr.Microphone() as source: 
            recognizer.adjust_for_ambient_noise(source)  # Perform noise reduction 
            recognizer.energy_threshold = energy_threshold  # Set the adjusted threshold 
            print("Ready for your commands...") 
            audio = recognizer.listen(source) 
        try: 
            # Convert speech to text 
            text = recognizer.recognize_google(audio, show_all=False, language="en_US") 
            print("You said:", text) 
            # Check for the wake word "Alfred" 
            if "Alfred" in text: 
                listening = True 
                engine.say("Listening...") 
                engine.runAndWait() 
        except sr.UnknownValueError: 
            print("Sorry, I couldn't understand.") 
        except sr.RequestError as e: 
            print("Could not request results from Google Speech Recognition service; {0}".format(e)) 
    else: 
        # Use the microphone as the audio source with adjusted energy threshold 
        with sr.Microphone() as source: 
            recognizer.adjust_for_ambient_noise(source)  # Perform noise reduction 
            recognizer.energy_threshold = energy_threshold  # Set the adjusted threshold 
            print("Listening for commands...") 
            audio = recognizer.listen(source) 
        try: 
            # Convert speech to text 
            text = recognizer.recognize_google(audio, show_all=False, language="en_US") 
            print("You said:", text) 
            # Check for the stop word "Stop listening" 
            if "see you later" in text: 
                listening = False 
                engine.say("Call me anytime if you need my help") 
                engine.runAndWait() 
            else: 
                handle_command(text) 
        except sr.UnknownValueError: 
            print("Sorry, I couldn't understand.") 
        except sr.RequestError as e: 
            print("Could not request results from Google Speech Recognition service; {0}".format(e))