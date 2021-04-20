@isTest
//ASI_MFM_SelectPaymentPrefixController
//ASI_MFM_SelectPOPrefixController
// ASI_MFM_SelectPlanPrefixController
private class ASI_MFM_PH_Prefix_TestClass {
    
    static testMethod void SelectPaymentPrefix1(){
        //DF 1 DF prefix
        List<ASI_MFM_Prefix__c> prefixList = new List<ASI_MFM_Prefix__c>();
        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='DFPHPayment', ASI_MFM_Module__c='Payment');
        prefixList.add(pxo);
        ASI_MFM_Prefix__c pxa = new ASI_MFM_Prefix__c(name='testpayment', ASI_MFM_Module__c='Payment');
        prefixList.add(pxa);
        insert prefixList;
        
        //User
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];
        u.ASI_MFM_Country__c = 'PH';
        update u;
        
        // Role Prefix Relationship
        List<ASI_MFM_Role_Prefix_Relationship__c> RPList = new List<ASI_MFM_Role_Prefix_Relationship__c>();
        ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        RPList.add(pro);
        ASI_MFM_Role_Prefix_Relationship__c pra = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        RPList.add(pra);
        insert RPList;
        
        List<Account> accList = ASI_MFM_PH_TestClassHelper.createDFAccount();
        
        ASI_MFM_Payment__c py = new ASI_MFM_Payment__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_PH_DF_Payment'), ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Payment_Date__c=date.today(),ASI_MFM_Supplier_Name__c = accList[0].id);  
        insert py;
        
        ApexPages.currentPage().getParameters().put('RecordType',Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_PH_DF_Payment') );
        
            
        ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(py);        
        ASI_MFM_SelectPaymentPrefixController ASI_MFM_SelectPaPrefixController = new ASI_MFM_SelectPaymentPrefixController(stdController);
        ASI_MFM_SelectPaPrefixController.getPrefixes();
        ASI_MFM_SelectPaPrefixController.proceed();
        
    }
    
      
    static testMethod void SelectPaymentPrefix2(){
        //DF 2 DF prefix
        List<ASI_MFM_Prefix__c> prefixList = new List<ASI_MFM_Prefix__c>();
        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='DFPHPayment', ASI_MFM_Module__c='Payment');
        prefixList.add(pxo);
        ASI_MFM_Prefix__c pxa = new ASI_MFM_Prefix__c(name='DFPHPayment2', ASI_MFM_Module__c='Payment');
        prefixList.add(pxa);
        insert prefixList;
        
        //User
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];
        u.ASI_MFM_Country__c = 'PH';
        update u;
        
        // Role Prefix Relationship
        List<ASI_MFM_Role_Prefix_Relationship__c> RPList = new List<ASI_MFM_Role_Prefix_Relationship__c>();
        ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        RPList.add(pro);
        ASI_MFM_Role_Prefix_Relationship__c pra = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        RPList.add(pra);
        insert RPList;
        
        List<Account> accList = ASI_MFM_PH_TestClassHelper.createDFAccount();
        
        ASI_MFM_Payment__c py = new ASI_MFM_Payment__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_PH_DF_Payment'), ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Payment_Date__c=date.today(),ASI_MFM_Supplier_Name__c = accList[0].id);  
        insert py;
        
        ApexPages.currentPage().getParameters().put('RecordType',Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_PH_DF_Payment') );
        
            
        ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(py);        
        ASI_MFM_SelectPaymentPrefixController ASI_MFM_SelectPaPrefixController = new ASI_MFM_SelectPaymentPrefixController(stdController);
        ASI_MFM_SelectPaPrefixController.getPrefixes();
        ASI_MFM_SelectPaPrefixController.proceed();
        
    }
    
    

    
    static testMethod void SelectPaymentPrefix3(){
        //DF 1 DP prefix
        List<ASI_MFM_Prefix__c> prefixList = new List<ASI_MFM_Prefix__c>();
        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='DPPHPayment', ASI_MFM_Module__c='Payment');
        prefixList.add(pxo);
        ASI_MFM_Prefix__c pxa = new ASI_MFM_Prefix__c(name='testpayment', ASI_MFM_Module__c='Payment');
        prefixList.add(pxa);
        insert prefixList;
        
        //User
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];
        u.ASI_MFM_Country__c = 'PH';
        update u;
        
        // Role Prefix Relationship
        List<ASI_MFM_Role_Prefix_Relationship__c> RPList = new List<ASI_MFM_Role_Prefix_Relationship__c>();
        ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        RPList.add(pro);
        ASI_MFM_Role_Prefix_Relationship__c pra = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        RPList.add(pra);
        insert RPList;
        
        List<Account> accList = ASI_MFM_PH_TestClassHelper.createDFAccount();
        
        ASI_MFM_Payment__c py = new ASI_MFM_Payment__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_PH_DP_Payment'), ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Payment_Date__c=date.today(),ASI_MFM_Supplier_Name__c = accList[0].id);  
        insert py;
        
        ApexPages.currentPage().getParameters().put('RecordType',Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_PH_DP_Payment') );
        
            
        ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(py);        
        ASI_MFM_SelectPaymentPrefixController ASI_MFM_SelectPaPrefixController = new ASI_MFM_SelectPaymentPrefixController(stdController);
        ASI_MFM_SelectPaPrefixController.getPrefixes();
        ASI_MFM_SelectPaPrefixController.proceed();
        
    }
    
      
    static testMethod void SelectPaymentPrefix4(){
        //DF 2 DP prefix
        List<ASI_MFM_Prefix__c> prefixList = new List<ASI_MFM_Prefix__c>();
        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='DPPHPayment', ASI_MFM_Module__c='Payment');
        prefixList.add(pxo);
        ASI_MFM_Prefix__c pxa = new ASI_MFM_Prefix__c(name='DPPHPayment2', ASI_MFM_Module__c='Payment');
        prefixList.add(pxa);
        insert prefixList;
        
        //User
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];
        u.ASI_MFM_Country__c = 'PH';
        update u;
        
        // Role Prefix Relationship
        List<ASI_MFM_Role_Prefix_Relationship__c> RPList = new List<ASI_MFM_Role_Prefix_Relationship__c>();
        ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        RPList.add(pro);
        ASI_MFM_Role_Prefix_Relationship__c pra = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        RPList.add(pra);
        insert RPList;
        
        List<Account> accList = ASI_MFM_PH_TestClassHelper.createDFAccount();
        
        ASI_MFM_Payment__c py = new ASI_MFM_Payment__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_PH_DP_Payment'), ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Payment_Date__c=date.today(),ASI_MFM_Supplier_Name__c = accList[0].id);  
        insert py;
        
        ApexPages.currentPage().getParameters().put('RecordType',Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_PH_DP_Payment') );
        
            
        ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(py);        
        ASI_MFM_SelectPaymentPrefixController ASI_MFM_SelectPaPrefixController = new ASI_MFM_SelectPaymentPrefixController(stdController);
        ASI_MFM_SelectPaPrefixController.getPrefixes();
        ASI_MFM_SelectPaPrefixController.proceed();
        
    }
        
}