/**

EUR_CRM_FI_AdminConsoleController
EUR_CRM_FI_CreateVisitActionFollowUps
EUR_CRM_FI_ScheduleVisitActionFollowUp
EUR_CRM_FI_AccrueAchievements
*/
@isTest
public class EUR_CRM_FI_TestOPVisitActions{
    
    private static EUR_CRM_OP_Action_List_Template__c makeActionListTemplate(String rtDevName, String externalId) {
        Id rtId = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_OP_Action_List_Template__c', rtDevName);
        return new EUR_CRM_OP_Action_List_Template__c(
            Name = 'Template Name',
            EUR_CRM_External_ID__c = externalId,
            RecordTypeId = rtId
        );
    }
        
    /**
        EUR_CRM_FI_AdminConsoleController
    */
    static testMethod  void testAdminConsoleContrller(){
        EUR_CRM_FI_AdminConsoleController con = new EUR_CRM_FI_AdminConsoleController();
        con.createFollowUp();
        con.accrue();
        con.refresh();        
        con.deactiveOPMappings();
        con.getSurveyHeaders(); 
        con.deactiveSurveys(); 
        
    }
    
    /**
        EUR_CRM_FI_CreateVisitActionFollowUps
    */
    static User eurSysUser;
    static User eurSalesRep;
    static EUR_CRM_Size__c bqs;
    static EUR_CRM_Quality__c bq;
    static void setUser(){
        Profile p = [SELECT Id FROM Profile WHERE Name ='EUR System Admin']; 
        UserRole r = [select id from UserRole where Developername ='EMEA'];
        eurSysUser = new User(Alias = 'standt', Email='userEmail1234aoke@test.com', userroleid=r.id,
        EmailEncodingKey='UTF-8', LastName='userEmail1234aokelastName', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='userEmail1234aoke@test.com');
        insert eurSysUser;
    }
    
