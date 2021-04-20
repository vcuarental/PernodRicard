@isTest
public class EUR_CRM_FI_TestContractAccountMapHandler{
    
    static User eurSysUser;
    static EUR_CRM_Size__c bqs;
    static void setUser(){

        User thisUser = [ SELECT Id,BypassTriggers__c FROM User WHERE Id = :UserInfo.getUserId() ];
        String bypass = ''+thisUser.BypassTriggers__c;
        
        thisUser.BypassTriggers__c = 'Autofollow_User_InsertUpdate,AutoJoin_User_InsertUpdate,ESN_User_AutojoinByAffiliates,ChatterEmailSettings';
        Update thisUser;

        Profile p = [SELECT Id FROM Profile WHERE Name ='EUR System Admin']; 
        UserRole r = [select id from UserRole where Developername ='EMEA'];
        eurSysUser = new User(Alias = 'standt', Email='userEmail1234aoke@test.com', userroleid=r.id,
        EmailEncodingKey='UTF-8', LastName='userEmail1234aokelastName', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='userEmail1234aoke@test.com');
        insert eurSysUser;
    }

    /**
       EUR_CRM_FI_ContractAccountMapHandler
    */
    static testMethod  void tesContractAccountMapHandler(){
        setUser();
        System.runAs(eurSysUser){
            //create eu account, contact, contract
            Id fiOnAccountRecordTypeId = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Account__c' ,'EUR_FI_Direct_On_Trade');
            Id fiOnContactRecordTypeId = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('Contact' ,'EUR_Contact_FI');         
            Id fiOnContractRecordTypeId = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Contract__c' ,'EUR_FI_Chain_Contract');
         
            EUR_CRM_Account__c headOffice = new EUR_CRM_Account__c(recordtypeid = fiOnAccountRecordTypeId,
            name = 'test', EUR_CRM_Business_Type__c ='Head Office');
            insert headOffice ;
           // Contact contact = new Contact (EUR_CRM_Account__c = headOffice.id, recordtypeid = fiOnContactRecordTypeId, lastname='test');
         //   insert contact;;
         Test.startTest();           
            // START TEST --- 
            EUR_CRM_Account__c outlet = new EUR_CRM_Account__c(recordtypeid = fiOnAccountRecordTypeId,
            name = 'test', EUR_CRM_Parent_Account__c = headOffice.id);
            insert outlet;      
            EUR_CRM_Contract__c contract = new EUR_CRM_Contract__c(
                 recordtypeid = fiOnContractRecordTypeId,
                 EUR_CRM_Account__c = headOffice.id,
           //      EUR_CRM_Contact__c = contact.id,
                 EUR_CRM_Start_Date__c = System.today(),
                 EUR_CRM_End_Date__c = System.today(),
                 EUR_CRM_Status__c = 'Draft'
            );
            insert contract;
            contract = [select id, EUR_CRM_Status__c , EUR_CRM_Include_VAT__c,EUR_CRM_Contact__c,EUR_CRM_Account__c,EUR_CRM_Account__r.ownerid ,EUR_CRM_Is_this_contract_material__c,EUR_CRM_Is_this_contract_profitable__c,RecordType.developername,EUR_CRM_Country_Code__c
                             from  EUR_CRM_Contract__c where id=:contract.id];
         
            contract.EUR_CRM_Status__c = 'Activated';
            update contract;
            
            List<EUR_CRM_Contract_Account_Mapping__c> mapping = [select id from EUR_CRM_Contract_Account_Mapping__c where
            EUR_CRM_Account__c =: outlet.id and EUR_CRM_Contract__c =: contract.id];
            system.assert(mapping != null && mapping.size() == 1);
            Test.stopTest();           
            // STOP TEST ---
        }
    }
    /**
        EUR_CRM_FI_ContractAccountHandler
    */
    static testMethod  void testContractAccountHandler(){
        setUser();
        System.runAs(eurSysUser){
            //create eu account, contact, contract
            Id fiOnAccountRecordTypeId = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Account__c' ,'EUR_FI_Direct_On_Trade');
            Id fiOnContactRecordTypeId = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('Contact' ,'EUR_Contact_FI');         
            Id fiOnContractRecordTypeId = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Contract__c' ,'EUR_FI_Chain_Contract');
         
            EUR_CRM_Account__c headOffice = new EUR_CRM_Account__c(recordtypeid = fiOnAccountRecordTypeId,
            name = 'test', EUR_CRM_Business_Type__c ='Head Office');
            insert headOffice ;
           // Contact contact = new Contact (EUR_CRM_Account__c = headOffice.id, recordtypeid = fiOnContactRecordTypeId, lastname='test');
         //   insert contact;;
         Test.startTest();           
            // START TEST ---     
            EUR_CRM_Contract__c contract = new EUR_CRM_Contract__c(
                 recordtypeid = fiOnContractRecordTypeId,
                 EUR_CRM_Account__c = headOffice.id,
           //      EUR_CRM_Contact__c = contact.id,
                 EUR_CRM_Start_Date__c = System.today(),
                 EUR_CRM_End_Date__c = System.today(),
                 EUR_CRM_Status__c = 'Draft'
            );
            insert contract;
            contract = [select id, EUR_CRM_Status__c , EUR_CRM_Include_VAT__c,EUR_CRM_Contact__c,EUR_CRM_Account__c,EUR_CRM_Account__r.ownerid ,EUR_CRM_Is_this_contract_material__c,EUR_CRM_Is_this_contract_profitable__c,RecordType.developername,EUR_CRM_Country_Code__c
                             from  EUR_CRM_Contract__c where id=:contract.id];
        }
    }

