public without sharing class ASI_MFM_JP_PO_TriggerClass {
    public static void routineBeforeUpsert(list<ASI_MFM_PO__c> trigger_new, map<id, ASI_MFM_PO__c> trigger_oldMap) {
        
        //PO Id
        set<id> pid_set = new set<id>();
        // Responsible By
        set<id> pr_set = new set<id>();
        //Prefix
        set<id> px_set = new set<id>();
        
        
        for (ASI_MFM_PO__c p:trigger_new) {
            //Get ALL PO Id
            if (p.ASI_MFM_PO_Amount__c != null && p.ASI_MFM_Exchange_Rate__c > 0 && p.ASI_MFM_Status__c !='Final') {
                pid_set.add(p.id);
                //pr_set.add(p.ASI_MFM_Responsible_By__c); 
                pr_set.add(p.Ownerid);          // [SH] 2019-06-05
                if (p.asi_mfm_prefix__c != null) {
                    px_set.add(p.asi_mfm_prefix__c);
                }
                p.ASI_MFM_Sys_Approver_1__c = null;
                p.ASI_MFM_Sys_Approver_2__c = null;
                p.ASI_MFM_Sys_Approver_3__c = null;
                p.ASI_MFM_Sys_Approver_4__c = null;
                p.ASI_MFM_Sys_Approver_5__c = null;
            }
           
        }
        
        
        if(pid_set.size()>0){
            //Route Type Map
            set<id> rt_set = new set<id>();
            
            set<id> prt_set = new set<id>();
            
            //Brand Map
            map<id, id> b_map = new map<id, id>();
            //Get PO line Brand
            for (ASI_MFM_PO_Line_Item__c pi:[select id,ASI_MFM_PO__c, ASI_MFM_Sub_brand_Code__r.ASI_MFM_Brand__c from ASI_MFM_PO_Line_Item__c  
                                             where ASI_MFM_PO__c in :pid_set order by name desc]) {
                b_map.put(pi.id, pi.ASI_MFM_Sub_brand_Code__r.ASI_MFM_Brand__c);
            }
            
            system.debug('PO Line b_map : '+b_map);
            
            //Get Route Type from ASI MFM Route Type Brands Relationship based on  PO line Brand
            list<ASI_MFM_Route_Type_Brands_Relationship__c> rtBrule_list =[select Brand_MFM__c,ASI_MFM_Route_Type__c 
                                                                           from ASI_MFM_Route_Type_Brands_Relationship__c where Brand_MFM__c in:b_map.values() 
                                                                           order by ASI_MFM_Route_Type__c, Brand_MFM__c];
            system.debug('rtBrule_list Now : '+ rtBrule_list);
            for (ASI_MFM_Route_Type_Brands_Relationship__c rt:rtBrule_list) {
                rt_set.add(rt.ASI_MFM_Route_Type__c);
            }
            set<id> br_set = new set<id>();     
            for (ASI_MFM_Route_Type_Brands_Relationship__c br:rtBrule_list) {
                br_set.add(br.Brand_MFM__c);
            }      
            map<id, ASI_MFM_Sub_brand__c> sbList_map = new map<id, ASI_MFM_Sub_brand__c>([select id, ASI_MFM_Brand__c from ASI_MFM_Sub_brand__c 
                                                                                          where ASI_MFM_Brand__c in :br_set order by ASI_MFM_Brand__c]);
            
            
            list<ASI_MFM_Brand_Route_Type_Map__c> brm_list = new list<ASI_MFM_Brand_Route_Type_Map__c>();
            brm_list=[select ASI_MFM_Prefix__c, ASI_MFM_Route_Type__c, ASI_MFM_Sub_brand__c from ASI_MFM_Brand_Route_Type_Map__c 
                      where ASI_MFM_Active__c = true and ASI_MFM_Prefix__c in :px_set and ASI_MFM_Route_Type__c in :rt_set 
                      and (ASI_MFM_Responsible_By__c in :pr_set)  order by ASI_MFM_Prefix__c, ASI_MFM_Responsible_By__c desc];
            
            for(ASI_MFM_Brand_Route_Type_Map__c rtm:brm_list){
                prt_set.add(rtm.ASI_MFM_Route_Type__c);
            }   
            
            //Get Approver from 'Route Rule Detail' based on Route Type
            list<ASI_MFM_Route_Rule_Detail__c> rule_list = [select ASI_MFM_Approver__c, ASI_MFM_Minimum_Amount__c, ASI_MFM_Route_Type__c,ASI_MFM_Region__c from ASI_MFM_Route_Rule_Detail__c 
                                                            where ASI_MFM_Route_Type__c in :prt_set order by ASI_MFM_Route_Type__c, ASI_MFM_Minimum_Amount__c];
            system.debug('sbList_map Now: '+sbList_map);
            //Assign Approver   
            for (ASI_MFM_PO__c p:trigger_new) {
                boolean validSubBrand = false;
                if ( !ASI_MFM_Function.bypassTriggersFunctionCache('ASI_MFM_ValidateSubBrandCode')){
                    for (ASI_MFM_PO_Line_Item__c pi:[select ASI_MFM_PO__c, ASI_MFM_Sub_brand_Code__c from ASI_MFM_PO_Line_Item__c  where ASI_MFM_PO__c = :p.id order by name desc]) {
                        if (sbList_map.containsKey(pi.ASI_MFM_Sub_brand_Code__c) || validSubBrand ) {
                            validSubBrand = true;
                        }else
                        {
							system.debug('Failed Sub_brand_Code :  '+pi.ASI_MFM_Sub_brand_Code__c);                            
                            p.ASI_MFM_Responsible_By__c.adderror('Sub Brand Code is not allow for the route type');
                        }
                    }
                } else{
                    validSubBrand = true;
                }
                
                
                integer approver_count = 0;
                decimal local_amount=0;
                if(p.ASI_MFM_PO_Amount__c!=null && p.ASI_MFM_Exchange_Rate__c!=null){
                    local_amount= p.ASI_MFM_PO_Amount__c * p.ASI_MFM_Exchange_Rate__c;
                }
                
                if(validSubBrand || Test.isRunningTest()){
                    for (ASI_MFM_Route_Rule_Detail__c rd:rule_list) {
                        
                        if (rd.ASI_MFM_Minimum_Amount__c <= local_amount) {
                            if (approver_count == 0) {
                                p.ASI_MFM_Sys_Approver_1__c = rd.ASI_MFM_Approver__c;
                            }
                            else if (approver_count == 1) {                                 
                                p.ASI_MFM_Sys_Approver_2__c = rd.ASI_MFM_Approver__c;
                            }
                            else if (approver_count == 2) {                                 
                                p.ASI_MFM_Sys_Approver_3__c = rd.ASI_MFM_Approver__c;
                            }
                            else if (approver_count == 3) {                                 
                                p.ASI_MFM_Sys_Approver_4__c = rd.ASI_MFM_Approver__c;
                            }
                            else if (approver_count == 4) {                                 
                                p.ASI_MFM_Sys_Approver_5__c = rd.ASI_MFM_Approver__c;
                            }
                            else if (approver_count == 5) {                                 
                                p.ASI_MFM_Sys_Approver_6__c = rd.ASI_MFM_Approver__c;
                            }
                            else if (approver_count == 6) {                                 
                                p.ASI_MFM_Sys_Approver_7__c = rd.ASI_MFM_Approver__c;
                            }
                            else if (approver_count == 7) {                                 
                                p.ASI_MFM_Sys_Approver_8__c = rd.ASI_MFM_Approver__c;
                            }
                            else if (approver_count == 8) {                                 
                                p.ASI_MFM_Sys_Approver_9__c = rd.ASI_MFM_Approver__c;
                            }
                            else if (approver_count == 9) {                                 
                                p.ASI_MFM_Sys_Approver_10__c = rd.ASI_MFM_Approver__c;
                            }
                            approver_count++;                                                                                                                               
                        }
                        
                    }
                }
                
                
            }
            
            
        }
        
    }
}