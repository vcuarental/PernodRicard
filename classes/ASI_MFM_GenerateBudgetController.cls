public with sharing class ASI_MFM_GenerateBudgetController {

    public ASI_MFM_budget__c selected {get; set;}
    public list<selectOption> available_prefixes {get; private set;}
    public string selected_prefix {get; set;}
    
    public ASI_MFM_GenerateBudgetController(apexpages.standardSetController sc) {
        selected = new ASI_MFM_budget__c();
        Map<String, id> MRecType = new Map<String, id>();
        for(RecordType rec :Global_RecordTypeCache.getRtList('ASI_MFM_Budget__c')){
            MRecType.put(rec.developername,rec.id);
        }
        
        string UserCountry=[select ASI_MFM_Country__c from user where id = :userInfo.getUserId()].ASI_MFM_Country__c.trim();
        if(UserCountry=='TR'){
            available_prefixes = new list<selectOption>();
            available_prefixes.add(new selectOption('', '-- None --'));
            for(ASI_MFM_Prefix__c px:[select id,name from ASI_MFM_Prefix__c where ASI_MFM_Module__c='Plan' and ASI_MFM_Inactive__c =false and ASI_MFM_country_name__c=:UserCountry and recordType.developerName like  'ASI_MFM_TR%']){
                available_prefixes.add(new selectOption(px.id, px.name));
            }
        }else if(UserCountry=='HK'){
            selected.RecordTypeId = MRecType.get('ASI_MFM_HK_Budget');
            Map<Id, Boolean> mapRecordEditRight = new Map<Id, Boolean>();
            Map<Id, ASI_MFM_Prefix__c> mapPrefix = new Map<Id, ASI_MFM_Prefix__c>();
            List<ASI_MFM_Prefix__c> lstPrefix = new List<ASI_MFM_Prefix__c>();
            
            available_prefixes = new list<selectOption>();
            available_prefixes.add(new selectOption('', '-- None --'));
            
            lstPrefix = [SELECT Id, Name FROM ASI_MFM_Prefix__c WHERE ASI_MFM_Module__c='Plan' AND ASI_MFM_Inactive__c =false AND ASI_MFM_country_name__c=:UserCountry AND recordType.developerName LIKE 'ASI_MFM_HK%'];
            
            for(ASI_MFM_Prefix__c px :lstPrefix){
                mapPrefix.put(px.Id, px);
            }
            
            for(UserRecordAccess itm :[SELECT RecordId, HasReadAccess, HasEditAccess, HasAllAccess, MaxAccessLevel FROM UserRecordAccess WHERE UserId = :UserInfo.getUserId() AND RecordId IN :mapPrefix.keySet()]){
                mapRecordEditRight.put(itm.RecordId, itm.HasEditAccess);
            }
            
            for(ASI_MFM_Prefix__c px :lstPrefix){
                if(mapRecordEditRight.get(px.Id)){
                    available_prefixes.add(new selectOption(px.id, px.name));
                }
            }
            
            
            /*for(ASI_MFM_Prefix__c px:[SELECT Id, Name FROM ASI_MFM_Prefix__c WHERE ASI_MFM_Module__c='Plan' AND ASI_MFM_Inactive__c =false AND ASI_MFM_country_name__c=:UserCountry AND recordType.developerName LIKE 'ASI_MFM_HK%']){
                available_prefixes.add(new selectOption(px.id, px.name));
            }*/
        }
        
        //End
    }
    
    public pageReference redirect() {
        string UserCountry=[select ASI_MFM_Country__c from user where id = :userInfo.getUserId()].ASI_MFM_Country__c.trim();
        PageReference myVFPage = new PageReference('/apex/myVFPage');
        myVFPage = null;
        if(UserCountry=='TR'){
            myVFPage = new PageReference('/apex/ASI_MFM_TR_GenerateBudgetPage');
            myVFPage.setRedirect(true);
        }else if(UserCountry=='HK'){
            myVFPage = new PageReference('/apex/ASI_MFM_HK_GenerateBudgetPage');
            myVFPage.setRedirect(true);
        }
        return myVFPage;
    }
    
    public pageReference proceed() {
        string country = 'ASI_MFM_' + [select ASI_MFM_Country__c from user where id = :userInfo.getUserId()].ASI_MFM_Country__c.trim() + '%';
        string fiscal_year = selected.ASI_MFM_fiscal_year__c;
        string tr_recordType = selected.ASI_MFM_TR_Record_Type__c;
        list<ASI_MFM_budget__c> budget_list = new list<ASI_MFM_budget__c>();
        string prefixId;
        //TR MFM Logic: Generate budget separately for ATR & JDF & HK
        if (country.contains('TR')){
            budget_list = [select id from ASI_MFM_budget__c 
                where recordType.developerName like :country and ASI_MFM_type__c = :selected.ASI_MFM_type__c and ASI_MFM_fiscal_year__c = :fiscal_year and ASI_MFM_Department__c=:selected_prefix
                    and ASI_MFM_TR_Record_Type__c = :tr_recordType];
            prefixId=selected_prefix;
        }
        else if (country.contains('SG')){
            budget_list = [select id from ASI_MFM_budget__c 
                where recordType.developerName like :country and ASI_MFM_type__c = :selected.ASI_MFM_type__c and ASI_MFM_fiscal_year__c = :fiscal_year
                    and  OwnerId= :userInfo.getUserId()];
        }
        else if (country.contains('HK')){
            budget_list = [
                SELECT Id 
                FROM ASI_MFM_budget__c 
                WHERE recordType.developerName LIKE :country 
                AND ASI_MFM_type__c = :selected.ASI_MFM_type__c 
                AND ASI_MFM_fiscal_year__c = :fiscal_year 
                AND ASI_MFM_Department__c = :selected_prefix
            ];
            
            prefixId = selected_prefix;
        }
        else {
            budget_list = [select Id from ASI_MFM_budget__c 
                where recordType.developerName like :country and ASI_MFM_type__c = :selected.ASI_MFM_type__c and ASI_MFM_fiscal_year__c = :fiscal_year];

        }
        
        if (budget_list.size() > 0) {
            delete budget_list;
            budget_list.clear();
        }
        Map<String, id> MRecType = new Map<String, id>();
        for(RecordType rec :Global_RecordTypeCache.getRtList('ASI_MFM_Budget__c')){
            MRecType.put(rec.developername,rec.id);
        }
        
        String CNRecTypeID = MRecType.get('ASI_MFM_CN_Budget');
        
        string query_string = ASI_MFM_Function.buildQuery('ASI_MFM_plan_line_item__c') + 
            ' where recordType.developerName like :country and ASI_MFM_plan__r.ASI_MFM_fiscal_year__c = :fiscal_year';          
            
        if (country.contains('TR')){
            query_string += ' and ASI_MFM_TR_Record_Type__c = :tr_recordType and ASI_MFM_plan__r.ASI_MFM_Prefix__c=:prefixId';
        }else if(country.contains('HK')){
            query_string += ' and ASI_MFM_plan__r.ASI_MFM_Prefix__c=:prefixId';
        }
        
        for (ASI_MFM_plan_line_item__c pi:database.query(query_string)) {
            ASI_MFM_budget__c b = new ASI_MFM_budget__c();
            b.ASI_MFM_A_C_Code__c = pi.ASI_MFM_A_C_Code__c;
            b.ASI_MFM_AP_Code__c = pi.ASI_MFM_AP_Code__c;
            b.ASI_MFM_BU__c = pi.ASI_MFM_BU_Code__c;
            b.ASI_MFM_Currency__c = pi.ASI_MFM_Currency__c;
            b.ASI_MFM_customer_name__c = pi.ASI_MFM_customer_name__c;
            
            //GF Logic:
            if (country.contains('GF')){
                b.ASI_MFM_Reference__c = pi.ASI_MFM_Reference__c;
                b.ASI_MFM_Sub_brand_Allocation__c = pi.ASI_MFM_Sub_brand_Allocation_Type__c;
            }
            else if (country.contains('CN'))
            {
                b.recordtypeid = CNRecTypeID ;
            }
            else if (country.contains('TR'))
            {
                b.recordtypeid = MRecType.get('ASI_MFM_TR_Budget');
                b.ASI_MFM_TR_Record_Type__c = pi.ASI_MFM_TR_Rec_Type__c;
                b.ASI_MFM_Department__c=selected_prefix;
            }
            else if (country.contains('HK'))
            {
                b.recordtypeid = MRecType.get('ASI_MFM_HK_Budget');
                b.ASI_MFM_Department__c = selected_prefix;
            }
            // Add By Alan Wong (elufa) 02-2015
            else if (country.contains('SG'))
            {
                b.recordtypeid = MRecType.get('ASI_MFM_SG_Budget');
            }
            
            b.ASI_MFM_Fiscal_Year__c = selected.ASI_MFM_fiscal_year__c;
            b.ASI_MFM_P1_Amount__c = pi.ASI_MFM_Month_1_Cost__c;
            b.ASI_MFM_P2_Amount__c = pi.ASI_MFM_Month_2_Cost__c;            
            b.ASI_MFM_P3_Amount__c = pi.ASI_MFM_Month_3_Cost__c;
            b.ASI_MFM_P4_Amount__c = pi.ASI_MFM_Month_4_Cost__c;            
            b.ASI_MFM_P5_Amount__c = pi.ASI_MFM_Month_5_Cost__c;
            b.ASI_MFM_P6_Amount__c = pi.ASI_MFM_Month_6_Cost__c;            
            b.ASI_MFM_P7_Amount__c = pi.ASI_MFM_Month_7_Cost__c;
            b.ASI_MFM_P8_Amount__c = pi.ASI_MFM_Month_8_Cost__c;            
            b.ASI_MFM_P9_Amount__c = pi.ASI_MFM_Month_9_Cost__c;
            b.ASI_MFM_P10_Amount__c = pi.ASI_MFM_Month_10_Cost__c;          
            b.ASI_MFM_P11_Amount__c = pi.ASI_MFM_Month_11_Cost__c;
            b.ASI_MFM_P12_Amount__c = pi.ASI_MFM_Month_12_Cost__c;  
            b.ASI_MFM_Plan__c = pi.ASI_MFM_Plan__c;
            b.ASI_MFM_Plan_Line_Item__c = pi.id;
            b.ASI_MFM_Sub_brand_Code__c = pi.ASI_MFM_Sub_brand_Code__c;
            b.ASI_MFM_Size__c = pi.ASI_MFM_Size__c;
            b.ASI_MFM_Type__c = selected.ASI_MFM_type__c;
            budget_list.add(b);                                         
        }
        if (budget_list.size() > 0) {
            insert budget_list;
        } 

        if (country.contains('HK')){
            Schema.DescribeSObjectResult result = ASI_MFM_budget__c.SObjectType.getDescribe();
            PageReference pageRef = new PageReference('/' + result.getKeyPrefix());
            pageRef.setRedirect(true);
            return pageRef;
        }else{
            return new pageReference('/home/home.jsp');
        }
    }   
}