    static void setSalesRep() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'EUR FI IT Admin User'];
        UserRole r = [SELECT Id FROM UserRole WHERE Developername = 'EUR_FI'];
        eurSalesRep = new User(Alias = 'eursr', Email='userEmail5678fi@test.com', userroleid=r.id,
        EmailEncodingKey='UTF-8', LastName='userEmail5678filastName', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='userEmail5678fi@test.com');
        insert eurSalesRep;
    }
    
    /**
        EUR_CRM_FI_CreateVisitActionFollowUps
    */
    static testMethod  void testCreateVisitActionFollowUps(){
        setUser();
        System.runAs(eurSysUser){ 
            Id fiOnAccountRecordTypeId = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Account__c','EUR_FI_Direct_On_Trade');
            Id visitActionAdhocRecordTypeId =  EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Visit_Action__c','EUR_CRM_FI_ON_Ad_Hoc_Activate_Toolkit');
            Id visitActionIndivRecordTypeId =  EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Visit_Action__c','FI_ON_Ad_Hoc_Create_Indiv_Account_OP');
            Id visitSubActionActionIndivRecordTypeId =  EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Visit_Sub_Action__c','FI_ON_Trade_Visit_Sub_Action_Adhoc_Create_Indiv_Account_OP_Add_BQ');
            Id productToolKitRecordTypeId =  EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Product_Toolkit__c','EUR_FI_Product_Toolkit');
            Id productToolKitItemRecordTypeId =  EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Product_Toolkit_Item__c','EUR_FI_Product_Toolkit_Item');
       
            Id bqRecordTypeId= EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Quality__c','EUR_FI_Quality');
            bq = new EUR_CRM_Quality__c(recordtypeid=bqRecordTypeId,name = 'testBQ');
            insert bq ;
            
            EUR_CRM_Account__c account = new EUR_CRM_Account__c(recordtypeid = fiOnAccountRecordTypeId ,
            name = 'test' );
            insert account; 
            
            
            EUR_CRM_Product_Toolkit__c productToolkit= new EUR_CRM_Product_Toolkit__c(
                 recordtypeid =   productToolKitRecordTypeId,
                 Name= 'test',
                 EUR_CRM_Is_Active__c = true
            );
            insert productToolkit;
            EUR_CRM_Product_Toolkit_Item__c productToolkitItem = new EUR_CRM_Product_Toolkit_Item__c(
                 recordtypeid =   productToolKitItemRecordTypeId , 
                 EUR_CRM_Product_Toolkit__c = productToolkit.id,
                 EUR_CRM_Brand_Quality__c = bq.id
            );
            insert productToolkitItem ;
            //create adhov visit Action.
            EUR_CRM_Visit_Action__c visitActionAdhoc = new EUR_CRM_Visit_Action__c(
                 recordtypeid =   visitActionAdhocRecordTypeId,
                 EUR_CRM_Account__c = account.id,
                 EUR_CRM_Product_Toolkit__c = productToolkit.id
                 );
                 insert visitActionAdhoc ;
            EUR_CRM_Visit_Action__c visitActionIndiv = new EUR_CRM_Visit_Action__c(
                 recordtypeid =   visitActionIndivRecordTypeId ,
                 EUR_CRM_Account__c = account.id 
                 );
                 insert visitActionIndiv ;
             
            EUR_CRM_Visit_Sub_Action__c visitSubAction= new EUR_CRM_Visit_Sub_Action__c(
                 recordtypeid =   visitSubActionActionIndivRecordTypeId , 
                 EUR_CRM_Visit_Action__c = visitActionIndiv.id,
                 EUR_CRM_Brand_Quality__c = bq.id
                 );
                 insert visitSubAction;
            
            visitActionAdhoc = [select id, recordType.developername, EUR_CRM_Visit_ID__c, EUR_CRM_Stage__c,EUR_CRM_Remarks__c,OwnerId, EUR_CRM_Activation_Start_Date__c,
                EUR_CRM_Stage_Sequence_Order__c,  EUR_CRM_Activation_End_Date__c,EUR_CRM_Account__c, EUR_CRM_Product_Toolkit__c, EUR_CRM_Active__c, EUR_CRM_End_Datetime__c 
                from EUR_CRM_Visit_Action__c where id =:visitActionAdhoc.id ];
            visitActionIndiv = [select id, recordType.developername, EUR_CRM_Indiv_Account_OP_Name__c, EUR_CRM_Visit_ID__c, EUR_CRM_Stage__c,EUR_CRM_Remarks__c,OwnerId, EUR_CRM_Activation_Start_Date__c,
                EUR_CRM_Stage_Sequence_Order__c,  EUR_CRM_Activation_End_Date__c,EUR_CRM_Account__c, EUR_CRM_Product_Toolkit__c, EUR_CRM_Active__c, EUR_CRM_End_Datetime__c 
                from EUR_CRM_Visit_Action__c where id =:visitActionIndiv.id ];
             
            
            List<EUR_CRM_Visit_Action__c> visitActions = new List<EUR_CRM_Visit_Action__c>();
            visitActions.add(visitActionAdhoc);
            visitActions.add(visitActionIndiv );
            EUR_CRM_FI_CreateVisitActionFollowUps.createFollowUps(visitActions );
            
            List<EUR_CRM_Visit_Sub_Action__c> newVisitSubActions = [select id from EUR_CRM_Visit_Sub_Action__c where recordtype.developername = 'FI_ON_Trade_Visit_Sub_Action_Adhoc_Create_Indiv_Account_OP_Follow_Up_BQ_Vol' and EUR_CRM_Brand_Quality__c =: bq.id];
             List<EUR_CRM_Visit_Action__c> newVisitAdhoc = [select id from EUR_CRM_Visit_Action__c where recordtype.developername = 'EUR_CRM_FI_ON_Ad_Hoc_Activate_Toolkit_Follow_Up' ];
             List<EUR_CRM_Visit_Action__c> newVisitIndiv= [select id from EUR_CRM_Visit_Action__c where recordtype.developername = 'FI_ON_Ad_Hoc_Create_Indiv_Account_OP_Follow_Up' ];
            
            
            system.assert(newVisitSubActions != null && newVisitSubActions.size() == 1);
            system.assert(newVisitAdhoc != null && newVisitAdhoc.size() == 1);
            system.assert(newVisitIndiv!= null && newVisitIndiv.size() == 1);
        }
    }
    
    /**
    *   testMethod: testAccrueAchievementsMultipleSR
    *   test accruing multiple visit actions belonging to an OP from different SR
    *
    */
    static testMethod void testAccrueAchievementsMultipleSR() {
        setUser();
        setSalesRep();
        System.runAs(eurSysUser){ 
            Id fiOnAccountRecordTypeId = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Account__c','EUR_FI_Direct_On_Trade');
            Id bqRecordTypeId= EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Quality__c','EUR_FI_Quality');
            Id fiOnObjPromoRecordTypeId = [select id from RecordType where sobjecttype='EUR_CRM_ObjPromo__c' and developername ='EUR_FI_On_Trade_O_P'].id;
              
            Id opTargetObjCommitmentRecordTypeId= EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_ObjPromo_Target__c','EUR_CRM_Objective_Commitment_Target');
            Id opTargetSRCommitmentRecordTypeId= EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_ObjPromo_Target__c','EUR_CRM_SR_Commitment_Target');
          
            //Id visitActionConfirmParticipationRecordTypeId =  EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Visit_Action__c','EUR_FI_Confirm_Participation');
            RecordType visitActionConfirmParticipationRecordType = [SELECT Id, DeveloperName FROM RecordType WHERE sObjectType = 'EUR_CRM_Visit_Action__c' and Developername = 'EUR_FI_Confirm_Participation'];
            
            bq = new EUR_CRM_Quality__c(recordtypeid=bqRecordTypeId,name = 'testBQ');
            insert bq ;
            
            EUR_CRM_Account__c account = new EUR_CRM_Account__c(recordtypeid = fiOnAccountRecordTypeId ,
                ownerId = UserInfo.getUserId(),
                name = 'test' );
            EUR_CRM_Account__c account2 = new EUR_CRM_Account__c(recordTypeId = fiOnAccountRecordTypeId,
                ownerId = eurSalesRep.Id,
                name = 'test2');
            insert new List<EUR_CRM_Account__c>{ account, account2};

            Test.startTest();

            EUR_CRM_OP_Action_List_Template__c listTemplate = makeActionListTemplate('EUR_FI_O_P_Action_List_Template', 'FI_Type_02');
            insert listTemplate;

            EUR_CRM_ObjPromo__c op = new EUR_CRM_ObjPromo__c(
                recordtypeid = fiOnObjPromoRecordTypeId,
                name = 'test op',
                EUR_CRM_Active_End_Date__c = system.today(),
                EUR_CRM_Active_Start_Date__c = system.today(),
                EUR_CRM_Status__c = 'Active',
                eur_crm_product_hierarchy_Level__c = 'BQS',
                EUR_CRM_O_P_Type__c= 'Type 2',
                EUR_CRM_Account_Selection_Type__c = 'Customer Taxonomy'
            );
            insert op;
            
            EUR_CRM_ObjPromo_Target__c opTargetObjCommitment = new EUR_CRM_ObjPromo_Target__c(
                 recordTypeId = opTargetObjCommitmentRecordTypeId,
                 EUR_CRM_ObjPromo__c = op.id,
                 EUR_CRM_Is_Quota__c = true,
                 EUR_CRM_Visit_Targets__c = 4
            );
            insert opTargetObjCommitment;
           
            EUR_CRM_ObjPromo_Target__c opTargetSRCommitment= new EUR_CRM_ObjPromo_Target__c(
                 recordTypeId = opTargetSRCommitmentRecordTypeId,
                 EUR_CRM_ObjPromo__c = op.id,
                 EUR_CRM_O_P_Target__c = opTargetObjCommitment.id,
                 EUR_CRM_Target_Owner__c = UserInfo.getUserId(),
                 EUR_CRM_Visit_Targets__c = 4,
                 EUR_CRM_Is_Quota__c = false
            );
            EUR_CRM_ObjPromo_Target__c opTargetSRCommitment2 = new EUR_CRM_ObjPromo_Target__c(
                recordTypeId = opTargetSRCommitmentRecordTypeId,
                EUR_CRM_ObjPromo__c = op.Id,
                EUR_CRM_O_P_Target__c = opTargetObjCommitment.Id,
                EUR_CRM_Target_Owner__c = eurSalesRep.Id,
                EUR_CRM_Visit_Targets__c = 4,
                EUR_CRM_Is_Quota__c = false
            );
            insert new List<EUR_CRM_ObjPromo_Target__c>{opTargetSRCommitment, opTargetSRCommitment2};
            
            EUR_CRM_Visit_Action__c visitActionConfirmParticipation= new EUR_CRM_Visit_Action__c(
                 //recordTypeId =   visitActionConfirmParticipationRecordTypeId,
                 recordTypeId = visitActionConfirmParticipationRecordType.Id,
                 recordType = visitActionConfirmParticipationRecordType,
                 EUR_CRM_Account__c = account.id,
                 EUR_CRM_Account__r = account,
                 EUR_CRM_ObjPromo__c = op.id,
                 EUR_CRM_Status__c = 'Participating'
            );
            EUR_CRM_Visit_Action__c visitActionConfirmParticipation2 = new EUR_CRM_Visit_Action__c(
                recordTypeId = visitActionConfirmParticipationRecordType.Id,
                recordType = visitActionConfirmParticipationRecordType,
                EUR_CRM_Account__c = account2.Id,
                EUR_CRM_Account__r = account2,
                EUR_CRM_objPromo__c = op.Id,
                EUR_CRM_Status__c = 'Participating'
            );
            insert new List<EUR_CRM_Visit_Action__c>{visitActionConfirmParticipation, visitActionConfirmParticipation2};
            System.assertNotEquals(null, visitActionConfirmParticipation.recordTypeId);
            System.assertNotEquals(null, visitActionConfirmParticipation2.recordTypeId);

            
            List<EUR_CRM_Visit_Action__c> visitActions = new List<EUR_CRM_Visit_Action__c>{visitActionConfirmParticipation, visitActionConfirmParticipation2};
            EUR_CRM_FI_AccrueAchievements.accrue(visitActions);
            
            
            opTargetSRCommitment = [SELECT EUR_CRM_Actual_Number_of_Commitments__c FROM EUR_CRM_ObjPromo_Target__c WHERE Id = :opTargetSRCommitment.Id];
            System.assertEquals(1, opTargetSRCommitment.EUR_CRM_Actual_Number_of_Commitments__c);
            
            opTargetSRCommitment2 = [SELECT EUR_CRM_Actual_Number_of_Commitments__c FROM EUR_CRM_ObjPromo_Target__c WHERE Id = :opTargetSRCommitment2.Id];
            System.assertEquals(1, opTargetSRCommitment2.EUR_CRM_Actual_Number_of_Commitments__c);

            Test.stopTest();
        }        
    }
    
    /**
    *   testMethod: testAccrueAchievementsMultipleVisitActions
    *   test accruing multiple visit actions belonging to the same SR
    */
    static testMethod void testAccrueAchievementsMultipleVisitActions() {
        setUser();
        System.runAs(eurSysUser){ 
            Id fiOnAccountRecordTypeId = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Account__c','EUR_FI_Direct_On_Trade');
            Id bqRecordTypeId= EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Quality__c','EUR_FI_Quality');
            Id fiOnObjPromoRecordTypeId = [select id from RecordType where sobjecttype='EUR_CRM_ObjPromo__c' and developername ='EUR_FI_On_Trade_O_P'].id;
              
            Id opTargetObjCommitmentRecordTypeId= EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_ObjPromo_Target__c','EUR_CRM_Objective_Commitment_Target');
            Id opTargetSRCommitmentRecordTypeId= EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_ObjPromo_Target__c','EUR_CRM_SR_Commitment_Target');
          
            //Id visitActionConfirmParticipationRecordTypeId =  EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Visit_Action__c','EUR_FI_Confirm_Participation');
            RecordType visitActionConfirmParticipationRecordType = [SELECT Id, DeveloperName FROM RecordType WHERE sObjectType = 'EUR_CRM_Visit_Action__c' and Developername = 'EUR_FI_Confirm_Participation'];
            
            bq = new EUR_CRM_Quality__c(recordtypeid=bqRecordTypeId,name = 'testBQ');
            insert bq ;
            
            EUR_CRM_Account__c account = new EUR_CRM_Account__c(
                recordtypeid = fiOnAccountRecordTypeId,
                ownerId = UserInfo.getUserId(),
                name = 'test' );
            insert account;
            
            EUR_CRM_OP_Action_List_Template__c listTemplate = makeActionListTemplate('EUR_FI_O_P_Action_List_Template', 'FI_Type_02');
            insert listTemplate;

            EUR_CRM_ObjPromo__c op = new EUR_CRM_ObjPromo__c(
                recordtypeid = fiOnObjPromoRecordTypeId,
                name = 'test op',
                EUR_CRM_Active_End_Date__c = system.today(),
                EUR_CRM_Active_Start_Date__c = system.today(),
                EUR_CRM_Status__c = 'Active',
                eur_crm_product_hierarchy_Level__c = 'BQS',
                EUR_CRM_O_P_Type__c= 'Type 2',
                EUR_CRM_Account_Selection_Type__c = 'Customer Taxonomy'
            );
            insert op;
            
            EUR_CRM_ObjPromo_Target__c opTargetObjCommitment = new EUR_CRM_ObjPromo_Target__c(
                 recordTypeId = opTargetObjCommitmentRecordTypeId,
                 EUR_CRM_ObjPromo__c = op.id,
                 EUR_CRM_Is_Quota__c = true,
                 EUR_CRM_Visit_Targets__c = 4
            );
            insert opTargetObjCommitment;
            
            EUR_CRM_ObjPromo_Target__c opTargetSRCommitment= new EUR_CRM_ObjPromo_Target__c(
                 recordTypeId = opTargetSRCommitmentRecordTypeId,
                 EUR_CRM_ObjPromo__c = op.id,
                 EUR_CRM_O_P_Target__c = opTargetObjCommitment.id,
                 EUR_CRM_Target_Owner__c = UserInfo.getUserId(),
                 EUR_CRM_Visit_Targets__c = 4,
                 EUR_CRM_Is_Quota__c = false
            );
            insert opTargetSRCommitment;
            
            EUR_CRM_Visit_Action__c visitActionConfirmParticipation= new EUR_CRM_Visit_Action__c(
                 //recordTypeId =   visitActionConfirmParticipationRecordTypeId,
                 recordTypeId = visitActionConfirmParticipationRecordType.Id,
                 recordType = visitActionConfirmParticipationRecordType,
                 EUR_CRM_Account__c = account.id,
                 EUR_CRM_Account__r = account,
                 EUR_CRM_ObjPromo__c = op.id,
                 EUR_CRM_Status__c = 'Participating'
            );
            EUR_CRM_Visit_Action__c visitActionConfirmParticipation2 = new EUR_CRM_Visit_Action__c(
                recordTypeId = visitActionConfirmParticipationRecordType.Id,
                recordType = visitActionConfirmParticipationRecordType,
                EUR_CRM_Account__c = account.Id,
                EUR_CRM_Account__r = account,
                EUR_CRM_objPromo__c = op.Id,
                EUR_CRM_Status__c = 'Participating'
            );
            insert new List<EUR_CRM_Visit_Action__c>{visitActionConfirmParticipation, visitActionConfirmParticipation2};
            System.assertNotEquals(null, visitActionConfirmParticipation.recordTypeId);
            System.assertNotEquals(null, visitActionConfirmParticipation2.recordTypeId);

            Test.startTest();
            List<EUR_CRM_Visit_Action__c> visitActions = new List<EUR_CRM_Visit_Action__c>{visitActionConfirmParticipation, visitActionConfirmParticipation2};
            EUR_CRM_FI_AccrueAchievements.accrue(visitActions);
            
            
            opTargetSRCommitment = [SELECT EUR_CRM_Actual_Number_of_Commitments__c FROM EUR_CRM_ObjPromo_Target__c WHERE Id = :opTargetSRCommitment.Id];
            System.assertEquals(2, opTargetSRCommitment.EUR_CRM_Actual_Number_of_Commitments__c);

            Test.stopTest();
        }         
    }
    
    /**
    *   testMethod: testAccrueAchievementsMultipleOP
    *   test accruing multiple visit actions belonging to multiple OP from the same SR
    */
    static testMethod void testAccrueAchievementsMultipleOP() {
        setUser();
        System.runAs(eurSysUser){ 
            Id fiOnAccountRecordTypeId = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Account__c','EUR_FI_Direct_On_Trade');
            Id bqRecordTypeId= EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Quality__c','EUR_FI_Quality');
            Id fiOnObjPromoRecordTypeId = [select id from RecordType where sobjecttype='EUR_CRM_ObjPromo__c' and developername ='EUR_FI_On_Trade_O_P'].id;
              
            Id opTargetObjCommitmentRecordTypeId= EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_ObjPromo_Target__c','EUR_CRM_Objective_Commitment_Target');
            Id opTargetSRCommitmentRecordTypeId= EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_ObjPromo_Target__c','EUR_CRM_SR_Commitment_Target');
          
            //Id visitActionConfirmParticipationRecordTypeId =  EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Visit_Action__c','EUR_FI_Confirm_Participation');
            RecordType visitActionConfirmParticipationRecordType = [SELECT Id, DeveloperName FROM RecordType WHERE sObjectType = 'EUR_CRM_Visit_Action__c' and Developername = 'EUR_FI_Confirm_Participation'];
            
            bq = new EUR_CRM_Quality__c(recordtypeid=bqRecordTypeId,name = 'testBQ');
            insert bq ;
            
            EUR_CRM_Account__c account = new EUR_CRM_Account__c(recordtypeid = fiOnAccountRecordTypeId ,
            ownerId = UserInfo.getUserId(),
            name = 'test' );
            insert account;

            EUR_CRM_OP_Action_List_Template__c listTemplate = makeActionListTemplate('EUR_FI_O_P_Action_List_Template', 'FI_Type_02');
            insert listTemplate;

            EUR_CRM_ObjPromo__c op = new EUR_CRM_ObjPromo__c(
                recordtypeid = fiOnObjPromoRecordTypeId,
                name = 'test op',
                EUR_CRM_Active_End_Date__c = system.today(),
                EUR_CRM_Active_Start_Date__c = system.today(),
                EUR_CRM_Status__c = 'Active',
                eur_crm_product_hierarchy_Level__c = 'BQS',
                EUR_CRM_O_P_Type__c= 'Type 2',
                EUR_CRM_Account_Selection_Type__c = 'Customer Taxonomy'
            );
            EUR_CRM_ObjPromo__c op2 = new EUR_CRM_ObjPromo__c(
                recordTypeId = fiOnObjPromoRecordTypeId,
                name = 'test OP 2',
                EUR_CRM_Active_End_Date__c = system.today(),
                EUR_CRM_Active_Start_Date__c = system.today(),
                EUR_CRM_Status__c = 'Active',
                EUR_CRM_Product_Hierarchy_Level__c = 'BQS',
                EUR_CRM_O_P_Type__c = 'Type 2',
                EUR_CRM_Account_Selection_Type__c = 'Customer Taxonomy'
            );
            //List<EUR_CRM_ObjPromo__c> testOP = new List<EUR_CRM_ObjPromo__c>{op, op2};
            insert new List<EUR_CRM_ObjPromo__c>{op, op2};
            
            EUR_CRM_ObjPromo_Target__c opTargetObjCommitment = new EUR_CRM_ObjPromo_Target__c(
                 recordTypeId = opTargetObjCommitmentRecordTypeId,
                 EUR_CRM_ObjPromo__c = op.id,
                 EUR_CRM_Is_Quota__c = true,
                 EUR_CRM_Visit_Targets__c = 4
            );
            EUR_CRM_ObjPromo_Target__c opTargetObjCommitment2 = new EUR_CRM_ObjPromo_Target__c(
                RecordTypeId = opTargetObjCommitmentRecordTypeId,
                EUR_CRM_ObjPromo__c = op2.id,
                EUR_CRM_Is_Quota__c = true,
                EUR_CRM_Visit_Targets__c = 4
            );
            insert new List<EUR_CRM_ObjPromo_Target__c>{opTargetObjCommitment, opTargetObjCommitment2};
            System.assertNotEquals(opTargetObjCommitment2.Id, null);
            System.assertNotEquals(opTargetObjCommitment.Id, null);
            
            EUR_CRM_ObjPromo_Target__c opTargetSRCommitment= new EUR_CRM_ObjPromo_Target__c(
                 recordTypeId = opTargetSRCommitmentRecordTypeId,
                 EUR_CRM_ObjPromo__c = op.id,
                 EUR_CRM_O_P_Target__c = opTargetObjCommitment.id,
                 EUR_CRM_Target_Owner__c = UserInfo.getUserId(),
                 EUR_CRM_Visit_Targets__c = 4,
                 EUR_CRM_Is_Quota__c = false
            );
            EUR_CRM_ObjPromo_Target__c opTargetSRCommitment2 = new EUR_CRM_ObjPromo_Target__c(
                recordTypeId = opTargetSRCommitmentRecordTypeId,
                EUR_CRM_ObjPromo__c = op2.Id,
                EUR_CRM_O_P_Target__c = opTargetObjCommitment2.Id,
                EUR_CRM_Target_Owner__c = UserInfo.getUserId(),
                EUR_CRM_Visit_Targets__c = 4,
                EUR_CRM_Is_Quota__c = false
            );
            insert new List<EUR_CRM_ObjPromo_Target__c>{opTargetSRCommitment, opTargetSRCommitment2};
            
            EUR_CRM_Visit_Action__c visitActionConfirmParticipation= new EUR_CRM_Visit_Action__c(
                 //recordTypeId =   visitActionConfirmParticipationRecordTypeId,
                 recordTypeId = visitActionConfirmParticipationRecordType.Id,
                 recordType = visitActionConfirmParticipationRecordType,
                 EUR_CRM_Account__c = account.id,
                 EUR_CRM_Account__r = account,
                 EUR_CRM_ObjPromo__c = op.id,
                 EUR_CRM_Status__c = 'Participating'
            );
            EUR_CRM_Visit_Action__c visitActionConfirmParticipation2 = new EUR_CRM_Visit_Action__c(
                recordTypeId = visitActionConfirmParticipationRecordType.Id,
                recordType = visitActionConfirmParticipationRecordType,
                EUR_CRM_Account__c = account.Id,
                EUR_CRM_Account__r = account,
                EUR_CRM_objPromo__c = op2.Id,
                EUR_CRM_Status__c = 'Participating'
            );
            insert new List<EUR_CRM_Visit_Action__c>{visitActionConfirmParticipation, visitActionConfirmParticipation2};
            System.assertNotEquals(null, visitActionConfirmParticipation.recordTypeId);
            System.assertNotEquals(null, visitActionConfirmParticipation2.recordTypeId);

            Test.startTest();
            
            List<EUR_CRM_Visit_Action__c> visitActions = new List<EUR_CRM_Visit_Action__c>{visitActionConfirmParticipation, visitActionConfirmParticipation2};
            EUR_CRM_FI_AccrueAchievements.accrue(visitActions);
            
            
            opTargetSRCommitment = [SELECT EUR_CRM_Actual_Number_of_Commitments__c FROM EUR_CRM_ObjPromo_Target__c WHERE Id = :opTargetSRCommitment.Id];
            System.assertEquals(1, opTargetSRCommitment.EUR_CRM_Actual_Number_of_Commitments__c);
            
            opTargetSRCommitment2 = [SELECT EUR_CRM_Actual_Number_of_Commitments__c FROM EUR_CRM_ObjPromo_Target__c WHERE Id = :opTargetSRCommitment2.Id];
            System.assertEquals(1, opTargetSRCommitment2.EUR_CRM_Actual_Number_of_Commitments__c);

            Test.stopTest();
        }
    }
    
    /**
        EUR_CRM_FI_AccrueAchievements
    */
    static testMethod  void testAccrueAchievements(){
        setUser();
        System.runAs(eurSysUser){ 
            Id fiOnAccountRecordTypeId = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Account__c','EUR_FI_Direct_On_Trade');
            Id bqRecordTypeId= EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Quality__c','EUR_FI_Quality');
            Id fiOnObjPromoRecordTypeId = [select id from RecordType where sobjecttype='EUR_CRM_ObjPromo__c' and developername ='EUR_FI_On_Trade_O_P'].id;
              
            Id opTargetObjCommitmentRecordTypeId= EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_ObjPromo_Target__c','EUR_CRM_Objective_Commitment_Target');
            Id opTargetObjVolumeRecordTypeId= EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_ObjPromo_Target__c','EUR_CRM_Objective_Volume_Target');
            Id opTargetSRCommitmentRecordTypeId= EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_ObjPromo_Target__c','EUR_CRM_SR_Commitment_Target');
            Id opTargetSRVolumeRecordTypeId= EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_ObjPromo_Target__c','EUR_CRM_SR_Volume_Target');
          
            Id visitActionConfirmParticipationRecordTypeId =  EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Visit_Action__c','EUR_FI_Confirm_Participation');
            Id visitActionSellInVolumeRecordTypeId =  EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Visit_Action__c','EUR_FI_Enter_Sell_In_Volume_Estimate');
            Id visitActionFollowUpType1RecordTypeId =  EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Visit_Action__c','EUR_FI_Follow_Up_Type_1');
             Id visitSubActionActionIndivRecordTypeId =  EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Visit_Sub_Action__c','FI_ON_Trade_Visit_Sub_Action_Adhoc_Create_Indiv_Account_OP_Add_BQ');
       
            bq = new EUR_CRM_Quality__c(recordtypeid=bqRecordTypeId,name = 'testBQ');
            insert bq ;
            
            EUR_CRM_Account__c account = new EUR_CRM_Account__c(recordtypeid = fiOnAccountRecordTypeId ,
            name = 'test' );
            insert account;

            EUR_CRM_OP_Action_List_Template__c listTemplate = makeActionListTemplate('EUR_FI_O_P_Action_List_Template', 'FI_Type_02');
            insert listTemplate;

            EUR_CRM_ObjPromo__c op = new EUR_CRM_ObjPromo__c(
                recordtypeid = fiOnObjPromoRecordTypeId,
                name = 'test op',
                EUR_CRM_Active_End_Date__c = system.today(),
                EUR_CRM_Active_Start_Date__c = system.today(),
                EUR_CRM_Status__c = 'Active',
                eur_crm_product_hierarchy_Level__c = 'BQS',
                EUR_CRM_O_P_Type__c= 'Type 2',
                EUR_CRM_Account_Selection_Type__c = 'Customer Taxonomy'
            ); 
            insert op;
            
               EUR_CRM_ObjPromo_Target__c opTargetObjCommitment = new EUR_CRM_ObjPromo_Target__c(
                 recordTypeId = opTargetObjCommitmentRecordTypeId,
                 EUR_CRM_ObjPromo__c = op.id,
                 EUR_CRM_Is_Quota__c = true,
                 EUR_CRM_Visit_Targets__c = 1
             );
             insert opTargetObjCommitment;
             EUR_CRM_ObjPromo_Target__c opTargetSRCommitment= new EUR_CRM_ObjPromo_Target__c(
                 recordTypeId = opTargetSRCommitmentRecordTypeId,
                 EUR_CRM_ObjPromo__c = op.id,
                 EUR_CRM_O_P_Target__c = opTargetObjCommitment.id,
                 EUR_CRM_Target_Owner__c = UserInfo.getUserId(),
                 EUR_CRM_Visit_Targets__c = 1,
                 EUR_CRM_Is_Quota__c = true

             );
             insert opTargetSRCommitment;
             EUR_CRM_ObjPromo_Target__c opTargetObjVolume = new EUR_CRM_ObjPromo_Target__c(
                 recordTypeId = opTargetObjVolumeRecordTypeId,
                 EUR_CRM_ObjPromo__c = op.id,
                 EUR_CRM_BQ__c = bq.id
             );
             insert opTargetObjVolume ;
             EUR_CRM_ObjPromo_Target__c opTargetSRVolume = new EUR_CRM_ObjPromo_Target__c(
                 recordTypeId = opTargetSRVolumeRecordTypeId,
                 EUR_CRM_ObjPromo__c = op.id,
                 EUR_CRM_O_P_Target__c = opTargetObjVolume.id,
                 EUR_CRM_Target_Owner__c = UserInfo.getUserId(),
                 EUR_CRM_BQ__c = bq.id
             );
             insert opTargetSRVolume; 
            EUR_CRM_Visit_Action__c visitActionConfirmParticipation= new EUR_CRM_Visit_Action__c(
                 recordtypeid =   visitActionConfirmParticipationRecordTypeId,
                 EUR_CRM_Account__c = account.id,
                 EUR_CRM_ObjPromo__c = op.id,
                 EUR_CRM_Status__c = 'Participating'
                 );
                 insert visitActionConfirmParticipation ; 
            EUR_CRM_Visit_Action__c visitActionSellInVolume = new EUR_CRM_Visit_Action__c(
                 recordtypeid =   visitActionSellInVolumeRecordTypeId,
                 EUR_CRM_Account__c = account.id,
                 EUR_CRM_ObjPromo__c = op.id
                 ); 
                 insert visitActionSellInVolume ; 
            
            EUR_CRM_Visit_Sub_Action__c visitSubAction= new EUR_CRM_Visit_Sub_Action__c(
                 recordtypeid =   visitSubActionActionIndivRecordTypeId , 
                 EUR_CRM_Visit_Action__c = visitActionSellInVolume.id,
                 EUR_CRM_Brand_Quality__c = bq.id,
                 EUR_CRM_Number_of_Bottles__c = 1
                 );
                 insert visitSubAction;

            EUR_CRM_Visit_Action__c visitActionFolloUpType1 = new EUR_CRM_Visit_Action__c(
                 recordtypeid =   visitActionFollowUpType1RecordTypeId,
                 EUR_CRM_Account__c = account.id,
                 EUR_CRM_ObjPromo__c = op.id,
                 EUR_CRM_Status__c = 'Evaluation: Successful'
                 );
                 insert visitActionFolloUpType1 ; 

            Test.startTest();
            visitActionConfirmParticipation = [select id,EUR_CRM_Is_Accrued__c, EUR_CRM_ObjPromo__c,
             recordType.developername,EUR_CRM_Account__r.OwnerId, EUR_CRM_Visit_ID__c,EUR_CRM_Status__c, EUR_CRM_Stage__c,EUR_CRM_Remarks__c,OwnerId, EUR_CRM_Stage_Sequence_Order__c,  EUR_CRM_Activation_End_Date__c,EUR_CRM_Account__c, EUR_CRM_Product_Toolkit__c, EUR_CRM_Active__c, EUR_CRM_End_Datetime__c from EUR_CRM_Visit_Action__c where id =:visitActionConfirmParticipation.id ];
             visitActionSellInVolume = [select id,EUR_CRM_Is_Accrued__c, EUR_CRM_ObjPromo__c,
             recordType.developername,EUR_CRM_Account__r.OwnerId, EUR_CRM_Visit_ID__c,EUR_CRM_Status__c, EUR_CRM_Stage__c,EUR_CRM_Remarks__c,OwnerId, EUR_CRM_Stage_Sequence_Order__c,  EUR_CRM_Activation_End_Date__c,EUR_CRM_Account__c, EUR_CRM_Product_Toolkit__c, EUR_CRM_Active__c, EUR_CRM_End_Datetime__c from EUR_CRM_Visit_Action__c where id =:visitActionSellInVolume.id ];
               
            
            List<EUR_CRM_Visit_Action__c> visitActions = new List<EUR_CRM_Visit_Action__c>();
            visitActions.add(visitActionConfirmParticipation);
            visitActions.add(visitActionSellInVolume ); 
            EUR_CRM_FI_AccrueAchievements.accrue(visitActions);
              op.EUR_CRM_Status__c = 'Under Evaluation';
              update op;
               visitActionFolloUpType1 = [select id,EUR_CRM_Is_Accrued__c, EUR_CRM_ObjPromo__c,
             recordType.developername,EUR_CRM_ObjPromo__r.EUR_CRM_Status__c, EUR_CRM_Account__r.OwnerId, EUR_CRM_Visit_ID__c,EUR_CRM_Status__c, EUR_CRM_Stage__c,EUR_CRM_Remarks__c,OwnerId, EUR_CRM_Stage_Sequence_Order__c,  EUR_CRM_Activation_End_Date__c,EUR_CRM_Account__c, EUR_CRM_Product_Toolkit__c, EUR_CRM_Active__c, EUR_CRM_End_Datetime__c from EUR_CRM_Visit_Action__c where id =:visitActionFolloUpType1.id ];
          
            visitActions = new List<EUR_CRM_Visit_Action__c>(); 
            visitActions.add(visitActionFolloUpType1 );
            
            
            EUR_CRM_FI_AccrueAchievements.accrue(visitActions);
            Test.stopTest();
        }
    }
    /**
    EUR_CRM_FI_ScheduleVisitActionFollowUp
    */
    static testMethod void testFIScheduleVisitActionFollowUp() {
        
                String sched = '0 00 * * * ?';
                // Abort all CronTrigger records
               // for (CronTrigger cronTrigger : [SELECT Id FROM CronTrigger]) System.abortJob(cronTrigger.Id);
              List<CronJobDetail> details = [ SELECT Id FROM CronJobDetail where name = 'Create Finland Visit Follow Ups'];
                   if(details  != null && details.size() > 0){
                          CronJobDetail cd =details.get(0);
                       CronTrigger d =[select id from CronTrigger where  CronJobDetailId =: cd.id ];
                       if(d!=null)
                           System.abortJob(d.Id);
                    } 
                Test.startTest();
                    EUR_CRM_FI_ScheduleVisitActionFollowUp.schedule();
                  //String jobId = System.schedule('Create Finland Visit Follow Ups', sched, new EUR_CRM_FI_ScheduleVisitActionFollowUp());
                Test.stopTest();
    }
    /**
    EUR_CRM_FI_ScheduleVisitActionFollowUp
    */
    static testMethod void testFIScheduleAccrueAchievements() {
        
                String sched = '0 00 * * * ?';
                // Abort all CronTrigger records
               // for (CronTrigger cronTrigger : [SELECT Id FROM CronTrigger]) System.abortJob(cronTrigger.Id);
              List<CronJobDetail> details = [ SELECT Id FROM CronJobDetail where name = 'Accrue Finland Objective Achievements'];
                   if(details  != null && details.size() > 0){
                          CronJobDetail cd =details.get(0);
                       CronTrigger d =[select id from CronTrigger where  CronJobDetailId =: cd.id ];
                       if(d!=null)
                           System.abortJob(d.Id);
                    } 
                Test.startTest();  
                    EUR_CRM_FI_ScheduleAccrueAchievements.schedule();
                //  String jobId = System.schedule('Accrue Finland Objective Achievements', sched, new EUR_CRM_FI_ScheduleAccrueAchievements());
                Test.stopTest();
    }
}