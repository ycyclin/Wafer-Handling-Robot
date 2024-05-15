classdef TwinCATInterface
    %TWINCATINTERFACE The interface for MATLAB to connect to twincat
    properties(Constant)
        asm = NET.addAssembly('C:\TwinCAT\AdsApi\.NET\v4.0.30319\TwinCAT.Ads.dll');
        ADS_client=TwinCAT.Ads.TcAdsClient;
    end
    
    methods(Access = public)
        function obj = TwinCATInterface()
            obj.init()
        end

        function init(this)
            this.ADS_client.Connect('35.3.234.20.1.1',851);
        end

        function execute_method(this, function_name, tx_stream, rx_stream)
            function_name = split(function_name,'.');
            function_name = char(strjoin(function_name(1:end-1),'.')+'#'+function_name(end));
            function_handle = this.ADS_client.CreateVariableHandle(function_name);
            this.ADS_client.ReadWrite(int32(ads_reserved_index_groups_t.SymbolValueByHandle),...
                function_handle, rx_stream, tx_stream);
        end

        function write_variables(this, variable_name, data)
            variable_handle = this.ADS_client.ReadSymbolInfo(variable_name);
            this.ADS_client.WriteAny(variable_handle.IndexGroup,...
                variable_handle.IndexOffset,data);
        end
        function read_varaibles(this, variable_name, rx_stream)
            variable_handle = this.ADS_client.ReadSymbolInfo(variable_name);
            this.ADS_client.Read(variable_handle.IndexGroup,...
                variable_handle.IndexOffset, rx_stream);
        end
    end
    properties(Access=private)
        
    end
end