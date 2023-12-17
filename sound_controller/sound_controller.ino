#define ruido 9  // D9
#define posicao 8 // D8


void setup() {
  Serial.begin(9600);
  pinMode (A0, INPUT);
  pinMode (A4, INPUT);
  pinMode (ruido, OUTPUT);
  pinMode (posicao, OUTPUT);
}

void loop() {
  unsigned int output_sensor1 = analogRead(A0); 
  unsigned int output_sensor2 = analogRead(A4);
  
  if(output_sensor1 > 150 && output_sensor2 < 150){
    Serial.print("sensor 1: ");
    Serial.print(output_sensor1);
    Serial.print("\n");
    digitalWrite(posicao, HIGH);
    digitalWrite(ruido, HIGH);
    delay(400);
  } else if (output_sensor2 > 150 && output_sensor1 < 150) {
    Serial.print("sensor 2: ");
    Serial.print(output_sensor2);
    Serial.print("\n");
     digitalWrite(posicao, LOW);
    digitalWrite(ruido, HIGH);
    delay(400);
  } else if (output_sensor1 > 150 && output_sensor2 > 150 && output_sensor1 - output_sensor2 > 50) {
    Serial.print("sensor 1: ");
    Serial.print(output_sensor1);
    Serial.print("\n");
    digitalWrite(posicao, HIGH);
    digitalWrite(ruido, HIGH);
    delay(400);
  } else if (output_sensor1 > 150 && output_sensor2 > 150 && output_sensor2 - output_sensor1 > 50) {
    Serial.print("sensor 2: ");
    Serial.print(output_sensor2);
    Serial.print("\n");
    digitalWrite(posicao, LOW);
    digitalWrite(ruido, HIGH);
    Serial.print("\n");
    delay(400);
  }
  digitalWrite(ruido, LOW);
  digitalWrite(posicao, LOW);
}
