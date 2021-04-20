global class ASI_eForm_HK_CustomerFormController {
    
    @AuraEnabled(cacheable = true)
    public static List<SObject> fetchsObjectData(String soqlStatement){  
        return database.query(soqlStatement);
    }
    
    @AuraEnabled
    public static String GenerateRefreshToken(){
        ASI_MFM_Setting__c s = ASI_MFM_Setting__c.getInstance();
        
        String getTokenUrl = s.ASI_eform_HK_Token_Url__c;
        String grant_type = 'refresh_token';
        String refresh_token = s.ASI_eForm_HK_Refresh_Token__c;
        String client_id = s.ASI_eForm_HK_Client_Id__c;
        String client_secret = s.ASI_eForm_HK_Client_Secret__c;
        
        String endpoint = getTokenUrl + '?' + 'grant_type=' + grant_type + '&client_id=' + client_id 
            + '&client_secret=' + client_secret + '&refresh_token=' + refresh_token ;
        HttpRequest req = new HttpRequest();
        system.debug('Endpoint is : ' + endpoint);
        req.setEndpoint(endpoint);
        req.setMethod('POST');
        String result ='';
         Http http = new Http();
        if(!Test.isRunningTest() ){
           
            HTTPResponse res = http.send(req);
            result = res.getBody(); 
        }
        
        
        return result;
        
    }
    
    
    
    //****************************************** to be deleted *************************************************

    /*
    @AuraEnabled
    public static List<String> GetVF_CountryPicklist(){
        List<String> OptionList = new List<String>();
        Schema.DescribeFieldResult fieldResult = ASI_eForm_Vendor_Form__c.ASI_eForm_Country__c.getDescribe();
        List<Schema.PicklistEntry> ple = new List<Schema.PicklistEntry>();
        
        for(Schema.PicklistEntry tempPle : fieldResult.getPicklistValues()){
            String val = tempPle.getValue();
            OptionList.add(val);
            system.debug('val : '+val);
        }
        
        return OptionList;
    }
    
    
    
    
    
    public List<SelectOption> getPickListValue(Schema.DescribeFieldResult fieldResult){
        List<SelectOption> Selectoptions = new List<SelectOption>();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple){
            Selectoptions.add(new SelectOption(f.getLabel(), f.getValue()));
        }
        return Selectoptions;
    }
    */
    
    

    
    
}