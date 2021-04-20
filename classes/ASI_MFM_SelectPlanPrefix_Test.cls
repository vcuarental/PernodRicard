@isTest
private class ASI_MFM_SelectPlanPrefix_Test {
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
    
    static testMethod void Test1(){
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];
        u.ASI_MFM_Country__c = 'CN';
        update u;
        
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', ASI_MFM_Fiscal_year__c=getFiscalYear(),ASI_MFM_Inactive__c = false);
        insert px;
        
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;

        Map<String, id> MPlanRecType = ASI_MFM_function.getRecordTypeId('ASI_MFM_Plan__c');        
        String recType=((String)MPlanRecType.get('ASI_MFM_CN_Plan')).substring(0,15);
        PageReference pageRef = new Pagereference('/apex/ASI_MFM_SelectPlanPrefixPage');
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('RecordType', recType);   // change status as draft
        ASI_MFM_SelectPlanPrefixController ext1 = new ASI_MFM_SelectPlanPrefixController(new apexpages.standardController(new asi_mfm_plan__c()));
        ext1.getPrefixes();
    }
   
   
    static testMethod void Test2(){
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];
        u.ASI_MFM_Country__c = 'PH';
        update u;
        
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', asi_mfm_module__c='Payment', ASI_MFM_Fiscal_year__c=getFiscalYear(),ASI_MFM_Inactive__c = false, OwnerID = u.ID);
        insert px;
        
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        
        ASI_MFM_Prefix__c px2 = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', ASI_MFM_Fiscal_year__c=getFiscalYear(),ASI_MFM_Inactive__c = false);
        insert px2;
        
        ASI_MFM_Role_Prefix_Relationship__c pr2 = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px2.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr2;

        Map<String, id> MPlanRecType = ASI_MFM_function.getRecordTypeId('ASI_MFM_Plan__c');        
        String recType=((String)MPlanRecType.get('ASI_MFM_PH_DP_Plan')).substring(0,15);
        PageReference pageRef = new Pagereference('/apex/ASI_MFM_SelectPlanPrefixPage');
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('RecordType', recType);   // change status as draft
        ASI_MFM_SelectPlanPrefixController ext1 = new ASI_MFM_SelectPlanPrefixController(new apexpages.standardController(new asi_mfm_plan__c()));
        ext1.getPrefixes();
        
        recType=((String)MPlanRecType.get('ASI_MFM_PH_DF_Plan')).substring(0,15);
        pageRef = new Pagereference('/apex/ASI_MFM_SelectPlanPrefixPage');
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('RecordType', recType);   // change status as draft
        ext1 = new ASI_MFM_SelectPlanPrefixController(new apexpages.standardController(new asi_mfm_plan__c()));
        ext1.getPrefixes();
        
        recType=((String)MPlanRecType.get('ASI_MFM_HK_Plan')).substring(0,15);
        pageRef = new Pagereference('/apex/ASI_MFM_SelectPlanPrefixPage');
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('RecordType', recType);   // change status as draft
        ext1 = new ASI_MFM_SelectPlanPrefixController(new apexpages.standardController(new asi_mfm_plan__c()));
        ext1.getPrefixes();
    }
    
    static testMethod void Test3(){
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];
        u.ASI_MFM_Country__c = 'HK';
        update u;
        
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', ASI_MFM_Fiscal_year__c=getFiscalYear(),ASI_MFM_Inactive__c = false);
        insert px;
        
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;

        Map<String, id> MPlanRecType = ASI_MFM_function.getRecordTypeId('ASI_MFM_Plan__c');        
        String recType=((String)MPlanRecType.get('ASI_MFM_HK_Plan')).substring(0,15);
        PageReference pageRef = new Pagereference('/apex/ASI_MFM_SelectPlanPrefixPage');
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('RecordType', recType);   // change status as draft
        ASI_MFM_SelectPlanPrefixController ext1 = new ASI_MFM_SelectPlanPrefixController(new apexpages.standardController(new asi_mfm_plan__c()));
        ext1.getPrefixes();
    }
    
    static testMethod void Test4(){
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];
        u.ASI_MFM_Country__c = 'HK';
        update u;
        
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', ASI_MFM_Fiscal_year__c=getFiscalYear(),ASI_MFM_Inactive__c = false);
        insert px;
        
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        
        ASI_MFM_Prefix__c px2 = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', ASI_MFM_Fiscal_year__c=getFiscalYear(),ASI_MFM_Inactive__c = false);
        insert px2;
        
        ASI_MFM_Role_Prefix_Relationship__c pr2 = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px2.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr2;

        Map<String, id> MPlanRecType = ASI_MFM_function.getRecordTypeId('ASI_MFM_Plan__c');        
        String recType=((String)MPlanRecType.get('ASI_MFM_SC_Plan')).substring(0,15);
        PageReference pageRef = new Pagereference('/apex/ASI_MFM_SelectPlanPrefixPage');
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('RecordType', recType);   // change status as draft
        ASI_MFM_SelectPlanPrefixController ext1 = new ASI_MFM_SelectPlanPrefixController(new apexpages.standardController(new asi_mfm_plan__c()));
        ext1.getPrefixes();
    }

    // static testMethod void Test5(){
    //     user u = [select userRole.developerName from user where id = :userInfo.getUserId()];
    //     u.ASI_MFM_Country__c = 'VN';
    //     update u;

    //     ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', ASI_MFM_Fiscal_year__c=getFiscalYear(),ASI_MFM_Inactive__c = false);
    //     insert px;

    //     ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
    //     insert pr;

    //     ASI_MFM_Prefix__c px2 = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', ASI_MFM_Fiscal_year__c=getFiscalYear(),ASI_MFM_Inactive__c = false);
    //     insert px2;

    //     ASI_MFM_Role_Prefix_Relationship__c pr2 = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px2.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
    //     insert pr2;

    //     Map<String, id> MPlanRecType = ASI_MFM_function.getRecordTypeId('ASI_MFM_Plan__c');
    //     String recType=((String)MPlanRecType.get('ASI_MFM_VN_DP_Plan')).substring(0,15);
    //     PageReference pageRef = new Pagereference('/apex/ASI_MFM_SelectPlanPrefixPage');
    //     Test.setCurrentPage(pageRef);

    //     ApexPages.currentPage().getParameters().put('RecordType', recType);   // change status as draft
    //     ASI_MFM_SelectPlanPrefixController ext1 = new ASI_MFM_SelectPlanPrefixController(new apexpages.standardController(new asi_mfm_plan__c()));
    //     ext1.getPrefixes();

    //     recType=((String)MPlanRecType.get('ASI_MFM_VN_DF_Plan')).substring(0,15);
    //     pageRef = new Pagereference('/apex/ASI_MFM_SelectPlanPrefixPage');
    //     Test.setCurrentPage(pageRef);

    //     ApexPages.currentPage().getParameters().put('RecordType', recType);   // change status as draft
    //     ext1 = new ASI_MFM_SelectPlanPrefixController(new apexpages.standardController(new asi_mfm_plan__c()));
    //     ext1.getPrefixes();

    //     recType=((String)MPlanRecType.get('ASI_MFM_HK_Plan')).substring(0,15);
    //     pageRef = new Pagereference('/apex/ASI_MFM_SelectPlanPrefixPage');
    //     Test.setCurrentPage(pageRef);

    //     ApexPages.currentPage().getParameters().put('RecordType', recType);   // change status as draft
    //     ext1 = new ASI_MFM_SelectPlanPrefixController(new apexpages.standardController(new asi_mfm_plan__c()));
    //     ext1.getPrefixes();
    // }
}