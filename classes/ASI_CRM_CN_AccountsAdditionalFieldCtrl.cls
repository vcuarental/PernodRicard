public with sharing class ASI_CRM_CN_AccountsAdditionalFieldCtrl{ 
    public ApexPages.StandardController standardController;  
 
    public ASI_CRM_AccountsAdditionalField__c accountAdditionalField {set;get;}
      
    public boolean isOutlet {set;get;}
    
    public boolean isWholesaler {set;get;}
    
    public ASI_CRM_CN_AccountsAdditionalFieldCtrl(ApexPages.StandardController controller) {
        standardController = controller;        
        Account account = (Account)controller.getRecord();
        
        if(account.RecordTypeId != null){
            RecordType recordType = [SELECT DeveloperName, id FROM RecordType WHERE id = :account.RecordTypeId];
            
            isOutlet = recordType.DeveloperName == 'ASI_MFM_CN_Outlet';
            isWholesaler = recordType.DeveloperName == 'ASI_CRM_CN_Wholesales_CN';         
            
            accountAdditionalField = getAccountsAdditionalFieldById(account.id);
        }                                
    }
           
    private ASI_CRM_AccountsAdditionalField__c getAccountsAdditionalFieldById(String accountId) {
        //2014-07-29 Stella Sing
        ASI_CRM_AccountsAdditionalField__c returnObject = new ASI_CRM_AccountsAdditionalField__c();
        //----------------------
        try{    
            String query = 'SELECT ';
            
            if(isOutlet){   
                for(Schema.FieldSetMember f : SObjectType.ASI_CRM_AccountsAdditionalField__c.FieldSets.ASI_CRM_CN_OutletBasicAdlFldSt.getFields()) {    
                    query += f.getFieldPath() + ', ';    
                } 
                for(Schema.FieldSetMember f : SObjectType.ASI_CRM_AccountsAdditionalField__c.FieldSets.ASI_CRM_CN_OutletPRDirectSalesAdlFldSt.getFields()) {    
                    query += f.getFieldPath() + ', ';    
                }
                for(Schema.FieldSetMember f : SObjectType.ASI_CRM_AccountsAdditionalField__c.FieldSets.ASI_CRM_CN_OutletTraceabilityAdlFldSet.getFields()) {    
                    query += f.getFieldPath() + ', ';    
                }
            } 
            
            if(isWholesaler){   
                for(Schema.FieldSetMember f : SObjectType.ASI_CRM_AccountsAdditionalField__c.FieldSets.ASI_CRM_CN_WSBasicAdlFldSt.getFields()) {    
                    query += f.getFieldPath() + ', ';    
                } 
                for(Schema.FieldSetMember f : SObjectType.ASI_CRM_AccountsAdditionalField__c.FieldSets.ASI_CRM_CN_WSBrndT1AppAdlAdlFldSt.getFields()) {    
                    query += f.getFieldPath() + ', ';    
                }
                for(Schema.FieldSetMember f : SObjectType.ASI_CRM_AccountsAdditionalField__c.FieldSets.ASI_CRM_CN_WSBsnsScopeAdlFldSt.getFields()) {    
                    query += f.getFieldPath() + ', ';    
                }
                for(Schema.FieldSetMember f : SObjectType.ASI_CRM_AccountsAdditionalField__c.FieldSets.ASI_CRM_CN_WSChnlCvrgAdlFldSt.getFields()) {    
                    query += f.getFieldPath() + ', ';    
                } 
                for(Schema.FieldSetMember f : SObjectType.ASI_CRM_AccountsAdditionalField__c.FieldSets.ASI_CRM_CN_WST2AppAdlFldSt.getFields()) {    
                    query += f.getFieldPath() + ', ';    
                }
                for(Schema.FieldSetMember f : SObjectType.ASI_CRM_AccountsAdditionalField__c.FieldSets.ASI_CRM_CN_WSTrcbltyScpAdlFldSt.getFields()) {    
                    query += f.getFieldPath() + ', ';    
                }                
            }
                                           
            //query += 'Id, Name, ASI_CRM_Account__c FROM ASI_CRM_AccountsAdditionalField__c WHERE ASI_CRM_Account__c = \''+accountId+'\'';  
            
            //2014-07-29 Stella Sing
            query += 'Id, Name, ASI_CRM_Account__c FROM ASI_CRM_AccountsAdditionalField__c WHERE ASI_CRM_Account__c = \''+accountId+'\'' + ' LIMIT 1';   
            returnObject = Database.query(query); 
            //System.Debug(query);
            System.Debug(returnObject);
            if (returnObject != null)
                return returnObject;
            else
                return null;
            //-------------------------
            //return Database.query(query);    
        }    
        catch(Exception e){
            //Utility.addError('There is error while Fetching existing Question using Dynamic SOQL in Field Set. Error Detail - '+e.getMessage()); //This is Utility Method to display error message on VF Page    
            return null;
        }    
    }        
    
    public PageReference save() {
        try {
            upsert(standardController.getRecord());   
            if (accountAdditionalField.ASI_CRM_Account__c == null) {
                accountAdditionalField.ASI_CRM_Account__c = standardController.getRecord().id;
                
                RecordType recordType = [SELECT DeveloperName, id FROM RecordType WHERE DeveloperName = 'ASI_TH_CRM_Potential_Outlet' AND SobjectType = 'ASI_CRM_AccountsAdditionalField__c'];
                accountAdditionalField.RecordTypeId = recordType.id;        
            }
            upsert(accountAdditionalField);
        } catch(System.DMLException e) {
            ApexPages.addMessages(e);
            return null;
        }
        
        PageReference ReturnPage = new PageReference('/' + standardController.getRecord().id);
        ReturnPage.setRedirect(true); 
        return ReturnPage;
    }
    
}