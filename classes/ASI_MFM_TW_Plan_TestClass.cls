/********************
* ASI_MFM_TW_PlanLineItem_TriggerClass
*
*********************/
@isTest
public class ASI_MFM_TW_Plan_TestClass {
    //----------------------------------------------------------Fiscal Year---------------------------------------------------------------------------------------
    public static string getFiscalYear(){
        Integer orgFiscalMonth = [SELECT FiscalYearStartMonth FROM Organization].FiscalYearStartMonth;  //i.e. 7
        Date orgFiscalYear = Date.newinstance(system.today().year(), orgFiscalMonth, 1);    
        Datetime GMTdate = Datetime.now();
        String yearA1 = GMTdate.format('YY');
        Integer yearA0 = Integer.valueOf(yearA1) -1;
        Integer yearA2 = Integer.valueOf(yearA1) +1;
        String Current_Fiscal_year;
        
        if(system.today()< orgFiscalYear){
            Current_Fiscal_year = 'FY' + yearA0 + yearA1 ;
        }else{
            Current_Fiscal_year = 'FY' + yearA1 + yearA2 ;
        }
        
        return Current_Fiscal_year;
    }
    
    static testMethod void ASI_MFM_TW_Plan_TriggerClass_Test(){
        
        Profile prof = [select id from profile where name='System Administrator'];
        UserRole ur=new UserRole(Name='Test UserRole', DeveloperName = 'Test_UserRole');
        insert ur;
        System.debug('-----------------------------'+ur.id);
        User u = new User(alias = 'systemA', email='systemadmin@testorg.com',
                          emailencodingkey='UTF-8', lastname='Testing', 
                          languagelocalekey='en_US', localesidkey='en_US', 
                          profileid = prof.Id,isactive = true ,
                          timezonesidkey='America/Los_Angeles',
                          username='systemadmin@updaterspregiontest.com',
                          userroleID=ur.id, ASI_CRM_User_Group__c = 'Test',
                          ASI_MFM_Country__c = 'TW');
        
        //user u = [select userRole.developerName from user where id = :userInfo.getUserId()];
        //u.ASI_MFM_Country__c = 'TW';
        //update u;
        System.runAs(u) { 
            id planLinertId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_TW_Plan_Line_Item');
            
            ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c='FY0000');
            insert px;        
            
            ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c='Test_UserRole');
            insert pr;
                    
            Map<string, id> subBrandCode_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Sub_brand__c');  
            ASI_MFM_Sub_brand__c subBrand1 = new ASI_MFM_Sub_brand__c(Name='subBrand1'
            ,recordTypeId=subBrandCode_map.get('ASI_MFM_TW_Sub_brand'), ASI_MFM_Sub_brand_Code__c = 'testcode', ASI_CRM_TW_Company__c ='PRT', ASI_TH_CRM_Active__c = true);
            insert subBrand1;
                        
            ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC', ASI_MFM_A_C_Code__c='5220test', ASI_MFM_A_and_P_Tree__c = 'Total A&P');
            insert ac;
            
            ASI_MFM_A_C_Code__c ac2 = new ASI_MFM_A_C_Code__c(name='testAC', ASI_MFM_A_C_Code__c='Spending per Bottle', ASI_MFM_A_and_P_Tree__c = 'Total A&D');
            insert ac2;
            
            id customerrtId = Global_RecordTypeCache.getRtId('AccountASI_MFM_TW_Customer');
            Account acc2 = new Account(recordTypeId=customerrtId,Name='Name3');  
            
