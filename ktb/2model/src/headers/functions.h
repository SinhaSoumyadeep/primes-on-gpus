//
// Author: Kaustubh Shivdikar
//


#ifndef FUNCTIONS_H
#define FUNCTIONS_H

#define NODE_MAX_JOBS 128 // Equal to MAX Cores

#include <iostream>
#include <stdio.h>
#include <cstdio>
#include <cstdlib>
#include <string>
#include <array>
#include <cmath>
#include <fstream>
#include <sstream>
#include <string>
#include <time.h>
#include <cstring>
#include <fcntl.h>
#include <unistd.h>
#include <algorithm>

using namespace std;




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






extern string res,jobs;

void read_data_from_file();

void get_jobs(string jobs,TheJob *job_ds_ptr, int global_counter,long batch_size);

void get_ten_nodes(string res, CompNode *cnode_ptr, long int global_counter);


void generate_data(TheJob *data_jobs, CompNode *data_nodes, bool TRUE_RANDOM, long int db_size,long int max_cores,long int max_job_time,long int max_nodes);


long int nodes_job_free_number(CompNode *data_nodes,long int no);

void assign_j2n(CompNode *data_nodes, TheJob *data_jobs,long int no, long int jo, bool print_file);


void update_time(CompNode *data_nodes, long int end_node);


unsigned long long int core_wastage (CompNode *data_nodes, long int end_node,unsigned long long int prev_wasted);


bool all_jobs_scheduled(TheJob *data_jobs,long int end_job);

bool all_nodes_free(CompNode *data_nodes,long int end_node);

void reset_nodes_jobs(CompNode *data_nodes,TheJob *data_jobs,long int db_size);


long int matching_cores(long int req_cores,CompNode *data_nodes, long int end_node);

void match_and_set_multi(TheJob *data_jobs, long int end_job,CompNode *data_nodes,long int end_node);

void arrange_nodes_ascending(CompNode *data_nodes,long int end_node);


unsigned long long int rem_jobs(TheJob *data_jobs,long int end_job);

unsigned long long int free_cores(CompNode *data_nodes, long int end_node);

void arrange_jobs_descending(TheJob *data_jobs,long int end_job);

void stats(long global_counter,long int end_node,long int end_job, unsigned long long int fc,unsigned long long int rj);


#endif // FUNCTIONS_H
