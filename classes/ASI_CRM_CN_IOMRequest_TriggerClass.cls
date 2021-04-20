public with sharing class ASI_CRM_CN_IOMRequest_TriggerClass {
    
    public static void routineAfterUpdate(list<ASI_CRM_Image_Outlet_Request__c> trigger_new, map<id, ASI_CRM_Image_Outlet_Request__c> trigger_oldMap) {
        /*Set<id> IOMID = new Set<id>();
        for (ASI_CRM_Image_Outlet_Request__c p:trigger_new) {
            if (p.ASI_CRM_Status__c == 'Budget Approved' && trigger_oldMap.get(p.id).ASI_CRM_Status__c == 'Submitted for Budget Approval'){
                IOMID.add(p.id);
            }
        }
        if(IOMID.size()>0){
            //Send email Notificaton  to ASI_CRM_Sys_Approver__c 
            List<ASI_CRM_Image_Outlet_Request__c> IOMterm=[select ownerId,ASI_CRM_Sys_Approver__c,ASI_CRM_Sys_Approver__r.Email from ASI_CRM_Image_Outlet_Request__c where id in: IOMID];
            List <String> ToAddresses = new List <String>();
            ID ownerid;
            Id templateId;
            String templateApiName = 'ASI_CRM_CN_IOM_Approved_Template';  
            for(ASI_CRM_Image_Outlet_Request__c iom:IOMterm){
                if(iom.ASI_CRM_Sys_Approver__r.Email!=null){
                    ToAddresses.add(iom.ASI_CRM_Sys_Approver__r.Email);
                    ownerid=iom.ownerId;
                }
            }
            try {
                templateId = [select id, name from EmailTemplate where developername = : templateApiName].id;
            }catch (Exception e) {
            }
            for(id sid:IOMID){
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); 
                email.setTargetObjectId(ownerid);
                email.setToAddresses( ToAddresses );
                email.setWhatId(sid );
                email.setSaveAsActivity(false); 
                email.setBccSender(false);
                email.setUseSignature(false);
                email.setTemplateId(templateId);
                //Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
            }
        } */
    }
    
    public static void routineBeforeUpdate(list<ASI_CRM_Image_Outlet_Request__c> trigger_new, map<id, ASI_CRM_Image_Outlet_Request__c> trigger_oldMap) {
        Set<id> SAccountID = new Set<id>();
        Set<String> SRegionChannel = new Set<String>();
        set<id> rejected_set = new set<id>();
        map<id, ASI_CRM_Image_Outlet_Request__c> reject_map = new map<id, ASI_CRM_Image_Outlet_Request__c>();
        // Get involved outlet account additional field records
        for(ASI_CRM_Image_Outlet_Request__c r : trigger_new){
            setApproverToNull(r);
            SAccountID.add(r.ASI_CRM_Outlet__c);
            if ((r.ASI_CRM_Status__c == 'Draft' && trigger_oldMap.get(r.id).ASI_CRM_Status__c == 'Submitted to RTMK')||(r.ASI_CRM_Status__c == 'Preliminary Approved'  && trigger_oldMap.get(r.id).ASI_CRM_Status__c == 'Submitted for Budget Approval')) {
                reject_map.put(r.id, r);
            }
        }
        if (reject_map.size() > 0) {
            list<ASI_CRM_Image_Outlet_Request__c> reject_list = [select (select Comments from ProcessSteps order by createdDate desc limit 1) from ASI_CRM_Image_Outlet_Request__c where id in :reject_map.keySet()];
            if(reject_list.size()>0){
                for (ASI_CRM_Image_Outlet_Request__c r:reject_list) {
                    if (r.processSteps.size() > 0 && reject_map.containsKey(r.id)) {
                        reject_map.get(r.id).ASI_CRM_Comments__c = r.processSteps[0].comments;
                    }
            	}
            } else {
                System.debug('No List:::'+reject_list.size());
            }
        }
        
        
        // Query Account additional Field for sub-channel, region
        Map<id, ASI_CRM_AccountsAdditionalField__c> MAccount = new Map<id,ASI_CRM_AccountsAdditionalField__c>();
        for(ASI_CRM_AccountsAdditionalField__c a :[Select id,ASI_CRM_City__c,ASI_CRM_CN_Division_Name__c,ASI_CRM_CN_Sub_Channel__r.name, ASI_CRM_CN_Region__c,ASI_CRM_CN_Sub_Channel__r.ASI_MFM_Channel__c,ASI_CRM_CN_Sub_Channel__r.ASI_CRM_Channel_Name__c
                                                   from ASI_CRM_AccountsAdditionalField__c where id IN :SAccountID]){
                if(a.ASI_CRM_CN_Sub_Channel__c != null){
                    SRegionChannel.add(a.ASI_CRM_CN_Sub_Channel__r.ASI_MFM_Channel__c.replaceALL('-', ''));
                    MAccount.put(a.id,a);
                    System.debug(SRegionChannel+'TestABC:'+a.ASI_CRM_CN_Sub_Channel__r.ASI_MFM_Channel__c);
                }
                if(a.ASI_CRM_CN_Division_Name__c != null && a.ASI_CRM_CN_Division_Name__c != ''){
                    SRegionChannel.add(a.ASI_CRM_CN_Division_Name__c);
                    System.debug('TestApproverDivision'+a.ASI_CRM_CN_Division_Name__c);
                    if(!MAccount.containsKey(a.id))
                        MAccount.put(a.id,a);
                }
            }

        System.debug('TestABC123:');
        // Query Fix approval route based on sub-channel, region -- 
        Map<string, ASI_CRM_Fix_Approval_Route__c> MApprover = new Map<string, ASI_CRM_Fix_Approval_Route__c>();
        for(ASI_CRM_Fix_Approval_Route__c r : [Select id, ASI_CRM_CN_Region_Area_Channel__c, ASI_CRM_CN_Type__c,ASI_CRM_CN_Approver_1__r.name,ASI_CRM_CN_Regional_BA__c,ASI_CRM_CN_Regional_BA__r.name,
            ASI_CRM_CN_Approver_1__c, ASI_CRM_CN_Approver_2__c      
            from ASI_CRM_Fix_Approval_Route__c where (ASI_CRM_CN_Type__c = 'IOM' or ASI_CRM_CN_Type__c='IOM-Channel')and ASI_CRM_CN_Region_Area_Channel__c IN :SRegionChannel]){
                MApprover.put(r.ASI_CRM_CN_Region_Area_Channel__c,r);
                System.debug('TestApprover'+r.ASI_CRM_CN_Approver_1__r.name);
            }
        
        // Assign Approver
        for(ASI_CRM_Image_Outlet_Request__c r : trigger_new){
            setApprovers(r, MAccount, MApprover);
        }
    }
    
    
    
    
    public static void routineBeforeInsert(list<ASI_CRM_Image_Outlet_Request__c> trigger_new){
        //Add By Elufa-set Approvers
        Set<id> SAccountID = new Set<id>();
        Set<String> SRegionChannel = new Set<String>();
        
        // Get involved outlet account additional field records
        for(ASI_CRM_Image_Outlet_Request__c r : trigger_new){
            setApproverToNull(r);
            SAccountID.add(r.ASI_CRM_Outlet__c);
        }
          Map<id, ASI_CRM_AccountsAdditionalField__c> MAccount = new Map<id,ASI_CRM_AccountsAdditionalField__c>();
        for(ASI_CRM_AccountsAdditionalField__c a :[Select id,ASI_CRM_City__c,ASI_CRM_CN_Division_Name__c,ASI_CRM_CN_Sub_Channel__r.name, ASI_CRM_CN_Region__c,ASI_CRM_CN_Sub_Channel__r.ASI_MFM_Channel__c,ASI_CRM_CN_Sub_Channel__r.ASI_CRM_Channel_Name__c
                                                   from ASI_CRM_AccountsAdditionalField__c where id IN :SAccountID]){
                if(a.ASI_CRM_CN_Sub_Channel__c != null){
                    SRegionChannel.add(a.ASI_CRM_CN_Sub_Channel__r.ASI_MFM_Channel__c.replaceALL('-', ''));
                    MAccount.put(a.id,a);
                    System.debug(SRegionChannel+'TestABC:'+a.ASI_CRM_CN_Sub_Channel__r.ASI_MFM_Channel__c);
                }
                if(a.ASI_CRM_CN_Division_Name__c != null && a.ASI_CRM_CN_Division_Name__c != ''){
                    SRegionChannel.add(a.ASI_CRM_CN_Division_Name__c);
                    System.debug('TestApproverDivision'+a.ASI_CRM_CN_Division_Name__c);
                    if(!MAccount.containsKey(a.id))
                        MAccount.put(a.id,a);
                }
            }

        System.debug('TestABC123:');
        // Query Fix approval route based on sub-channel, region -- 
        Map<string, ASI_CRM_Fix_Approval_Route__c> MApprover = new Map<string, ASI_CRM_Fix_Approval_Route__c>();
        for(ASI_CRM_Fix_Approval_Route__c r : [Select id, ASI_CRM_CN_Region_Area_Channel__c, ASI_CRM_CN_Type__c,ASI_CRM_CN_Approver_1__r.name,ASI_CRM_CN_Regional_BA__c,ASI_CRM_CN_Regional_BA__r.name,
            ASI_CRM_CN_Approver_1__c, ASI_CRM_CN_Approver_2__c      
            from ASI_CRM_Fix_Approval_Route__c where (ASI_CRM_CN_Type__c = 'IOM' or ASI_CRM_CN_Type__c='IOM-Channel')and ASI_CRM_CN_Region_Area_Channel__c IN :SRegionChannel]){
                MApprover.put(r.ASI_CRM_CN_Region_Area_Channel__c,r);
                System.debug('TestApprover'+r.ASI_CRM_CN_Approver_1__r.name);
            }
        
        // Assign Approver
        for(ASI_CRM_Image_Outlet_Request__c r : trigger_new){
            setApprovers(r, MAccount, MApprover);
        }
        
        /*
        // Added by Michael Yip (Introv) 4May2014 for Assign Approver by fix route for Image outlet request
        Set<id> SAccountID = new Set<id>();
        Set<String> SRegionChannel = new Set<String>();
        
        // Get involved outlet account additional field records
        for(ASI_CRM_Image_Outlet_Request__c r : trigger_new){
            setApproverToNull(r);
            SAccountID.add(r.ASI_CRM_Outlet__c);
        }
        // Query Account additional Field for sub-channel, region
        Map<id, ASI_CRM_AccountsAdditionalField__c> MAccount = new Map<id,ASI_CRM_AccountsAdditionalField__c>();
        for(ASI_CRM_AccountsAdditionalField__c a :[Select id, ASI_CRM_CN_Sub_Channel__r.name, ASI_CRM_CN_Region__c,ASI_CRM_CN_Sub_Channel__r.ASI_MFM_Channel__c
            from ASI_CRM_AccountsAdditionalField__c where id IN :SAccountID]){
                if(a.ASI_CRM_CN_Sub_Channel__c != null){
                    SRegionChannel.add(a.ASI_CRM_CN_Sub_Channel__r.ASI_MFM_Channel__c);
                    MAccount.put(a.id,a);
                }
                if(a.ASI_CRM_CN_Region__c != null && a.ASI_CRM_CN_Region__c != ''){
                    SRegionChannel.add(a.ASI_CRM_CN_Region__c);
                    if(!MAccount.containsKey(a.id))
                        MAccount.put(a.id,a);
                }
            }
        
        // Query Fix approval route based on sub-channel, region -- 
        Map<string, ASI_CRM_Fix_Approval_Route__c> MApprover = new Map<string, ASI_CRM_Fix_Approval_Route__c>();
        for(ASI_CRM_Fix_Approval_Route__c r : [Select id, ASI_CRM_CN_Region_Area_Channel__c, ASI_CRM_CN_Type__c,
            ASI_CRM_CN_Approver_1__c, ASI_CRM_CN_Approver_2__c      
            from ASI_CRM_Fix_Approval_Route__c where ASI_CRM_CN_Type__c = 'IOM' and ASI_CRM_CN_Region_Area_Channel__c IN :SRegionChannel]){
                MApprover.put(r.ASI_CRM_CN_Region_Area_Channel__c,r);
            }
            
        
        // Assign Approver
        for(ASI_CRM_Image_Outlet_Request__c r : trigger_new){
            setApprovers(r, MAccount, MApprover);
        }
        */
        
        ////// Start Update Image Outlet Plan and Count
        {
            //prepare Outlets for lookup
            set<Id> outletIds = new set<Id>();
            for(ASI_CRM_Image_Outlet_Request__c iom :trigger_new) {
                outletIds.add(iom.ASI_CRM_Outlet__c);    
            }
            map<Id, ASI_CRM_AccountsAdditionalField__c> mapOutlets = new map<Id, ASI_CRM_AccountsAdditionalField__c>(
                [SELECT Id, ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c, ASI_CRM_CN_Sub_Channel__c 
                 FROM ASI_CRM_AccountsAdditionalField__c
                 WHERE Id in :outletIds]);
            
            //prepare Image Outlet Plan lookup keys
            list<IOMPlanKey> iomPlanKeys = new list<IOMPlanKey>();
            map<string, ASI_CRM_Image_Outlet_Request__c> mapIOMRequests = new map<string, ASI_CRM_Image_Outlet_Request__c>();
            for(ASI_CRM_Image_Outlet_Request__c iom :trigger_new) {
                IOMPlanKey iomPlanKey = new IOMPlanKey();
                iomPlanKey.FiscalYear = getFiscalYearString(iom.ASI_CRM_Application_Date__c);
                iomPlanKey.RegionId = mapOutlets.get(iom.ASI_CRM_Outlet__c).ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c;
                iomPlanKey.SubChannelId = mapOutlets.get(iom.ASI_CRM_Outlet__c).ASI_CRM_CN_Sub_Channel__c;
                iomPlanKeys.add(iomPlanKey);
                string key = iomPlanKey.FiscalYear + '|' + iomPlanKey.RegionId + '|' + iomPlanKey.SubChannelId;
                mapIOMRequests.put(key, iom);
            }
            
            //prepare map of Image Outlet Plan by lookup keys
            list<ASI_CRM_Image_Outlet_Plan__c> iomPlans = getIOMPlans(iomPlanKeys);
            map<string, ASI_CRM_Image_Outlet_Plan__c> mapIOMPlans = new map<string, ASI_CRM_Image_Outlet_Plan__c>();
            for(ASI_CRM_Image_Outlet_Plan__c iomPlan :iomPlans) {
                string key = iomPlan.ASI_CRM_Fiscal_Year__c + '|' + iomPlan.ASI_CRM_Region__c + '|' + iomPlan.ASI_CRM_Sub_Channel__c;
                if(!mapIOMPlans.containsKey(key)) 
                    mapIOMPlans.put(key, iomPlan);
            }
            iomPlans.clear();
            
            for(string key: mapIOMRequests.keySet()) {
                ASI_CRM_Image_Outlet_Plan__c iomPlan = mapIOMPlans.get(key);
                ASI_CRM_Image_Outlet_Request__c iomRequest = mapIOMRequests.get(key);
                if(iomPlan==null || iomRequest==null) continue;
                
                iomRequest.ASI_CRM_Image_Outlet_Plan__c = iomPlan.Id;
                iomPlan.ASI_CRM_Actual_No_of_Image_Outlet__c = iomPlan.ASI_CRM_Actual_No_of_Image_Outlet__c==null? 1 : (iomPlan.ASI_CRM_Actual_No_of_Image_Outlet__c+1);
            }
            
            update mapIOMPlans.values();
        }
        ////// End   Update Image Outlet Plan and Count
    }

    public static void routineBeforeDelete(list<ASI_CRM_Image_Outlet_Request__c> trigger_new){
        
        ////// Start Update Image Outlet Plan Count
        {
            //prepare Outlets for lookup
            set<Id> outletIds = new set<Id>();
            for(ASI_CRM_Image_Outlet_Request__c iom :trigger_new) {
                outletIds.add(iom.ASI_CRM_Outlet__c);    
            }
            map<Id, ASI_CRM_AccountsAdditionalField__c> mapOutlets = new map<Id, ASI_CRM_AccountsAdditionalField__c>(
                [SELECT Id, ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c, ASI_CRM_CN_Sub_Channel__c 
                 FROM ASI_CRM_AccountsAdditionalField__c
                 WHERE Id in :outletIds]);
            
            //prepare Image Outlet Plan lookup keys
            list<IOMPlanKey> iomPlanKeys = new list<IOMPlanKey>();
            map<string, ASI_CRM_Image_Outlet_Request__c> mapIOMRequests = new map<string, ASI_CRM_Image_Outlet_Request__c>();
            for(ASI_CRM_Image_Outlet_Request__c iom :trigger_new) {
                IOMPlanKey iomPlanKey = new IOMPlanKey();
                iomPlanKey.FiscalYear = getFiscalYearString(iom.ASI_CRM_Application_Date__c);
                iomPlanKey.RegionId = mapOutlets.get(iom.ASI_CRM_Outlet__c).ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c;
                iomPlanKey.SubChannelId = mapOutlets.get(iom.ASI_CRM_Outlet__c).ASI_CRM_CN_Sub_Channel__c;
                iomPlanKeys.add(iomPlanKey);
                string key = iomPlanKey.FiscalYear + '|' + iomPlanKey.RegionId + '|' + iomPlanKey.SubChannelId;
                mapIOMRequests.put(key, iom);
            }
            
            //prepare map of Image Outlet Plan by lookup keys
            list<ASI_CRM_Image_Outlet_Plan__c> iomPlans = getIOMPlans(iomPlanKeys);
            map<string, ASI_CRM_Image_Outlet_Plan__c> mapIOMPlans = new map<string, ASI_CRM_Image_Outlet_Plan__c>();
            for(ASI_CRM_Image_Outlet_Plan__c iomPlan :iomPlans) {
                string key = iomPlan.ASI_CRM_Fiscal_Year__c + '|' + iomPlan.ASI_CRM_Region__c + '|' + iomPlan.ASI_CRM_Sub_Channel__c;
                if(!mapIOMPlans.containsKey(key)) 
                    mapIOMPlans.put(key, iomPlan);
            }
            iomPlans.clear();
            
            for(string key: mapIOMRequests.keySet()) {
                ASI_CRM_Image_Outlet_Plan__c iomPlan = mapIOMPlans.get(key);
                ASI_CRM_Image_Outlet_Request__c iomRequest = mapIOMRequests.get(key);
                if(iomPlan==null || iomRequest==null) continue;
                
                iomPlan.ASI_CRM_Actual_No_of_Image_Outlet__c = iomPlan.ASI_CRM_Actual_No_of_Image_Outlet__c==null? null : (iomPlan.ASI_CRM_Actual_No_of_Image_Outlet__c-1);
            }
            
            update mapIOMPlans.values();
        }
        ////// End   Update Image Outlet Plan Count

    }
    
    private static string getFiscalYearString(Date d) {
        integer yr1 = (d.month()>=7) ? d.year() : (d.year()-1);
        string syr1 = string.valueOf(yr1);
        syr1 = syr1.substring(syr1.length()-2);
        string syr2 = string.valueOf(yr1+1);
        syr2 = syr2.substring(syr2.length()-2);
        return 'FY' + syr1 + '/' + syr2;
    }
    
    private class IOMPlanKey {
        public string FiscalYear;
        public Id RegionId;
        public Id SubChannelId;
    }
    
    private static list<ASI_CRM_Image_Outlet_Plan__c> getIOMPlans(list<IOMPlanKey> iomPlanKeys) {
        list<string> fiscalYears = new list<string>();
        list<Id> regionIds = new list<Id>();
        list<Id> subChannelIds = new list<Id>();
        for(IOMPlanKey iomPlanKey :iomPlanKeys) {
            fiscalYears.add(iomPlanKey.FiscalYear);
            regionIds.add(iomPlanKey.RegionId);
            subChannelIds.add(iomPlanKey.SubChannelId);
        }
            
        return [SELECT Id, ASI_CRM_Fiscal_Year__c, ASI_CRM_Region__c, ASI_CRM_Sub_Channel__c, ASI_CRM_Actual_No_of_Image_Outlet__c 
                FROM ASI_CRM_Image_Outlet_Plan__c
                WHERE ASI_CRM_Fiscal_Year__c in :fiscalYears AND ASI_CRM_Region__c in :regionIds AND ASI_CRM_Sub_Channel__c in :subChannelIds
                FOR UPDATE];
    }
        
    
    public static void setApprovers(ASI_CRM_Image_Outlet_Request__c request, Map<id, ASI_CRM_AccountsAdditionalField__c> MAccount, Map<string, ASI_CRM_Fix_Approval_Route__c> MApprover){
        if(request != null && MAccount != null && MApprover != null){
            if(request.ASI_CRM_Outlet__c != null  & MAccount.containsKey(request.ASI_CRM_Outlet__c)){
                ASI_CRM_AccountsAdditionalField__c accountAddField = MAccount.get(request.ASI_CRM_Outlet__c);
                // Assign approver 1 (region)
                if(accountAddField.ASI_CRM_CN_Division_Name__c != null && MApprover.containsKey(accountAddField.ASI_CRM_CN_Division_Name__c)){
                    ASI_CRM_Fix_Approval_Route__c approver = MApprover.get(accountAddField.ASI_CRM_CN_Division_Name__c);
                    if(approver != null){
                        request.ASI_CRM_Sys_Approver__c= approver.ASI_CRM_CN_Approver_1__c;
                        request.ASI_CRM_Sys_Approver_2__c=approver.ASI_CRM_CN_Approver_2__c;
                        request.ASI_CRM_Sys_Approver_Region__c=approver.ASI_CRM_CN_Regional_BA__c;  //ASI_CRM_Sys_Approver_2__c
                    }
                }   
                // Assign approver 2 (sub-channel)
                if(accountAddField.ASI_CRM_CN_Sub_Channel__c != null && MApprover.containsKey(accountAddField.ASI_CRM_CN_Sub_Channel__r.ASI_CRM_Channel_Name__c.replaceALL('-', ''))){ //Change By Elufa
                    ASI_CRM_Fix_Approval_Route__c approver = MApprover.get(accountAddField.ASI_CRM_CN_Sub_Channel__r.ASI_CRM_Channel_Name__c.replaceALL('-', ''));
                    System.debug(approver+'TestaccountAddField'+accountAddField.ASI_CRM_CN_Sub_Channel__r.ASI_CRM_Channel_Name__c);
                    if(approver != null && request.ASI_CRM_Need_HQ_Sponsor__c==true){
                        request.ASI_CRM_Sys_Approver_Channel__c = approver.ASI_CRM_CN_Approver_1__c;
                        request.ASI_CRM_Notificaton_Merchindising__c=approver.ASI_CRM_CN_Regional_BA__c; //Add By Elufa
                    }
                    if(approver != null){
                        request.ASI_CRM_Notificaton_Merchindising__c=approver.ASI_CRM_CN_Regional_BA__c; 
                    }
                }
                
                if( request.ASI_CRM_Need_HQ_Sponsor__c==false){
                    request.ASI_CRM_Sys_Approver_Channel__c=null;
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
    
    public static void setApproverToNull(ASI_CRM_Image_Outlet_Request__c p){
        p.ASI_CRM_Sys_Approver_Channel__c = null;
        p.ASI_CRM_Sys_Approver_Region__c = null;
        
        
    }
}