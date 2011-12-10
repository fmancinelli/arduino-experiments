/* Arduino Led Fun
 * Copyright (C) 2011 - Fabio Mancinelli <fm@fabiomancinelli.org>
 * 
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 * 
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 * 
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
 */
#define LEDS 5

/* This array of arrays contains the led configuration for the different patterns. */
unsigned int pattern_data[14][LEDS] = {
 { LOW, LOW, LOW, LOW, LOW },   //Off pattern
 /***/
 { HIGH, LOW, LOW, LOW, LOW },  //Sequence pattern step 1 of 5
 { LOW, HIGH, LOW, LOW, LOW },  //Sequence pattern step 2 of 5
 { LOW, LOW, HIGH, LOW, LOW },  //Sequence pattern step 3 of 5
 { LOW, LOW, LOW, HIGH, LOW },  //Sequence pattern step 4 of 5
 { LOW, LOW, LOW, LOW, HIGH },  //Sequence pattern step 5 of 5
 /***/
 { HIGH, LOW, HIGH, LOW, HIGH}, //Alternate pattern step 1 of 2
 { LOW, HIGH, LOW, HIGH, LOW},  //Alternate pattern step 2 of 2
 /***/
 { HIGH, LOW, LOW, LOW, HIGH},  //In pattern step 1 of 3
 { LOW, HIGH, LOW, HIGH, LOW},  //In pattern step 2 of 3
 { LOW, LOW, HIGH, LOW, LOW},   //In pattern step 3 of 3
 /***/
 { LOW, LOW, HIGH, LOW, LOW},   //Out pattern step 1 of 3
 { LOW, HIGH, LOW, HIGH, LOW},  //Out pattern step 2 of 3
 { HIGH, LOW, LOW, LOW, HIGH}   //Out pattern step 3 of 3
};

/* This array contains the start and end indexes for the led configuration 
   described in the pattern_data array corresponding to a given pattern. */
unsigned int patterns[5][2] = {
  {0, 0},  // Start, end index for the Off pattern data
  {1, 5},  // Start, end index for the Sequence pattern data
  {6, 7},  // Start, end index for the Alternate pattern data
  {8, 10}, // Start, end index for the In pattern data
  {11, 13} // Start, end index for the Out pattern data
};

/* Pin configuration. */
const unsigned int button_pin = 2;
const unsigned int led_pins[LEDS] = {8, 9, 10, 11, 12};

unsigned int current_pattern = 0;

/* Delay to be waited before changing the pattern configuration. */
const unsigned int delay_length = 200;

/* Used to avoid to repeatedly change the state if the button is kept pressed */
unsigned int current_pattern_changed;

unsigned int counter;

/******************************************************************************/

void setup() {
  Serial.begin(9600);
  
  pinMode(button_pin, INPUT);

  for(int i = 0; i < LEDS; i++) {
    pinMode(led_pins[i], OUTPUT);
  }

  Serial.println("Arduino led fun initialized.");
}

/******************************************************************************/

void loop() {
  int button_state = digitalRead(button_pin);
    
  /* Check button state */
  if(button_state == LOW) {
    /* This checks prevents to change repeatedly the pattern if the button is
       pressed for a long time */
    if(current_pattern_changed == 0) {
      current_pattern = (current_pattern + 1) % (sizeof(patterns) / sizeof(patterns[0]));
    }
    
    current_pattern_changed = 1;
  }
  else {
    current_pattern_changed = 0;
  }
  
  /* Find the pattern start and end index in the pattern data */
  unsigned int pattern_start_index = patterns[current_pattern][0];
  unsigned int pattern_end_index = patterns[current_pattern][1];

  /* Compute how many steps the pattern has */
  unsigned int steps_in_current_pattern = pattern_end_index - pattern_start_index + 1;

  /* Find the current step based on the counter */
  unsigned int current_step = counter % steps_in_current_pattern;
  
  /* Get the led configuration for the current step */
  unsigned int *led_configuration = pattern_data[pattern_start_index + current_step];
  
  /* Write the led configuration for the current pattern step */
  for(int i = 0; i < LEDS; i++) {
    digitalWrite(led_pins[i], led_configuration[i]);
  }
     
  /* Next iteration */
  counter++;
  
  delay(delay_length);
}
