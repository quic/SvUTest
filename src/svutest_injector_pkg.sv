// Copyright (c) 2024 Qualcomm Innovation Center, Inc. All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause-Clear

package svutest_injector_pkg;
    import svutest_core_pkg::*;
    
    class injector #(
        type T_payload,
        type T_vif
    );
        typedef struct {
            bit         req;
            T_payload   req_payload;
        } T_queue_type;
        
        protected T_queue_type m_queue [$];
        protected T_vif m_vif;
        
        function new (T_vif vif);
            m_queue = {};
            m_vif = vif;
        endfunction
        
        function void put (T_payload req_payload);
            T_queue_type queue_entry;
            
            queue_entry = '{
                req:            1'b1,
                req_payload:    req_payload
            };
            
            m_queue.push_back(queue_entry);
        endfunction
        
        function void put_delay ();
            T_queue_type queue_entry;
            
            queue_entry = '{
                req:            1'b0,
                req_payload:    'x
            };
            
            m_queue.push_back(queue_entry);
        endfunction
    endclass
    
    class level_data_injector #(type T_payload)
        extends injector#(T_payload, virtual svutest_payload_if#(T_payload).driver)
        implements protocol;
        
        function new (virtual svutest_payload_if#(T_payload).driver vif);
            super.new(vif);
        endfunction
        
        virtual task clear ();
            m_vif.req_payload <= '0;
        endtask
        
        virtual task run ();
            this.clear();
            
            forever begin
                T_queue_type queue_entry;
                
                wait (m_queue.size() != 0);
                
                queue_entry = m_queue.pop_front();
                
                if (queue_entry.req) begin
                    m_vif.req_payload <= queue_entry.req_payload;
                    
                    @(posedge m_vif.clk iff !m_vif.rst);
                end else begin
                    this.clear();
                    
                    @(posedge m_vif.clk iff !m_vif.rst);
                end
            end
        endtask
    endclass
    
    class pulse_data_injector #(type T_payload)
        extends injector#(T_payload, virtual svutest_payload_if#(T_payload).driver)
        implements protocol;
        
        function new (virtual svutest_payload_if#(T_payload).driver vif);
            super.new(vif);
        endfunction
        
        virtual task clear ();
            m_vif.req_payload <= '0;
        endtask
        
        virtual task run ();
            this.clear();
            
            forever begin
                T_queue_type queue_entry;
                
                wait (m_queue.size() != 0);
                
                queue_entry = m_queue.pop_front();
                
                if (queue_entry.req) begin
                    m_vif.req_payload <= queue_entry.req_payload;
                    
                    @(posedge m_vif.clk iff !m_vif.rst);
                end else begin
                    this.clear();
                    
                    @(posedge m_vif.clk iff !m_vif.rst);
                end
                
                this.clear();
            end
        endtask
    endclass
    
    class valid_data_injector #(type T_payload)
        extends injector#(T_payload, virtual svutest_req_payload_if#(T_payload).driver)
        implements protocol;
        
        function new (virtual svutest_req_payload_if#(T_payload).driver vif);
            super.new(vif);
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
                
                if (queue_entry.req) begin
                    m_vif.req <= 1'b1;
                    m_vif.req_payload <= queue_entry.req_payload;
                    
                    @(posedge m_vif.clk iff !m_vif.rst);
                end else begin
                    this.clear();
                    
                    @(posedge m_vif.clk iff !m_vif.rst);
                end
                
                this.clear();
            end
        endtask
    endclass
    
    class valid_data_ready_injector #(type T_payload)
        extends injector#(T_payload, virtual svutest_req_payload_rsp_if#(T_payload).driver)
        implements protocol;
        
        function new (virtual svutest_req_payload_rsp_if#(T_payload).driver vif);
            super.new(vif);
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
                
                if (queue_entry.req) begin
                    m_vif.req <= 1'b1;
                    m_vif.req_payload <= queue_entry.req_payload;
                    
                    @(posedge m_vif.clk iff (!m_vif.rst && m_vif.rsp));
                end else begin
                    this.clear();
                    
                    @(posedge m_vif.clk iff !m_vif.rst);
                end
                
                this.clear();
            end
        endtask
    endclass
    
    class credit_write_injector #(type T_payload)
        extends injector#(T_payload, virtual svutest_req_payload_rsp_if#(T_payload).driver)
        implements protocol;
        
        local int unsigned m_credit_count;
        
        function new (virtual svutest_req_payload_rsp_if#(T_payload).driver vif, int unsigned init_credit_count = 0);
            super.new(vif);
            
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
                
                if (queue_entry.req) begin
                    wait (m_credit_count != 0);
                    
                    m_vif.req <= 1'b1;
                    m_vif.req_payload <= queue_entry.req_payload;
                    
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
endpackage
