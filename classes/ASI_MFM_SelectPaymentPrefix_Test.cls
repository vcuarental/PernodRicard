@isTest
private class ASI_MFM_SelectPaymentPrefix_Test {
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
        
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Payment', ASI_MFM_Fiscal_year__c=getFiscalYear(),ASI_MFM_Inactive__c = false);
        insert px;
        
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;

        Map<String, id> MPaymentRecType = ASI_MFM_function.getRecordTypeId('ASI_MFM_Payment__c');        
        String recType=((String)MPaymentRecType.get('ASI_MFM_CN_Payment')).substring(0,15);
system.debug('cn rectype='+recType);   
        
        PageReference pageRef = new Pagereference('/apex/ASI_MFM_SelectPaymentPrefixPage');
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('RecordType', recType);   // change status as draft
        ASI_MFM_SelectPaymentPrefixController ext1 = new ASI_MFM_SelectPaymentPrefixController(new apexpages.standardController(new ASI_MFM_Payment__c()));
        ext1.getPrefixes();
    }
   
   
    static testMethod void Test2(){
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];
        u.ASI_MFM_Country__c = 'PH';
        update u;
        
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Payment', ASI_MFM_Fiscal_year__c=getFiscalYear(),ASI_MFM_Inactive__c = false);
        insert px;
        
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        
        ASI_MFM_Prefix__c px2 = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Payment', ASI_MFM_Fiscal_year__c=getFiscalYear(),ASI_MFM_Inactive__c = false);
        insert px2;
        
        ASI_MFM_Role_Prefix_Relationship__c pr2 = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px2.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr2;

        Map<String, id> MPaymentRecType = ASI_MFM_function.getRecordTypeId('ASI_MFM_Payment__c');        
        String recType=((String)MPaymentRecType.get('ASI_MFM_PH_DP_Payment')).substring(0,15);
        PageReference pageRef = new Pagereference('/apex/ASI_MFM_SelectPaymentPrefixPage');
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('RecordType', recType);   // change status as draft
        ASI_MFM_SelectPaymentPrefixController ext1 = new ASI_MFM_SelectPaymentPrefixController(new apexpages.standardController(new ASI_MFM_Payment__c()));
        ext1.getPrefixes();
        
        recType=((String)MPaymentRecType.get('ASI_MFM_PH_DF_Payment')).substring(0,15);
        pageRef = new Pagereference('/apex/ASI_MFM_SelectPaymentPrefixPage');
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('RecordType', recType);   // change status as draft
        ext1 = new ASI_MFM_SelectPaymentPrefixController(new apexpages.standardController(new ASI_MFM_Payment__c()));
        ext1.getPrefixes();
        
        recType=((String)MPaymentRecType.get('ASI_MFM_HK_Payment')).substring(0,15);
 system.debug('hk rectype='+recType);       
        pageRef = new Pagereference('/apex/ASI_MFM_SelectPaymentPrefixPage');
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('RecordType', recType);   // change status as draft
        ext1 = new ASI_MFM_SelectPaymentPrefixController(new apexpages.standardController(new ASI_MFM_Payment__c()));
        ext1.getPrefixes();
    }
    
    static testMethod void Test3(){
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];
        u.ASI_MFM_Country__c = 'HK';
        update u;
        
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Payment', ASI_MFM_Fiscal_year__c=getFiscalYear(),ASI_MFM_Inactive__c = false);
        insert px;
        
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;

        Map<String, id> MPaymentRecType = ASI_MFM_function.getRecordTypeId('ASI_MFM_Payment__c');        
        String recType=((String)MPaymentRecType.get('ASI_MFM_HK_Payment')).substring(0,15);
 system.debug('hk rectype='+recType);
        PageReference pageRef = new Pagereference('/apex/ASI_MFM_SelectPaymentPrefixPage');
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('RecordType', recType);   // change status as draft
        ASI_MFM_SelectPaymentPrefixController ext1 = new ASI_MFM_SelectPaymentPrefixController(new apexpages.standardController(new ASI_MFM_Payment__c()));
        ext1.getPrefixes();
    }
    
    static testMethod void Test4(){
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];
        u.ASI_MFM_Country__c = 'HK';
        update u;
        
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Payment', ASI_MFM_Fiscal_year__c=getFiscalYear(),ASI_MFM_Inactive__c = false);
        insert px;
        
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        
        ASI_MFM_Prefix__c px2 = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Payment', ASI_MFM_Fiscal_year__c=getFiscalYear(),ASI_MFM_Inactive__c = false);
        insert px2;
        
        ASI_MFM_Role_Prefix_Relationship__c pr2 = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px2.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr2;

        Map<String, id> MPaymentRecType = ASI_MFM_function.getRecordTypeId('ASI_MFM_Payment__c');        
        String recType=((String)MPaymentRecType.get('ASI_MFM_SC_Payment')).substring(0,15);
 system.debug('SC rectype='+recType);
        PageReference pageRef = new Pagereference('/apex/ASI_MFM_SelectPaymentPrefixPage');
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('RecordType', recType);   // change status as draft
        ASI_MFM_SelectPaymentPrefixController ext1 = new ASI_MFM_SelectPaymentPrefixController(new apexpages.standardController(new ASI_MFM_Payment__c()));
        ext1.getPrefixes();
    }
    
    static testMethod void Test5(){
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];
        u.ASI_MFM_Country__c = 'KR';
        update u;
        
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Payment', ASI_MFM_Fiscal_year__c=getFiscalYear(),ASI_MFM_Inactive__c = false);
        insert px;
        
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        
        Map<String, id> MPaymentRecType = ASI_MFM_function.getRecordTypeId('ASI_MFM_Payment__c');        
        String recType=((String)MPaymentRecType.get('ASI_MFM_KR_Payment')).substring(0,15);
