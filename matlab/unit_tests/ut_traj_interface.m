addpath('../BaseLib')
addpath('../twincat_interface')
traj_ext = ScurveTBI(600,180,300,2000,4000,1e-3);
IO = TrajInterface;
IO.activate()
IO.write_trajectory(traj_ext,zeros(size(traj_ext)));
IO.start_operation()
while(IO.get_state()~=2)
    fprintf("Waiting for Robot Moving to Start Point...\n")
    pause(1)
end
fprintf("Start Operation")
IO.trigger();