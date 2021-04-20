public with sharing class ASI_MFM_SelectPlanPrefixLWC_Cls {
    //20200915:HF@introv - copy from ASI_MFM_SelectPlanPrefixController

    @AuraEnabled(cacheable = true)
	public static List<Selection> getPrefixes(Id RecordTypeId) {
        List<Selection> prefixList = new List<Selection>();
        List<Selection> errorList = new List<Selection>();
    	map<string, asi_mfm_role_prefix_relationship__c> px_map = new map<string, asi_mfm_role_prefix_relationship__c>();   

        user u = [select userRole.developerName, asi_mfm_country__c from user where id = :userInfo.getUserId()];
        if (u.userRole.developerName == null) {
            errorList.add(new Selection('','',true, 'The role of the user is not defined yet'));
            return errorList;
        }
        else if (u.asi_mfm_country__c == null) {
            errorList.add(new Selection('','',true, 'The country of the user is not defined yet'));
            return errorList;
        }
        else {
            list<asi_mfm_role_prefix_relationship__c> px_list = new list<asi_mfm_role_prefix_relationship__c>();
            for (asi_mfm_role_prefix_relationship__c px:[
                	select asi_mfm_prefix__c, asi_mfm_prefix__r.name,asi_mfm_prefix__r.RecordType.DeveloperName, asi_mfm_prefix__r.ASI_MFM_PAF_Prefix__c, asi_mfm_prefix__r.ASI_MFM_Description__c 
                	from asi_mfm_role_prefix_relationship__c
                	where asi_mfm_prefix__r.ASI_MFM_Inactive__c = false 
                	and asi_mfm_prefix__r.asi_mfm_module__c = 'Plan' 
                	and asi_mfm_role_name__c = :u.userRole.developerName 
                	and asi_mfm_prefix__r.asi_mfm_country_name__c = :u.asi_mfm_country__c 
                	order by asi_mfm_prefix__r.name]) {
                        px_map.put(px.asi_mfm_prefix__c, px);
                        px_list.add(px);
                        /*if(u.asi_mfm_country__c != 'TW'){
                                px_map.put(px.asi_mfm_prefix__c, px);
                                px_list.add(px);
                        }
                        else
                        {
                            if(px.asi_mfm_prefix__r.ASI_MFM_PAF_Prefix__c == false){
                                px_map.put(px.asi_mfm_prefix__c, px);
                                px_list.add(px); 
                            }
                        }*/
                    }
            		/*
                    if(u.asi_mfm_country__c=='KR'){//For KR User only
                        return new pageReference('/apex/ASI_MFM_KR_SelectProjectCodePage?Module=Plan'); 
                    }
					*/
            if (px_list.size() == 0) {
                errorList.add(new Selection('', '', true, 'The user is not entitled to input plans'));
                return errorList;
            }
            /*else if(u.asi_mfm_country__c=='PH' && px_list.size()>1){ 
                String Recordtypeid = ApexPages.currentPage().getParameters().get('RecordType');
                System.debug('Recordtypeid = ' +ApexPages.currentPage().getParameters());
                Map<String, id> MPlanRecType = new Map<String,id>();
                for(Recordtype r : Global_recordTypeCache.getRtList('ASI_MFM_Plan__c')){
                    MPlanRecType.put(r.developername,r.id);
                }
                if(MPlanRecType.get('ASI_MFM_PH_DP_Plan')==Recordtypeid){
                    available_prefixes = new list<selectOption>();
                    available_prefixes.add(new selectOption('', '-- None --'));
                    for (asi_mfm_role_prefix_relationship__c rp:px_list) {
                        if(rp.asi_mfm_prefix__r.name.contains('DP')){
                            available_prefixes.add(new selectOption(rp.asi_mfm_prefix__c, rp.asi_mfm_prefix__r.name));
                        }
                  }
                    
                    if(available_prefixes.size()==2){
                        selected_prefix=available_prefixes[1].getValue();
                        return proceed();
                    }else{
                        return null;
                    }
                    
                }
                 if(MPlanRecType.get('ASI_MFM_PH_DF_Plan')==Recordtypeid){
                    available_prefixes = new list<selectOption>();
                    available_prefixes.add(new selectOption('', '-- None --'));
                    for (asi_mfm_role_prefix_relationship__c rp:px_list) {
                        if(rp.asi_mfm_prefix__r.name.contains('DF')){
                            available_prefixes.add(new selectOption(rp.asi_mfm_prefix__c, rp.asi_mfm_prefix__r.name));
                        }
                  }
                    if(available_prefixes.size()==2){
                        selected_prefix=available_prefixes[1].getValue();
                        return proceed();
                    }else{
                        return null;
                    }
                }
                
                if(MPlanRecType.get('ASI_MFM_PH_DF_Plan')!=Recordtypeid && MPlanRecType.get('ASI_MFM_PH_DP_Plan')!=Recordtypeid){
                    available_prefixes = new list<selectOption>();
                    available_prefixes.add(new selectOption('', '-- None --'));
                    for (asi_mfm_role_prefix_relationship__c rp:px_list) {
                        available_prefixes.add(new selectOption(rp.asi_mfm_prefix__c, rp.asi_mfm_prefix__r.name));
                    }
                }
                
            }*/
            /*else if(u.asi_mfm_country__c=='VN' && px_list.size()>1){
                String Recordtypeid = ApexPages.currentPage().getParameters().get('RecordType');
                System.debug('Recordtypeid = ' +ApexPages.currentPage().getParameters());
                Map<String, id> MPlanRecType = new Map<String,id>();
                for(Recordtype r : Global_recordTypeCache.getRtList('ASI_MFM_Plan__c')){
                    MPlanRecType.put(r.developername,r.id);
                }
                if(MPlanRecType.get('ASI_MFM_VN_DP_Plan')==Recordtypeid){
                    available_prefixes = new list<selectOption>();
                    available_prefixes.add(new selectOption('', '-- None --'));
                    for (asi_mfm_role_prefix_relationship__c rp:px_list) {
                        if(rp.asi_mfm_prefix__r.name.contains('DP')){
                            available_prefixes.add(new selectOption(rp.asi_mfm_prefix__c, rp.asi_mfm_prefix__r.name));
                        }
                    }

                    if(available_prefixes.size()==2){
                        selected_prefix=available_prefixes[1].getValue();
                        return proceed();
                    }else{
                        return null;
                    }

                }
                if(MPlanRecType.get('ASI_MFM_VN_DF_Plan')==Recordtypeid){
                    available_prefixes = new list<selectOption>();
                    available_prefixes.add(new selectOption('', '-- None --'));
                    for (asi_mfm_role_prefix_relationship__c rp:px_list) {
                        if(rp.asi_mfm_prefix__r.name.contains('DF')){
                            available_prefixes.add(new selectOption(rp.asi_mfm_prefix__c, rp.asi_mfm_prefix__r.name));
                        }
                    }
                    if(available_prefixes.size()==2){
                        selected_prefix=available_prefixes[1].getValue();
                        return proceed();
                    }else{
                        return null;
                    }
                }

                if(MPlanRecType.get('ASI_MFM_VN_DF_Plan')!=Recordtypeid && MPlanRecType.get('ASI_MFM_VN_DP_Plan')!=Recordtypeid){
                    available_prefixes = new list<selectOption>();
                    available_prefixes.add(new selectOption('', '-- None --'));
                    for (asi_mfm_role_prefix_relationship__c rp:px_list) {
                        available_prefixes.add(new selectOption(rp.asi_mfm_prefix__c, rp.asi_mfm_prefix__r.name));
                    }
                }
                
            }*/
            else {
                prefixList = new List<Selection>();
                prefixList.add(new Selection('','-- None --',false,''));
                for (asi_mfm_role_prefix_relationship__c rp:px_list) {
                    string sTmpDesc = (rp.asi_mfm_prefix__r.ASI_MFM_Description__c == NULL?'-':rp.asi_mfm_prefix__r.ASI_MFM_Description__c);
                    prefixList.add(new Selection(rp.asi_mfm_prefix__c, rp.asi_mfm_prefix__r.name, sTmpDesc));
                }
            }
        }
        system.debug('prefixList : ' + prefixList);
        List<Selection> test = new List<Selection>();
        /*test.add(prefixList[0]);
		test.add(prefixList[1]);
        return test;*/
        return prefixList;
    }
    
    public class Selection {
        @AuraEnabled 
        public String selectionName {get; set;}
        
        @AuraEnabled
        public String selectionId {get; set;}
        
        @AuraEnabled
        public boolean error {get; set;}
        
        @AuraEnabled
        public String errorMsg {get; set;}
        
        @AuraEnabled
        public String selectionDesc {get; set;}
        
                
        public Selection(String selectionId, String selectionName, boolean error, String errorMsg) {
        	this.selectionName = selectionName;
            this.selectionId = selectionId;     
            this.error = error;  
            this.errorMsg = selectionId;  
        }
        
        public Selection(String selectionId, String selectionName, String selectionDesc) {
        	this.selectionName = selectionName;
            this.selectionId = selectionId;
            this.selectionDesc = selectionDesc;
            this.error = false;  
        }
    }
}