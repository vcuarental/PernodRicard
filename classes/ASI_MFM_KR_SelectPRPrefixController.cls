public class ASI_MFM_KR_SelectPRPrefixController {
    
    map<string, ASI_MFM_Prefix__c> px_map = new map<string, ASI_MFM_Prefix__c>();   
    
    public list<selectOption> available_prefixes {get; private set;}
    public string selected_prefix {get; set;}
    public string PRType {get; set;}{PRType='';}
    public ASI_MFM_KR_SelectPRPrefixController(apexpages.standardController sc) {
        
        System.debug(LoggingLevel.INFO, '*** sc: ' + sc.getRecord());
    }
    
    
    public pageReference getPrefixes() {

        // string recordType_id = apexpages.currentPage().getParameters().get('RecordType');
        // system.debug('recordType ID: ' + recordType_id);
        // if(String.isBlank(recordType_id))
        // {
        //     Schema.DescribeSObjectResult dsr = ASI_MFM_Purchase_Request__c.SObjectType.getDescribe();
        //     Schema.RecordTypeInfo defaultRecordType;
        //     System.debug(LoggingLevel.INFO, '*** dsr: ' + dsr.getRecordTypeInfos());
        //     for(Schema.RecordTypeInfo rti : dsr.getRecordTypeInfos()) {
        //         if(!rti.isDefaultRecordTypeMapping() && rti.isAvailable()) {
        //             recordType_id = rti.getRecordTypeId();
        //         }
        //     }
        //     if(String.isBlank(recordType_id))
        //     {
        //         recordType_id = Global_RecordTypeCache.getRtId('ASI_MFM_Purchase_Request__cASI_CN_Vendor_Purchase_Request');
        //     }
        // }
        // System.debug(LoggingLevel.INFO, '*** recordType_id: ' + recordType_id);
        // List<RecordType> recs =[SELECT Id, DeveloperName,Name FROM RecordType where Id =:recordType_id];
        // if(recs.size()>0 && recs[0].DeveloperName.equals('ASI_CN_Vendor_Purchase_Request'))
        // {
        //     return new pageReference('/apex/ASI_CTY_CN_Vendor_PR_PurchaseCreatPage');
        // }

        User u = [SELECT Profile.Name,ASI_MFM_Country__c FROM User where Id =: UserInfo.getUserId() ];
        String profileName = u.Profile.Name;
        String contryName = u.ASI_MFM_Country__c;
        if(profileName.contains('ASI CN') || contryName == 'CN')
        {
            return new pageReference('/apex/ASI_CTY_CN_Vendor_PR_PurchaseCreatPage');
        }

        list<ASI_MFM_Prefix__c> px_list = new list<ASI_MFM_Prefix__c>();
        for (ASI_MFM_Prefix__c px:[select id, name from asi_mfm_prefix__c where ASI_MFM_Inactive__c = false and asi_mfm_module__c = 'PR' and RecordType.DeveloperName ='ASI_MFM_KR_Prefix']) {
            px_map.put(px.id, px);
            px_list.add(px);    
        }     
        available_prefixes = new list<selectOption>();
        available_prefixes.add(new selectOption('', '-- None --'));
        for (ASI_MFM_Prefix__c rp:px_list) {
            available_prefixes.add(new selectOption(rp.id, rp.name));
        }
        
        /*
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
            for (asi_mfm_role_prefix_relationship__c px:[select asi_mfm_prefix__c, asi_mfm_prefix__r.name,asi_mfm_prefix__r.ASI_MFM_Location__c from asi_mfm_role_prefix_relationship__c
                                                         where asi_mfm_prefix__r.ASI_MFM_Inactive__c = false and asi_mfm_prefix__r.asi_mfm_module__c = 'PR' and asi_mfm_role_name__c = :u.userRole.developerName and asi_mfm_prefix__r.asi_mfm_country_name__c = :u.asi_mfm_country__c order by asi_mfm_prefix__r.name]) {
                                                             px_map.put(px.asi_mfm_prefix__c, px);
                                                             px_list.add(px);    
                                                         }     
            
            if (px_list.size() == 0) {
                apexpages.message err = new apexpages.message(apexpages.severity.error, 'The user is not entitled to input PRs');
                apexpages.addmessage(err); 
            }
            else if (px_list.size() == 1) {
                selected_prefix = px_list[0].asi_mfm_prefix__c;
                return proceed();
            }
            else {
                available_prefixes = new list<selectOption>();
                available_prefixes.add(new selectOption('', '-- None --'));
                for (asi_mfm_role_prefix_relationship__c rp:px_list) {
                    available_prefixes.add(new selectOption(rp.asi_mfm_prefix__c, rp.asi_mfm_prefix__r.name));
                }
            }
        }    
*/
        return null;
        
    }
    
    public pageReference proceed() {
        if (selected_prefix == null || selected_prefix == '') {
            apexpages.message err = new apexpages.message(apexpages.severity.error, 'Please select prefix first');
            apexpages.addmessage(err); 
            return null;            
        }else{
            string prefix_name = px_map.get(selected_prefix).name;
            string obj_id = sObjectType.ASI_MFM_Purchase_Request__c.getKeyPrefix();
            string FieldId_PRType = ASI_MFM_Function.getFieldId('ASI_MFM_Purchase_Request__c', 'ASI_MFM_Type__c');
            string field_id = ASI_MFM_Function.getFieldId('ASI_MFM_Purchase_Request__c', 'ASI_MFM_Prefix__c');
            string plan_id = apexpages.currentPage().getParameters().get('planid');
            // Added by 2017-06-16 Linus@Introv
            string recordType_id = apexpages.currentPage().getParameters().get('RecordType');
            system.debug('recordType ID: ' + recordType_id);
            string url = '/' + obj_id + '/e?retURL=%2F' + obj_id + '%2Fo&nooverride=1&CF' + field_id + '_lkid=' + selected_prefix + '&CF' + field_id + '=' + prefix_name + '&Name=' + prefix_name + '&' + FieldId_PRType + '=' +prefix_name ;  
            
            if(plan_id!=null){
                ASI_MFM_Plan__c plan = [select id, name,ASI_MFM_Status__c, ASI_MFM_Plan_Name__c from ASI_MFM_Plan__c where Id =: plan_id];
                string FieldId_PRname = ASI_MFM_Function.getFieldId('ASI_MFM_Purchase_Request__c', 'ASI_MFM_PR_Name__c');
                
                string Field_Planid = ASI_MFM_Function.getFieldId('ASI_MFM_Purchase_Request__c','ASI_MFM_Plan__c');   
                url += '&CF' + Field_Planid + '_lkid=' + plan.id + '&CF' + Field_Planid + '=' + plan.name + '&' + FieldId_PRname + '=' +  EncodingUtil.urlEncode(plan.ASI_MFM_Plan_Name__c, 'UTF-8')  ;
                
            }else{
                url += '&RecordType=' + recordType_id;
            }
            
            return new pageReference(url);
        }
        
        
        return null;
    }
    
    
}