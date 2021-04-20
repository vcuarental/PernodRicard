public with sharing class ASI_MFM_SelectPOPrefixLWC_Cls {
	//20200915:AM@introv - copy from ASI_MFM_SelectPOPrefixController

	@AuraEnabled(cacheable=true)
	public static List<Selection> getPrefixes(Id RecordTypeId) {
        List<Selection> prefixList = new List<Selection>();
        List<Selection> errorList = new List<Selection>();
        
        user u = [select userRole.developerName, asi_mfm_country__c from user where id = :userInfo.getUserId()];
        //showTable = false;       
        //String Recordtypeid = ApexPages.currentPage().getParameters().get('RecordType');
        //system.debug('Recordtypeid ====> '+ Recordtypeid);
        //String strRecordDevName = null;
        //if (Recordtypeid != null){
        //    strRecordDevName = Schema.SObjectType.ASI_MFM_PO__c.getRecordTypeInfosById().get(Recordtypeid).getDeveloperName();
		//	System.debug('Record Developer Name ====> '+strRecordDevName);
        //}
        if (u.userRole.developerName == null) {
            errorList.add(new Selection(true, 'The role of the user is not defined yet'));
            return errorList;
        }
        else if (u.asi_mfm_country__c == null) {
            errorList.add(new Selection(true, 'The country of the user is not defined yet'));
            return errorList;
        }
        else {
            map<string, asi_mfm_role_prefix_relationship__c> px_map = new map<string, asi_mfm_role_prefix_relationship__c>(); 
            list<asi_mfm_role_prefix_relationship__c> px_list = new list<asi_mfm_role_prefix_relationship__c>();
            list<asi_mfm_role_prefix_relationship__c> pxQuerylist = new list<asi_mfm_role_prefix_relationship__c>();
            
            //if(strRecordDevName == 'ASI_MFM_SC_PO' || strRecordDevName == 'ASI_MFM_SC_PO_Read_Only'){
            //	pxQuerylist = [select asi_mfm_prefix__c, asi_mfm_prefix__r.name,asi_mfm_prefix__r.ASI_MFM_Location__c from asi_mfm_role_prefix_relationship__c
            //    where asi_mfm_prefix__r.ASI_MFM_Inactive__c = false and asi_mfm_prefix__r.asi_mfm_module__c = 'PO' and asi_mfm_role_name__c = :u.userRole.developerName and ASI_MFM_Prefix__r.RecordType.Name = 'ASI MFM SC Prefix'
            //    order by asi_mfm_prefix__r.name];
            //}else{
           	pxQuerylist = [select asi_mfm_prefix__c, asi_mfm_prefix__r.name,asi_mfm_prefix__r.ASI_MFM_Location__c, asi_mfm_prefix__r.ASI_MFM_Description__c from asi_mfm_role_prefix_relationship__c
            	where asi_mfm_prefix__r.ASI_MFM_Inactive__c = false and asi_mfm_prefix__r.asi_mfm_module__c = 'PO' and asi_mfm_role_name__c = :u.userRole.developerName and asi_mfm_prefix__r.asi_mfm_country_name__c = :u.asi_mfm_country__c order by asi_mfm_prefix__r.name];
            //}
            for (asi_mfm_role_prefix_relationship__c px : pxQuerylist ) {
                px_map.put(px.asi_mfm_prefix__c, px);
                px_list.add(px);    
            } 
            /*for (asi_mfm_role_prefix_relationship__c px:[select asi_mfm_prefix__c, asi_mfm_prefix__r.name,asi_mfm_prefix__r.ASI_MFM_Location__c from asi_mfm_role_prefix_relationship__c
                where asi_mfm_prefix__r.ASI_MFM_Inactive__c = false and asi_mfm_prefix__r.asi_mfm_module__c = 'PO' and asi_mfm_role_name__c = :u.userRole.developerName and asi_mfm_prefix__r.asi_mfm_country_name__c = :u.asi_mfm_country__c order by asi_mfm_prefix__r.name]) {
                px_map.put(px.asi_mfm_prefix__c, px);
                px_list.add(px);    
            } */                        
            if (px_list.size() == 0) {
                errorList.add(new Selection(true, 'The user is not entitled to input POs'));
                return errorList;
            }
            /*else if (px_list.size() == 1) {
                selected_prefix = px_list[0].asi_mfm_prefix__c;
                return proceed();
            }
            else if(u.asi_mfm_country__c=='KR' && px_list.size()>1){
                if (!u.userRole.developerName.contains('ASI_KR_Purchasing')) {
                    return new pageReference('/apex/ASI_MFM_KR_SelectPOErrorPage');
                }
                
                string prefixid = apexpages.currentPage().getParameters().get('prefixid');
                if(prefixid!=null){
                    selected_prefix=prefixid;
                    return proceed();
                }else{
                    available_prefixes = new list<selectOption>();
                    available_prefixes.add(new selectOption('', '-- None --'));
                    for (asi_mfm_role_prefix_relationship__c rp:px_list) {
                        available_prefixes.add(new selectOption(rp.asi_mfm_prefix__c, rp.asi_mfm_prefix__r.name));
                    }
                }
            }
            else if(u.asi_mfm_country__c=='PH' && px_list.size()>1){ 
                //String Recordtypeid = ApexPages.currentPage().getParameters().get('RecordType');
                Map<String, id> MPlanRecType = new Map<String,id>();
                for(Recordtype r : Global_recordTypeCache.getRtList('ASI_MFM_PO__c')){
                    MPlanRecType.put(r.developername,r.id);
                }
                if(MPlanRecType.get('ASI_MFM_PH_DP_PO')==Recordtypeid){
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
                 if(MPlanRecType.get('ASI_MFM_PH_DF_PO')==Recordtypeid){
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
                
                if(MPlanRecType.get('ASI_MFM_PH_DF_PO')!=Recordtypeid && MPlanRecType.get('ASI_MFM_PH_DP_PO')!=Recordtypeid ){
                    available_prefixes = new list<selectOption>();
                    available_prefixes.add(new selectOption('', '-- None --'));
                    for (asi_mfm_role_prefix_relationship__c rp:px_list) {
                        available_prefixes.add(new selectOption(rp.asi_mfm_prefix__c, rp.asi_mfm_prefix__r.name));
                    }
                }
                
            }*/
            else {
                /*available_prefixes = new list<selectOption>();
                prefixName_Describ = new Map<String, String>();
                available_prefix_str = new List<String>();
                available_prefixes.add(new selectOption('', '-- None --'));
                for (asi_mfm_role_prefix_relationship__c rp:px_list) {
                    available_prefixes.add(new selectOption(rp.asi_mfm_prefix__c, rp.asi_mfm_prefix__r.name));
                    available_prefix_str.add(rp.asi_mfm_prefix__r.name);
                    prefixName_Describ.put(rp.asi_mfm_prefix__r.name, (rp.asi_mfm_prefix__r.ASI_MFM_Description__c == NULL?'-':rp.asi_mfm_prefix__r.ASI_MFM_Description__c));
                }
                if(u.asi_mfm_country__c=='MY')
                //if(strRecordDevName == 'ASI_MFM_MY_PO' || strRecordDevName == 'ASI_MFM_MY_PO_Read_Only')
                {
                    showTable = true;
                }*/
                prefixList = new List<Selection>();
                prefixList.add(new Selection('','-- None --'));
                for (asi_mfm_role_prefix_relationship__c rp:px_list) {
                    string sTmpDesc = (rp.asi_mfm_prefix__r.ASI_MFM_Description__c == NULL?'-':rp.asi_mfm_prefix__r.ASI_MFM_Description__c);
                    prefixList.add(new Selection(rp.asi_mfm_prefix__c, rp.asi_mfm_prefix__r.name, sTmpDesc));
                }
				
            }
        }
        
        return prefixList;
    }
    
    @AuraEnabled(cacheable=true)
    public static InitParam getInitParam(Id PlanID) {
        InitParam oParam = new InitParam();
        
        try
        {
            //check to display prefix table
            oParam.showTable = false;
            user u = [select userRole.developerName, asi_mfm_country__c from user where id = :userInfo.getUserId()];
            string sMFMCountry = u.asi_mfm_country__c;
            if (sMFMCountry == 'MY') {
                oParam.showTable = true;
            }
            
            //get plan details
            if(PlanID != null) {
                oParam.planId = PlanID;
                oParam.planName = [select name from asi_mfm_plan__c where id = :PlanID limit 1].Name;
            }
            
            //get default PO RecordTypeId
            Map<String, id> oPO_AllRecTypeByName = ASI_MFM_function.getRecordTypeId('ASI_MFM_PO__c');
            Map<Id, String> oPO_AllRecType = new Map<Id, String>();
            for(String sRecTypeName : oPO_AllRecTypeByName.keySet())
            {
                oPO_AllRecType.put(oPO_AllRecTypeByName.get(sRecTypeName), sRecTypeName);
            }

            List<String> oPO_AvailRecType = GetAvailableRecordTypeIDsForSObject(ASI_MFM_PO__c.SObjectType);
            if (oPO_AvailRecType.size() == 1) {
                oParam.defaultRecordTypeId = oPO_AvailRecType[0];
            } else {
                if ((sMFMCountry != null) && (sMFMCountry != '')) {
                    for(string sTmpID : oPO_AvailRecType) {
                        if (oPO_AllRecType.containsKey(sTmpID)) {
                            string sTmpName = oPO_AllRecType.get(sTmpID);
                            if (sTmpName.contains(sMFMCountry) && !sTmpName.contains('RO') && !sTmpName.contains('Read')) {
                                oParam.defaultRecordTypeId = sTmpID;
                            }
                        }
                    }
                }
            }
            if ((oParam.defaultRecordTypeId == null) && (oPO_AvailRecType.size() > 0)) {
                oParam.defaultRecordTypeId = oPO_AvailRecType[0];
            }
            
        } catch(Exception ex)
        {
            oParam = new InitParam(true, 'Fail to initialize the parameters.');
        }
        
        return oParam;
    }
    
    public static List<String> GetAvailableRecordTypeIDsForSObject(Schema.SObjectType objType) {
        List<String> ltID = new List<String>();
        List<RecordTypeInfo> infos = objType.getDescribe().getRecordTypeInfos();
        // If there are 2 or more RecordTypes...
        if (infos.size() > 1) {
            for (RecordTypeInfo i : infos) {
                if (i.isAvailable() 
                    // Ignore the Master Record Type, whose Id always ends with 'AAA'.
                    // We check the Id because Name can change depending on the user's language.
                    && !String.valueOf(i.getRecordTypeId()).endsWith('AAA'))
                    ltID.add(i.getRecordTypeId());
            }
        } 
        // Otherwise there's just the Master record type,
        // so add it in, since it MUST always be available
        else ltID.add(infos[0].getRecordTypeId());
        return ltID;
    }
    
    public class InitParam {
        @AuraEnabled
        public boolean error {get; set;}
        
        @AuraEnabled
        public String errorMsg {get; set;}
        
        @AuraEnabled 
        public boolean showTable {get; set;}
        
        @AuraEnabled 
        public Id planId {get; set;}
            
        @AuraEnabled 
        public string planName {get; set;}
        
        @AuraEnabled
        public Id defaultRecordTypeId {get; set;}

        public InitParam() {
            this.error = false;
        }
        
        public InitParam(boolean error, String errorMsg) {
            this.error = error;
            this.errorMsg = errorMsg;
        }
    }
    
    public class Selection {
        @AuraEnabled
        public boolean error {get; set;}
        
        @AuraEnabled
        public String errorMsg {get; set;}
        
        @AuraEnabled 
        public String selectionName {get; set;}
        
        @AuraEnabled
        public String selectionId {get; set;}
        
        @AuraEnabled
        public String selectionDesc {get; set;}
        
        public Selection(boolean error, String errorMsg) {
            this.error = error;
            this.errorMsg = errorMsg;
        }
        
        public Selection(String selectionId, String selectionName) {
        	this.selectionName = selectionName;
            this.selectionId = selectionId;
            this.error = false;
        }
        
        public Selection(String selectionId, String selectionName, String selectionDesc) {
        	this.selectionName = selectionName;
            this.selectionId = selectionId;
            this.selectionDesc = selectionDesc;
            this.error = false;  
        }
    }

}