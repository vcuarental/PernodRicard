public with sharing class ASI_CRM_CN_Channel_Strategy_TriggerClass {
//lokman 4/5/2014 
    public static void routineBeforeInsert(list<ASI_CRM_CN_Channel_Strategy__c> trigger_new){
                // Get involved outlet account additional field records
       // System.Debug('routineBeforeInsert:');
        Set<String> Area_name= new Set<String>();
       // System.Debug('trigger_new:'+trigger_new);
        // Get involved outlet account additional field records
        for(ASI_CRM_CN_Channel_Strategy__c r : trigger_new){
            Area_name.add(r.ASI_CRM_CN_Area_Eng_Name__c);
           // System.Debug('Area:'+r.ASI_CRM_CN_Area_Eng_Name__c);
           
        }

        // Query Fix approval route based on sub-channel, region -- 
        Map<string, ASI_CRM_Fix_Approval_Route__c> MApprover = new Map<string, ASI_CRM_Fix_Approval_Route__c>();
        for(ASI_CRM_Fix_Approval_Route__c r : [Select id, ASI_CRM_CN_Region_Area_Channel__c, ASI_CRM_CN_Type__c,
            ASI_CRM_CN_Approver_1__c   
            from ASI_CRM_Fix_Approval_Route__c where ASI_CRM_CN_Type__c = 'Channel Strategy' and ASI_CRM_CN_Region_Area_Channel__c IN :Area_name]){
                MApprover.put(r.ASI_CRM_CN_Region_Area_Channel__c,r);
            }
            
        
        // Assign Approver
        for(ASI_CRM_CN_Channel_Strategy__c r : trigger_new){
            setApprovers(r, MApprover);
        }
        
        
    }
    
    
    public static void setApprovers(ASI_CRM_CN_Channel_Strategy__c request, Map<string, ASI_CRM_Fix_Approval_Route__c> MApprover){
        if(request != null && MApprover != null){
            if(request.ASI_CRM_CN_Area_Eng_Name__c!= null  && MApprover.containsKey(request.ASI_CRM_CN_Area_Eng_Name__c)){
                    ASI_CRM_Fix_Approval_Route__c approver = MApprover.get(request.ASI_CRM_CN_Area_Eng_Name__c);
                    if(approver != null){
                   // System.Debug('approver :'+approver.ASI_CRM_CN_Approver_1__c);
                        request.ASI_CRM_CN_Sys_Approver_1__c= approver.ASI_CRM_CN_Approver_1__c;
                    }
                }
        }
    }
    
    /*
    public static void setApproverByCount(ASI_CRM_Image_Outlet_Request__c p, integer approver_count, Id userId)
    {
        if(approver_count == 0){
            p.ASI_CRM_Sys_Approver_Region__c = userId;
        }
        else if(approver_count == 1){
            p.ASI_CRM_Sys_Approver_Channel__c = userId;
        }        
    }
    */
    
    public static void setApproverToNull(ASI_CRM_CN_Channel_Strategy__c p){

        p.ASI_CRM_CN_Sys_Approver_1__c= null; 
    }

    
}