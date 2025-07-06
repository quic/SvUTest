// Copyright (c) 2024 Qualcomm Innovation Center, Inc. All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause-Clear

package svutest_extractor_pkg;
    import svutest_core_pkg::*;
    
    class extractor #(type T_payload);
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
    ) extends extractor#(T_payload) implements protocol;
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
