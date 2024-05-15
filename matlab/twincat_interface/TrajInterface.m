classdef TrajInterface < TwinCATInterface
    properties
    end
    methods
        function activate(this)
            rx_terminal = TwinCAT.Ads.AdsStream(16);
            tx_terminal = TwinCAT.Ads.AdsStream(0);
            this.execute_method("robot_settings.robot_traj_scheduler.activate",tx_terminal, rx_terminal)
        end
        function write_trajectory(this,trajectory_extension, trajectory_rotation)
            if(length(trajectory_extension) > 1000000)
                warning('Trajectory exceeds the 1,000,000 length. Drop.')
                return
            end
            this.write_variables('robot_settings.robot_traj_ext',trajectory_extension);
            this.write_variables('robot_settings.robot_traj_rot',trajectory_rotation);
            input_stream = TwinCAT.Ads.AdsStream(4);
            stream_writer = TwinCAT.Ads.AdsBinaryWriter(input_stream);
            stream_writer.Write(int32(length(trajectory_extension)));
            terminal = TwinCAT.Ads.AdsStream(2);
            this.execute_method("robot_settings.robot_traj_scheduler.set_trajectory_length", ...
                input_stream,terminal);
        end
        function start_operation(this)
            rx_terminal = TwinCAT.Ads.AdsStream(16);
            tx_terminal = TwinCAT.Ads.AdsStream(0);
            this.execute_method("robot_settings.robot_traj_scheduler.start_operation", ...
                tx_terminal, rx_terminal);
        end
        function trigger(this)
            rx_terminal = TwinCAT.Ads.AdsStream(16);
            tx_terminal = TwinCAT.Ads.AdsStream(0);
            this.execute_method("robot_settings.robot_traj_scheduler.trigger", ...
                tx_terminal, rx_terminal);
        end
        function state_num = get_state(this)
            rx_stream = TwinCAT.Ads.AdsStream(2);
            tx_terminal = TwinCAT.Ads.AdsStream(0);
            this.execute_method("robot_settings.robot_traj_scheduler.get_state", ...
                tx_terminal, rx_stream);
            state_num = TwinCAT.Ads.AdsBinaryReader(rx_stream).ReadInt16();
        end
    end
end

