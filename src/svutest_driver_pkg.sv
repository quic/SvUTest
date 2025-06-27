package svutest_driver_pkg;
    /// Driver for svutest_if_data
    class data_driver #(type T_payload = bit);
        typedef virtual svutest_if_data#(T_payload) T_vif;
        
        typedef struct {
            T_payload   payload;
        } T_sender_packet;
        
        T_vif m_vif;
        
        function new (T_vif vif);
            m_vif = vif;
        endfunction
        
        task sender_clear ();
            m_vif.payload <= '0;
        endtask
        
        task sender_drive (T_sender_packet p);
            m_vif.payload <= p.payload;
            
            @(posedge m_vif.clk iff (!m_vif.rst));
        endtask
        
        task monitor (output T_sender_packet p);
            @(posedge m_vif.clk iff (!m_vif.rst));
            
            p = '{ payload: m_vif.payload };
        endtask
    endclass
    
    /// Driver for svutest_if_valid_data
    class valid_data_driver #(type T_payload = bit);
        typedef virtual svutest_if_valid_data#(T_payload) T_vif;
        
        typedef struct {
            logic       valid;
            T_payload   payload;
        } T_sender_packet;
        
        T_vif m_vif;
        
        static function valid_data_driver#(T_payload) create (T_vif vif);
            valid_data_driver#(T_payload) driver;
            
            driver = new (vif);
            
            return driver;
        endfunction
        
        function new (T_vif vif);
            m_vif = vif;
        endfunction
        
        task sender_clear ();
            m_vif.valid <= 1'b0;
            m_vif.payload <= 'x;
        endtask
        
        task sender_drive (T_sender_packet p);
            m_vif.valid <= 1'b1;
            m_vif.payload <= p.payload;
            
            @(posedge m_vif.clk iff (!m_vif.rst));
            
            sender_clear();
        endtask
        
        task monitor (output T_sender_packet p);
            @(posedge m_vif.clk iff (!m_vif.rst && m_vif.valid));
            
            p = '{ valid: m_vif.valid, payload: m_vif.payload };
        endtask
    endclass
    
    /// Driver for svutest_if_valid_ready
    class valid_ready_driver #(type T_payload = bit);
        typedef virtual svutest_if_valid_ready#(T_payload) T_vif;
        
        typedef struct {
            logic       valid;
            T_payload   payload;
        } T_sender_packet;
        
        typedef struct {
            logic ready;
        } T_target_packet;
        
        T_vif m_vif;
        
        static function valid_ready_driver#(T_payload) create (T_vif vif);
            valid_ready_driver#(T_payload) driver;
            
            driver = new (vif);
            
            return driver;
        endfunction
        
        function new (T_vif vif);
            m_vif = vif;
        endfunction
        
        task sender_clear ();
            m_vif.valid <= 1'b0;
            m_vif.payload <= 'x;
        endtask
        
        task sender_drive (T_sender_packet p);
            m_vif.valid <= p.valid;
            m_vif.payload <= p.payload;
            
            if (p.valid) begin
                @(posedge m_vif.clk iff (!m_vif.rst && m_vif.ready));
            end else begin
                @(posedge m_vif.clk iff (!m_vif.rst));
            end
            
            sender_clear();
        endtask
        
        task target_clear ();
            m_vif.ready <= 1'b1;
        endtask
        
        task target_drive (T_target_packet p);
            m_vif.ready <= p.ready;
            
            @(posedge m_vif.clk iff !m_vif.rst);
            
            target_clear();
        endtask
        
        task monitor (output T_sender_packet p);
            @(posedge m_vif.clk iff (!m_vif.rst && m_vif.valid && m_vif.ready));
            
            p = '{ valid: m_vif.valid, payload: m_vif.payload };
        endtask
    endclass
    
    /// Driver for svutest_if_validcount_readycount
    class validcount_readycount_driver #(int unsigned MAX_COUNT = 1, type T_payload = bit);
        typedef virtual svutest_if_validcount_readycount#(MAX_COUNT, T_payload) T_vif;
        
        typedef struct {
            int unsigned    valid_count;
            T_payload       payload [MAX_COUNT-1:0];
        } T_sender_packet;
        
        typedef struct {
            int unsigned    ready_count;
        } T_target_packet;
        
        T_vif m_vif;
        
        function new (T_vif vif);
            m_vif = vif;
        endfunction
        
        task sender_clear();
            m_vif.valid_count <= '0;
            m_vif.payload <= '{ default: 'x };
        endtask
        
        task sender_drive (T_sender_packet p);
            m_vif.valid_count <= '0;
            m_vif.payload <= p.payload;
            
            @(posedge m_vif.clk iff (!m_vif.rst && (m_vif.ready_count != '0)));
            
            sender_clear();
        endtask
        
        task target_clear();
            m_vif.ready_count <= MAX_COUNT;
        endtask
        
        task target_drive(T_target_packet p);
            m_vif.ready_count <= p.ready_count;
            
            @(posedge m_vif.clk iff !m_vif.rst);
            
            target_clear();
        endtask
        
        task monitor (output T_sender_packet p);
            int unsigned count;
            
            @(posedge m_vif.clk iff (!m_vif.rst && (m_vif.valid_count != '0) && (m_vif.ready_count != '0)));
            
            count = m_vif.valid_count < m_vif.ready_count ? m_vif.valid_count : m_vif.ready_count;
            
            p = '{ valid_count: count, payload: '{ default: 'x } };
            
            for (int unsigned i = 0 ; i < count ; i++) begin
                p.payload[i] = m_vif.payload[i];
            end
        endtask
    endclass
endpackage
