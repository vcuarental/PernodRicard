@isTest
public class EUR_CRM_FI_TestOPAccountHandler{

    static User eurSysUser; 
    static void setUser(){
        Profile p = [SELECT Id FROM Profile WHERE Name ='EUR System Admin']; 
        UserRole r = [select id from UserRole where Developername ='EMEA'];
        eurSysUser = new User(Alias = 'standt', Email='userEmail1234aoke@test.com', userroleid=r.id,
        EmailEncodingKey='UTF-8', LastName='userEmail1234aokelastName', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='userEmail1234aoke@test.com');
        insert eurSysUser;
    }
    static testMethod  void testCustomerTaxonomy(){
        setUser();
        System.runAs(eurSysUser){
            Id fiOnAccountRecordTypeId = [select id from RecordType where sobjecttype='eur_crm_account__C' and developername ='EUR_FI_Direct_On_Trade'].id;
            Id fiOnObjPromoRecordTypeId = [select id from RecordType where sobjecttype='EUR_CRM_ObjPromo__c' and developername ='EUR_FI_On_Trade_O_P'].id;
            Id fiCustomerTaxonomyRecordTypeId= EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Customer_Taxonomy__c','EUR_FI_ON_Trade_Customer_Taxonomy');
              Id bqsRecordTypeId= EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Size__c','EUR_FI_Size');
             
            EUR_CRM_Customer_Taxonomy__c custTax= new EUR_CRM_Customer_Taxonomy__c(recordtypeid = fiCustomerTaxonomyRecordTypeId,
            name = 'test');
            insert custTax; 
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
            
            EUR_CRM_OP_Customer_Taxonomy_Mapping__c custOPMapping= new EUR_CRM_OP_Customer_Taxonomy_Mapping__c(
                EUR_CRM_Customer_Taxonomy__c = custTax.id,
                EUR_CRM_ObjPromo__c = op.id
            );
            
            insert custOPMapping; 
        
            Test.startTest();
            
            EUR_CRM_Account__c account = new EUR_CRM_Account__c(recordtypeid = fiOnAccountRecordTypeId,
            name = 'test',
            EUR_JB_Customer_Taxonomy__c = custTax.id,
            EUR_CRM_Status__c = 'Active');
            insert account;
            
            List<EUR_CRM_ObjPromo_Account_Mapping__c>  opaccountmapping= [select id from EUR_CRM_ObjPromo_Account_Mapping__c  where
                        EUR_CRM_Account__c =: account.id AND 
                        EUR_CRM_ObjPromo__c =: op.id AND
                        EUR_CRM_Is_Active__c = true];
            system.assert(opaccountmapping!= null && opaccountmapping.size() > 0);
            
       
             
            Test.stopTest();
        }
    } 
    static testMethod  void testPROS(){
        setUser();
        System.runAs(eurSysUser){
            Id fiOnAccountRecordTypeId = [select id from RecordType where sobjecttype='eur_crm_account__C' and developername ='EUR_FI_Direct_On_Trade'].id;
            Id fiOnObjPromoRecordTypeId = [select id from RecordType where sobjecttype='EUR_CRM_ObjPromo__c' and developername ='EUR_FI_On_Trade_O_P'].id;
            Id fiCustomerTaxonomyRecordTypeId= EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Customer_Taxonomy__c','EUR_FI_ON_Trade_Customer_Taxonomy');
            
           Id fiGroupOutletRecordTypeId = [select id from RecordType where sobjecttype='EUR_CRM_Group_Outlet_Type__c' and developername ='EUR_FI_Group_Outlet'].id; 
           Id fiImageLevelRecordTypeId = [select id from RecordType where sobjecttype='EUR_CRM_Image_Level__c' and developername ='EUR_FI_Image_Level'].id;
            Id bqsRecordTypeId= EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Size__c','EUR_FI_Size');
            
             EUR_CRM_Group_Outlet_Type__c groupOutletType = new EUR_CRM_Group_Outlet_Type__c(recordtypeid= fiGroupOutletRecordTypeId , EUR_CRM_Name__c = 'Restaurant', EUR_CRM_Group_Outlet_Name__c = 'Restaurant' );
            insert groupOutletType;
              EUR_CRM_Image_Level__c imageLevel= new EUR_CRM_Image_Level__c (recordtypeid= fiImageLevelRecordTypeId , EUR_CRM_Name__c = 'Iconic');
            insert imageLevel; 

            EUR_CRM_ObjPromo__c op2 = new EUR_CRM_ObjPromo__c(
                recordtypeid = fiOnObjPromoRecordTypeId,
                name = 'test op',
                EUR_CRM_Active_End_Date__c = system.today(),
                EUR_CRM_Active_Start_Date__c = system.today(),
                EUR_CRM_Status__c = 'Active',
                eur_crm_product_hierarchy_Level__c = 'BQS',
                EUR_CRM_O_P_Type__c= 'Type 2',
                EUR_CRM_Account_Selection_Type__c = 'PROS'
            ); 
            insert op2;
             
            EUR_CRM_ObjPromo_to_PROS_Segment_Mapping__c prosOPMapping= new EUR_CRM_ObjPromo_to_PROS_Segment_Mapping__c( 
                EUR_CRM_ObjPromo__c = op2.id,
                EUR_CRM_Group_Outlet_Type__c = groupOutletType.EUR_CRM_Group_Outlet_Name__c,
                EUR_CRM_Image_Level__c = imageLevel.EUR_CRM_Name__c
                
            );
            
            insert prosOPMapping;
        
            Test.startTest();
             
            
            EUR_CRM_Account__c account2 = new EUR_CRM_Account__c(recordtypeid = fiOnAccountRecordTypeId,
            name = 'test', 
            EUR_CRM_Status__c = 'Active'
            );
            insert account2; 
           account2 = [select id,EUR_CRM_Status__c ,  EUR_CRM_Group_Outlet_Type_Name__c, EUR_CRM_Image_Level_Name__c from  EUR_CRM_Account__c where id=:account2.id];
            
            account2.EUR_CRM_Group_Outlet_Type__c= groupOutletType.id;
           account2.EUR_CRM_Image_Level__c= imageLevel.id;
            update account2;
            
            List<EUR_CRM_ObjPromo_Account_Mapping__c>  opaccountmapping= [select id from EUR_CRM_ObjPromo_Account_Mapping__c  where
                        EUR_CRM_Account__c =: account2.id AND 
                        EUR_CRM_ObjPromo__c =: op2.id AND
                        EUR_CRM_Is_Active__c = true];
            system.assert(opaccountmapping!= null && opaccountmapping.size() > 0);

            Test.stopTest();
        }
    } 
}