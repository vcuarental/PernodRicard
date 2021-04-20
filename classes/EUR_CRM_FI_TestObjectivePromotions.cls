@isTest
public class EUR_CRM_FI_TestObjectivePromotions {
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
    EUR_CRM_FI_OPTargetMgmtController
    EUR_CRM_FI_ObjectivePromoHandler
    */
    static testMethod  void testOPManagement(){
        setUser();
        System.runAs(eurSysUser){
            Id fiOnAccountRecordTypeId = [select id from RecordType where sobjecttype='eur_crm_account__C' and developername ='EUR_FI_Direct_On_Trade'].id;
            Id fiOnObjPromoRecordTypeId = [select id from RecordType where sobjecttype='EUR_CRM_ObjPromo__c' and developername ='EUR_FI_On_Trade_O_P'].id;
            
            Id bqsRecordTypeId= EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Size__c','EUR_FI_Size');
            bqs = new EUR_CRM_Size__c(recordtypeid=bqsRecordTypeId,name = 'testBQS');
            insert bqs;
            
            EUR_CRM_ObjPromo__c op = new EUR_CRM_ObjPromo__c(
                recordtypeid = fiOnObjPromoRecordTypeId,
                name = 'test op',
                EUR_CRM_Active_End_Date__c = system.today(),
                EUR_CRM_Active_Start_Date__c = system.today(),
                EUR_CRM_Status__c = 'Draft'
            );
            insert op;
            Test.startTest();           
            // START TEST ---
            
            PageReference aPage = Page.EUR_CRM_FI_OPTargetMgmtPage;
            test.setCurrentPage(aPage);
            
            ApexPages.StandardController sc = new ApexPages.StandardController(op);
            EUR_CRM_FI_OPTargetMgmtController con = new EUR_CRM_FI_OPTargetMgmtController(sc);
                op.EUR_CRM_Product_Hierarchy_Level__c = 'BQS';
                op.EUR_CRM_O_P_Type__c = 'Type 2';
                op.EUR_CRM_Account_Selection_Type__c = 'Customer Taxonomy';
             con.saveOPAttribute();
             con.saveOPAttributeContinue();
             aPage.getParameters().put('p1',bqs.id);
             con.getDisableStep2();
             con.getDisableStep3();
             con.getActiveTab();
             con.add();
             aPage.getParameters().put('rowIndex','1');
             con.removeProduct();
             con.add();
             EUR_CRM_ObjPromo_Target__c target = con.objectiveCommitmentTarget.get(0);
             target.EUR_CRM_Visit_Targets__c = 0;
             con.quickSave();
             con.getSalesRepCommitmentTargets();
             con.quickSaveSRTargets();
             con.getSRTargetWraps();
             
             con.resetOPSelectionValues();
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
                 EUR_CRM_O_P_Target__c = opTargetObjCommitement.id
             );
             insert opTargetSRCommitement;
             EUR_CRM_ObjPromo_Target__c opTargetObjVolume = new EUR_CRM_ObjPromo_Target__c(
                 recordTypeId = opTargetObjVolumeRecordTypeId,
                 EUR_CRM_ObjPromo__c = op.id
             );
             insert opTargetObjVolume ;
             EUR_CRM_ObjPromo_Target__c opTargetSRVolume = new EUR_CRM_ObjPromo_Target__c(
                 recordTypeId = opTargetSRVolumeRecordTypeId,
                 EUR_CRM_ObjPromo__c = op.id,
                 EUR_CRM_O_P_Target__c = opTargetObjVolume.id
             );
             insert opTargetSRVolume;
             
             sc = new ApexPages.StandardController(op);
             con = new EUR_CRM_FI_OPTargetMgmtController(sc);
             
             
             con.save();
             con.getObjCommitmentTarget();
             List<EUR_CRM_ObjPromo_to_PROS_Segment_Mapping__c> p=  con.prosSegments;
             List<EUR_CRM_ObjPromo_Target__c> o = con.objectiveVolumeTargets;
             
             op.EUR_CRM_Product_Hierarchy_Level__c = 'BQ';
             con.initProductLevel();
             op.EUR_CRM_Product_Hierarchy_Level__c = 'SKU';
             con.initProductLevel();
             con.deleteSRCommitmentTargets();
             con.deleteAllTargets();
            // STOP TEST ---            
            Test.stopTest();
        }
    }
    /**
    
    EUR_CRM_FI_ObjectivePromoPageController
    */
    static testMethod  void testOPSummaryController(){
        setUser();
        System.runAs(eurSysUser){
            Id fiOnAccountRecordTypeId = [select id from RecordType where sobjecttype='eur_crm_account__C' and developername ='EUR_FI_Direct_On_Trade'].id;
            Id fiOnObjPromoRecordTypeId = [select id from RecordType where sobjecttype='EUR_CRM_ObjPromo__c' and developername ='EUR_FI_On_Trade_O_P'].id;
            
            Id bqsRecordTypeId= EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Size__c','EUR_FI_Size');
            bqs = new EUR_CRM_Size__c(recordtypeid=bqsRecordTypeId,name = 'testBQS');
            insert bqs;
            
            EUR_CRM_ObjPromo__c op = new EUR_CRM_ObjPromo__c(
                recordtypeid = fiOnObjPromoRecordTypeId,
                name = 'test op',
                EUR_CRM_Active_End_Date__c = system.today(),
                EUR_CRM_Active_Start_Date__c = system.today(),
                EUR_CRM_Status__c = 'Draft'
            );
            insert op;
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
                 EUR_CRM_O_P_Target__c = opTargetObjCommitement.id
             );
             insert opTargetSRCommitement;
             EUR_CRM_ObjPromo_Target__c opTargetObjVolume = new EUR_CRM_ObjPromo_Target__c(
                 recordTypeId = opTargetObjVolumeRecordTypeId,
                 EUR_CRM_ObjPromo__c = op.id
             );
             insert opTargetObjVolume ;
             EUR_CRM_ObjPromo_Target__c opTargetSRVolume = new EUR_CRM_ObjPromo_Target__c(
                 recordTypeId = opTargetSRVolumeRecordTypeId,
                 EUR_CRM_ObjPromo__c = op.id,
                 EUR_CRM_O_P_Target__c = opTargetObjVolume.id
             );
             insert opTargetSRVolume;
            Test.startTest();           
            // START TEST --- 
            
            ApexPages.StandardController sc = new ApexPages.StandardController(op);
            EUR_CRM_FI_ObjectivePromoPageController con = new EUR_CRM_FI_ObjectivePromoPageController(sc);
                op.EUR_CRM_Product_Hierarchy_Level__c = 'BQS';
                op.EUR_CRM_O_P_Type__c = 'Type 2';
                op.EUR_CRM_Account_Selection_Type__c = 'Customer Taxonomy';
             con.getActions(); 
             List<EUR_CRM_FI_ObjectivePromoPageController.TargetWrapper> targetWraps = con.targetWraps;
            // STOP TEST ---            
            Test.stopTest();
        }
    }


}