#include "mbed.h"
AnalogIn analog_sensor(p20);

int main() {
    float eda_value;
    while(1) {
        wait(0.25); 
        eda_value = analog_sensor.read();
        printf("%f\n", eda_value);
    }
}
