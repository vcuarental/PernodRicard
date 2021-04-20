@isTest
public class EUR_CRM_FI_TestPublishObjectivePageCtrl {
    static User eurSysUser;
    static EUR_CRM_Size__c bqs;
    static void setUser(){
        Profile p = [SELECT Id FROM Profile WHERE Name ='EUR System Admin']; 
        UserRole r = [select id from UserRole where Developername ='EMEA'];
        eurSysUser = new User(Alias = 'standt', Email='userEmail1234aoke@test.com', userroleid=r.id,
        EmailEncodingKey='UTF-8', LastName='userEmail1234aokelastName', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='userEmail1234aoke@test.com');
        insert eurSysUser;
    }
    
    /**
       EUR_CRM_FI_PublishObjectivePageCtrl
    */
    static testMethod  void testPublishObjectivePageCtrl(){
        setUser();
        System.runAs(eurSysUser){
            Id fiOnAccountRecordTypeId = [select id from RecordType where sobjecttype='eur_crm_account__C' and developername ='EUR_FI_Direct_On_Trade'].id;
            Id fiOnObjPromoRecordTypeId = [select id from RecordType where sobjecttype='EUR_CRM_ObjPromo__c' and developername ='EUR_FI_On_Trade_O_P'].id;
            Id fiCustomerTaxonomyRecordTypeId= EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Customer_Taxonomy__c','EUR_FI_ON_Trade_Customer_Taxonomy');
            
            Id bqsRecordTypeId= EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Size__c','EUR_FI_Size');
            
            EUR_CRM_Customer_Taxonomy__c custTax= new EUR_CRM_Customer_Taxonomy__c(recordtypeid = fiCustomerTaxonomyRecordTypeId,
            name = 'test');
            insert custTax;
            EUR_CRM_Account__c account = new EUR_CRM_Account__c(recordtypeid = fiOnAccountRecordTypeId,
            name = 'test',
            EUR_JB_Customer_Taxonomy__c = custTax.id);
            insert account;
            bqs = new EUR_CRM_Size__c(recordtypeid=bqsRecordTypeId,name = 'testBQS');
            insert bqs;
            EUR_CRM_ObjPromo__c op = new EUR_CRM_ObjPromo__c(
                recordtypeid = fiOnObjPromoRecordTypeId,
                name = 'test op',
                EUR_CRM_Active_End_Date__c = system.today(),
                EUR_CRM_Active_Start_Date__c = system.today(),
                EUR_CRM_Status__c = 'Draft',
                eur_crm_product_hierarchy_Level__c = 'BQS',
                EUR_CRM_O_P_Type__c= 'Type 2',
                EUR_CRM_Account_Selection_Type__c = 'Customer Taxonomy'
            );
            insert op;
            EUR_CRM_OP_Customer_Taxonomy_Mapping__c mapping = new EUR_CRM_OP_Customer_Taxonomy_Mapping__c(
                EUR_CRM_Customer_Taxonomy__c = custTax.id,
                EUR_CRM_ObjPromo__c = op.id
            );
            
            insert mapping;
             //set targets 
             Id opTargetObjCommitementRecordTypeId= EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_ObjPromo_Target__c','EUR_CRM_Objective_Commitment_Target');
             Id opTargetObjVolumeRecordTypeId= EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_ObjPromo_Target__c','EUR_CRM_Objective_Volume_Target');
             Id opTargetSRCommitementRecordTypeId= EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_ObjPromo_Target__c','EUR_CRM_SR_Commitment_Target');
             Id opTargetSRVolumeRecordTypeId= EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_ObjPromo_Target__c','EUR_CRM_SR_Volume_Target');
             
             EUR_CRM_ObjPromo_Target__c opTargetObjCommitement = new EUR_CRM_ObjPromo_Target__c(
                 recordTypeId = opTargetObjCommitementRecordTypeId,
                 EUR_CRM_ObjPromo__c = op.id,
                 EUR_CRM_Is_Quota__c = true
             );
             insert opTargetObjCommitement;
             EUR_CRM_ObjPromo_Target__c opTargetSRCommitement= new EUR_CRM_ObjPromo_Target__c(
                 recordTypeId = opTargetSRCommitementRecordTypeId,
                 EUR_CRM_ObjPromo__c = op.id,
                 EUR_CRM_O_P_Target__c = opTargetObjCommitement.id,
                 EUR_CRM_Target_Owner__c = UserInfo.getUserId()

             );
             insert opTargetSRCommitement;
             EUR_CRM_ObjPromo_Target__c opTargetObjVolume = new EUR_CRM_ObjPromo_Target__c(
                 recordTypeId = opTargetObjVolumeRecordTypeId,
                 EUR_CRM_ObjPromo__c = op.id,
                 EUR_CRM_BQS__c = bqs.id
             );
             insert opTargetObjVolume ;
             EUR_CRM_ObjPromo_Target__c opTargetSRVolume = new EUR_CRM_ObjPromo_Target__c(
                 recordTypeId = opTargetSRVolumeRecordTypeId,
                 EUR_CRM_ObjPromo__c = op.id,
                 EUR_CRM_O_P_Target__c = opTargetObjVolume.id,
                 EUR_CRM_Target_Owner__c = UserInfo.getUserId(),
                 EUR_CRM_BQS__c = bqs.id
             );
             insert opTargetSRVolume;
            Test.startTest();           
            // START TEST ---
             
            
            ApexPages.StandardController sc = new ApexPages.StandardController(op);
            EUR_CRM_FI_PublishObjectivePageCtrl con = new EUR_CRM_FI_PublishObjectivePageCtrl(sc);              
              con.getWrapAccounts();       
              con.doNext();       
              con.doPrevious();       
              con.first();       
              con.last();  
              con.getHasPrevious();  
              con.getHasNext();  
              con.getTotalPages();   
              con.getPageSize();
              con.getRecordSize();
              con.doDeselectItem();
              con.getHasSelectedAccounts();
              con.selectAll();
              con.deSelectAll(); 
              con.doSelectItem(); 
              con.cancel();
              Integer pageNumber = con.pageNumber;
              con.getPageNumber();
              con.publish();
              con.sort();
              
            // STOP TEST ---            
            Test.stopTest();
        }
    } 
    
    
    /**
       EUR_CRM_FI_PublishObjectivePageCtrl
    */
    static testMethod  void testPublishObjectivePageCtrlPROS(){
        setUser();
        System.runAs(eurSysUser){
            Id fiOnAccountRecordTypeId = [select id from RecordType where sobjecttype='eur_crm_account__C' and developername ='EUR_FI_Direct_On_Trade'].id;
            Id fiOnObjPromoRecordTypeId = [select id from RecordType where sobjecttype='EUR_CRM_ObjPromo__c' and developername ='EUR_FI_On_Trade_O_P'].id;
            Id fiCustomerTaxonomyRecordTypeId= EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Customer_Taxonomy__c','EUR_FI_ON_Trade_Customer_Taxonomy');
            
            Id bqsRecordTypeId= EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Size__c','EUR_FI_Size');
            
            EUR_CRM_Customer_Taxonomy__c custTax= new EUR_CRM_Customer_Taxonomy__c(recordtypeid = fiCustomerTaxonomyRecordTypeId,
            name = 'test');
            insert custTax;
            EUR_CRM_Account__c account = new EUR_CRM_Account__c(recordtypeid = fiOnAccountRecordTypeId,
            name = 'test',
            EUR_JB_Customer_Taxonomy__c = custTax.id);
            insert account;
            bqs = new EUR_CRM_Size__c(recordtypeid=bqsRecordTypeId,name = 'testBQS');
            insert bqs;
            EUR_CRM_ObjPromo__c op = new EUR_CRM_ObjPromo__c(
                recordtypeid = fiOnObjPromoRecordTypeId,
                name = 'test op',
                EUR_CRM_Active_End_Date__c = system.today(),
                EUR_CRM_Active_Start_Date__c = system.today(),
                EUR_CRM_Status__c = 'Draft',
                eur_crm_product_hierarchy_Level__c = 'BQS',
                EUR_CRM_O_P_Type__c= 'Type 2',
                EUR_CRM_Account_Selection_Type__c = 'PROS'
            );
            insert op;
            EUR_CRM_OP_Customer_Taxonomy_Mapping__c mapping = new EUR_CRM_OP_Customer_Taxonomy_Mapping__c(
                EUR_CRM_Customer_Taxonomy__c = custTax.id,
                EUR_CRM_ObjPromo__c = op.id
            );
            
            insert mapping;
             //set targets 
             Id opTargetObjCommitementRecordTypeId= EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_ObjPromo_Target__c','EUR_CRM_Objective_Commitment_Target');
             Id opTargetObjVolumeRecordTypeId= EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_ObjPromo_Target__c','EUR_CRM_Objective_Volume_Target');
             Id opTargetSRCommitementRecordTypeId= EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_ObjPromo_Target__c','EUR_CRM_SR_Commitment_Target');
             Id opTargetSRVolumeRecordTypeId= EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_ObjPromo_Target__c','EUR_CRM_SR_Volume_Target');
             
             EUR_CRM_ObjPromo_Target__c opTargetObjCommitement = new EUR_CRM_ObjPromo_Target__c(
                 recordTypeId = opTargetObjCommitementRecordTypeId,
                 EUR_CRM_ObjPromo__c = op.id,
                 EUR_CRM_Is_Quota__c = true
             );
             insert opTargetObjCommitement;
             EUR_CRM_ObjPromo_Target__c opTargetSRCommitement= new EUR_CRM_ObjPromo_Target__c(
                 recordTypeId = opTargetSRCommitementRecordTypeId,
                 EUR_CRM_ObjPromo__c = op.id,
                 EUR_CRM_O_P_Target__c = opTargetObjCommitement.id,
                 EUR_CRM_Target_Owner__c = UserInfo.getUserId()

             );
             insert opTargetSRCommitement;
             EUR_CRM_ObjPromo_Target__c opTargetObjVolume = new EUR_CRM_ObjPromo_Target__c(
                 recordTypeId = opTargetObjVolumeRecordTypeId,
                 EUR_CRM_ObjPromo__c = op.id,
                 EUR_CRM_BQS__c = bqs.id
             );
             insert opTargetObjVolume ;
             EUR_CRM_ObjPromo_Target__c opTargetSRVolume = new EUR_CRM_ObjPromo_Target__c(
                 recordTypeId = opTargetSRVolumeRecordTypeId,
                 EUR_CRM_ObjPromo__c = op.id,
                 EUR_CRM_O_P_Target__c = opTargetObjVolume.id,
                 EUR_CRM_Target_Owner__c = UserInfo.getUserId(),
                 EUR_CRM_BQS__c = bqs.id
             );
             insert opTargetSRVolume;
            Test.startTest();           
            // START TEST ---
             
            
            ApexPages.StandardController sc = new ApexPages.StandardController(op);
            EUR_CRM_FI_PublishObjectivePageCtrl con = new EUR_CRM_FI_PublishObjectivePageCtrl(sc);              
              con.getWrapAccounts();        
              con.sort();
            // STOP TEST ---            
            Test.stopTest();
        }
    } 


}