            ASI_MFM_Plan__c p0 = new ASI_MFM_Plan__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_TW_Plan'), name='test',
                                                    ASI_MFM_End_Date__c = Date.newInstance(Date.today().year(),6,30), ASI_MFM_Plan_Description__c = 'test', 
            										ASI_MFM_Plan_Name__c = 'planName test', ASI_MFM_Start_Date__c = Date.newInstance(Date.today().year(),6,1),
                                                    ASI_MFM_Prefix__c=px.id, ASI_MFM_Fiscal_Year__c=getFiscalYear(), ASI_MFM_Status__c='Submitted');
            insert p0;
            ASI_MFM_Plan_Line_Item__c pi0 = new ASI_MFM_Plan_Line_Item__c(recordTypeId=planLinertId, ASI_MFM_Plan__c=p0.id
                                                                          ,ASI_MFM_Sub_brand_Code__c = subBrand1.id, ASI_MFM_A_C_Code__c=ac2.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription2',ASI_MFM_Size__c='1', ASI_MFM_Total_Cost__c=100);
            insert pi0;
            
            ASI_MFM_Plan__c p = new ASI_MFM_Plan__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_TW_Plan'), name='test',
            ASI_MFM_End_Date__c = Date.newInstance(Date.today().year(),6,30), ASI_MFM_Plan_Description__c = 'veryLongDescriptionveryLongDescriptionveryLongDescriptionveryLongDescriptionveryLongDescriptionveryLongDescriptionveryLongDescriptionveryLongDescriptionveryLongDescriptionveryLongDescriptionveryLongDescription', 
            ASI_MFM_Plan_Name__c = 'planName test', ASI_MFM_Start_Date__c = Date.newInstance(Date.today().year(),6,1), 
            ASI_MFM_Prefix__c=px.id, ASI_MFM_Fiscal_year__c='FY0000', ASI_MFM_Additional_Brand_Manager_1__c=u.id, ASI_MFM_Status__c='Draft', ASI_MFM_Cloned_Plan_ID__c=p0.id, ASI_CRM_Converted_Date__c=System.today());
            insert p;        
                     
            insert acc2;
        
            Test.startTest();
                        
            ASI_MFM_Plan_Line_Item__c pi1 = new ASI_MFM_Plan_Line_Item__c(recordTypeId=planLinertId, ASI_MFM_Plan__c=p.id
                                                                          ,ASI_MFM_Sub_brand_Code__c = subBrand1.id, ASI_MFM_A_C_Code__c=ac2.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription2',ASI_MFM_Size__c='1', ASI_MFM_Total_Cost__c=100);
            insert pi1;
            
            ASI_MFM_Plan_Line_Item__c pi2 = new ASI_MFM_Plan_Line_Item__c(recordTypeId=planLinertId, ASI_MFM_Plan__c=p.id 
                                                                         ,ASI_MFM_Sub_brand_Code__c = subBrand1.id, ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Month_8_Cost__c=100);
            insert pi2;
            
            p0.ASI_MFM_Status__c='Draft';
            update p0;                        
            
            delete p0;
            
            Test.stopTest();
        }
    }
    
    static testMethod void ASI_MFM_TW_PlanLineItem_TriggerClass_Test(){
        
        Profile prof = [select id from profile where name='System Administrator'];
        UserRole ur=new UserRole(Name='Test UserRole', DeveloperName = 'Test_UserRole');
        insert ur;
        System.debug('-----------------------------'+ur.id);
        User u = new User(alias = 'systemA', email='systemadmin@testorg.com',
                          emailencodingkey='UTF-8', lastname='Testing', 
                          languagelocalekey='en_US', localesidkey='en_US', 
                          profileid = prof.Id,isactive = true ,
                          timezonesidkey='America/Los_Angeles',
                          username='systemadmin@updaterspregiontest.com',
                          userroleID=ur.id, ASI_CRM_User_Group__c = 'Test',
                          ASI_MFM_Country__c = 'TW');
        
        //user u = [select userRole.developerName from user where id = :userInfo.getUserId()];
        //u.ASI_MFM_Country__c = 'TW';
        //update u;
        System.runAs(u) {        
            ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c='FY0000');
            insert px;        
            
            ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c='Test_UserRole');
            insert pr;
                    
            Map<string, id> subBrandCode_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Sub_brand__c');  
            ASI_MFM_Sub_brand__c subBrand1 = new ASI_MFM_Sub_brand__c(Name='subBrand1'
            ,recordTypeId=subBrandCode_map.get('ASI_MFM_TW_Sub_brand'), ASI_MFM_Sub_brand_Code__c = 'testcode', ASI_CRM_TW_Company__c ='PRT', ASI_TH_CRM_Active__c = true);
            insert subBrand1;
            
            ASI_MFM_Plan__c p = new ASI_MFM_Plan__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_TW_Plan'), name='test',
            ASI_MFM_End_Date__c = Date.newInstance(Date.today().year(),6,30), ASI_MFM_Plan_Description__c = 'veryLongDescriptionveryLongDescriptionveryLongDescriptionveryLongDescriptionveryLongDescriptionveryLongDescriptionveryLongDescriptionveryLongDescriptionveryLongDescriptionveryLongDescriptionveryLongDescription', 
            ASI_MFM_Plan_Name__c = 'planName test', ASI_MFM_Start_Date__c = Date.newInstance(Date.today().year(),6,1), 
            ASI_MFM_Prefix__c=px.id, ASI_MFM_Fiscal_year__c='FY0000', ASI_MFM_Additional_Brand_Manager_1__c=u.id);
            insert p;        
                                    
            ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC', ASI_MFM_A_C_Code__c='5220test', ASI_MFM_A_and_P_Tree__c = 'Total A&P');
            insert ac;
            
            ASI_MFM_A_C_Code__c ac2 = new ASI_MFM_A_C_Code__c(name='testAC', ASI_MFM_A_C_Code__c='Spending per Bottle', ASI_MFM_A_and_P_Tree__c = 'Total A&D');
            insert ac2;
            
            id customerrtId = Global_RecordTypeCache.getRtId('AccountASI_MFM_TW_Customer');
            Account acc2 = new Account(recordTypeId=customerrtId,Name='Name3');           
            insert acc2;
        
            Test.startTest();
            id planLinertId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_TW_Plan_Line_Item');
            
            ASI_MFM_Plan_Line_Item__c pi1 = new ASI_MFM_Plan_Line_Item__c(recordTypeId=planLinertId, ASI_MFM_Plan__c=p.id
                                                                          ,ASI_MFM_Sub_brand_Code__c = subBrand1.id, ASI_MFM_A_C_Code__c=ac2.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription2',ASI_MFM_Size__c='1', ASI_MFM_Total_Cost__c=100);
            insert pi1;
            
            ASI_MFM_Plan_Line_Item__c pi2 = new ASI_MFM_Plan_Line_Item__c(recordTypeId=planLinertId, ASI_MFM_Plan__c=p.id 
                                                                         ,ASI_MFM_Sub_brand_Code__c = subBrand1.id, ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Month_8_Cost__c=100);
            insert pi2;
            
            delete pi1;
            
            Test.stopTest();
        }
    }
}