    static testMethod void testContractAccountActivatedHandler() {
        setUser();
        System.runAs(eurSysUser){
            //create eu account, contact, contract
            Id fiOnAccountRecordTypeId = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Account__c' ,'EUR_FI_Direct_On_Trade');
            Id fiOnContactRecordTypeId = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('Contact' ,'EUR_Contact_FI');         
            Id fiOnContractRecordTypeId = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Contract__c' ,'EUR_FI_Chain_Contract');
         
            EUR_CRM_Account__c headOffice = new EUR_CRM_Account__c(recordtypeid = fiOnAccountRecordTypeId,
            name = 'test', EUR_CRM_Business_Type__c ='Head Office');
            insert headOffice ;

        Test.startTest();  
            EUR_CRM_Contract__c contract = new EUR_CRM_Contract__c(
                 recordtypeid = fiOnContractRecordTypeId,
                 EUR_CRM_Account__c = headOffice.id,
                 EUR_CRM_Start_Date__c = System.today(),
                 EUR_CRM_End_Date__c = System.today(),
                 EUR_CRM_Status__c = 'Activated'
            );

            insert contract;
            contract = [select id, EUR_CRM_Status__c , EUR_CRM_Include_VAT__c,EUR_CRM_Contact__c,EUR_CRM_Account__c,EUR_CRM_Account__r.ownerid ,EUR_CRM_Is_this_contract_material__c,EUR_CRM_Is_this_contract_profitable__c,RecordType.developername,EUR_CRM_Country_Code__c
                             from  EUR_CRM_Contract__c where id=:contract.id];
         
            EUR_CRM_Account__c outlet = new EUR_CRM_Account__c(recordtypeid = fiOnAccountRecordTypeId,
            name = 'test', EUR_CRM_Parent_Account__c = headOffice.id, EUR_CRM_Business_Type__c ='Outlet');
            insert outlet;  
            
            List<EUR_CRM_Contract_Account_Mapping__c> mapping = [select id from EUR_CRM_Contract_Account_Mapping__c where
            EUR_CRM_Account__c =: outlet.id and EUR_CRM_Contract__c =: contract.id];
            system.assert(mapping != null && mapping.size() == 1);
            outlet.EUR_CRM_Parent_Account__c = null;
            update outlet;

        Test.stopTest();

        }
    }
}