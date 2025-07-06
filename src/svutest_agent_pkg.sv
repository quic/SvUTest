// Copyright (c) 2024 Qualcomm Innovation Center, Inc. All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause-Clear

package svutest_agent_pkg;
    interface class protocol;
        pure virtual task clear ();
        pure virtual task run ();
    endclass
    
    class injector_queue #(type T_payload);
        typedef struct {
            bit         valid;
            T_payload   payload;
        } T_queue_type;
        
        protected T_queue_type m_queue [$];
        
        function new ();
            m_queue = {};
        endfunction
        
        function void put (T_payload payload);
            T_queue_type queue_entry;
            
            queue_entry = '{
                valid:      1'b1,
                payload:    payload
            };
            
            m_queue.push_back(queue_entry);
        endfunction
        
        function void put_delay ();
            T_queue_type queue_entry;
            
            queue_entry = '{
                valid:      1'b0,
                payload:    'x
            };
            
            m_queue.push_back(queue_entry);
        endfunction
    endclass
    
    class valid_ready_injector #(
        type T_payload = logic
    ) extends injector_queue#(T_payload) implements protocol;
        typedef virtual svutest_req_payload_rsp_if#(T_payload).sender T_vif;
        
        local T_vif m_vif;
        
        function new (T_vif vif);
            super.new();
            
            m_vif = vif;
        endfunction
        
        virtual task clear ();
            m_vif.req <= 1'b0;
            m_vif.req_payload <= 'x;
        endtask
        
        virtual task run ();
            this.clear();
            
            forever begin
                T_queue_type queue_entry;
                
                wait (m_queue.size() != 0);
                
                queue_entry = m_queue.pop_front();
                
                if (queue_entry.valid) begin
                    m_vif.req <= 1'b1;
                    m_vif.req_payload <= queue_entry.payload;
                    
                    @(posedge m_vif.clk iff (!m_vif.rst && m_vif.rsp));
                end else begin
                    m_vif.req <= 1'b0;
                    m_vif.req_payload <= 'x;
                    
                    @(posedge m_vif.clk iff !m_vif.rst);
                end
                
                this.clear();
            end
        endtask
    endclass
    
    class credit_write_injector #(
        type T_payload = logic
    ) extends injector_queue#(T_payload) implements protocol;
        typedef virtual svutest_req_payload_rsp_if#(T_payload).sender T_vif;
        
        local T_vif m_vif;
        local int unsigned m_credit_count;
        
        function new (T_vif vif, int unsigned init_credit_count = 0);
            super.new();
            
            m_vif = vif;
            m_credit_count = init_credit_count;
        endfunction
        
        virtual task clear ();
            m_vif.req <= 1'b0;
            m_vif.req_payload <= 'x;
        endtask
        
        task monitor_credit_release ();
            forever begin
                @(posedge clk iff (!rst && m_vif.rsp));
                
                m_credit_count <= m_credit_count + 1;
            end
        endtask
        
        virtual task run ();
            fork
                this.monitor_credit_release();
            join_none
            
            this.clear();
            
            while (m_queue.size() != 0) begin
                T_queue_type queue_entry;
                
                wait (m_queue.size() != 0);
                
                queue_entry = m_queue.pop_front();
                
                if (queue_entry.valid) begin
                    wait (m_credit_count != 0);
                    
                    m_vif.req <= 1'b1;
                    m_vif.req_payload <= queue_entry.payload;
                    
                    @(posedge m_vif.clk iff !m_vif.rst);
                end else begin
                    m_vif.req <= 1'b0;
                    m_vif.req_payload <= 'x;
                    
                    @(posedge m_vif.clk iff !m_vif.rst);
                end
                
                this.clear();
            end
        endtask
    endclass
    
    // interface class protocol;
    //     virtual task clear ();
    //     virtual task run ();
    // endclass
    
    class extractor_queue #(type T_payload);
        typedef T_payload T_queue [$];
        
        protected logic m_rsp_queue [$];
        protected T_queue m_queue;
        
        function new ();
            m_rsp_queue = {};
            m_queue = {};
        endfunction
        
        function void put_rsp (logic value);
            m_rsp_queue.push_back(value);
        endfunction
        
        function T_queue get_queue ();
            return m_queue;
        endfunction
    endclass
    
    class valid_ready_extractor #(
        type T_payload = logic
    ) extends extractor_queue#(T_payload) implements protocol;
        typedef virtual svutest_req_payload_rsp_if#(T_payload).target T_vif;
        
        T_vif m_vif;
        
        function new (T_vif vif);
            m_vif = vif;
        endfunction
        
        local task monitor ();
            forever begin
                @(posedge m_vif.clk iff (!m_vif.rst && m_vif.req && m_vif.rsp));
                
                m_queue.push_back(m_vif.req_payload);
            end
        endtask
        
        virtual task clear();
            m_vif.rsp <= 1'b1;
        endtask
        
        virtual task run ();
            fork
                this.monitor();
            join_none
            
            this.clear();
            
            forever begin
                wait (m_rsp_queue.size() != 0);
                
                m_vif.rsp <= m_rsp_queue.pop_front();
                
                @(posedge m_vif.clk iff !m_vif.rst);
                
                this.clear();
            end
        endtask
    endclass
endpackage
