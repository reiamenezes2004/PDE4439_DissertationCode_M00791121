#include <Servo.h>

// === motor pins ===
const int ENA = 5;   // left motor speed (pwm)
const int IN1 = 4;
const int IN2 = 3;
const int ENB = 6;   // right motor speed (pwm)
const int IN3 = 8;
const int IN4 = 7;

// === servo and ultrasonic pins ===
Servo scanServo;
const int servoPin = 10;   // servo signal pin
const int trigPin = 11;    // ultrasonic trigger
const int echoPin = 12;    // ultrasonic echo

// === line tracking sensor pins ===
const int leftSensor = A0;
const int centerSensor = A1;
const int rightSensor = A2;

// === speed and distance settings ===
int baseSpeed = 100;     // drive speed
int turnSpeed = 80;      // turning speed
int stopDistance = 15;   // obstacle distance in cm

void setup() {
  // motor setup
  pinMode(ENA, OUTPUT); pinMode(IN1, OUTPUT); pinMode(IN2, OUTPUT);
  pinMode(ENB, OUTPUT); pinMode(IN3, OUTPUT); pinMode(IN4, OUTPUT);

  // ultrasonic setup
  pinMode(trigPin, OUTPUT);
  pinMode(echoPin, INPUT);

  // line sensors setup
  pinMode(leftSensor, INPUT);
  pinMode(centerSensor, INPUT);
  pinMode(rightSensor, INPUT);

  // servo setup
  scanServo.attach(servoPin);
  scanServo.write(90);  // center

  Serial.begin(9600);
  Serial.println("car ready with obstacle avoidance and line tracking");
}

void loop() {
  // check for obstacle ahead
  bool obstacle = detectObstacle();

  if (obstacle) {
    Serial.println("obstacle detected - backing up");
    moveBackward();
    delay(600);  // move backwards
    stopMotors();
    delay(1000); // small pause before retry
  } else {
    followLine();
  }
}

// === ultrasonic distance reading ===
long getDistance() {
  digitalWrite(trigPin, LOW); delayMicroseconds(2);
  digitalWrite(trigPin, HIGH); delayMicroseconds(10);
  digitalWrite(trigPin, LOW);

  long duration = pulseIn(echoPin, HIGH, 20000); // 20ms timeout
  if (duration == 0) return -1; // no reading
  return duration * 0.034 / 2;  // convert to cm
}

// === obstacle detection ===
bool detectObstacle() {
  scanServo.write(90);  // look forward
  delay(100);
  int dist = getDistance();
  Serial.print("distance: "); Serial.println(dist);
  return (dist > 0 && dist < stopDistance);
}

// === line tracking logic ===
void followLine() {
  int left = digitalRead(leftSensor);
  int center = digitalRead(centerSensor);
  int right = digitalRead(rightSensor);

  // print sensor state
  Serial.print("L:"); Serial.print(left);
  Serial.print(" C:"); Serial.print(center);
  Serial.print(" R:"); Serial.println(right);

  // center line (only middle sensor sees black)
  if (center == 0 && left == 1 && right == 1) {
    moveForward();
  }
  // line curving left (left sensor black)
  else if (left == 0) {
    turnLeft();
  }
  // line curving right (right sensor black)
  else if (right == 0) {
    turnRight();
  }
  // all white or all black - stop 
  else {
    stopMotors();
  }

  delay(50);
}

// === motor control functions ===
void moveForward() {
  digitalWrite(IN1, HIGH); digitalWrite(IN2, HIGH);
  analogWrite(ENA, baseSpeed);
  digitalWrite(IN3, LOW); digitalWrite(IN4, LOW);
  analogWrite(ENB, baseSpeed);
}

void moveBackward() {
  digitalWrite(IN1, LOW); digitalWrite(IN2, HIGH);
  analogWrite(ENA, baseSpeed);
  digitalWrite(IN3, HIGH); digitalWrite(IN4, LOW);
  analogWrite(ENB, baseSpeed);
}

void turnLeft() {
  digitalWrite(IN1, LOW); digitalWrite(IN2, HIGH);
  analogWrite(ENA, turnSpeed);
  digitalWrite(IN3, HIGH); digitalWrite(IN4, LOW);
  analogWrite(ENB, turnSpeed);
}

void turnRight() {
  digitalWrite(IN1, HIGH); digitalWrite(IN2, LOW);
  analogWrite(ENA, turnSpeed);
  digitalWrite(IN3, LOW); digitalWrite(IN4, HIGH);
  analogWrite(ENB, turnSpeed);
}

void stopMotors() {
  analogWrite(ENA, 0);
  analogWrite(ENB, 0);
}
