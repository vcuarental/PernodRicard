public with sharing class ASI_MFM_SelectPOPrefixController {
    id plan_id;
    id iom_id;
    string planname;  
    map<string, asi_mfm_role_prefix_relationship__c> px_map = new map<string, asi_mfm_role_prefix_relationship__c>();   
    
    public list<selectOption> available_prefixes {get; private set;}
    public string selected_prefix {get; set;}
    public list<string> available_prefix_str {get;set;}
    public Map<string, string> prefixName_Describ {get;set;}
    public boolean showTable{get; set;}
    public ASI_MFM_SelectPOPrefixController(apexpages.standardController sc) {
        plan_id = apexpages.currentPage().getParameters().get('pid');
        iom_id = apexpages.currentPage().getParameters().get('iomid');
        planname = apexpages.currentPage().getParameters().get('planname');    
    }
    
    public pageReference getPrefixes() {
        
        user u = [select userRole.developerName, asi_mfm_country__c from user where id = :userInfo.getUserId()];
        showTable = false;       
        String Recordtypeid = ApexPages.currentPage().getParameters().get('RecordType');
        system.debug('Recordtypeid ====> '+ Recordtypeid);
        String strRecordDevName = null;
        if(Recordtypeid != null){
            strRecordDevName = Schema.SObjectType.ASI_MFM_PO__c.getRecordTypeInfosById().get(Recordtypeid).getDeveloperName();
            System.debug('Record Developer Name ====> '+strRecordDevName);
        }
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
            
            if(strRecordDevName == 'ASI_MFM_SC_PO' || strRecordDevName == 'ASI_MFM_SC_PO_Read_Only'){
                pxQuerylist = [select asi_mfm_prefix__c, asi_mfm_prefix__r.name,asi_mfm_prefix__r.ASI_MFM_Location__c, asi_mfm_prefix__r.ASI_MFM_Description__c  from asi_mfm_role_prefix_relationship__c
                               where asi_mfm_prefix__r.ASI_MFM_Inactive__c = false and asi_mfm_prefix__r.asi_mfm_module__c = 'PO' and asi_mfm_role_name__c = :u.userRole.developerName and ASI_MFM_Prefix__r.RecordType.Name = 'ASI MFM SC Prefix'
                               order by asi_mfm_prefix__r.name];
            }else{
                pxQuerylist = [select asi_mfm_prefix__c, asi_mfm_prefix__r.name,asi_mfm_prefix__r.ASI_MFM_Location__c, asi_mfm_prefix__r.ASI_MFM_Description__c from asi_mfm_role_prefix_relationship__c
                               where asi_mfm_prefix__r.ASI_MFM_Inactive__c = false and asi_mfm_prefix__r.asi_mfm_module__c = 'PO' and asi_mfm_role_name__c = :u.userRole.developerName and asi_mfm_prefix__r.asi_mfm_country_name__c = :u.asi_mfm_country__c order by asi_mfm_prefix__r.name];
            }
            for (asi_mfm_role_prefix_relationship__c px : pxQuerylist ) {
                px_map.put(px.asi_mfm_prefix__c, px);
                px_list.add(px);    
            } 
                        
            if (px_list.size() == 0) {
                apexpages.message err = new apexpages.message(apexpages.severity.error, 'The user is not entitled to input POs');
                apexpages.addmessage(err); 
            }
            else if (px_list.size() == 1) {
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
                if(MPlanRecType.get('ASI_MFM_PH_DF_PO')==Recordtypeid){
                    available_prefixes = new list<selectOption>();
                    available_prefixes.add(new selectOption('', '-- None --'));
                    for (asi_mfm_role_prefix_relationship__c rp:px_list) {
                        if(rp.asi_mfm_prefix__r.name.contains('DF') || rp.asi_mfm_prefix__r.name.startsWith('F')){
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
                if(u.asi_mfm_country__c=='MY')
                    //if(strRecordDevName == 'ASI_MFM_MY_PO' || strRecordDevName == 'ASI_MFM_MY_PO_Read_Only')
                {
                    showTable = true;
                }
            }
        }       
        return null;
        
        
    }
    
    public pageReference proceed() {
        /* Added by Michael Yip (Introv) 6Jan2013
Override Plan id with "System generated" for CN PO record type
*/
        
        String POType = ApexPages.currentPage().getParameters().get('POType');
        String BudgetOwnerId = ApexPages.currentPage().getParameters().get('BudgetOwnerId');
        String SupplierId = ApexPages.currentPage().getParameters().get('supplierId');
        
        
        String Recordtypeid = ApexPages.currentPage().getParameters().get('RecordType');
        String OwnerId = ApexPages.currentPage().getParameters().get('Owner');    
        System.debug(ApexPages.currentPage().getParameters());
        
        Map<String, id> MPORecType = ASI_MFM_function.getRecordTypeId('ASI_MFM_PO__c');
        
        // Default CN PO record type if new from Event
        
        
        Boolean overRidePOID = false;
        Boolean isTRJDFUser = false;
        String defaultRType = ApexPages.currentPage().getParameters().get('rType');
        System.debug(defaultRType);
        if(defaultRType == 'CN'){
            Recordtypeid = MPORecType.get('ASI_MFM_CN_PO');
            overRidePOID = true;
        }
        if (Recordtypeid == null || test.isRunningTest()){
            List<String> availableRecordTypes =  GetAvailableRecordTypeNamesForSObject(ASI_MFM_PO__c.SObjectType);
            if (availableRecordTypes.size() == 1 ){
                Recordtypeid = availableRecordTypes[0];
            }
            else
            {
                // mod by BLS(wzq) When a user has multiple record type permissions, the readonly permission is excluded 20201221 begin
                List<RecordType>  eecordTypeList = [SELECT Id,Name FROM RecordType WHERE Id IN:availableRecordTypes];
                Map<String,String> recordMap = new Map<String,String>();
                for(RecordType re:eecordTypeList)
                {
                   if(availableRecordTypes.size() == 2 && !re.Name.equals('CN PO Read-Only'))
                   {
                       Recordtypeid = re.Id;
                   }
                   if(availableRecordTypes.size() == 3 && !re.Name.equals('CN PO Read-Only') && !re.Name.equals('CN PO'))
                   {
                       Recordtypeid = re.Id;
                   }
                }
                // mod by BLS(wzq) When a user has multiple record type permissions, the readonly permission is excluded 20201221 end
            }
        }
        System.debug(Recordtypeid + '/' + MPORecType.get('ASI_MFM_TR_PO'));
        //overRidePOID = true;
        Set<id> SCNProf = new Set<id>();
        Set<id> SJPProf = new Set<id>();
        for(Profile p : [Select id,name from profile]){
            if (p.name.contains('ASI CN'))
                SCNProf.add(p.id);
            else if (p.name.contains('ASI JP'))
                SJPProf.add(p.id);
        }
        System.debug(SCNProf);
        System.debug(SJPProf);
        System.debug(UserInfo.getProfileId());
        if((MPORecType.containsKey('ASI_MFM_CN_PO') && ((String)MPORecType.get('ASI_MFM_CN_PO')).substring(0,15) == Recordtypeid) ||
           (MPORecType.containsKey('ASI_MFM_JP_PO') && ((String)MPORecType.get('ASI_MFM_JP_PO')).substring(0,15) == Recordtypeid) || 
           SCNProf.contains(UserInfo.getProfileId())){
               overRidePOID = true;
           }
        if (MPORecType.containsKey('ASI_MFM_TR_PO') && (((String)MPORecType.get('ASI_MFM_TR_PO')).substring(0,15) == Recordtypeid || ((String)MPORecType.get('ASI_MFM_TR_PO')) == Recordtypeid) && SJPProf.contains(UserInfo.getProfileId())){
            isTRJDFUser = true;
        }
        System.debug(isTRJDFUser );
        // Added by Michael Yip (Introv) 6Jan2013
        if (selected_prefix == null || selected_prefix == '') {
            apexpages.message err = new apexpages.message(apexpages.severity.error, 'Please select prefix first');
            apexpages.addmessage(err); 
            return null;            
        }
        else {
            string prefix_name = px_map.get(selected_prefix).asi_mfm_prefix__r.name;
            string prefix_location = px_map.get(selected_prefix).asi_mfm_prefix__r.ASI_MFM_Location__c;      
            string obj_id = sObjectType.ASI_MFM_PO__c.getKeyPrefix();
            string field_id = ASI_MFM_Function.getFieldId('ASI_MFM_PO__c', 'ASI_MFM_Prefix__c');
            string currency_field_id = ASI_MFM_Function.getFieldId('ASI_MFM_PO__c', 'ASI_MFM_Currency__c');
            // string Respon_field_id = ASI_MFM_Function.getFieldId('ASI_MFM_PO__c', 'ASI_MFM_Responsible_By__c');
            
            string url = '/' + obj_id + '/e?retURL=%2F' + obj_id + '%2Fo&nooverride=1&CF' + field_id + '_lkid=' + selected_prefix + '&CF' + field_id + '=' + prefix_name + '&Name=' + prefix_name;                      
            if(overRidePOID){
                url = '/' + obj_id + '/e?retURL=%2F' + obj_id + '%2Fo&nooverride=1&CF' + field_id + '_lkid=' + selected_prefix + '&CF' + field_id + '=' + prefix_name + '&Name=' + 'Automated, Do not change';
                if(Recordtypeid != null && Recordtypeid != ''){
                    url += '&RecordType=' + Recordtypeid;
                }
            }
            
            if (MPORecType.containsKey('ASI_MFM_KR_PO') ){
                System.debug ('KR rectype='+((String)MPORecType.get('ASI_MFM_KR_PO')).substring(0,15));
                System.debug ('line 199='+Recordtypeid);
            }
            
            if (MPORecType.containsKey('ASI_MFM_KR_PO') && ((String)MPORecType.get('ASI_MFM_KR_PO')).substring(0,15) == Recordtypeid)
            {
                string ShipAddress_field_id = ASI_MFM_Function.getFieldId('ASI_MFM_PO__c', 'ASI_MFM_Company_Address__c');
                string Exchange_Rate_field_id = ASI_MFM_Function.getFieldId('ASI_MFM_PO__c', 'ASI_MFM_Exchange_Rate__c');
                
                url = '/' + obj_id + '/e?retURL=%2F' + obj_id + '%2Fo&nooverride=1&CF' + field_id + '_lkid=' + selected_prefix + '&CF' + field_id + '=' + prefix_name + '&Name=' + prefix_name;
                if(Recordtypeid != null && Recordtypeid != ''){
                    url += '&RecordType=' + Recordtypeid;
                }
                //Purchase Requests
                string prid = apexpages.currentPage().getParameters().get('prid');
                string prname= apexpages.currentPage().getParameters().get('prname');
                if(prid!=null){
                    string pr_field_id = ASI_MFM_Function.getFieldId('ASI_MFM_PO__c', 'ASI_MFM_Purchase_Request__c');
                    url += '&CF' + pr_field_id + '_lkid=' + prid + '&CF' + pr_field_id + '=' + prname;
                }
                
                //Currency
                string currencyName= apexpages.currentPage().getParameters().get('currencyName');
                string ExRate= apexpages.currentPage().getParameters().get('ExRate');
                url+='&' + currency_field_id + '=' + currencyName+'&'+Exchange_Rate_field_id+'='+ExRate;
                
                //Ship to
                string shiptoid= apexpages.currentPage().getParameters().get('shiptoid');
                string shiptoname= apexpages.currentPage().getParameters().get('shiptoname');
                string shiptoaddress= apexpages.currentPage().getParameters().get('shiptoaddress');  //added by Kammy
                
                if(shiptoaddress!=null){  //Added by Kammy at 19 Apr 2016
                    url+='&' + ShipAddress_field_id + '=' + EncodingUtil.urlEncode(shiptoaddress, 'UTF-8');//shiptoaddress;
                    
                }
                
                if(shiptoid!=null){  
                    string shipto_field_id = ASI_MFM_Function.getFieldId('ASI_MFM_PO__c', 'ASI_MFM_Warehouse__c');
                    url += '&CF' + shipto_field_id + '_lkid=' + shiptoid + '&CF' + shipto_field_id + '=' + shiptoname;
                }       
            }else{
                url = '/' + obj_id + '/e?retURL=%2F' + obj_id + '%2Fo&nooverride=1&CF' + field_id + '_lkid=' + selected_prefix + '&CF' + field_id + '=' + prefix_name + '&Name=' + prefix_name;
                if(Recordtypeid != null && Recordtypeid != ''){
                    url += '&RecordType=' + Recordtypeid;
                }
            }
            
            if(POType != null){
                string field_id3 = ASI_MFM_Function.getFieldId('ASI_MFM_PO__c', 'ASI_MFM_PO_Type__c');
                url += '&' + field_id3 + '=' + POType;
            }
            
            if(BudgetOwnerId != null){
                System.debug(BudgetOwnerid);
                string budget_name = '';
                List<user> LU = [select name from user where id = :BudgetOwnerId limit 1];
                System.debug(LU);
                if(LU.size()>0){
                    budget_name = LU[0].name;
                }
                string field_id4 = ASI_MFM_Function.getFieldId('ASI_MFM_PO__c', 'ASI_MFM_Budget_Owner__c');
                url += '&CF' + field_id4 + '_lkid=' + BudgetOwnerId + '&CF' + field_id4 + '=' + budget_name;
            }
            if (MPORecType.containsKey('ASI_MFM_SG_PO') && ((String)MPORecType.get('ASI_MFM_SG_PO')).substring(0,15) == (Recordtypeid!=null&&RecordTypeId.length()>15?RecordTypeId.subString(0,15):RecordTypeId ) ) {               
                if(prefix_location != 'Singapore'){
                    url += '&' + currency_field_id + '=' + 'USD';
                }              
            } 
            
            if(SupplierId != null && SupplierId != ''){
                System.debug(SupplierId);
                string supplier_name = '';
                List<Account> LU = [select name from account where id = :SupplierId limit 1];
                System.debug(LU);
                if(LU.size()>0){
                    supplier_name = LU[0].name;
                }
                string field_id5 = ASI_MFM_Function.getFieldId('ASI_MFM_PO__c', 'ASI_MFM_Supplier_Name__c');
                url += '&CF' + field_id5 + '_lkid=' + supplierId + '&CF' + field_id5 + '=' + supplier_name;
            }
            if(isTRJDFUser){
                string field_id6 = ASI_MFM_Function.getFieldId('ASI_MFM_PO__c', 'ASI_MFM_Currency__c');
                url += '&' + field_id6 + '=' + 'JPY';
            }
            
            if(plan_id != null) {
                string plan_name = [select name from asi_mfm_plan__c where id = :plan_id limit 1].name;
                string field_id2 = ASI_MFM_Function.getFieldId('ASI_MFM_PO__c', 'ASI_MFM_Plan__c');
                
                //Added by Elufa 20151116
                if(planname!=null){
                    string po_name_field_id = ASI_MFM_Function.getFieldId('ASI_MFM_PO__c', 'ASI_MFM_PO_Name__c');
                    url+='&'+po_name_field_id+'='+EncodingUtil.urlEncode(planname, 'UTF-8');
                }        
                return new pageReference(url + '&CF' + field_id2 + '_lkid=' + plan_id + '&CF' + field_id2 + '=' + plan_name);
            }
            else if(iom_id != null){
                string plan_name = [select name from ASI_CRM_Image_Outlet_Request__c where id = :iom_id limit 1].name;
                string field_id2 = ASI_MFM_Function.getFieldId('ASI_MFM_PO__c', 'ASI_CRM_CN_IOM_ID__c');
                return new pageReference(url + '&CF' + field_id2 + '_lkid=' + iom_id + '&CF' + field_id2 + '=' + plan_name);
            }
            else{
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