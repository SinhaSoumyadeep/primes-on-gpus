#include "debugger.h"
#include "functions.h"

#define DEBUG 1
#define TRUE_RANDOM 0

using namespace std;

// Global Variables
long int db_size = 1000000; // 1 Million
long int max_cores = 128;
long int max_job_time = 10;
long int max_nodes = 32;
string res,jobs; // Placeholder. Not used


//**********   MAIN FUNCTION   **********


int main (int argc, char *argv[] ) {

if (DEBUG) cout << "\n\n\n\n\n\n\n\n\n\n\e[1;32mProgram Start\e[0m\n";

// Accepting input from Console
    switch (argc) { // For getting input from console
        case 6:
            long input_5;
            input_5 = atol(argv[5]); //Fifth Input
        case 5:
            long input_4;
            input_4 = atol(argv[4]); //Fourth Input
        case 4:
            long input_3;
            input_3 = atol(argv[3]); // Third Input
        case 3:
            long input_2;
            input_2 = atol(argv[2]); // Second Input
        case 2:
            long input_1;
            input_1 = atol(argv[1]); // First input // **** DB SIZE
            db_size = input_1;
            break;
        case 1:
            // Keep this empty
            break;
        default:
            cout << "FATAL ERROR: Wrong Number of Inputs" << endl; // If incorrect number of inputs are used.
            return 1;
    }
    
    
    
    cout << "Generating "<< db_size <<" data points to feed the Schedular simulator..." << endl;
    
    
    if (TRUE_RANDOM) {
        srand (time(NULL));
    }
    
    ofstream resources;
    resources.open ("resources.dat");
    
    string tuple;
    string comma = ",";
    for (long int i=0;i<db_size;i++) {
        tuple = to_string(rand() % max_nodes); // Will start from 0 and end at N - 1
        tuple += comma;
        tuple += to_string((rand() % max_cores)+1);
    	resources << tuple << "\n";
    }
    resources.close();
   
    cout << "Resource Data generation complete" << endl;
    
    if (TRUE_RANDOM) {
        srand (time(NULL));
    }
    
    ofstream jobs;
    jobs.open ("jobs.dat");
    
    for (long int i=0;i<db_size;i++) {
        tuple = to_string((rand() % max_cores)+1);
        if (rand() % 3) {
        tuple = to_string((rand() % (max_cores/4))+1);
        }
        tuple += comma;
        tuple += to_string((rand() % max_job_time)+1);
        jobs << tuple << "\n";
    }
    jobs.close();
    
    cout << "Jobs Data generation complete" << endl;


    cout << "\n\e[1;31mProgram End\e[0m\n\n\n";

    return 0;

}








