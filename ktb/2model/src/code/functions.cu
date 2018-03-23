#include "functions.h"
#include "debugger.h"

using namespace std;

#define WARNINGS 0

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


void generate_data(TheJob *data_jobs, CompNode *data_nodes, bool RND, long int db_size,long int max_cores,long int max_job_time,long int max_nodes) {
    
    ofstream node_file,job_file;
    node_file.open ("nodes.dat", std::ofstream::out | std::ofstream::app);
    job_file.open ("jobs.dat", std::ofstream::out | std::ofstream::app);
    
    node_file << "Compute Nodes Stream.\n";
    job_file << "Jobs Stream.\n";
    

    
    
    

    
    for (long int i=0; i < db_size; i++) {
        data_jobs[i].id = i;
        job_file << "Job ID:\t" << data_jobs[i].id;
        data_jobs[i].required_cores = (rand() % max_cores)+1;
        
        
        data_jobs[i].valid = true;
        if (rand() % 3) {
            data_jobs[i].required_cores = (rand() % (max_cores/4))+1; // Increasing affinity towards lower numbers
        }
        job_file << "\tRequired Cores:\t" << data_jobs[i].required_cores;
        
        data_jobs[i].duration = (rand() % max_job_time)+1;
        
        job_file << "\tProcess Duration:\t" << data_jobs[i].duration;
        
        data_jobs[i].duration_left = data_jobs[i].duration;
        
        data_nodes[i].id = i;
        node_file << "Node ID:\t" << data_nodes[i].id;
        
        data_nodes[i].node_number = rand() % max_nodes;
        
        node_file << "\tNode Number:\t" << data_nodes[i].node_number;
        
        data_nodes[i].total_cores = (rand() % max_cores)+1;
        node_file << "\tFree Cores:\t" << data_nodes[i].total_cores;
        
        data_nodes[i].used_cores = 0;
        data_nodes[i].free_cores = data_nodes[i].total_cores;
        data_nodes[i].node_job_queue = 0;
        
        job_file << "\n" ;
        node_file << "\n";
        
    }
    
    
    node_file.close();
    job_file.close();
    

    

    
}


void assign_j2n(CompNode *data_nodes,TheJob *data_jobs,long int no,long int jo,bool print_file = false) {
    if (no < 0 ) return;
    
    if (WARNINGS && data_jobs[jo].valid == false) {
        red_start();
        cout << "Warning: Assigning Pre-assigned Job: " << jo << endl;
        color_reset();
    }
    
    long int the_free_job_no = nodes_job_free_number(data_nodes,no);
    data_nodes[no].NodeJob[the_free_job_no] = data_jobs[jo];
    data_nodes[no].used_cores += data_jobs[jo].required_cores;
    data_nodes[no].free_cores -= data_jobs[jo].required_cores;
    data_jobs[jo].valid = false;
    
    if (print_file) {
    ofstream schedule;
    schedule.open ("schedule.dat", std::ofstream::out | std::ofstream::app);
    
    schedule << "Assigned Job:\t" << jo << "\tto Node:\t" << no << "\n";
    schedule.close();
    }
    
    
    if (WARNINGS && data_nodes[no].free_cores < 0) {
        red_start();
        cout << "Warning: Overloading Node: " << no << endl;
        color_reset();
    }
    
}


long int nodes_job_free_number(CompNode *data_nodes,long int no) {
    for (long int i=0;i<128;i++) {
        if (data_nodes[no].NodeJob[i].valid == false) {
            return (i);
        }
    }
}

void update_time(CompNode *data_nodes, long int end_node) {
    for (long int i=0;i<end_node;i++) {
        for (int j=0;j<128;j++) {
            if (data_nodes[i].NodeJob[j].valid) {
                data_nodes[i].NodeJob[j].duration_left--;
                if (data_nodes[i].NodeJob[j].duration_left <= 0) {
                    data_nodes[i].NodeJob[j].valid = false;
                    data_nodes[i].used_cores -= data_nodes[i].NodeJob[j].required_cores;
                    data_nodes[i].free_cores += data_nodes[i].NodeJob[j].required_cores;
                }
            }
        }
    }
    
}


unsigned long long int core_wastage (CompNode *data_nodes, long int end_node,unsigned long long int prev_wasted) {
    unsigned long long int waste = prev_wasted;
    for (long int i=0;i<end_node;i++) {
        waste += (unsigned long long int)data_nodes[i].free_cores;
    }
    
    return (waste);
}




bool all_nodes_free(CompNode *data_nodes,long int end_node) {
    for (long int i=0;i<end_node;i++) {
        for (int j=0;j<128;j++) {
            if (data_nodes[i].NodeJob[j].valid == true) {
                return (false);
            }
        }
    }
    return (true);
}


bool all_jobs_scheduled(TheJob *data_jobs,long int end_job) {
    for (long int i=0;i<end_job;i++) {
        if (data_jobs[i].valid == true) {
            return (false);
        }
    }
    return (true);
}


