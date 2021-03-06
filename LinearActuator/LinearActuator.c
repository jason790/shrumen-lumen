#include <wiringPi.h>
#include <signal.h>
#include <stdio.h>
#include <sched.h>
#include <string.h>
#include <stdlib.h>
#include <curl/curl.h>
#include "cJSON.h"


#define GET_URL "http://localhost:3000/linearactuator"

//Digital Pin for setting direction
#define DIRECTION_PIN 6

//PWM Pin for setting speeds
#define PWM_PIN 12

// Setup a struct for strings
struct string {
  char *ptr;
  size_t len;
};

//Function for initializing string
void init_string(struct string *s) {
  s->len = 0;
  s->ptr = malloc(s->len+1);
  if (s->ptr == NULL) {
    fprintf(stderr, "malloc() failed\n");
    exit(EXIT_FAILURE);
  }
  s->ptr[0] = '\0';
}

//Writing data to the string
size_t writefunc(void *ptr, size_t size, size_t nmemb, struct string *s)
{
  size_t new_len = s->len + size*nmemb;
  s->ptr = realloc(s->ptr, new_len+1);
  if (s->ptr == NULL) {
    fprintf(stderr, "realloc() failed\n");
    exit(EXIT_FAILURE);
  }
  memcpy(s->ptr+s->len, ptr, size*nmemb);
  s->ptr[new_len] = '\0';
  s->len = new_len;

  return size*nmemb;
}

//Set an initial global state variable
//  1: Extending
//  0: Stopped
// -1: Retracting
int state = 0;

//Initialize the pins with correct types
void setup_gpio()
{
  pinMode(DIRECTION_PIN, OUTPUT);
  //pinMode(PWM_PIN, OUTPUT);
  softPwmCreate(PWM_PIN, 0, 100);
}

//A function that use the libcurl library to get the 
//linear actuator state from the Node.js server.
void getState(){
	
	CURL *curl;
	CURLcode res;

	curl_global_init(CURL_GLOBAL_DEFAULT);

	curl = curl_easy_init();
	
	if(curl) {
		struct string s;
		init_string(&s);
		curl_easy_setopt(curl, CURLOPT_URL, GET_URL);
		curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, writefunc);
		curl_easy_setopt(curl, CURLOPT_WRITEDATA, &s);

		/* Perform the request, res will get the return code */ 
		res = curl_easy_perform(curl);
				
		/* Check for errors */ 
		if(res != CURLE_OK){
			printf("Curl failed: %s.\n", curl_easy_strerror(res));
		} else if(s.len == 0){
			printf("Response is empty.\n");
		} else {
			printf("Server Response: %s\n", s.ptr);
			//Parse the string into JSON
			cJSON * json = cJSON_Parse(s.ptr);

			if(json == NULL){
				printf("JSON is null.\n");
			} else {
				//Get the state as an integer
				state = cJSON_GetObjectItem(json, "state")->valueint;
			
				//Delete the JSON object and free the string
				cJSON_Delete(json);
				printf("New State: %d\n", state);
				free(s.ptr);
			}
		}	
		/* always cleanup */ 
		curl_easy_cleanup(curl);
	} else {
		printf("Failed to set up curl.\n");
	}
	
	//Cleanup the CURLs info globablly.
	//One call to this paired with each globabl init.
	curl_global_cleanup();
}

void stopActuator() {
	printf("Stopping...\n");
	softPwmWrite(PWM_PIN, 0);
}

void retractActuator() {
	stopActuator();
	printf("Retracting...\n");
	digitalWrite(DIRECTION_PIN, HIGH);
	softPwmWrite(PWM_PIN, 100);
}

void extendActuator() {
	stopActuator();
	printf("Extending...\n");
	digitalWrite(DIRECTION_PIN, LOW);
	softPwmWrite(PWM_PIN, 100);
}

void signalHandler(int signal){
	printf("Handling signal: %d\n", signal);
	printf("Retracting actuator...\n");
	retractActuator();
	delay(1000);
	printf("Actuator Retracted. Ending program.\n");
	exit(signal);
}

int main(int argc, char **argv) {

	signal(SIGINT, signalHandler);

	//Setup WiringPi w/ GPIO pins
	if(wiringPiSetupGpio() == -1)
		exit(1);
	//~ Set the pins to the correct output types.
	setup_gpio();
	
	//Start the program by stopping the actuator
	stopActuator();
	
	while(1) {
		usleep(500 * 1000);
		
		//~ Run CURL GET command
		getState();
		
		printf("Current state: %d\n", state);
		if(state == 1) {
			extendActuator();
		}
		else if(state == 0) {
			stopActuator();
		}
		else if (state == -1){
			retractActuator();
		}			
	}
	
}
