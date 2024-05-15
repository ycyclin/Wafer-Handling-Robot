close all;clear;clc;
addpath('../BaseLib')
addpath('../twincat_interface')
IO = HMInterface;
IO.activate()
IO.start_operation()