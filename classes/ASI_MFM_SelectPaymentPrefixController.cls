public with sharing class ASI_MFM_SelectPaymentPrefixController {
    /* Test class : 
ASI_MFM_SG_Class_Test
ASI_MFM_MY_Test_Class
ASI_MFM_PH_Payment_TestClass
ASI_MFM_SelectPaymentPrefix_Test
ASI_MFM_KR_ManageAll_TestClass
ASI_MFM_VN_Prefix_TestClass
*/
    map<string, asi_mfm_role_prefix_relationship__c> px_map = new map<string, asi_mfm_role_prefix_relationship__c>();   
    
    public list<selectOption> available_prefixes {get; private set;}
    public string selected_prefix {get; set;}
    public list<string> available_prefix_str {get;set;}
    public Map<string, string> prefixName_Describ {get;set;}
    public boolean showTable{get; set;}

    public ASI_MFM_SelectPaymentPrefixController(apexpages.standardController sc) {
    }
    
    public pageReference getPrefixes() {
        
        //20170227 Elufa redirect to China Structure Cost Payment
        String CNRecordtypeid = ApexPages.currentPage().getParameters().get('RecordType');
        String scrt = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_CAP_CN_StructureCost_Payment');
        
        if(scrt!=null){
            if(CNRecordtypeid!=null){
                if(scrt.substring(0,15) == (CNRecordtypeid!=null&&CNRecordtypeid.length()>15?CNRecordtypeid.subString(0,15):CNRecordtypeid )){
                    
                    Return new pageReference('/Apex/ASI_MFM_CN_StructureCostPrefix_Page');
                }
            }
        }
        //20170227 End
        //20190312 laputa add SC
        String strRecordDevName = null;
        if(CNRecordtypeid != null){
            strRecordDevName = Schema.SObjectType.ASI_MFM_Payment__c.getRecordTypeInfosById().get(CNRecordtypeid).getDeveloperName();
			System.debug('Record Developer Name ====> '+strRecordDevName);
        }
        user u = [select userRole.developerName, asi_mfm_country__c from user where id = :userInfo.getUserId()];
        showTable = false;
        System.debug('User ====>'+ u);
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
            list<asi_mfm_role_prefix_relationship__c> pxQuerylist = new list<asi_mfm_role_prefix_relationship__c>();
            
            if(strRecordDevName == 'ASI_MFM_SC_Payment'){
            	pxQuerylist = [select asi_mfm_prefix__c, asi_mfm_prefix__r.name,asi_mfm_prefix__r.ASI_MFM_Location__c,asi_mfm_prefix__r.ASI_MFM_Description__c from asi_mfm_role_prefix_relationship__c 
                where asi_mfm_prefix__r.ASI_MFM_Inactive__c = false and asi_mfm_prefix__r.asi_mfm_module__c = 'Payment' and asi_mfm_role_name__c = :u.userRole.developerName and ASI_MFM_Prefix__r.RecordType.Name = 'ASI MFM SC Prefix'
                order by asi_mfm_prefix__r.name];
            }else{
            	pxQuerylist = [select asi_mfm_prefix__c, asi_mfm_prefix__r.name,asi_mfm_prefix__r.ASI_MFM_Location__c, asi_mfm_prefix__r.ASI_MFM_Description__c  from asi_mfm_role_prefix_relationship__c
                where asi_mfm_prefix__r.ASI_MFM_Inactive__c = false and asi_mfm_prefix__r.asi_mfm_module__c = 'Payment' and asi_mfm_role_name__c = :u.userRole.developerName and asi_mfm_prefix__r.asi_mfm_country_name__c = :u.asi_mfm_country__c order by asi_mfm_prefix__r.name];
            }
            for (asi_mfm_role_prefix_relationship__c px : pxQuerylist ) {
                px_map.put(px.asi_mfm_prefix__c, px);
                px_list.add(px);    
            } 
            /*for (asi_mfm_role_prefix_relationship__c px:[select asi_mfm_prefix__c, asi_mfm_prefix__r.name,asi_mfm_prefix__r.ASI_MFM_Location__c from asi_mfm_role_prefix_relationship__c
                where asi_mfm_prefix__r.ASI_MFM_Inactive__c = false and asi_mfm_prefix__r.asi_mfm_module__c = 'Payment' and asi_mfm_role_name__c = :u.userRole.developerName and asi_mfm_prefix__r.asi_mfm_country_name__c = :u.asi_mfm_country__c order by asi_mfm_prefix__r.name]) {
                px_map.put(px.asi_mfm_prefix__c, px);


                px_list.add(px);    
            }*/  
            system.debug('============================px_list size============================================='+ px_list.size());
            if (px_list.size() == 0) {
                apexpages.message err = new apexpages.message(apexpages.severity.error, 'The user is not entitled to input payments');
                apexpages.addmessage(err); 
            }
            else if (px_list.size() == 1) {
                selected_prefix = px_list[0].asi_mfm_prefix__c;
                return proceed();
            }
            else if(u.asi_mfm_country__c=='KR' && px_list.size()>1){ 
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
                String Recordtypeid = ApexPages.currentPage().getParameters().get('RecordType');
                Map<String, id> MPlanRecType = new Map<String,id>();
                for(Recordtype r : Global_recordTypeCache.getRtList('ASI_MFM_Payment__c')){
                    MPlanRecType.put(r.developername,r.id);
                }
                if(MPlanRecType.get('ASI_MFM_PH_DP_Payment')==Recordtypeid){
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
                 if(MPlanRecType.get('ASI_MFM_PH_DF_Payment')==Recordtypeid){
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
                if(MPlanRecType.get('ASI_MFM_PH_DF_Payment')!=Recordtypeid && MPlanRecType.get('ASI_MFM_PH_DP_Payment')!=Recordtypeid ){
                    available_prefixes = new list<selectOption>();
                    available_prefixes.add(new selectOption('', '-- None --'));
                    for (asi_mfm_role_prefix_relationship__c rp:px_list) {
                        available_prefixes.add(new selectOption(rp.asi_mfm_prefix__c, rp.asi_mfm_prefix__r.name));
                    }
                }
            }      
            else {
                String Recordtypeid = ApexPages.currentPage().getParameters().get('RecordType');
                Map<String, id> MPlanRecType = new Map<String,id>();
                for(Recordtype r : Global_recordTypeCache.getRtList('ASI_MFM_Payment__c')){
                    MPlanRecType.put(r.developername,r.id);
                }
                available_prefixes = new list<selectOption>();
                prefixName_Describ = new Map<String, String>();
                available_prefix_str = new List<String>();
                available_prefixes.add(new selectOption('', '-- None --'));
                for (asi_mfm_role_prefix_relationship__c rp:px_list) {
                    available_prefixes.add(new selectOption(rp.asi_mfm_prefix__c, rp.asi_mfm_prefix__r.name));
                    available_prefix_str.add(rp.asi_mfm_prefix__r.name);
                    prefixName_Describ.put(rp.asi_mfm_prefix__r.name, (rp.asi_mfm_prefix__r.ASI_MFM_Description__c == NULL?'-':rp.asi_mfm_prefix__r.ASI_MFM_Description__c));
                }
                if(u.asi_mfm_country__c=='MY')
                //if(MPlanRecType.get('ASI_MFM_MY_Payment')==Recordtypeid || MPlanRecType.get('ASI_MFM_MY_Payment_Read_Only')==Recordtypeid)
                {
                    showTable = true;
                }
            }
        }       
        return null;
    }
    
    public pageReference proceed() {
        /* Added by Michael Yip (Introv) 6Jan2013
                Override Payment id with "System generated" for CN Payment record type
        */
        String Recordtypeid = ApexPages.currentPage().getParameters().get('RecordType');
        System.debug(ApexPages.currentPage().getParameters());
        
        if (Recordtypeid == null || test.isRunningTest()){
            List<String> availableRecordTypes =  GetAvailableRecordTypeNamesForSObject(ASI_MFM_Payment__c.SObjectType);
            if (availableRecordTypes.size() == 1 ){
                Recordtypeid = availableRecordTypes[0];
            }
        }
        
        // Modified by Michael Yip (Introv) 24Apr2014 reduce SOQL usage

            
        //Map<String, id> MPaymentRecType = ASI_MFM_function.getRecordTypeId('ASI_MFM_Payment__c');
        Map<String, id> MPYRecType = ASI_MFM_function.getRecordTypeId('ASI_MFM_Payment__c');
        Map<String, id> MPaymentRecType = new Map<String, id>();
        for(RecordType rec : global_recordtypecache.getRtList('ASI_MFM_Payment__c')){
            MPaymentRecType.put(rec.developername,rec.id);
        }
        
        Boolean overRidePaymentID = false;
        Boolean overTaxCodeID = false;
        String TaxCodeRecordType;    
        System.debug(Recordtypeid + '/' + MPaymentRecType.get('ASI_MFM_CN_Payment'));
        //overRidePaymentID = true;
        Set<id> SCNProf = new Set<id>();
        for(Profile p : [Select id from profile where name like 'ASI CN%']){
            SCNProf.add(p.id);
        }
        System.debug(SCNProf);
        System.debug(UserInfo.getProfileId());
        if((MPaymentRecType.containsKey('ASI_MFM_CN_Payment') && ((String)MPaymentRecType.get('ASI_MFM_CN_Payment')).substring(0,15) == (Recordtypeid!=null&&RecordTypeId.length()>15?RecordTypeId.subString(0,15):RecordTypeId )) || 
           SCNProf.contains(UserInfo.getProfileId())){
            overRidePaymentID = true;

        }
        if((MPaymentRecType.containsKey('ASI_MFM_JP_Payment') && ((String)MPaymentRecType.get('ASI_MFM_JP_Payment')).substring(0,15) == (Recordtypeid!=null&&RecordTypeId.length()>15?RecordTypeId.subString(0,15):RecordTypeId )) || 
           SCNProf.contains(UserInfo.getProfileId())){
               overRidePaymentID = true;
               overTaxCodeID=true;
               TaxCodeRecordType='ASI_MFM_JP_Tax_Code';
           }
        
       if((MPaymentRecType.containsKey('ASI_MFM_KR_Payment') && ((String)MPaymentRecType.get('ASI_MFM_KR_Payment')).substring(0,15) == (Recordtypeid!=null&&RecordTypeId.length()>15?RecordTypeId.subString(0,15):RecordTypeId )) || 
           SCNProf.contains(UserInfo.getProfileId())){
               overRidePaymentID = true;
               overTaxCodeID=true;
               //TaxCodeRecordType='ASI_MFM_KR_Tax_Code';
           }

        // Added by Michael Yip (Introv) 6Jan2013
        if (selected_prefix == null || selected_prefix == '') {
            apexpages.message err = new apexpages.message(apexpages.severity.error, 'Please select prefix first');
            apexpages.addmessage(err); 
            return null;            
        }
        else {
            string prefix_name = px_map.get(selected_prefix).asi_mfm_prefix__r.name;
            string prefix_location = px_map.get(selected_prefix).asi_mfm_prefix__r.ASI_MFM_Location__c;
            string obj_id = sObjectType.ASI_MFM_Payment__c.getKeyPrefix();
            string field_id = ASI_MFM_Function.getFieldId('ASI_MFM_Payment__c', 'ASI_MFM_Prefix__c');
            string currency_field_id = ASI_MFM_Function.getFieldId('ASI_MFM_Payment__c', 'ASI_MFM_Currency__c');
            // Added by Michael Yip (Introv) 6Jan2013
            if(overRidePaymentID){
                string retURL = '%2F' + obj_id + '%2Fo';
                map<string, string> originalParams = ApexPages.currentPage().getParameters();
                if(originalParams.containsKey('retURL')) {
                    retURL = originalParams.get('retURL');
                    originalParams.remove('retURL');
                }
                if(originalParams.containsKey('save_new')) originalParams.remove('save_new');
                if(originalParams.containsKey('sfdc.override')) originalParams.remove('sfdc.override');
                
                string url = '/' + obj_id + '/e?retURL=' + retURL + '&nooverride=1&CF' + field_id + '_lkid=' + selected_prefix + '&CF' + field_id + '=' + prefix_name + '&Name=' + 'Automated, Do not change';
                if(!overTaxCodeID){ // Not JP 
                    for(string key :originalParams.keySet())
                        url += '&' + key + '=' + originalParams.get(key);
                }else{ //JP Supplier Name cantain '&'
                    for(string key :originalParams.keySet())
                        url += '&' + key + '=' + EncodingUtil.urlEncode(originalParams.get(key), 'UTF-8');
                }
                //// END: Modified by KF Leung, append original parameters and return URL from query string
                
                if(overTaxCodeID && TaxCodeRecordType!=null){  //For JP MFM Get Default Tax Code
                    string TaxCode_field_id = ASI_MFM_Function.getFieldId('ASI_MFM_Payment__c', 'ASI_MFM_Tax_Code__c');
                    string TaxCode_name = '';
                    id TaxCode_id;
                    List<ASI_MFM_Tax_Code__c> TC = [select id,name from ASI_MFM_Tax_Code__c where RecordType.DeveloperName=:TaxCodeRecordType and ASI_MFM_Default__c=true limit 1];
                    if(TC.size()>0){
                        TaxCode_name = TC[0].name;
                        TaxCode_id = TC[0].id;
                    }
                    url += '&CF' + TaxCode_field_id + '_lkid=' + TaxCode_id + '&CF' + TaxCode_field_id + '=' + TaxCode_name;
                    
                }// JP MFM Get Default Tax Code End  
                return new pageReference(url);
            }else{
                string url = '/' + obj_id + '/e?retURL=%2F' + obj_id + '%2Fo&nooverride=1&CF' + field_id + '_lkid=' + selected_prefix + '&CF' + field_id + '=' + prefix_name + '&Name=' + prefix_name;
                 if(Recordtypeid != null && Recordtypeid != ''){
                    url += '&RecordType=' + Recordtypeid;

                    }
                    
                
                if (MPaymentRecType.containsKey('ASI_MFM_SG_Payment') && ((String)MPaymentRecType.get('ASI_MFM_SG_Payment')).substring(0,15) == (Recordtypeid!=null&&RecordTypeId.length()>15?RecordTypeId.subString(0,15):RecordTypeId ) ){
                    if(prefix_location != 'Singapore'){
                        url += '&' + currency_field_id + '=' + 'USD';
                    }
                }
                return new pageReference(url);
            
            
            }
        }
    }

    public static List<String> GetAvailableRecordTypeNamesForSObject(    Schema.SObjectType objType) {
            List<String> names = new List<String>();
            List<RecordTypeInfo> infos = objType.getDescribe().getRecordTypeInfos();
            // If there are 2 or more RecordTypes...
            if (infos.size() > 1) {
                for (RecordTypeInfo i : infos) {
                   if (i.isAvailable() 
                   // Ignore the Master Record Type, whose Id always ends with 'AAA'.
                   // We check the Id because Name can change depending on the user's language.
                    && !String.valueOf(i.getRecordTypeId()).endsWith('AAA'))
                        names.add(i.getRecordTypeId());


                }
            } 
            // Otherwise there's just the Master record type,
            // so add it in, since it MUST always be available
            else names.add(infos[0].getRecordTypeId());
            return names;


  }
}