void reset_nodes_jobs(CompNode *data_nodes,TheJob *data_jobs,long int db_size) {
    for (long int i=0;i<db_size;i++) {
        data_jobs[i].valid = true;
        for (long int j=0;j<128;j++) {
            data_nodes[i].NodeJob[j].valid == false;
        }
    }
}


long int matching_cores(long int req_cores,CompNode *data_nodes, long int end_node) {
    for (int i=0 ; i < end_node; i++ ) {
        if (data_nodes[i].free_cores == req_cores) {
            return (i);
        }
    }
    return (-1);
}


void match_and_set_multi(TheJob *data_jobs, long int end_job,CompNode *data_nodes,long int end_node) {
    long int matched_node_no = -1;
    for (int i=0;i<end_job;i++) {
        if (data_jobs[i].valid) {
            for (int j=0;j<end_job;j++) {
                if (data_jobs[j].valid) {
                    if (i != j) {
                        matched_node_no = matching_cores(data_jobs[i].required_cores + data_jobs[j].required_cores,data_nodes,end_node);
                        if (matched_node_no >= 0) {
                            assign_j2n(data_nodes,data_jobs,matched_node_no,i,false);
                            assign_j2n(data_nodes,data_jobs,matched_node_no,j,false);
                        }
                    }
                }
            }
        }
    }
}


void swap(CompNode *data_nodes, long int a, long int b)
{
    CompNode temp_node;
    temp_node = data_nodes[a];
    data_nodes[a] = data_nodes[b];
    data_nodes[b] = temp_node;
    
}

int partition (CompNode *data_nodes, int low, int high)
{
    long int pivot = data_nodes[high].free_cores;    // pivot
    long int i = (low - 1);  // Index of smaller element
    
    for (long int j = low; j <= high- 1; j++)
    {

        if (data_nodes[j].free_cores <= pivot)
        {
            i++;    // increment index of smaller element
            swap(data_nodes, i, j);
        }
    }
    swap(data_nodes, i + 1, high);
    return (i + 1);
}

void quickSort(CompNode *data_nodes, int low, int high)
{
    if (low < high)
    {
        /* pi is partitioning index, arr[p] is now
         at right place */
        long int pi = partition(data_nodes, low, high);
        
        // Separately sort elements before
        // partition and after partition
        quickSort(data_nodes, low, pi - 1);
        quickSort(data_nodes, pi + 1, high);
    }
}






void arrange_nodes_ascending(CompNode *data_nodes,long int end_node) {
    quickSort(data_nodes, 0, end_node);
}



unsigned long long int rem_jobs(TheJob *data_jobs,long int end_job) {
    unsigned long long int rj=0;
    for (long int i=0;i<end_job;i++) {
        if (data_jobs[i].valid) {
            rj++;
        }
    }
    return (rj);
}



unsigned long long int free_cores(CompNode *data_nodes, long int end_node) {
    unsigned long long int fc=0;
    for (long int i=0;i<end_node;i++) {
        fc += data_nodes[i].free_cores;
    }
    return (fc);
}








void swap2(TheJob *data_jobs, long int a, long int b)
{
    TheJob temp_job;
    temp_job = data_jobs[a];
    data_jobs[a] = data_jobs[b];
    data_jobs[b] = temp_job;
    
}

int partition2 (TheJob *data_jobs, int low, int high)
{
    long int pivot = data_jobs[high].required_cores;    // pivot
    long int i = (low - 1);  // Index of smaller element
    
    for (long int j = low; j <= high- 1; j++)
    {

        if (data_jobs[j].required_cores <= pivot)
        {
            i++;    // increment index of smaller element
            swap2(data_jobs, i, j);
        }
    }
    swap2(data_jobs, i + 1, high);
    return (i + 1);
}


void quickSort2(TheJob *data_jobs, int low, int high)
{
    if (low < high)
    {

        long int pi = partition2(data_jobs, low, high);
        

        quickSort2(data_jobs, low, pi - 1);
        quickSort2(data_jobs, pi + 1, high);
    }
}




void arrange_jobs_descending(TheJob *data_jobs,long int end_job) {
    quickSort2(data_jobs, 0, end_job);
    for (long int i=0;i<end_job/2;i++) {
        swap2(data_jobs,i,(end_job-1-i));
    }
    
}


void stats(long global_counter,long int end_node,long int end_job, unsigned long long int fc,unsigned long long int rj) {
    cout << "Iteration:\t" << global_counter;
    cout << "\tTotal Nodes:\t" << end_node;
    cout << "\tRemaining Jobs:\t";
    if (rj > 70000) {
        red_start();
    } else if (rj > 10000) {
        yellow_start();
    } else if (rj>=0) {
        green_start();
    }
    cout << rj;
    color_reset();
    
    
    
    cout << "\tFree Cores:\t";
    if (fc > 1000) {
        red_start();
    } else if (fc > 200) {
        yellow_start();
    } else if (fc>=0) {
        green_start();
    }
    cout << fc;
    color_reset();
    
    
    cout << endl;
}


