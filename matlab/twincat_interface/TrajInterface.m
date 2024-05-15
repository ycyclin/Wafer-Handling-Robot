classdef TrajInterface < TwinCATInterface
    properties
        motor1_fb;
        motor2_fb;
        motor1_tg;
        motor2_tg;
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
%             rx_stream = TwinCAT.Ads.AdsStream(8);
%             this.read_varaibles("motor_settings.motor_interfaces[0].feedback_position", rx_stream);
%             motor_1_angle = int16(rx_stream);
%             rx_stream = TwinCAT.Ads.AdsStream(8);
%             this.read_varaibles("motor_settings.motor_interfaces[1].feedback_position", rx_stream);
%             motor_2_angle = int16(rx_stream);
%             robot_direction = (motor_1_angle+motor_2_angle)/2000000.0*360.0;
%             rotation_diff = round((robot_direction - trajectory_rotation)/360.0)*360.0;
            
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
        function [motor1_tg,motor2_tg,motor1_fb,motor2_fb] = read_t_fb(this,fb_length)
           rx_stream1 = TwinCAT.Ads.AdsStream(1000000*8);
           rx_stream2 = TwinCAT.Ads.AdsStream(1000000*8);
           rx_stream3 = TwinCAT.Ads.AdsStream(1000000*8);
           rx_stream4 = TwinCAT.Ads.AdsStream(1000000*8);
           this.read_varaibles('robot_settings.robot_fb_motor_1',rx_stream1);
           this.read_varaibles('robot_settings.robot_fb_motor_2',rx_stream2);
           this.read_varaibles('robot_settings.robot_tg_motor_1',rx_stream3);
           this.read_varaibles('robot_settings.robot_tg_motor_2',rx_stream4);
           motor1_fb = typecast(uint8(rx_stream1.GetBuffer()),'int64');
           motor1_fb = motor1_fb(1:fb_length);
           motor2_fb = typecast(uint8(rx_stream2.GetBuffer()),'int64');
           motor2_fb = motor2_fb(1:fb_length);
           motor1_tg = typecast(uint8(rx_stream3.GetBuffer()),'int64');
           motor1_tg = motor1_tg(1:fb_length);
           motor2_tg = typecast(uint8(rx_stream4.GetBuffer()),'int64');
           motor2_tg = motor2_tg(1:fb_length);
        end
    end
end

