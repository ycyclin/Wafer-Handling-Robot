classdef PPInterface < TwinCATInterface
    properties
    end
    methods
        function activate(this)
            rx_terminal = TwinCAT.Ads.AdsStream(16);
            tx_terminal = TwinCAT.Ads.AdsStream(0);
            this.execute_method("robot_settings.robot_pp_scheduler.activate",tx_terminal, rx_terminal)
        end
        function start_operation(this,target_distance, target_angle)
            rx_stream = TwinCAT.Ads.AdsStream(16);
            tx_stream = TwinCAT.Ads.AdsStream(16);
            stream_writer = TwinCAT.Ads.AdsBinaryWriter(tx_stream);
            tx_stream.Position = 0;
            stream_writer.Write(double(target_distance));
            tx_stream.Position = 8;
            stream_writer.Write(target_angle);
            this.execute_method("robot_settings.robot_pp_scheduler.start_operation", ...
                tx_stream, rx_stream);
        end
        function state_num = get_state(this)
            rx_stream = TwinCAT.Ads.AdsStream(2);
            tx_terminal = TwinCAT.Ads.AdsStream(0);
            this.execute_method("robot_settings.robot_pp_scheduler.get_state", ...
                tx_terminal, rx_stream);
            state_num = TwinCAT.Ads.AdsBinaryReader(rx_stream).ReadInt16();
        end
    end
end

