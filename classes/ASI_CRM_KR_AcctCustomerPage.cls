public with sharing class ASI_CRM_KR_AcctCustomerPage {
    
    public ApexPages.StandardController standardController {get;set;}
    public Account AccountHeader { get; set; }
    public Account header{get;set;}
    
    public ASI_CRM_AccountsAdditionalField__c accountAdditionalField {set;get;}
    public boolean isVenue {set;get;}
    public boolean isOffTrade {set;get;}

    public ASI_CRM_KR_AcctCustomerPage(ApexPages.StandardController standardController){
        this.standardController = standardController;
        this.header = (Account)standardController.getRecord();
        
        AccountHeader = [SELECT id, Owner.name, ASI_KOR_Venue_Status__c, ASI_KOR_Salesman_Code__c, Name, ASI_KOR_Venue_Type__c, ASI_KOR_Customer_Code__c,RecordType.DeveloperName,
                        ASI_KOR_Grade__c, NameLocal, ASI_KOR_Wholesaler_Channel__c, ASI_KOR_Venue_Business_License_Number__c,
                        ASI_KOR_Venue_PR_Market_Share__c, ASI_KOR_Venue_Capacity__c,ASI_LUX_Le_Cercle_Member__c,
                        ASI_KOR_Venue_PR_Korea_Managed__c,ASI_KOR_Venue_Number_of_Rooms__c,
                        ASI_KOR_Venue_Diageo_Managed__c,ASI_KOR_Venue_Incentive_Method__c,
                        ASI_KOR_Venue_Total_of_Whisky_CAPA__c, ASI_KOR_Venue_Malt_Whisky_CAPA__c,
                        ASI_KOR_Venue_Whisky_CAPA_Local_12_Brand__c,ASI_KOR_Venue_Whisky_CAPA_Local_17_Brand__c ,
                        ASI_KOR_Venue_Whisky_CAPA_Intl_12_Brand__c, ASI_KOR_Venue_Whisky_CAPA_Intl_17_Brand__c,
                        ASI_KOR_Venue_Tot_of_White_Spirits_CAPA__c,ASI_KOR_Venue_Vodka_CAPA__c,
                        ASI_KOR_Venue_Other_Wine_Spirits_CAPA__c,ASI_KOR_Venue_Champagne_CAPA__c,
                        ASI_KOR_Venue_Tot_PR_KOR_Whisky_CAPA__c , ASI_KOR_Venue_PRK_Malt_Whisky_CAPA__c,
                        ASI_KOR_Venue_Whisky_CAPA_PRK_Lcl_12_Brd__c , ASI_KOR_Venue_Whisky_CAPA_PRK_Lcl17Brd__c ,
                        ASI_KOR_Venue_Whisky_CAPA_PRK_Intl12Brd__c, ASI_KOR_Venue_Tot_PRK_White_Spirits_CAPA__c,
                        ASI_KOR_Venue_PR_Korea_Vodka_CAPA__c, ASI_KOR_Venue_PRK_Other_Wht_Spirits_CAPA__c,
                        ASI_KOR_Venue_PRK_Champagne_CAPA__c,
                        ASI_KOR_Venue_Venue_Point__c, ASI_KOR_Venue_Consumer_Profile__c,
                        ASI_KOR_Venue_Content__c, ASI_KOR_Venue_Popularity__c,
                        ASI_KOR_Venue_Influential_Venue__c,
            //ASI_KOR_Venue_Opening_Date__c,
            ASI_KOR_Venue_Annual_Contract_Status__c,
                        ASI_KOR_Postal_Code__c,ASI_KOR_Addr_Province__c,
                        ASI_KOR_Addr_City__c, ASI_KOR_Addr_Street__c, 
                        ASI_KOR_Wholesaler_Addr_Building__c
                        FROM Account WHERE Id =: header.id];
        
        
        isOffTrade = false;
        isVenue= false;                
        accountAdditionalField = getAccountsAdditionalField_DynamiCSOQL(header.id, AccountHeader.RecordType.DeveloperName);

        if (accountAdditionalField == null){  
            accountAdditionalField = new ASI_CRM_AccountsAdditionalField__c();
            //accountAdditionalField.RecordType.DeveloperName = '';
            accountAdditionalField.RecordTypeid = Global_RecordTypeCache.getRTId('ASI_CRM_AccountsAdditionalField__cASI_CRM_KR_Venue');
            accountAdditionalField.Name = AccountHeader.name;
            accountAdditionalField.ASI_CRM_Account__c = standardController.getRecord().id;
        
        }
        
        if(accountAdditionalField != null){
            if(accountAdditionalField.ASI_CRM_Off_Trade_Customer__c){
                isOffTrade = true;
            }
            else{
                
                isVenue = true;
            }
        }
        
        if(AccountHeader.RecordType.DeveloperName=='ASI_KOR_Wholesaler'){
            isOffTrade = false;
            isVenue=false;
            
        }
    }
    
  
    
    private ASI_CRM_AccountsAdditionalField__c getAccountsAdditionalField_DynamiCSOQL(String accountId, string Accttype) {
        String query = 'SELECT '; 
        Set<String> queryFields = new Set<String>();
        try{  

                for(Schema.FieldSetMember f : SObjectType.ASI_CRM_AccountsAdditionalField__c.FieldSets.ASI_KR_CRM_Off_trade_Venue.getFields()) {    
                    queryFields.add(f.getFieldPath());
                } 

                for(Schema.FieldSetMember f : SObjectType.ASI_CRM_AccountsAdditionalField__c.FieldSets.ASI_KR_CRM_Venue.getFields()) {    
                   queryFields.add(f.getFieldPath());   
                } 
                
                List<String> queryString = new List<String>(queryFields);
                query += 'Id, Name, ASI_CRM_Account__c,ASI_CRM_Off_Trade_Customer__c,' + String.join(queryString,',') +  ' FROM ASI_CRM_AccountsAdditionalField__c WHERE ASI_CRM_Account__c = \''+accountId+'\' limit 1';
                return Database.query(query);
               
            
        }    
        catch(Exception e){    
               system.debug(e);
        }    
        return null;
    
    }
    
    
    public PageReference save() {
        try {
            upsert(standardController.getRecord());   
            if (accountAdditionalField.ASI_CRM_Account__c == null) {
                accountAdditionalField.ASI_CRM_Account__c = standardController.getRecord().id;
                
                RecordType recordType = [SELECT DeveloperName, id FROM RecordType WHERE DeveloperName = 'ASI_CRM_KR_Venue' AND SobjectType = 'ASI_CRM_AccountsAdditionalField__c'];
                accountAdditionalField.RecordTypeId = recordType.id;        
            }
            upsert(accountAdditionalField);
            
            update AccountHeader;
        } catch(System.DMLException e) {
            ApexPages.addMessages(e);
            return null;
        }
        
        PageReference ReturnPage = new PageReference('/apex/ASI_CRM_KR_AcctCustomer_Page?core.apexpages.request.devconsole=1&id='+ standardController.getRecord().id);//ASI_CRM_KR_AcctCustomer_Page
        ReturnPage.setRedirect(true); 
        return ReturnPage;
    }
    
    
    public PageReference eidtPage() {
        
        PageReference ReturnPage = new PageReference('/apex/ASI_CRM_KR_AccountEditPage?core.apexpages.request.devconsole=1&id=' + standardController.getRecord().id);
      
        ReturnPage.setRedirect(true); 
        
        return ReturnPage;
    }
    
    public PageReference cancel() {
         PageReference ReturnPage = new PageReference('/apex/ASI_CRM_KR_AcctCustomer_Page?core.apexpages.request.devconsole=1&id='+ standardController.getRecord().id);
        ReturnPage.setRedirect(true); 
        
        return ReturnPage;
    }
    
    
}