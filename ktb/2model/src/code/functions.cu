#include "functions.h"
#include "debugger.h"

using namespace std;

#define WARNINGS 0

long find_number_of_gpus() {
    // System command to find number of GPUs attached 
    // find /proc/driver/nvidia/gpus -type d | wc -l

    char cmd[100] = "find /proc/driver/nvidia/gpus -type d | wc -l\0";
    array<char, 128> buffer;
    string result;
    shared_ptr<FILE> pipe(popen(cmd, "r"), pclose);
    if (!pipe) throw runtime_error("popen() failed!");
    while (!feof(pipe.get())) {
        if (fgets(buffer.data(), 128, pipe.get()) != nullptr)
            result += buffer.data();
    }
    long number_of_gpus = (long)stoi(result);
    number_of_gpus--; // The systems command returns a value which is
    // one more than the actual number of GPUs.
    return (number_of_gpus);

}

