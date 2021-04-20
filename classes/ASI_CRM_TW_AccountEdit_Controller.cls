public with sharing class ASI_CRM_TW_AccountEdit_Controller {  
    public ASI_CRM_AccountsAdditionalField__c accountAdditionalField {set;get;}
    public ApexPages.StandardController standardController;    
    public boolean IsOutlet {set;get;} 
    public boolean IsKeyAccount {set;get;}
    public boolean IsWholesaler {set;get;}  
    public boolean IsForecast {set;get;}     // Added by 2018-03-29 Linus@introv
    public boolean chNonEditable {set;get;}
    public boolean whAddrSamesAs {get;set;}  
    public boolean invAddrSamesAs {get;set;}  
    
    public String selectedOutletTypeId {set;get;}
    public List<SelectOption> OutletTypeList {
        get{
            List<ASI_TH_CRM_OutletType__c> outletTypes = [SELECT id, Name FROM ASI_TH_CRM_OutletType__c WHERE RecordType.DeveloperName = 'ASI_CRM_TW_Outlet_Type' ORDER BY  ASI_CRM_Channel__c, ASI_CRM_Sub_Channel__c];
            
            List<SelectOption> outletTypeList = new List<SelectOption>();
            
            for(ASI_TH_CRM_OutletType__c outletType : outletTypes){
                outletTypeList .add(new SelectOption(outletType.id, outletType.Name));
            }
            return outletTypeList ;
        }
    } 
    
    public ASI_CRM_TW_AccountEdit_Controller(ApexPages.StandardController controller) {
        standardController = controller;        
        Account account = (Account)controller.getRecord();
        IsOutlet = false;
        IsWholesaler = false;
        IsKeyAccount = false;
        IsForecast = false;
        chNonEditable = false;
        whAddrSamesAs = false;
        invAddrSamesAs = false;
        
        account.ASI_HK_CRM_IsDeliveryAccount__c = false;
        if(account.id != null )
            accountAdditionalField = getAccountsAdditionalField_DynamiCSOQL(account.id);         
                       
        if (accountAdditionalField == null){
            accountAdditionalField = new ASI_CRM_AccountsAdditionalField__c();
            accountAdditionalField.ASI_CRM_Account__c = controller.getRecord().id;
        }else{
            selectedOutletTypeId = accountAdditionalField.ASI_TH_CRM_OutletType__c;
            
            //Added by Twinkle @20161209 - fields not editable if Channel is CR/HBR/LS/TOT/CVS/SWS
            if(accountAdditionalField.ASI_CRM_Channel__c != null &&
               accountAdditionalField.ASI_CRM_Channel__r.ASI_CRM_CN_Channel_Code__c != 'CR' &&
               accountAdditionalField.ASI_CRM_Channel__r.ASI_CRM_CN_Channel_Code__c != 'HBR' &&
               accountAdditionalField.ASI_CRM_Channel__r.ASI_CRM_CN_Channel_Code__c != 'LS' &&
               accountAdditionalField.ASI_CRM_Channel__r.ASI_CRM_CN_Channel_Code__c != 'TOT' &&
               accountAdditionalField.ASI_CRM_Channel__r.ASI_CRM_CN_Channel_Code__c != 'CVS' &&
               accountAdditionalField.ASI_CRM_Channel__r.ASI_CRM_CN_Channel_Code__c != 'SWS'){
                chNonEditable = true;
            }
        }
        
        //--Added by William Yang 20140530--
        if(accountAdditionalField.ASI_CRM_Region__c == null || accountAdditionalField.ASI_CRM_Region__c == '')
        {
            ID curUserId = UserInfo.getUserId();
            List<User> users = [SELECT Id, ASI_KOR_User_Region_Code__c, ASI_KOR_User_Region_Name__c FROM User WHERE Id = :curUserId];
            String regionCode = '';
            if (users.size() > 0 && users[0].ASI_KOR_User_Region_Code__c != null) 
                accountAdditionalField.ASI_CRM_Region__c = users[0].ASI_KOR_User_Region_Code__c;
        }
        //--End--
        
        if (account.RecordTypeId == null){
            RecordType recordType = [SELECT DeveloperName, id FROM RecordType WHERE DeveloperName = 'ASI_CRM_TW_Outlet' AND SobjectType = 'Account'];
            account.RecordTypeId = recordType.id;
            IsOutlet = true;
        } else{
            RecordType recordType = [SELECT DeveloperName, id FROM RecordType WHERE id = :account.RecordTypeId];
            
            if (recordType.DeveloperName == 'ASI_CRM_TW_Outlet'){
                IsOutlet = true;
            }else if (recordType.DeveloperName == 'ASI_CRM_TW_KeyAccount'){
                IsKeyAccount = true;        
            }else if (recordType.DeveloperName == 'ASI_CRM_TW_Wholesaler'){
                IsWholesaler = true;
            }else if (recordType.DeveloperName == 'ASI_CRM_TW_Forecast_Customer'){
                IsForecast = true;
            }
        }                                
    }
           
    private ASI_CRM_AccountsAdditionalField__c getAccountsAdditionalField_DynamiCSOQL(String accountId) {  
        System.Debug(accountId);
        String query = 'SELECT ';  
        
        for(Schema.FieldSetMember f : SObjectType.ASI_CRM_AccountsAdditionalField__c.FieldSets.ASI_CRM_TW_AdditionalField.getFields()) {    
            query += f.getFieldPath() + ', ';    
        } 
        
        query += 'Id, Name, ASI_CRM_TW_Warehouse_Address__c, ASI_CRM_TW_Invoice_Address__c, ASI_CRM_Account__c, ASI_CRM_CN_Legal_Name__c, ASI_CRM_CN_Inactive_Flag__c, ASI_CRM_TW_Parent_Account__c , ASI_TH_CRM_OutletType__c ,  ASI_CRM_IsParentAccount__c, ASI_CRM_Service_Pack__c, ASI_CRM_Segmentation_Criteria__c, ' +
        'ASI_CRM_City__c, ASI_CRM_Town__c, ASI_CRM_TW_Street__c, ASI_CRM_TW_Section__c, ASI_CRM_TW_Lane__c, ASI_CRM_TW_Alley__c, ASI_CRM_TW_Number__c, ASI_CRM_Is_Supplier__c, ASI_TH_CRM_Notes__c,ASI_CRM_Is_SCA_Customer__c , ASI_CRM_Longitude__c, ASI_CRM_Latitude__c, ' +
        'ASI_CRM_TW_Number_Hyphen__c, ASI_CRM_TW_Floor__c, ASI_CRM_TW_Hyphen__c, ASI_CRM_TW_Suite__c, ASI_CRM_TW_Phone_Area_Code__c, ASI_CRM_TW_Phone_Number__c, ASI_CRM_TW_Phone_Ext__c, ASI_CRM_Approval_Status__c, ' +
        'ASI_CRM_TW_Fax_Area_Code__c, ASI_CRM_TW_Fax_Number__c, ASI_CRM_Channel__c, ASI_CRM_Channel__r.ASI_CRM_CN_Channel_Code__c, ASI_CRM_CN_Sub_Channel__c, ASI_CRM_CN_Grade__c, ASI_CRM_Sales_Potential__c, ASI_CRM_Region__c, '+
        'ASI_CRM_TW_No_Visit__c, ASI_CRM_TW_No_Required_Visit__c, ASI_CRM_CN_Suggested_No_of_Visit__c, ASI_CRM_VN_EnglishName__c, ASI_CRM_English_Address__c, ASI_CRM_Account_Segment__c, ASI_CRM_TW_Action_Grade__c, ' +
        'ASI_CRM_TW_Warehouse_City__c, ASI_CRM_TW_Warehouse_Town__c, ASI_CRM_TW_Warehouse_Street__c, ASI_CRM_TW_Warehouse_Section__c, ASI_CRM_TW_Warehouse_Lane__c, ASI_CRM_TW_Warehouse_Alley__c, ASI_CRM_TW_Warehouse_Number__c, ' +
        'ASI_CRM_TW_Warehouse_Number_Hyphen__c, ASI_CRM_TW_Warehouse_Floor__c, ASI_CRM_TW_Warehouse_Hyphen__c, ASI_CRM_TW_Warehouse_Suite__c,' + 
        'ASI_CRM_TW_Invoice_City__c, ASI_CRM_TW_Invoice_Town__c, ASI_CRM_TW_Invoice_Street__c, ASI_CRM_TW_Invoice_Section__c, ASI_CRM_TW_Invoice_Lane__c, ASI_CRM_TW_Invoice_Alley__c, ASI_CRM_TW_Invoice_Number__c,' +
        'ASI_CRM_TW_Invoice_Number_Hyphen__c, ASI_CRM_TW_Invoice_Floor__c, ASI_CRM_TW_Invoice_Hyphen__c, ASI_CRM_TW_Invoice_Suite__c ' + 
        'FROM ASI_CRM_AccountsAdditionalField__c WHERE ASI_CRM_Account__c = \''+accountId+'\' LIMIT 1';  
        
        System.Debug(query);  
        if(Database.query(query) != null && Database.query(query).size() > 0)
            return Database.query(query);    
        
        return null;
    
    }        
   
    public PageReference save() {
        //Remarked by William Yang(Introv) to allow editing Rejected Outlets, disallow editing Pending for Approval Outlets
        if(!Test.isRunningTest() && accountAdditionalField.ASI_CRM_Approval_Status__c == 'Pending for Approval') {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'Cannot edit Outlet when it is Pending for Approval!');
            ApexPages.addMessage(msg); 
            return null;
        }
        
        if (IsOutlet && (accountAdditionalField.ASI_CRM_City__c == null || accountAdditionalField.ASI_CRM_Town__c == null || 
                         accountAdditionalField.ASI_CRM_TW_Street__c == null))
        {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'You have to enter values for City/Town/Street.');
            ApexPages.addMessage(msg); 
            return null;
        }
        if (IsOutlet && !whAddrSamesAs && !Test.isRunningTest() && (accountAdditionalField.ASI_CRM_TW_Warehouse_City__c == null || accountAdditionalField.ASI_CRM_TW_Warehouse_Town__c == null || 
                         accountAdditionalField.ASI_CRM_TW_Warehouse_Street__c == null)) 
        {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'You have to enter values for Warehouse City/Town/Street.');
            ApexPages.addMessage(msg); 
            return null;
        }

        
        
        if (accountAdditionalField.ASI_CRM_TW_Parent_Account__c != null && accountAdditionalField.ASI_CRM_IsParentAccount__c == true){
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'This Account is Parent Account. Cannot assign Parent Account to it.');
            ApexPages.addMessage(msg); 
            return null;
        }
        
        Account account = (Account)standardController.getRecord();      
        RecordType recordType = [SELECT DeveloperName, id FROM RecordType WHERE DeveloperName = 'ASI_CRM_TW_Outlet' AND SobjectType = 'Account'];
        
        List<Account> accList;
        if (account.id == null)
            accList = [SELECT id, Name FROM Account WHERE Name = :accountAdditionalField.Name AND ASI_TH_CRM_Region__c = :accountAdditionalField.ASI_CRM_Region__c
                AND RecordTypeid = :recordType.id];
        else
            accList = [SELECT id, Name FROM Account WHERE Name = :accountAdditionalField.Name AND id <> :account.id AND ASI_TH_CRM_Region__c = :accountAdditionalField.ASI_CRM_Region__c 
                AND RecordTypeid = :recordType.id];
        
        if (accList.size() > 0 ){
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'Duplicate Outlet Name \'' + accountAdditionalField.Name + '\' was found!');
            ApexPages.addMessage(msg); 
            return null;
        }
        
        account.Name = accountAdditionalField.Name;

        account.ASI_KOR_SYS_NeedRefreshGeolocation__c = true;
                    
        upsert(standardController.getRecord()); 
        
        if (accountAdditionalField.ASI_CRM_Account__c == null) {
            accountAdditionalField.ASI_CRM_Account__c = standardController.getRecord().id;                
             
            recordType = [SELECT DeveloperName, id FROM RecordType 
                WHERE DeveloperName = 'ASI_CRM_TW_Outlet' AND SobjectType = 'ASI_CRM_AccountsAdditionalField__c'];
            System.debug('recordType.id' + recordType.id);
            accountAdditionalField.RecordTypeId = recordType.id;                                                 
        }
        accountAdditionalField.ASI_TH_CRM_OutletType__c = selectedOutletTypeId;
                                  
        upsert(accountAdditionalField);
        
        PageReference ReturnPage = new PageReference('/' + standardController.getRecord().id);
        ReturnPage.setRedirect(true); 
        return ReturnPage;
    }

    public void updateWarehouseAddress() // Howard accountAdditionalField.ASI_CRM_TW_Warehouse_City__c = accountAdditionalField.ASI_CRM_City__c == null ? '':accountAdditionalField.ASI_CRM_City__c;
    {
        if(whAddrSamesAs){
            accountAdditionalField.ASI_CRM_TW_Warehouse_City__c = accountAdditionalField.ASI_CRM_City__c == null? '' : accountAdditionalField.ASI_CRM_City__c;
            accountAdditionalField.ASI_CRM_TW_Warehouse_Town__c = accountAdditionalField.ASI_CRM_Town__c == null? '' : accountAdditionalField.ASI_CRM_Town__c;
            accountAdditionalField.ASI_CRM_TW_Warehouse_Street__c = accountAdditionalField.ASI_CRM_TW_Street__c == null ? '' : accountAdditionalField.ASI_CRM_TW_Street__c;
            accountAdditionalField.ASI_CRM_TW_Warehouse_Section__c = accountAdditionalField.ASI_CRM_TW_Section__c == null ? '' : accountAdditionalField.ASI_CRM_TW_Section__c;
            accountAdditionalField.ASI_CRM_TW_Warehouse_Lane__c = accountAdditionalField.ASI_CRM_TW_Lane__c == null ? '' : accountAdditionalField.ASI_CRM_TW_Lane__c;
            accountAdditionalField.ASI_CRM_TW_Warehouse_Alley__c = accountAdditionalField.ASI_CRM_TW_Alley__c == null ? '' : accountAdditionalField.ASI_CRM_TW_Alley__c;
            accountAdditionalField.ASI_CRM_TW_Warehouse_Number__c = accountAdditionalField.ASI_CRM_TW_Number__c == null ? '' : accountAdditionalField.ASI_CRM_TW_Number__c;
            accountAdditionalField.ASI_CRM_TW_Warehouse_Number_Hyphen__c = accountAdditionalField.ASI_CRM_TW_Number_Hyphen__c == null ? '' : accountAdditionalField.ASI_CRM_TW_Number_Hyphen__c;
            accountAdditionalField.ASI_CRM_TW_Warehouse_Floor__c = accountAdditionalField.ASI_CRM_TW_Floor__c == null ? '' : accountAdditionalField.ASI_CRM_TW_Floor__c;
            accountAdditionalField.ASI_CRM_TW_Warehouse_Hyphen__c = accountAdditionalField.ASI_CRM_TW_Hyphen__c == null ? '' : accountAdditionalField.ASI_CRM_TW_Hyphen__c;
            accountAdditionalField.ASI_CRM_TW_Warehouse_Suite__c = accountAdditionalField.ASI_CRM_TW_Suite__c == null ? '' : accountAdditionalField.ASI_CRM_TW_Suite__c;
        }
        else{
            accountAdditionalField.ASI_CRM_TW_Warehouse_City__c = null;
            accountAdditionalField.ASI_CRM_TW_Warehouse_Town__c = null;
            accountAdditionalField.ASI_CRM_TW_Warehouse_Street__c = null;
            accountAdditionalField.ASI_CRM_TW_Warehouse_Section__c = null;
            accountAdditionalField.ASI_CRM_TW_Warehouse_Lane__c = null;
            accountAdditionalField.ASI_CRM_TW_Warehouse_Alley__c = null;
            accountAdditionalField.ASI_CRM_TW_Warehouse_Number__c = null;
            accountAdditionalField.ASI_CRM_TW_Warehouse_Number_Hyphen__c = null;
            accountAdditionalField.ASI_CRM_TW_Warehouse_Floor__c = null;
            accountAdditionalField.ASI_CRM_TW_Warehouse_Hyphen__c = null;
            accountAdditionalField.ASI_CRM_TW_Warehouse_Suite__c = null;
        }
    }

    public void updateInvoiceAddress()
    {
        if(invAddrSamesAs){
            accountAdditionalField.ASI_CRM_TW_Invoice_City__c = accountAdditionalField.ASI_CRM_City__c == null? '' : accountAdditionalField.ASI_CRM_City__c;
            accountAdditionalField.ASI_CRM_TW_Invoice_Town__c = accountAdditionalField.ASI_CRM_Town__c == null? '' : accountAdditionalField.ASI_CRM_Town__c;
            accountAdditionalField.ASI_CRM_TW_Invoice_Street__c = accountAdditionalField.ASI_CRM_TW_Street__c == null? '' : accountAdditionalField.ASI_CRM_TW_Street__c;
            accountAdditionalField.ASI_CRM_TW_Invoice_Section__c = accountAdditionalField.ASI_CRM_TW_Section__c == null? '' : accountAdditionalField.ASI_CRM_TW_Section__c;
            accountAdditionalField.ASI_CRM_TW_Invoice_Lane__c = accountAdditionalField.ASI_CRM_TW_Lane__c == null? '' : accountAdditionalField.ASI_CRM_TW_Lane__c;
            accountAdditionalField.ASI_CRM_TW_Invoice_Alley__c = accountAdditionalField.ASI_CRM_TW_Alley__c == null? '' : accountAdditionalField.ASI_CRM_TW_Alley__c;
            accountAdditionalField.ASI_CRM_TW_Invoice_Number__c = accountAdditionalField.ASI_CRM_TW_Number__c == null? '' : accountAdditionalField.ASI_CRM_TW_Number__c;
            accountAdditionalField.ASI_CRM_TW_Invoice_Number_Hyphen__c = accountAdditionalField.ASI_CRM_TW_Number_Hyphen__c == null? '' : accountAdditionalField.ASI_CRM_TW_Number_Hyphen__c;
            accountAdditionalField.ASI_CRM_TW_Invoice_Floor__c = accountAdditionalField.ASI_CRM_TW_Floor__c == null? '' : accountAdditionalField.ASI_CRM_TW_Floor__c;
            accountAdditionalField.ASI_CRM_TW_Invoice_Hyphen__c = accountAdditionalField.ASI_CRM_TW_Hyphen__c == null? '' : accountAdditionalField.ASI_CRM_TW_Hyphen__c;
            accountAdditionalField.ASI_CRM_TW_Invoice_Suite__c = accountAdditionalField.ASI_CRM_TW_Suite__c == null? '' : accountAdditionalField.ASI_CRM_TW_Suite__c;
        }
        else{
            accountAdditionalField.ASI_CRM_TW_Invoice_City__c = null;
            accountAdditionalField.ASI_CRM_TW_Invoice_Town__c = null;
            accountAdditionalField.ASI_CRM_TW_Invoice_Street__c = null;
            accountAdditionalField.ASI_CRM_TW_Invoice_Section__c = null;
            accountAdditionalField.ASI_CRM_TW_Invoice_Lane__c = null;
            accountAdditionalField.ASI_CRM_TW_Invoice_Alley__c = null;
            accountAdditionalField.ASI_CRM_TW_Invoice_Number__c = null;
            accountAdditionalField.ASI_CRM_TW_Invoice_Number_Hyphen__c = null;
            accountAdditionalField.ASI_CRM_TW_Invoice_Floor__c = null;
            accountAdditionalField.ASI_CRM_TW_Invoice_Hyphen__c = null;
            accountAdditionalField.ASI_CRM_TW_Invoice_Suite__c = null;
        }
    }
}