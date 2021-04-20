public without sharing class ASI_TH_CRM_AccountEdit_Controller {  
    public ASI_CRM_AccountsAdditionalField__c accountAdditionalField {set;get;}
    public ApexPages.StandardController standardController;    
    public boolean IsOutlet {set;get;}
    public boolean IsPotentialOutlet {set;get;}
    public boolean IsModernTrade {set;get;}
    public boolean IsWholesaler {set;get;}
    // Added by Michael for CN CRM wholesales
    public boolean IsCNWholeSaler {set;get;}
    public Account account {set;get;}
    public RecordType accountRecordType {set;get;}
    
    public Set<Id> setOutletType {set;get;}
    public Map<Id, List<ASI_TH_CRM_OutletSubType__c>> mapOutletSubType {set;get;}
    
    public String selectedOutletTypeId {set;get;}
    public String selectedOutletSubTypeId {set;get;}
    public List<SelectOption> OutletSubTypeList {set;get;}
    public Map<String, Id> mapCustRecordType {set;get;}
    
    public List<SelectOption> OutletTypeList{
        get{
            List<SelectOption> outletTypeList = new List<SelectOption>(); 
            List<ASI_TH_CRM_OutletType__c> outletTypes = queryOutletTypeList();
             
            for(ASI_TH_CRM_OutletType__c outletType : outletTypes){
                setOutletType.add(outletType.id);
                outletTypeList.add(new SelectOption(outletType.id, outletType.Name));
            }
            return outletTypeList;
        }
    } 
    
    public List<ASI_TH_CRM_OutletType__c> queryOutletTypeList(){
        List<ASI_TH_CRM_OutletType__c> outletTypes = [SELECT id, Name FROM ASI_TH_CRM_OutletType__c WHERE RecordType.DeveloperName = 'ASI_TH_CRM_Outlet_Type' AND ASI_CRM_Active_for_PROS__c = TRUE ORDER BY ASI_TH_CRM_Code__c];            
        
        setOutletType = new Set<Id>();
        //selectedOutletTypeId = null;
        
        for(ASI_TH_CRM_OutletType__c outletType : outletTypes){
            if(selectedOutletTypeId == null)
                selectedOutletTypeId = outletType.id;
            setOutletType.add(outletType.id);
        }
        
        return outletTypes;
    }
    
    Public void getOutletSubTypeOptions(){ 
        system.debug('Enter');
        OutletSubTypeList = new List<SelectOption>();
        if(mapOutletSubType != null && mapOutletSubType.get(selectedOutletTypeId) != null){
            for(ASI_TH_CRM_OutletSubType__c sot : mapOutletSubType.get(selectedOutletTypeId)){
                OutletSubTypeList.add(new SelectOption(sot.id, sot.Name));
            }
        }
        system.debug('Get Outlet Sub-Type: '+selectedOutletTypeId+'-'+OutletSubTypeList);
    }
    
    public void queryOutletSubTypeList(){
        mapOutletSubType = new Map<Id, List<ASI_TH_CRM_OutletSubType__c>>();
        List<ASI_TH_CRM_OutletSubType__c> OutletSubTypes = [SELECT id, Name, ASI_TH_CRM_Outlet_Type__c FROM ASI_TH_CRM_OutletSubType__c WHERE RecordType.DeveloperName = 'ASI_TH_CRM_Outlet_Sub_type' AND ASI_TH_CRM_Outlet_Type__c IN : setOutletType ORDER BY Name];              
        
        for(ASI_TH_CRM_OutletSubType__c outletSubType : outletSubTypes){
            List<ASI_TH_CRM_OutletSubType__c> listTempOutletSubType = new List<ASI_TH_CRM_OutletSubType__c>();
            if(mapOutletSubType != null && mapOutletSubType.get(outletSubType.ASI_TH_CRM_Outlet_Type__c) != null){
                listTempOutletSubType = mapOutletSubType.get(outletSubType.ASI_TH_CRM_Outlet_Type__c);
                listTempOutletSubType.add(outletSubType);
            }
            else
                listTempOutletSubType.add(outletSubType);
            mapOutletSubType.put(outletSubType.ASI_TH_CRM_Outlet_Type__c, listTempOutletSubType);
        }
        getOutletSubTypeOptions();
    } 
    
    public ASI_TH_CRM_AccountEdit_Controller(ApexPages.StandardController controller) {
        standardController = controller;        
        account = (Account)controller.getRecord();
        IsPotentialOutlet = false;
        IsOutlet = false;
        IsWholesaler = false;
        IsModernTrade = false;
        accountAdditionalField = getAccountsAdditionalField_DynamiCSOQL(account.id);   
        
        //Added by Introv @20170731 to assign record type upon creation
        mapCustRecordType = new Map<String, Id>();
        mapCustRecordType.put('ASI_TH_CRM_Outlet', Global_RecordTypeCache.getRTId('ASI_CRM_AccountsAdditionalField__cASI_TH_CRM_Outlet'));
        mapCustRecordType.put('ASI_TH_CRM_Potential_Outlet', Global_RecordTypeCache.getRTId('ASI_CRM_AccountsAdditionalField__cASI_TH_CRM_Potential_Outlet'));
        mapCustRecordType.put('ASI_TH_CRM_Wholesaler', Global_RecordTypeCache.getRTId('ASI_CRM_AccountsAdditionalField__cASI_TH_CRM_Wholesaler'));
        mapCustRecordType.put('ASI_TH_CRM_Modern_Trade', Global_RecordTypeCache.getRTId('ASI_CRM_AccountsAdditionalField__cASI_TH_CRM_Modern_Trade'));
        System.debug('account.RecordTypeId = ' + account.RecordTypeId);
        //End - Added by Introv @20170731 to assign record type upon creation
        
        if (accountAdditionalField != null) {
            //Modified by Introv @20170731 for issue fixing
        	selectedOutletTypeId = accountAdditionalField.ASI_TH_CRM_OutletType__c;
        	selectedOutletSubTypeId = accountAdditionalField.ASI_TH_CRM_OutletSubType__c;
    	}
        else {
            accountAdditionalField = new ASI_CRM_AccountsAdditionalField__c();
            accountAdditionalField.ASI_CRM_Account__c = controller.getRecord().id;
            
            //Added by Introv @20170731 to assign record type upon creation
            if(mapCustRecordType != null && accountRecordType != null)
                accountAdditionalField.RecordTypeId = mapCustRecordType.get(accountRecordType.DeveloperName);
            else
                accountAdditionalField.RecordTypeId = mapCustRecordType.get('ASI_TH_CRM_Potential_Outlet');
            //End - Added by Introv @20170731 to assign record type upon creation    
        }
        
        if (account.RecordTypeId == null){
            IsPotentialOutlet = true;
            RecordType recordType = [SELECT DeveloperName, id FROM RecordType WHERE DeveloperName = 'ASI_TH_CRM_Potential_Outlet' AND SobjectType = 'Account'];

            account.RecordTypeId = recordType.id;
            accountRecordType = recordType;
        } else{
            accountRecordType = [SELECT DeveloperName, id FROM RecordType WHERE id = :account.RecordTypeId];
            
            if (accountRecordType.DeveloperName == 'ASI_TH_CRM_Outlet'){
                IsOutlet = true;
            }else if (accountRecordType.DeveloperName == 'ASI_TH_CRM_Potential_Outlet'){
                IsPotentialOutlet = true;
            }else if (accountRecordType.DeveloperName == 'ASI_TH_CRM_Modern_Trade'){
                IsModernTrade = true;        
            }else if (accountRecordType.DeveloperName == 'ASI_TH_CRM_Wholesaler'){
                IsWholesaler = true;
            }else if (accountRecordType.DeveloperName == 'ASI_CRM_CN_Wholesales_CN' || accountRecordType.DeveloperName == 'ASI_MFM_CN_Outlet'){
                IsCNWholeSaler = true;
            //Added by Christina@Laputa for SG Demo
            }else if (accountRecordType.DeveloperName == 'ASI_SG_CRM_Outlet'){
                IsOutlet = true;
            }else if (accountRecordType.DeveloperName == 'ASI_SG_CRM_Potential_Outlet'){
                IsPotentialOutlet = true;  
            }else if (accountRecordType.DeveloperName == 'ASI_SG_CRM_Wholesaler'){
                IsWholesaler = true;
            }
        }  
        
        queryOutletTypeList();
        queryOutletSubTypeList();                    
    }
           
    private ASI_CRM_AccountsAdditionalField__c getAccountsAdditionalField_DynamiCSOQL(String accountId) {
        try{    
            String query = 'SELECT ';    
            for(Schema.FieldSetMember f : SObjectType.ASI_CRM_AccountsAdditionalField__c.FieldSets.ASI_TH_CRM_OutletAdditionalField.getFields()) {    
                query += f.getFieldPath() + ', ';    
            } 
            for(Schema.FieldSetMember f : SObjectType.ASI_CRM_AccountsAdditionalField__c.FieldSets.ASI_CRM_CN_FieldSet.getFields()) {    
                query += f.getFieldPath() + ', ';    
            }       
            query += 'ASI_CRM_Trusted_Offtake_SIT__c, Id, Name, ASI_CRM_Account__c, ASI_CRM_AccountAdditionalField_EXID__c  FROM ASI_CRM_AccountsAdditionalField__c WHERE ASI_CRM_Account__c = \''+accountId+'\'';  
            
            System.Debug(query);  
            return Database.query(query);    
        }    
        catch(Exception e){    
            //Utility.addError('There is error while Fetching existing Question using Dynamic SOQL in Field Set. Error Detail - '+e.getMessage()); //This is Utility Method to display error message on VF Page    
        }    
        return null;    
    }  
    
    public PageReference save() {
        String customerCode = '';
        try {
            upsert(account);   
            if (accountAdditionalField.ASI_CRM_Account__c == null) {
                accountAdditionalField.ASI_CRM_Account__c = account.id;
                //RecordType recordType = [SELECT DeveloperName, id FROM RecordType WHERE DeveloperName = 'ASI_TH_CRM_Potential_Outlet' AND SobjectType = 'ASI_CRM_AccountsAdditionalField__c'];
                Id recordType = Global_RecordTypeCache.getRTId('ASI_CRM_AccountsAdditionalField__cASI_TH_CRM_Potential_Outlet');
                accountAdditionalField.RecordTypeId = recordType; 
            }
            
            /*
            //Added by Twinkle @20160614 - Assign record type to Customer based on Account's
            Map<String, Id> mapCustRecordType = new Map<String, Id>();
            mapCustRecordType.put('ASI_TH_CRM_Outlet', Global_RecordTypeCache.getRTId('ASI_CRM_AccountsAdditionalField__cASI_TH_CRM_Outlet'));
            mapCustRecordType.put('ASI_TH_CRM_Potential_Outlet', Global_RecordTypeCache.getRTId('ASI_CRM_AccountsAdditionalField__cASI_TH_CRM_Potential_Outlet'));
            mapCustRecordType.put('ASI_TH_CRM_Wholesaler', Global_RecordTypeCache.getRTId('ASI_CRM_AccountsAdditionalField__cASI_TH_CRM_Wholesaler'));
            mapCustRecordType.put('ASI_TH_CRM_Modern_Trade', Global_RecordTypeCache.getRTId('ASI_CRM_AccountsAdditionalField__cASI_TH_CRM_Modern_Trade'));
            
            accountRecordType = [SELECT DeveloperName, id FROM RecordType WHERE id = :account.RecordTypeId];
            if(mapCustRecordType != null && accountRecordType != null)
                accountAdditionalField.RecordTypeId = mapCustRecordType.get(accountRecordType.DeveloperName);
            //End by Twinkle @20160614 - Assign record type to Customer based on Account's
            */
            
            //Added by Twinkle @20160428 - update customer RSM
            Account acc = [SELECT Name, Owner.Manager.Name, ASI_KOR_Customer_Code__c  FROM Account WHERE id =: account.id];
            accountAdditionalField.ASI_CRM_RSM__c = acc.Owner.Manager.Name;    
        
            if(accountAdditionalField.ASI_CRM_CN_Type__c == null || accountAdditionalField.ASI_CRM_CN_Type__c == '')
                accountAdditionalField.ASI_CRM_CN_Type__c = 'Potential';
            //End by Twinkle @20160428
            
            
            //Added by William Yang @20160602
            if(IsPotentialOutlet && acc.ASI_KOR_Customer_Code__c != null && acc.ASI_KOR_Customer_Code__c != ''){
                customerCode = acc.ASI_KOR_Customer_Code__c.subString(3);   
                if(!acc.Name.contains(customerCode))
                    acc.Name = acc.Name + '(' + customerCode +')';                    
            }
            accountAdditionalField.Name = acc.Name;
            if(accountAdditionalField.ASI_CRM_AccountAdditionalField_EXID__c == null)
                accountAdditionalField.ASI_CRM_AccountAdditionalField_EXID__c = acc.ASI_KOR_Customer_Code__c;
            //End by William Yang @20160602
            
            accountAdditionalField.ASI_TH_CRM_OutletType__c = selectedOutletTypeId;
            accountAdditionalField.ASI_TH_CRM_OutletSubType__c = selectedOutletSubTypeId;
            
            upsert(acc);
            upsert(accountAdditionalField);
            system.debug('accountAdditionalField: '+accountAdditionalField);
            system.debug(accountAdditionalField.RecordTypeId);
        } catch(Exception e) {
            ApexPages.addMessages(e);
            return null;
        }
        
        //Added by Twinkle @20160519 - redirect user to Criteria Sheet if Customer Outlet Image is empty
        ASI_CRM_AccountsAdditionalField__c  queryCustomer = [SELECT recordtype.developerName, ASI_TH_CRM_OutletImage__c FROM ASI_CRM_AccountsAdditionalField__c WHERE id =:accountAdditionalField.id];
        PageReference ReturnPage;
        
        if(queryCustomer.ASI_TH_CRM_OutletImage__c == null && accountRecordType != null &&
          (accountRecordType.DeveloperName == 'ASI_TH_CRM_Outlet' || accountRecordType.DeveloperName == 'ASI_TH_CRM_Potential_Outlet')){
            ASI_CRM_Pros_Segmentation__c proSeg = [SELECT id FROM ASI_CRM_Pros_Segmentation__c WHERE ASI_CRM_SG_Account__c=:account.id];
            ReturnPage = new PageReference('/apex/ASI_CRM_TH_CriteriaSheet?id='+proSeg.id+'&type=1'); 
        }
        else
            ReturnPage = new PageReference('/' + standardController.getRecord().id);         
            
        ReturnPage.setRedirect(true); 
        return ReturnPage;
    }
}