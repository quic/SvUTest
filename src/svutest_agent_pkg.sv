package svutest_agent_pkg;
    import svutest_driver_pkg::*;
    
    class agent;
        local semaphore m_sem;
        
        function new ();
            m_sem = new(0);
        endfunction
        
        task resume ();
            m_sem.put();
        endtask
        
        task pause ();
            m_sem.get();
        endtask
        
        virtual task run ();
            
        endtask
    endclass
    
    /// Injector for DUT input
    class sender_agent #(
        type T_vif = bit,
        type T_driver = bit
    ) extends agent;
        typedef T_driver::T_sender_packet T_sender_packet;
        
        T_sender_packet m_queue [$];
        T_driver m_driver;
        
        static function sender_agent#(T_vif, T_driver) create (T_vif vif);
            sender_agent#(T_vif, T_driver) ag;
            
            ag = new(vif);
            
            return ag;
        endfunction
        
        function new (T_vif vif);
            super.new();
            
            m_queue = {};
            m_driver = T_driver::create(vif);
        endfunction
        
        function void put (T_sender_packet packet);
            m_queue.push_back(packet);
        endfunction
        
        task run ();
            m_driver.sender_clear();
            
            this.pause();
            
            while ($size(m_queue) != 0) begin
                m_driver.sender_drive(m_queue.pop_front());
            end
        endtask
    endclass
    
    /// Sinks DUT output transactions
    /// Also provides required back-pressure
    class target_agent #(
        type T_payload = bit,
        type T_vif = bit,
        type T_driver = bit
    ) extends agent;
        typedef T_driver::T_target_packet T_target_packet;
        typedef T_driver::T_sender_packet T_sender_packet;
        
        typedef struct packed {
            time        timestamp;
            T_payload   payload;
        } T_mon_packet;
        
        T_mon_packet m_mon_queue [$];
        T_target_packet m_drv_queue [$];
        T_driver m_driver;
        
        static function target_agent#(T_payload, T_vif, T_driver) create (T_vif vif);
            target_agent#(T_payload, T_vif, T_driver) ag;
            
            ag = new(vif);
            
            return ag;
        endfunction
        
        function new (T_vif vif);
            super.new();
            
            m_mon_queue = {};
            m_drv_queue = {};
            m_driver = T_driver::create(vif);
        endfunction
        
        function void put (T_target_packet p);
            m_drv_queue.push_back(p);
        endfunction
        
        task run ();
            fork
                begin
                    forever begin
                        T_sender_packet packet;
                        
                        m_driver.monitor(packet);
                        m_mon_queue.push_back('{ $time, packet.payload });
                    end
                end
                
                begin
                    m_driver.target_clear();
                    
                    this.pause();
                    
                    while ($size(m_drv_queue) != 0) begin
                        m_driver.target_drive(m_drv_queue.pop_front());
                    end
                end
            join
        endtask
    endclass
    
    // /// Monitor-only interface for DUT outputs
    // class monitor_agent #(type T_driver = bit) extends agent;
    //     typedef T_driver::T_sender_packet T_sender_packet;
        
    //     typedef T_sender_packet T_monitor_queue [$];
        
    //     T_sender_packet m_mon_queue [$];
    //     local T_driver m_driver;
        
    //     function new (test_case test, T_driver vif);
    //         super.new(test);
            
    //         m_mon_queue = {};
    //         m_driver = vif;
    //     endfunction
        
    //     task run ();
    //         forever begin
    //             T_sender_packet packet;
                
    //             m_driver.monitor(packet);
    //             m_mon_queue.push_back(packet);
    //         end
    //     endtask
    // endclass
endpackage
