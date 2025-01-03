// Copyright (c) 2024 Qualcomm Innovation Center, Inc. All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause-Clear

package svutest_pkg;
    typedef class test_case;
    
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
            
            @(posedge m_vif.clk iff (!m_vif.rst && m_vif.ready));
            
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
    
    class agent;
        function new (test_case test);
            test.add_agent(this);
        endfunction
        
        virtual task init();
        endtask
        
        virtual task run();
        endtask
    endclass
    
    /// Injector for DUT input
    class sender_agent #(type T_driver = bit) extends agent;
        typedef T_driver::T_sender_packet T_sender_packet;
        
        T_sender_packet m_queue [$];
        T_driver m_driver;
        
        function new (test_case test, T_driver driver);
            super.new(test);
            
            m_queue = {};
            m_driver = driver;
        endfunction
        
        function void put (T_sender_packet packet);
            m_queue.push_back(packet);
        endfunction
        
        task init ();
            m_driver.sender_clear();
        endtask
        
        task run ();
            m_driver.sender_clear();
            
            while ($size(m_queue) != 0) begin
                m_driver.sender_drive(m_queue.pop_front());
            end
        endtask
    endclass
    
    /// Sinks DUT output transactions
    /// Also provides required back-pressure
    class target_agent #(type T_driver = bit) extends agent;
        typedef T_driver::T_sender_packet T_sender_packet;
        typedef T_driver::T_target_packet T_target_packet;
        
        T_sender_packet m_mon_queue [$];
        T_target_packet m_drv_queue [$];
        T_driver m_driver;
        
        function new (test_case test, T_driver vif);
            super.new(test);
            
            m_mon_queue = {};
            m_drv_queue = {};
            m_driver = vif;
        endfunction
        
        task init ();
            m_driver.target_clear();
        endtask
        
        function void put (T_target_packet p);
            m_drv_queue.push_back(p);
        endfunction
        
        task run ();
            fork
                forever begin
                    T_sender_packet packet;
                    
                    m_driver.monitor(packet);
                    m_mon_queue.push_back(packet);
                end
                
                begin
                    m_driver.target_clear();
                    
                    while ($size(m_drv_queue) != 0) begin
                        m_driver.target_drive(m_drv_queue.pop_front());
                    end
                end
            join
        endtask
    endclass
    
    /// Monitor-only interface for DUT outputs
    class monitor_agent #(type T_driver = bit) extends agent;
        typedef T_driver::T_sender_packet T_sender_packet;
        
        typedef T_sender_packet T_monitor_queue [$];
        
        T_sender_packet m_mon_queue [$];
        local T_driver m_driver;
        
        function new (test_case test, T_driver vif);
            super.new(test);
            
            m_mon_queue = {};
            m_driver = vif;
        endfunction
        
        task run ();
            forever begin
                T_sender_packet packet;
                
                m_driver.monitor(packet);
                m_mon_queue.push_back(packet);
            end
        endtask
    endclass
    
    typedef class regress_suite;
    
    /// Test case base class
    /// All test cases must derive from this class
    class test_case;
        virtual svutest_if_test_ctrl m_vif_test_ctrl;
        string m_test_name;
        
        int unsigned m_pass_count;
        int unsigned m_fail_count;
        
        bit m_done;
        
        agent m_agent_queue [$];
        
        function new (virtual svutest_if_test_ctrl vif_test_ctrl, string test_name);
            m_vif_test_ctrl = vif_test_ctrl;
            m_test_name = test_name;
            m_pass_count = 0;
            m_fail_count = 0;
            m_agent_queue = {};
            m_done = 1'b0;
            
            regress_suite::add_test_case(this);
        endfunction
        
        function void add_agent (agent ag);
            m_agent_queue.push_back(ag);
        endfunction
        
        local virtual task run_init ();
            for (int unsigned i = 0 ; i < $size(m_agent_queue) ; i++) begin
                fork
                    automatic int unsigned index = i;
                    
                    begin
                        m_agent_queue[index].init();
                    end
                join_none
            end
        endtask
        
        local task run_clk_gen ();
            m_vif_test_ctrl.clk = 1'b0;
            
            #2000;
            
            forever begin
                m_vif_test_ctrl.clk = 1'b1;
                #500;
                
                m_vif_test_ctrl.clk = 1'b0;
                #500;
            end
        endtask
        
        local task run_rst_gen ();
            m_vif_test_ctrl.rst = 1'b0;
            
            #1000;
            m_vif_test_ctrl.rst <= 1'b1;
            
            @(posedge m_vif_test_ctrl.clk) m_vif_test_ctrl.rst <= 1'b0;
        endtask
        
        local virtual task run_body ();
            for (int unsigned i = 0 ; i < $size(m_agent_queue) ; i++) begin
                fork
                    automatic int unsigned index = i;
                    
                    begin
                        m_agent_queue[index].run();
                    end
                join_none
            end
        endtask
        
        local virtual task run_wait ();
            
        endtask
        
        virtual function void build ();
            
        endfunction
        
        virtual function void inject ();
            
        endfunction
        
        virtual task run ();
            run_init();
            
            fork
                run_clk_gen();
            join_none
            run_rst_gen();
            
            @(posedge m_vif_test_ctrl.clk iff !m_vif_test_ctrl.rst);
            
            run_body();
            
            @(posedge m_vif_test_ctrl.clk iff !m_vif_test_ctrl.rst);
            @(posedge m_vif_test_ctrl.clk iff (!m_vif_test_ctrl.rst && !m_vif_test_ctrl.busy));
            
            @(posedge m_vif_test_ctrl.clk iff !m_vif_test_ctrl.rst);
            @(posedge m_vif_test_ctrl.clk iff (!m_vif_test_ctrl.rst && !m_vif_test_ctrl.busy));
            
            run_wait();
        endtask
        
        virtual function void check ();
            
        endfunction
        
        task automatic run_test ();
            this.build();
            
            this.inject();
            this.run();
            this.check();
            
            m_done = 1'b1;
        endtask
    endclass
    
    /// Global lookup table
    /// Key := { test_case, key }
    /// Might get deprecated in future
    class lookup #(type T_key = string, type T_value = logic);
        typedef virtual svutest_if_test_ctrl T_vif;
        
        typedef struct {
            test_case t;
            T_key key;
        } T_final_key;
        
        local static T_value storage [T_final_key];
        
        static function automatic void set (test_case t, T_key key, T_value value);
            T_final_key final_key;
            
            final_key = '{ t: t, key: key };
            
            if (storage.exists(final_key)) begin
                $fatal(0, $sformatf("Key %p exists", final_key));
            end
            
            storage[final_key] = value;
        endfunction
        
        static function automatic T_value get (test_case t, T_key key);
            T_final_key final_key;
            
            final_key = '{ t: t, key: key };
            
            if (!storage.exists(final_key)) begin
                $fatal(0, $sformatf("Failed to lookup %p", final_key));
            end
            
            return storage[final_key];
        endfunction
    endclass
    
    /// Regress suite
    /// Currently implemented as singleton/static. Do not instantiate
    class regress_suite;
        local static test_case sm_test_case_queue [$];
        
        static function automatic add_test_case (test_case t);
            sm_test_case_queue.push_back(t);
        endfunction
        
        static task automatic wait_for_done ();
            for (int unsigned i = 0 ; i < $size(sm_test_case_queue) ; i++) begin
                wait (sm_test_case_queue[i].m_done === 1'b1);
            end
        endtask
        
        static function automatic void report ();
            string done_str;
            string timeout_str;
            string pass_str;
            string fail_str;
            string unknown_str;
            
            string final_done_status_str;
            string final_pass_status_str;
            
            int unsigned num_done_tests;
            int unsigned num_timeout_tests;
            int unsigned num_passing_tests;
            int unsigned num_failing_tests;
            int unsigned num_unknown_tests;
            
            if ($test$plusargs("color")) begin
                done_str = "\033[0;34mDONE\033[0m";
                timeout_str = "\033[0;35mTIMEOUT\033[0m";
                pass_str = "\033[0;32mPASS\033[0m";
                fail_str = "\033[0;31mFAIL\033[0m";
                unknown_str = "\033[0;33mUNKNOWN\033[0m";
            end else begin
                done_str = "DONE";
                timeout_str = "TIMEOUT";
                pass_str = "PASS";
                fail_str = "FAIL";
                unknown_str = "UNKNOWN";
            end
            
            num_done_tests = 0;
            num_timeout_tests = 0;
            num_passing_tests = 0;
            num_failing_tests = 0;
            num_unknown_tests = 0;
            
            for (int unsigned i = 0 ; i < $size(sm_test_case_queue) ; i++) begin
                int unsigned total_count;
                
                string done_status_str;
                string pass_status_str;
                
                total_count = sm_test_case_queue[i].m_pass_count +
                    sm_test_case_queue[i].m_fail_count;
                
                if (sm_test_case_queue[i].m_done) begin
                    done_status_str = done_str;
                    num_done_tests++;
                end else begin
                    done_status_str = timeout_str;
                    num_timeout_tests++;
                end
                
                if (total_count == 0) begin
                    pass_status_str = unknown_str;
                    num_unknown_tests++;
                end else if (sm_test_case_queue[i].m_pass_count == total_count) begin
                    pass_status_str = pass_str;
                    num_passing_tests++;
                end else begin
                    pass_status_str = fail_str;
                    num_failing_tests++;
                end
                
                $write("%12t | %0s> %0s, %0s (%0d / %0d)\n", $time,
                    sm_test_case_queue[i].m_test_name, done_status_str,
                    pass_status_str, sm_test_case_queue[i].m_pass_count,
                    total_count);
            end
            
            if (num_timeout_tests > 0) begin
                final_done_status_str = timeout_str;
            end else begin
                final_done_status_str = done_str;
            end
            
            if (num_failing_tests > 0) begin
                final_pass_status_str = fail_str;
            end else if (num_unknown_tests > 0) begin
                final_pass_status_str = unknown_str;
            end else begin
                final_pass_status_str = pass_str;
            end
            
            $write("%12t | Status: %0s, %0s | (Done: %0d, Timeout: %0d), (Pass: %0d, Fail: %0d, Unknown: %0d)\n",
                $time, final_done_status_str, final_pass_status_str,
                num_done_tests, num_timeout_tests,
                num_passing_tests, num_failing_tests, num_unknown_tests);
        endfunction
        
        static task automatic run_all_tests ();
            #0;
            
            for (int unsigned i = 0 ; i < $size(sm_test_case_queue) ; i++) begin
                fork
                    automatic int unsigned index = i;
                    
                    sm_test_case_queue[index].run_test();
                join_none
            end
            
            fork
                begin
                    wait_for_done();
                    report();
                    
                    $finish();
                end
                
                begin
                    #1000000;
                    report();
                    
                    $fatal("Hang");
                    
                    $finish();
                end
            join_any
        endtask
    endclass
endpackage
