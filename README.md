# OCP Charge – A Semi-Autonomous Robotic EV Charging System

This repository contains the complete implementation of OCP Charge, a semi-autonomous robotic EV charging system designed for smart parking environments.  
The project integrates ANPR-based vehicle verification, Flutter mobile applications, and Arduino-based robot control to simulate a fully automated EV charging workflow.

---

## Repository Structure

| Folder / File | Description |
|----------------|-------------|
| **anpr_system** | Python-based ANPR (Automatic Number Plate Recognition) module for vehicle detection and access control. |
| **app_screenshots** | Screenshots of both the user-side and robot-side applications. |
| **arduino** | Arduino source code for motor control, obstacle detection, and robot movement logic. |
| **numberplates** | Test number plate images used for ANPR training and evaluation. |
| **ocp_charge_robot_app** | Flutter project for the robot-side tablet application (receives booking data and displays charging progress). |
| **ocp_charge_user_app** | Flutter project for the user-side mobile application (used to book EV charging, view status, and countdown). |
| **setup_pictures** | Contains setup images used in the demonstration video. |
| **Links.txt** | Contains all necessary links (demonstration, GitHub, blog) for the project. |
| **OCPCharge_PDE4439_Presentation.pptx** | Final presentation slides for project demonstration. |
| **PDE4439_DissertationReport_M00791121_OCPCharge.pdf** | Final dissertation report submitted for the project. |
| **anpr.py** | Main Python script implementing the ANPR logic (vehicle scanning, recognition, and access decision). |

---

## Key Features

- **Automatic Number Plate Recognition (ANPR)** using Python with OpenCV and Tesseract OCR  
- **Real-time booking and robot coordination** via Firebase Realtime Database  
- **Dual Flutter interfaces** – User-side booking app and Robot-side monitoring dashboard  
- **Autonomous robot navigation and obstacle avoidance** using Arduino and ultrasonic sensors  
- **Timed charging simulation and access control** based on verified bookings  

---

## How It Works

1. **User Booking**  
   - The user app allows EV drivers to book a charging robot by entering name, number plate, destination, and current charge level.  
   - The booking is sent to Firebase and synced in real-time with the robot app.

2. **Robot Deployment**  
   - The robot retrieves booking data and navigates autonomously to the assigned parking slot.  
   - ANPR verifies the incoming vehicle’s number plate before granting access.

3. **Charging Simulation**  
   - Once verified, the robot simulates charger connection and starts a countdown timer for charging.  
   - The system updates status in real-time on both user and robot apps.

---

## Technologies Used

- **Python** (OpenCV, Pytesseract) – ANPR and computer vision  
- **Flutter** – Mobile and tablet user interfaces  
- **Firebase Realtime Database** – Real-time communication between apps  
- **Arduino (Elegoo Smart Robot Car V4.1)** – Robot mobility and sensor control  
- **Laptop Webcam** – Camera streaming and object recognition  

---

## Author

**Reia Menezes (M00791121)**  
MSc Robotics, Middlesex University Dubai  
Project Supervisor: Dr. Judhi Prasetyo  

---

## Demonstration

The demonstration video showcases:
- Robot deployment and navigation  
- ANPR verification in action  
- Charging simulation workflow  
- Real-time synchronization between apps  

All setup and video frames can be found in the `setup_pictures` folder.

---

## How to Run

Download all the files, power on the robot, and use the Flutter applications to create a booking.

## Acknowledgement

Special thanks to Dr. Judhi for mentoring me throughout this process and for all his valuable feedback. Honorable mention to Dr. Sameer as well.
