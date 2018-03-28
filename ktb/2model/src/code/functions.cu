#include "functions.h"
#include "debugger.h"

using namespace std;

#define WARNINGS 0

long find_number_of_gpus() {

    char cmd[100] = "ls -a\0";


    array<char, 128> buffer;
    string result;
    shared_ptr<FILE> pipe(popen(cmd, "r"), pclose);
    if (!pipe) throw runtime_error("popen() failed!");
    while (!feof(pipe.get())) {
        if (fgets(buffer.data(), 128, pipe.get()) != nullptr)
            result += buffer.data();
    }
    cout << "GPU FINDER\n\n";
    cout << result << endl;
    //return result;
    

    //    find /proc/driver/nvidia/gpus -type d | wc -l

}