system.debug('KR rectype='+recType);  
        PageReference pageRef = new Pagereference('/apex/ASI_MFM_SelectPaymentPrefixPage');
        Test.setCurrentPage(pageRef);
      
        ApexPages.currentPage().getParameters().put('RecordType', recType);   // change status as draft
   //     ApexPages.currentPage().getParameters().put('prefixid', recType);
        ApexPages.currentPage().getParameters().put('prid', recType);
        ApexPages.currentPage().getParameters().put('shiptoaddress', recType);
        ApexPages.currentPage().getParameters().put('shiptoid', recType);
        
        ASI_MFM_SelectPaymentPrefixController ext1 = new ASI_MFM_SelectPaymentPrefixController(new apexpages.standardController(new ASI_MFM_Payment__c()));
        ext1.getPrefixes();
    }
    
    static testMethod void Test6(){
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];
        u.ASI_MFM_Country__c = 'JP';
        update u;
        
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Payment', ASI_MFM_Fiscal_year__c=getFiscalYear(),ASI_MFM_Inactive__c = false);
        insert px;
        
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        

        Map<String, id> MPaymentRecType = ASI_MFM_function.getRecordTypeId('ASI_MFM_Payment__c');        
        String recType=((String)MPaymentRecType.get('ASI_MFM_JP_Payment')).substring(0,15);
 system.debug('sg rectype='+recType);
        PageReference pageRef = new Pagereference('/apex/ASI_MFM_SelectPaymentPrefixPage');
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('RecordType', recType);   // change status as draft
        ApexPages.currentPage().getParameters().put('PaymentType','test');
        ApexPages.currentPage().getParameters().put('BudgetOwnerId',recType);
        ApexPages.currentPage().getParameters().put('supplierId',recType);
        ASI_MFM_SelectPaymentPrefixController ext1 = new ASI_MFM_SelectPaymentPrefixController(new apexpages.standardController(new ASI_MFM_Payment__c()));
        ext1.getPrefixes();
    }
    
    static testMethod void Test7(){
        try{
            user u = [select userRole.developerName from user where id = :userInfo.getUserId()];
            u.ASI_MFM_Country__c = 'SG';
            update u;
            
            ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Payment', ASI_MFM_Fiscal_year__c=getFiscalYear(),ASI_MFM_Inactive__c = false);
            insert px;
            
            ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
            insert pr;
            
    
            PageReference pageRef = new Pagereference('/apex/ASI_MFM_SelectPaymentPrefixPage');
            Test.setCurrentPage(pageRef);
            
            
            ASI_MFM_SelectPaymentPrefixController ext1 = new ASI_MFM_SelectPaymentPrefixController(new apexpages.standardController(new ASI_MFM_Payment__c()));
            ext1.getPrefixes();
            
        }catch(Exception e ){
            
            system.debug('error message:::::'+ e.getMessage());
        }
    }
}