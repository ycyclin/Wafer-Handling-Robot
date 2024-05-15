classdef HMInterface < TwinCATInterface
    properties
    end
    methods
        function activate(this)
            rx_terminal = TwinCAT.Ads.AdsStream(16);
            tx_terminal = TwinCAT.Ads.AdsStream(0);
            this.execute_method("robot_settings.robot_hm_scheduler.activate",tx_terminal, rx_terminal)
        end
        function start_operation(this)
            rx_terminal = TwinCAT.Ads.AdsStream(16);
            tx_terminal = TwinCAT.Ads.AdsStream(0);
            this.execute_method("robot_settings.robot_hm_scheduler.start_operation", ...
                tx_terminal, rx_terminal);
        end
        function state_num = get_state(this)
            rx_stream = TwinCAT.Ads.AdsStream(2);
            tx_terminal = TwinCAT.Ads.AdsStream(0);
            this.execute_method("robot_settings.robot_hm_scheduler.get_state", ...
                tx_terminal, rx_stream);
            state_num = TwinCAT.Ads.AdsBinaryReader(rx_stream).ReadInt16();
        end
    end
end

