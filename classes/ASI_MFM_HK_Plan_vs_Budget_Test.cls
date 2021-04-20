/*Test Class on Plan_vs_Budget
Version 0.0.2
Last Modified: 2013-07-23

*/
@isTest
private class ASI_MFM_HK_Plan_vs_Budget_Test {

    static testMethod void ASI_MFM_PlanVsBudgetTest() {
        /*  ------Test Class has been created by TW MFM------
        Test.startTest();
        
        User user1 = getSystemAdminUser();
        user1.ASI_MFM_Bypass_Callouts__c = true;
        //System.debug(user1.ASI_MFM_Country__c);
        //user1.ASI_MFM_Country__c ='TW';
        //update user1;
        
        System.runAs(user1){
            
        Map<string, id> plan_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Plan__c');
        Map<string, id> payment_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Payment__c');
        Map<string, id> po_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PO__c');
        Map<string, id> polineItem_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PO_Line_Item__c');
        Map<string, id> planlineItem_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Plan_Line_Item__c');   
        Map<string, id> acCode_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_A_C_Code__c');
        Map<string, id> subBrandCode_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Sub_brand__c');     
        Map<string, id> budget_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Budget__c');

            
            //Custom Settings
            ASI_MFM_Budget_Type_Mappings__c bugCustSett = new ASI_MFM_Budget_Type_Mappings__c();
            bugCustSett.ASI_MFM_Budget_Type__c = 'LE1';
            bugCustSett.Name = 'HK';
            insert bugCustSett;
            
            
            ASI_MFM_Prefix__c prefixTemp = new ASI_MFM_Prefix__c(Name='HKM13',ASI_MFM_Module__c='Plan',Plan_Type__c='Marketing A&P Plan'
            ,ASI_MFM_Fiscal_year__c='FY1314',ownerId = user1.Id);
            insert prefixTemp;
            
            ASI_MFM_Prefix__c prefix1 = [select id,Name,Plan_Type__c,ASI_MFM_country_name__c from ASI_MFM_Prefix__c where id =: prefixTemp.id];
            System.debug('lab id ' + prefix1.id);
            System.debug('lab name ' + prefix1.Name);
            System.debug('lab PlanType ' + prefix1.Plan_Type__c);
            System.debug('lab ASI_MFM_country_name__c ' + prefix1.ASI_MFM_country_name__c);
            
            ASI_MFM_Role_Prefix_Relationship__c prefixChild1 = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c = prefix1.Id,
            ASI_MFM_Role_Name__c =user1.userRole.developerName);

            insert prefixChild1;

            ASI_MFM_Plan__c Plan1 = new ASI_MFM_Plan__c(Name='HKM131',ASI_MFM_Prefix__c=prefix1.Id
            
            ,recordTypeId=plan_map.get('ASI_MFM_HK_Plan'),
            ASI_MFM_End_Date__c = Date.today().addMonths(1), ASI_MFM_Plan_Description__c='testDescription', 
            ASI_MFM_Plan_Name__c='plannameTest', ASI_MFM_Start_Date__c=Date.today());
            insert Plan1;
            
            ASI_MFM_Sub_brand__c subBrand1 = new ASI_MFM_Sub_brand__c(Name='subBrand1'
            ,recordTypeId=subBrandCode_map.get('ASI_HK_CRM_Sub_brand'));
            insert subBrand1;
            
            ASI_MFM_Sub_brand__c subBrand2 = new ASI_MFM_Sub_brand__c(Name='subBrand2'
            ,recordTypeId=subBrandCode_map.get('ASI_HK_CRM_Sub_brand'));
            insert subBrand2;
            
            map<string, id> rt_map = ASI_MFM_Function.getRecordTypeId('Account');
            ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC');
            insert ac;
            Account acc2 = new Account(recordTypeId=rt_map.get('ASI_HK_CRM_Outlet'),Name='Name3');           
            insert acc2;
            
            ASI_MFM_Plan_Line_Item__c planLineItem1 = new ASI_MFM_Plan_Line_Item__c(ASI_MFM_Plan__c = Plan1.id
            ,ASI_MFM_Sub_brand_Code__c = subBrand1.id,ASI_MFM_List_Item_Description__c='hello1'
            ,recordTypeId=planLineItem_map.get('ASI_MFM_HK_Plan_Line_Item'),
            ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id
            );
            insert planLineItem1;       

            ASI_MFM_Plan_Line_Item__c planLineItem2 = new ASI_MFM_Plan_Line_Item__c(ASI_MFM_Plan__c = Plan1.id
            ,ASI_MFM_Sub_brand_Code__c = subBrand1.id,ASI_MFM_List_Item_Description__c='hello2'
            ,recordTypeId=planLineItem_map.get('ASI_MFM_HK_Plan_Line_Item'),
            ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id
            );
            insert planLineItem2; 
            
            ASI_MFM_Budget__c budget1 = new ASI_MFM_Budget__c(ASI_MFM_Sub_brand_Code__c=subBrand1.id
            ,ASI_MFM_Fiscal_Year__c='FY1314',ASI_MFM_P1_Amount__c=1000
            ,recordTypeId=budget_map.get('ASI_MFM_HK_Budget')
            );
            insert budget1;
            
            ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(Plan1);
            ASI_MFM_PlanReportPageController controller = new ASI_MFM_PlanReportPageController(stdController);
        
        }   
        Test.stopTest();
        */
    }
    
    
    
    
    public static User getSystemAdminUser(){      
    
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];         
        User u1 = [select id,Name,ASI_MFM_Bypass_Callouts__c,ASI_MFM_Country__c, userRole.developerName from User where profileId =: p.Id 
        and isActive =: true limit 1];      
        return u1;

    }
}