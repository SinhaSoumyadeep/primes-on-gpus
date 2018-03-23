#include "debugger.h"
#include "functions.h"

#define DEBUG 0
#define DEBUG2 0
#define ADD_JOBS 10000
#define ADD_NODES 10
#define RND 0
//#define STAT_V 10

using namespace std;

// Global Variables
long fifs = 1;
long tetris = 1;
long batch_size = 100;
long STAT_V = 1000;
//string res,jobs;

long int db_size = 1000000; // 1 Million

long int max_cores = 128;
long int max_job_time = 10;
long int max_nodes = 32;

#define NODE_MAX_JOBS max_cores // Equal to Max cores per node

/*
 struct TheJob {
 long int id = -1; // Will be unique per job
 long int required_cores = -1;
 long int duration = -1;
 long int duration_left = -1;
 bool valid = false;
 };
 
 struct CompNode {
 long int id = -1;
 long int node_number = -1;
 long int total_cores= -1;
 long int used_cores = -1;
 long int free_cores = -1;
 TheJob NodeJob[NODE_MAX_JOBS]; // All Zero Initially
 long int node_job_queue = 0;
 
 };
 */




//**********   MAIN FUNCTION   **********


int main (int argc, char *argv[] ) {
    db_size = 100000; // Start with default value of 1 Lac.
    
    
    
    
    cout << "\n\n\n\n\n\n\n\n\n\n\e[1;32mProgram Start\e[0m\n\n";
    
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
            STAT_V = input_3;
        case 3:
            long input_2;
            input_2 = atol(argv[2]); // Second Input
            db_size = input_2;
        case 2:
            long input_1;
            input_1 = atol(argv[1]); // First input // Mode Fifs = 1 or Tetris = 2 Both = 3
            if (input_1 == 1) {
                fifs = 1;
                tetris = 0;
            } else if (input_1 == 2) {
                fifs = 0;
                tetris = 1;
            } else if (input_1 == 3) {
                fifs = 1;
                tetris = 1;
            } else {
                cout << "Incorrect Mode Number" << endl;
                cout << "Enter 1 for FIFS or 2 for Tetris mode or 3 for executing Both" << endl;
                exit(1);
            }
            break;
        case 1:
            // Keep this empty
            break;
        default:
            cout << "FATAL ERROR: Wrong Number of Inputs" << endl; // If incorrect number of inputs are used.
            return 1;
    }

    bool print_to_file = false;
    if (db_size < 500) {
        print_to_file = true;
    }
    
    TheJob *data_jobs;
    CompNode *data_nodes;
    
    data_jobs = new TheJob[db_size*10];
    data_nodes = new CompNode[db_size*10];
    
    cout << "Generating Database of Job Tuples and Node Tuples" << endl;
    cout << "Database (Stream) size, Jobs:\t" << db_size << "\tNodes:\t" << db_size << "\tMax Cores:\t" << 128 << endl << endl;
    generate_data(data_jobs,data_nodes,RND,db_size*10,max_cores,max_job_time,max_nodes);
    
    
    
    long int time_fifs=0;
    long int time_tetris=0;
    unsigned long long int cores_wasted_fifs=0;
    unsigned long long int cores_wasted_tetris=0;
    
    
    // ********************* First in First Serve Scheme ************************
    
    
    if (fifs) {
        yellow_start();
        cout << "Scheduling jobs using the First in First Serve Scheme" << endl;
        color_reset();
        long global_counter = 0;
        //long nodes[batch_size];
        //long cores[batch_size];
        bool end_reached = false;
        long int end_job = 100;
        long int end_node = 10;
        //long int waste_blocks = 0;
        //long int time_passed = 0;
        unsigned long long int cores_wasted=0;
        unsigned long long int total_time=0;
        
        
        
        ofstream schedule;
        schedule.open ("schedule.dat", std::ofstream::out | std::ofstream::app);
        
        schedule << "This is the assignment of jobs to nodes.\n";
        schedule.close();
        
        
        
        
        while(!end_reached) {
            
            if (DEBUG && global_counter%1000==0) cout << "Iter\t" << global_counter << "\tTot Job\t" << end_job << "\tTot Node\t" << end_node << "\tRem Job\t"<< rem_jobs(data_jobs,end_job)  << "\tFree Cores\t"<< free_cores(data_nodes,end_node) << endl;
            
            if (global_counter% STAT_V==0) {
                stats(global_counter, end_node, end_job, free_cores(data_nodes,end_node), rem_jobs(data_jobs,end_job));
            }
            // Get 100 Jobs every 50 seconds // Batch Size = 100
            
            if(global_counter % 10 == 0 && global_counter != 0) {
                end_job += ADD_JOBS; /////////////////////// TO BE UNCOMMENTED
                if (end_job > db_size) {
                    end_job = db_size;
                }
            }
            
            if (global_counter % 500 == 0 && global_counter != 0) {
                // After every 500 Jobs add 10 nodes
                end_node += ADD_NODES;
            }
            
            // Schedule 100 Jobs
            for (long int jo=0;jo<end_job;jo++) {
                
                if (data_jobs[jo].valid) {
                    if (DEBUG2) cout << "Computing Job: " << jo << endl;
                    //Assign 100 Jobs to Nodes using FIFS
                    for (long int no=0;no<end_node;no++) {
                        if (data_nodes[no].free_cores >= data_jobs[jo].required_cores) {
                            assign_j2n(data_nodes,data_jobs,no,jo,print_to_file);
                            if (DEBUG2) cout << "Assigned Job " << jo << " to node " << no << endl;
                            break;
                        }
                    }
                }
            }
            
            cores_wasted = core_wastage(data_nodes,end_node,cores_wasted);
            
            update_time(data_nodes,end_node);
            total_time++;
            
            
            global_counter++;
            
            if (end_job >= db_size && all_nodes_free(data_nodes,end_node) && all_jobs_scheduled(data_jobs,end_job)) {
                if (DEBUG2) cout << "Reached end, finishing scheduling."<< endl;
                if (DEBUG2) cout << "all_nodes_free: "<< all_nodes_free(data_nodes,end_node) << endl;
                if (DEBUG2) cout << "all_jobs_scheduled: "<< all_jobs_scheduled(data_jobs,end_job) << endl;
                end_reached = true;
                time_fifs = global_counter;
                cores_wasted_fifs = cores_wasted;
                
            }
        }
        
        cout << "Total Time in FIFS: " << total_time << endl;
        cout << "Cores Wasted in FIFS: " << cores_wasted << endl << endl;
    }
    
    reset_nodes_jobs(data_nodes,data_jobs,db_size);
    
    
    
    
    if (print_to_file) system("mv ./schedule.dat ./fifs_schedule.dat");
    
    
    
    
    
    // **********************     TETRIS MODE     **********************
    
    
    if (tetris) {
        yellow_start();
        cout << "Scheduling jobs using the Tetris Scheme" << endl;
        color_reset();
        
        long global_counter = 0;
        //long nodes[batch_size];
        //long cores[batch_size];
        bool end_reached = false;
        long int end_job = 100;
        long int end_node = 10;
        //long int waste_blocks = 0;
        //long int time_passed = 0;
        //unsigned long long int cores_wasted_tetris=0;
        unsigned long long int total_time_tetris=0;
        unsigned long long int cores_wasted=0;
        
        
        ofstream schedule;
        schedule.open ("schedule.dat", std::ofstream::out | std::ofstream::app);
        
        schedule << "This is the assignment of jobs to nodes.\n";
        schedule.close();
       
        while(!end_reached) {
            
            if (DEBUG && global_counter%1000==0) cout << "Iter\t" << global_counter << "\tTot Job\t" << end_job << "\tTot Node\t" << end_node << "\tRem Job\t"<< rem_jobs(data_jobs,end_job)  << "\tFree Cores\t"<< free_cores(data_nodes,end_node) << endl;
            
            
            if (global_counter%STAT_V==0) {
                stats(global_counter, end_node, end_job, free_cores(data_nodes,end_node), rem_jobs(data_jobs,end_job));
            }
            
            // Get 1000 Jobs every 10 seconds
            
            if(global_counter % 10 == 0 && global_counter != 0) {
                end_job += ADD_JOBS;
                if (end_job > db_size) {
                    end_job = db_size;
                }
            }
            
            if (global_counter % 500 == 0 && global_counter != 0) {
                // After every 500 Jobs add 10 nodes
                end_node += ADD_NODES;
            }
            
            
            arrange_nodes_ascending(data_nodes,end_node);
            
            if (global_counter % 1000 == 0) {
                if (DEBUG2) cout << "Sorting Jobs GC:" << global_counter << endl;
                arrange_jobs_descending(data_jobs,end_job);
            }

            for (long int jo=0;jo<end_job;jo++) {
                
                
                // Do a scheduling based on Core Match
                if (data_jobs[jo].valid) {
                    assign_j2n(data_nodes,data_jobs,matching_cores(data_jobs[jo].required_cores,data_nodes,end_node),jo,print_to_file);
                }
                
                
                if (data_jobs[jo].valid) {
                    if (DEBUG2) cout << "Computing Job: " << jo << endl;
                    
                    for (long int no=0;no<end_node;no++) {
                        if (data_nodes[no].free_cores >= data_jobs[jo].required_cores) {
                            assign_j2n(data_nodes,data_jobs,no,jo,print_to_file);
                            if (DEBUG2) cout << "Assigned Job " << jo << " to node " << no << endl;
                            break;
                        }
                    }

                }
            }
            
            cores_wasted = core_wastage(data_nodes,end_node,cores_wasted);
            
            update_time(data_nodes,end_node);
            total_time_tetris++;
            
            
            global_counter++;
            
            
            if (end_job >= db_size && all_nodes_free(data_nodes,end_node) && all_jobs_scheduled(data_jobs,end_job)) {
                if (DEBUG2) cout << "Reached end, finishing scheduling."<< endl;
                if (DEBUG2) cout << "all_nodes_free: "<< all_nodes_free(data_nodes,end_node) << endl;
                if (DEBUG2) cout << "all_jobs_scheduled: "<< all_jobs_scheduled(data_jobs,end_job) << endl;
                end_reached = true;
                time_tetris = global_counter;
                cores_wasted_tetris = cores_wasted;
                
            }
        }
        
        cout << endl;
        cout << "Total Time in Tetris: " << total_time_tetris << endl;
        cout << "Cores Wasted in Tetris: " << cores_wasted_tetris << endl << endl;
        
        
    }
    
    if (print_to_file) system("mv ./schedule.dat ./tetris_schedule.dat");

    
    long int diff = time_tetris - time_fifs;
    
    if (diff > 0) {
        cout << "First in First serve ran faster than Tetris scheduler by " << diff << " iterations." << endl;
        cout << "That is " << (float)(diff*100)/(float)time_tetris << " %" << endl;
    } else {
        diff = diff * -1;
        cout << "Tetris ran faster than First in First serve scheduler by " << diff << " iterations." << endl;
        cout << "That is " << (float)(diff*100)/(float)time_fifs << " %" << endl;
    }
    
    cout << endl << endl;
    float t_diff = (float)cores_wasted_tetris - (float)cores_wasted_fifs;
    
    if (t_diff > 0) {
        cout << "First in First serve saved more cores than Tetris scheduler by " << t_diff << " cores." << endl;
        cout << "That is " << (t_diff*100)/(float)cores_wasted_tetris << " %" << endl;
    } else {
        t_diff = t_diff * -1;
        cout << "Tetris saved more cores than First in First serve scheduler by " << t_diff << " cores." << endl;
        cout << "That is " << (t_diff*100)/(float)cores_wasted_fifs << " %" << endl;
    }
    
    
    
    cout << "\n\e[1;31mProgram End\e[0m\n\n\n";
    
    return 0;
    
}








