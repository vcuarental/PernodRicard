public with sharing class ASI_MFM_SelectPlanPrefixController {
    map<string, asi_mfm_role_prefix_relationship__c> px_map = new map<string, asi_mfm_role_prefix_relationship__c>();   
    public boolean showTable{get; set;}
    public list<selectOption> available_prefixes {get; private set;}
    public string selected_prefix {get; set;}
    public list<string> available_prefix_str {get;set;}{available_prefix_str = new list<string> (); }
    public Map<string, string> prefixName_Describ {get;set;} {prefixName_Describ = new Map<string, string> (); }
    public ASI_MFM_SelectPlanPrefixController(apexpages.standardController sc) {
    }
    
    public pageReference getPrefixes() {
        showTable = false; 
        user u = [select userRole.developerName, asi_mfm_country__c from user where id = :userInfo.getUserId()];
        if (u.userRole.developerName == null) {
            apexpages.message err = new apexpages.message(apexpages.severity.error, 'The role of the user is not defined yet');
            apexpages.addmessage(err); 
        }
        else if (u.asi_mfm_country__c == null) {
            apexpages.message err = new apexpages.message(apexpages.severity.error, 'The country of the user is not defined yet');
            apexpages.addmessage(err); 
        }
        else {
            list<asi_mfm_role_prefix_relationship__c> px_list = new list<asi_mfm_role_prefix_relationship__c>();
            for (asi_mfm_role_prefix_relationship__c px:[select asi_mfm_prefix__c, asi_mfm_prefix__r.name,asi_mfm_prefix__r.RecordType.DeveloperName, asi_mfm_prefix__r.ASI_MFM_PAF_Prefix__c,asi_mfm_prefix__r.ASI_MFM_Description__c  from asi_mfm_role_prefix_relationship__c where asi_mfm_prefix__r.ASI_MFM_Inactive__c = false and asi_mfm_prefix__r.asi_mfm_module__c = 'Plan' and asi_mfm_role_name__c = :u.userRole.developerName and asi_mfm_prefix__r.asi_mfm_country_name__c = :u.asi_mfm_country__c order by asi_mfm_prefix__r.name]) 
            {
                
                if(u.asi_mfm_country__c != 'TW'){
                    px_map.put(px.asi_mfm_prefix__c, px);
                    px_list.add(px);
                } else {
                    if(px.asi_mfm_prefix__r.ASI_MFM_PAF_Prefix__c == false){
                        px_map.put(px.asi_mfm_prefix__c, px);
                        px_list.add(px); 
                    }
                }
            }
            
            if(u.asi_mfm_country__c=='KR'){//For KR User only
                return new pageReference('/apex/ASI_MFM_KR_SelectProjectCodePage?Module=Plan'); 
            }
            
            if (px_list.size() == 0) {
                apexpages.message err = new apexpages.message(apexpages.severity.error, 'The user is not entitled to input plans');
                apexpages.addmessage(err); 
            }else if (px_list.size() == 1) {
                selected_prefix = px_list[0].asi_mfm_prefix__c;
                return proceed();
            }else if(u.asi_mfm_country__c=='PH' && px_list.size()>1){ 
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
                        if(rp.asi_mfm_prefix__r.name.contains('DP') || rp.asi_mfm_prefix__r.name.startsWith('P') ){
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
                        if(rp.asi_mfm_prefix__r.name.contains('DF') || rp.asi_mfm_prefix__r.name.startsWith('F') ){
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
                
            }
            //Add by Andy Zhang, for VN select prefix
            else if(u.asi_mfm_country__c=='VN' && px_list.size()>1){
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
                
            }
            else {
                available_prefixes = new list<selectOption>();
                prefixName_Describ = new Map<String, String>();
                available_prefix_str = new List<String>();
                available_prefixes.add(new selectOption('', '-- None --'));
                for (asi_mfm_role_prefix_relationship__c rp:px_list) {
                    available_prefixes.add(new selectOption(rp.asi_mfm_prefix__c, rp.asi_mfm_prefix__r.name));
                     available_prefix_str.add(rp.asi_mfm_prefix__r.name);
                    prefixName_Describ.put(rp.asi_mfm_prefix__r.name, (rp.asi_mfm_prefix__r.ASI_MFM_Description__c == NULL?'-':rp.asi_mfm_prefix__r.ASI_MFM_Description__c));
                }
                if(u.asi_mfm_country__c=='MY'){
                    showTable = true;
                }
            }
        }       
        return null;
    }
    
    public pageReference proceed() {
        String Recordtypeid = ApexPages.currentPage().getParameters().get('RecordType');
        System.debug('Recordtypeid = ' +ApexPages.currentPage().getParameters());
        // Modified by Michael Yip (Introv) 2May2014 for reduce SOQL for recordtype
        
        Map<String, id> MPlanRecType = new Map<String,id>();
        for(Recordtype r : Global_recordTypeCache.getRtList('ASI_MFM_Plan__c')){
            MPlanRecType.put(r.developername,r.id);
        }
        
        Boolean overRidePlanID = false;
        
        Set<id> SCNProf = new Set<id>();
        for(Profile p : [Select id from profile where name like 'ASI CN%']){
            SCNProf.add(p.id);
        }
        
        if((MPlanRecType.containsKey('ASI_MFM_CN_Plan') && ((String)MPlanRecType.get('ASI_MFM_CN_Plan')).substring(0,15) == Recordtypeid) ||  (MPlanRecType.containsKey('ASI_MFM_JP_Plan') && ((String)MPlanRecType.get('ASI_MFM_JP_Plan')).substring(0,15) == Recordtypeid) ||  SCNProf.contains(UserInfo.getProfileId())){
            overRidePlanID = true;
        }
        // Added by Michael Yip (Introv) 6Jan2013
        if (selected_prefix == null || selected_prefix == '') {
            apexpages.message err = new apexpages.message(apexpages.severity.error, 'Please select prefix first');
            apexpages.addmessage(err); 
            return null;            
        }
        else {
            string prefix_name = px_map.get(selected_prefix).asi_mfm_prefix__r.name;
            string obj_id = sObjectType.ASI_MFM_Plan__c.getKeyPrefix();
            string field_id = ASI_MFM_Function.getFieldId('ASI_MFM_Plan__c', 'ASI_MFM_Prefix__c');
            system.debug(overRidePlanID);
            // Added by Michael Yip (Introv) 6Jan2013
            if(overRidePlanID){             
                string url = '/' + obj_id + '/e?retURL=%2F' + obj_id + '%2Fo&nooverride=1&CF' + field_id + '_lkid=' + selected_prefix + '&CF' + field_id + '=' + prefix_name + '&Name=' + 'Automated, Do not change';
                
                if(Recordtypeid != null && Recordtypeid != ''){
                    url += '&RecordType=' + Recordtypeid;
                }
                return new pageReference(url ); 
            }else{
                string url = '/' + obj_id + '/e?retURL=%2F' + obj_id + '%2Fo&nooverride=1&CF' + field_id + '_lkid=' + selected_prefix + '&CF' + field_id + '=' + prefix_name + '&Name=' + prefix_name;
                if(Recordtypeid != null && Recordtypeid != ''){
                    url += '&RecordType=' + Recordtypeid;
                }
                return new pageReference(url ); 
            } // modified by ssc mark 2018-07-27 
            
        }
    } 
}