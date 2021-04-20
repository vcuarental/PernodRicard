/*
ASI_KOR_POSM_Order_Request_TriggerClass

ASI_MFM_KR_POSMManageAllController2



*/

@istest
public class ASI_MFM_KR_POSMTestClass {
    
    static testMethod void ASI_KOR_POSM_Order_Request_TriggerClassTest(){
        
        //Test class ASI_KOR_POSM_Order_Request_TriggerClass
        userrole Role_Test= new userrole(Name='XXXTrade Marketing',developerName = 'test');
        insert Role_Test;
        
        List<user> userList= new List<user>();
        
        user u = [select userRole.developerName, ASI_MFM_Country__c,UserRoleid,CompanyName from user where id = :userInfo.getUserId() limit 1]; 
        u.ASI_MFM_Country__c = 'KR';
        u.UserRoleid =Role_Test.id;
        u.CompanyName = 'Pernod Ricard Korea';
        update u;
        
        
        User u2 = ASI_TnE_TestClassHelper.newUser('testApprover');
        u2.ASI_MFM_Country__c = 'KR';
        u2.UserRoleid =Role_Test.id;
        u2.CompanyName = 'Pernod Ricard Korea';
        u2.Department = 'test';
        userList.add(u2);
        
        
        User u3 = ASI_TnE_TestClassHelper.newUser('testApprover2');
        u3.ASI_MFM_Country__c = 'KR';
        u3.UserRoleid =Role_Test.id;
        u3.CompanyName = 'Pernod Ricard Korea';
        u3.Department = 'test';
        userList.add(u3);
        
        User u4 = ASI_TnE_TestClassHelper.newUser('testApprover3');
        u4.ASI_MFM_Country__c = 'KR';
        u4.UserRoleid =Role_Test.id;
        u4.CompanyName = 'Pernod Ricard Korea';
        u4.Department = 'test';
        userList.add(u4);
        
        User u5 = ASI_TnE_TestClassHelper.newUser('testApprover4');
        u5.ASI_MFM_Country__c = 'KR';
        u5.UserRoleid =Role_Test.id;
        u5.CompanyName = 'Pernod Ricard Korea';
        u5.Department = 'test';
        userList.add(u5);
        
        User u6 = ASI_TnE_TestClassHelper.newUser('testApprover5');
        u6.ASI_MFM_Country__c = 'KR';
        u6.UserRoleid =Role_Test.id;
        u6.CompanyName = 'Pernod Ricard Korea';
        u6.Department = 'test';
        userList.add(u6);
        
        User u7 = ASI_TnE_TestClassHelper.newUser('testApprover6');
        u7.ASI_MFM_Country__c = 'KR';
        u7.UserRoleid =Role_Test.id;
        u7.CompanyName = 'Pernod Ricard Korea';
        u7.Department = 'test';
        userList.add(u7);
        
        User u8 = ASI_TnE_TestClassHelper.newUser('testApprover7');
        u8.ASI_MFM_Country__c = 'KR';
        u8.UserRoleid =Role_Test.id;
        u8.CompanyName = 'Pernod Ricard Korea';
        u8.Department = 'test';
        userList.add(u8);
        
        User u9 = ASI_TnE_TestClassHelper.newUser('testApprover8');
        u9.ASI_MFM_Country__c = 'KR';
        u9.UserRoleid =Role_Test.id;
        u9.CompanyName = 'Pernod Ricard Korea';
        u9.Department = 'test';
        userList.add(u9);
        
         
        User u10 = ASI_TnE_TestClassHelper.newUser('testApprover9');
        u10.ASI_MFM_Country__c = 'KR';
        u10.UserRoleid =Role_Test.id;
        u10.CompanyName = 'Pernod Ricard Korea';
        u10.Department = 'test';
        userList.add(u10);
        
        User u11 = ASI_TnE_TestClassHelper.newUser('testApprover10');
        u11.ASI_MFM_Country__c = 'KR';
        u11.UserRoleid =Role_Test.id;
        u11.CompanyName = 'Pernod Ricard Korea';
        u11.Department = 'test';
        userList.add(u11);
        
        insert userList;
        
        System.runAs(u){ 
            map<string, id> rt_map = ASI_MFM_Function.getRecordTypeId('ASI_KOR_POSM_Order_Request__c'); 
            rt_map = ASI_MFM_Function.getRecordTypeId('Account');
            Account acc1 = new Account(recordTypeId=rt_map.get('ASI_KOR_Venue'),Name='Name1');          
            insert acc1;
            
            List<ASI_KOR_POSM_Product__c> ProductList = new List<ASI_KOR_POSM_Product__c> ();
            ASI_KOR_POSM_Product__c POSM_Product = new ASI_KOR_POSM_Product__c(ASI_MFM_Product_Owner__c=u.ID,recordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_POSM_Product__cASI_KOR_POSM_Product'), Name='TestProduct',ASI_MFM_Vender_Email_address__c='Test@gmail.com');
            ProductList.add(POSM_Product);
            ASI_KOR_POSM_Product__c POSM_Product2 = new ASI_KOR_POSM_Product__c(ASI_MFM_Product_Owner__c=u2.ID,recordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_POSM_Product__cASI_KOR_POSM_Product'), Name='TestProduct',ASI_MFM_Vender_Email_address__c='Test@gmail.com');
            ProductList.add(POSM_Product2);
            ASI_KOR_POSM_Product__c POSM_Product3 = new ASI_KOR_POSM_Product__c(ASI_MFM_Product_Owner__c=u3.ID,recordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_POSM_Product__cASI_KOR_POSM_Product'), Name='TestProduct',ASI_MFM_Vender_Email_address__c='Test@gmail.com');
            ProductList.add(POSM_Product3);
            ASI_KOR_POSM_Product__c POSM_Product4 = new ASI_KOR_POSM_Product__c(ASI_MFM_Product_Owner__c=u4.ID,recordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_POSM_Product__cASI_KOR_POSM_Product'), Name='TestProduct',ASI_MFM_Vender_Email_address__c='Test@gmail.com');
            ProductList.add(POSM_Product4);
            ASI_KOR_POSM_Product__c POSM_Product5 = new ASI_KOR_POSM_Product__c(ASI_MFM_Product_Owner__c=u5.ID,recordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_POSM_Product__cASI_KOR_POSM_Product'), Name='TestProduct',ASI_MFM_Vender_Email_address__c='Test@gmail.com');
            ProductList.add(POSM_Product5);
            ASI_KOR_POSM_Product__c POSM_Product6 = new ASI_KOR_POSM_Product__c(ASI_MFM_Product_Owner__c=u6.ID,recordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_POSM_Product__cASI_KOR_POSM_Product'), Name='TestProduct',ASI_MFM_Vender_Email_address__c='Test@gmail.com');
            ProductList.add(POSM_Product6);
            ASI_KOR_POSM_Product__c POSM_Product7 = new ASI_KOR_POSM_Product__c(ASI_MFM_Product_Owner__c=u7.ID,recordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_POSM_Product__cASI_KOR_POSM_Product'), Name='TestProduct',ASI_MFM_Vender_Email_address__c='Test@gmail.com');
            ProductList.add(POSM_Product7);
            
            ASI_KOR_POSM_Product__c POSM_Product8 = new ASI_KOR_POSM_Product__c(ASI_MFM_Product_Owner__c=u8.ID,recordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_POSM_Product__cASI_KOR_POSM_Product'), Name='TestProduct',ASI_MFM_Vender_Email_address__c='Test@gmail.com');
            ProductList.add(POSM_Product8);
            ASI_KOR_POSM_Product__c POSM_Product9 = new ASI_KOR_POSM_Product__c(ASI_MFM_Product_Owner__c=u9.ID,recordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_POSM_Product__cASI_KOR_POSM_Product'), Name='TestProduct',ASI_MFM_Vender_Email_address__c='Test@gmail.com');
            ProductList.add(POSM_Product9);
            ASI_KOR_POSM_Product__c POSM_Product10 = new ASI_KOR_POSM_Product__c(ASI_MFM_Product_Owner__c=u10.ID,recordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_POSM_Product__cASI_KOR_POSM_Product'), Name='TestProduct',ASI_MFM_Vender_Email_address__c='Test@gmail.com');
            ProductList.add(POSM_Product10);
            ASI_KOR_POSM_Product__c POSM_Product11 = new ASI_KOR_POSM_Product__c(ASI_MFM_Product_Owner__c=u11.ID,recordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_POSM_Product__cASI_KOR_POSM_Product'), Name='TestProduct',ASI_MFM_Vender_Email_address__c='Test@gmail.com');
            ProductList.add(POSM_Product11);
            insert ProductList;
            
            ASI_KOR_POSM_Order_Request__c POSM_Header= new ASI_KOR_POSM_Order_Request__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_POSM_Order_Request__cASI_KOR_New_High_Value_POSM_Request'),ASI_KOR_POSM_TO_Venue__c=acc1.id, ASI_KOR_Status__c='Submitted');
            insert POSM_Header; 
            
            ASI_MFM_Sub_brand__c SubBrand = new ASI_MFM_Sub_brand__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_KR_Sub_Brand'), Name='TestSubBrand',ASI_MFM_Sub_brand_Code__c='Code');
            insert SubBrand;    
            
            List<ASI_KOR_POSM_Order_Detail__c> POSMLineList = new List<ASI_KOR_POSM_Order_Detail__c>();
            ASI_KOR_POSM_Order_Detail__c POSM_Line = new ASI_KOR_POSM_Order_Detail__c(ASI_KOR_UnitCost__c=10,ASI_KOR_Quantity__c=10,recordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_POSM_Order_Detail__cASI_MFM_KR_HV_POSM_Order_Detail'),ASI_KOR_POSM_Order_Request__c = POSM_Header.id, ASI_KOR_SubBrand__c=SubBrand.id,ASI_KOR_Item_Name__c = POSM_Product.id);
            POSMLineList.add(POSM_Line);
            ASI_KOR_POSM_Order_Detail__c POSM_Line1 = new ASI_KOR_POSM_Order_Detail__c(ASI_KOR_UnitCost__c=10,ASI_KOR_Quantity__c=10,recordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_POSM_Order_Detail__cASI_MFM_KR_HV_POSM_Order_Detail'),ASI_KOR_POSM_Order_Request__c = POSM_Header.id, ASI_KOR_SubBrand__c=SubBrand.id,ASI_KOR_Item_Name__c = POSM_Product2.id);
            POSMLineList.add(POSM_Line1);
            ASI_KOR_POSM_Order_Detail__c POSM_Line2 = new ASI_KOR_POSM_Order_Detail__c(ASI_KOR_UnitCost__c=10,ASI_KOR_Quantity__c=10,recordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_POSM_Order_Detail__cASI_MFM_KR_HV_POSM_Order_Detail'),ASI_KOR_POSM_Order_Request__c = POSM_Header.id, ASI_KOR_SubBrand__c=SubBrand.id,ASI_KOR_Item_Name__c = POSM_Product3.id);
            POSMLineList.add(POSM_Line2);
            ASI_KOR_POSM_Order_Detail__c POSM_Line3 = new ASI_KOR_POSM_Order_Detail__c(ASI_KOR_UnitCost__c=10,ASI_KOR_Quantity__c=10,recordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_POSM_Order_Detail__cASI_MFM_KR_HV_POSM_Order_Detail'),ASI_KOR_POSM_Order_Request__c = POSM_Header.id, ASI_KOR_SubBrand__c=SubBrand.id,ASI_KOR_Item_Name__c = POSM_Product4.id);
            POSMLineList.add(POSM_Line3);
            ASI_KOR_POSM_Order_Detail__c POSM_Line4 = new ASI_KOR_POSM_Order_Detail__c(ASI_KOR_UnitCost__c=10,ASI_KOR_Quantity__c=10,recordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_POSM_Order_Detail__cASI_MFM_KR_HV_POSM_Order_Detail'),ASI_KOR_POSM_Order_Request__c = POSM_Header.id, ASI_KOR_SubBrand__c=SubBrand.id,ASI_KOR_Item_Name__c = POSM_Product5.id);
            POSMLineList.add(POSM_Line4);
            ASI_KOR_POSM_Order_Detail__c POSM_Line5 = new ASI_KOR_POSM_Order_Detail__c(ASI_KOR_UnitCost__c=10,ASI_KOR_Quantity__c=10,recordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_POSM_Order_Detail__cASI_MFM_KR_HV_POSM_Order_Detail'),ASI_KOR_POSM_Order_Request__c = POSM_Header.id, ASI_KOR_SubBrand__c=SubBrand.id,ASI_KOR_Item_Name__c = POSM_Product6.id);
            POSMLineList.add(POSM_Line5);
            ASI_KOR_POSM_Order_Detail__c POSM_Line6 = new ASI_KOR_POSM_Order_Detail__c(ASI_KOR_UnitCost__c=10,ASI_KOR_Quantity__c=10,recordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_POSM_Order_Detail__cASI_MFM_KR_HV_POSM_Order_Detail'),ASI_KOR_POSM_Order_Request__c = POSM_Header.id, ASI_KOR_SubBrand__c=SubBrand.id,ASI_KOR_Item_Name__c = POSM_Product7.id);
            POSMLineList.add(POSM_Line6);            
            ASI_KOR_POSM_Order_Detail__c POSM_Line7 = new ASI_KOR_POSM_Order_Detail__c(ASI_KOR_UnitCost__c=10,ASI_KOR_Quantity__c=10,recordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_POSM_Order_Detail__cASI_MFM_KR_HV_POSM_Order_Detail'),ASI_KOR_POSM_Order_Request__c = POSM_Header.id, ASI_KOR_SubBrand__c=SubBrand.id,ASI_KOR_Item_Name__c = POSM_Product8.id);
            POSMLineList.add(POSM_Line7);
            ASI_KOR_POSM_Order_Detail__c POSM_Line8 = new ASI_KOR_POSM_Order_Detail__c(ASI_KOR_UnitCost__c=10,ASI_KOR_Quantity__c=10,recordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_POSM_Order_Detail__cASI_MFM_KR_HV_POSM_Order_Detail'),ASI_KOR_POSM_Order_Request__c = POSM_Header.id, ASI_KOR_SubBrand__c=SubBrand.id,ASI_KOR_Item_Name__c = POSM_Product9.id);
            POSMLineList.add(POSM_Line8);
            ASI_KOR_POSM_Order_Detail__c POSM_Line9 = new ASI_KOR_POSM_Order_Detail__c(ASI_KOR_UnitCost__c=10,ASI_KOR_Quantity__c=10,recordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_POSM_Order_Detail__cASI_MFM_KR_HV_POSM_Order_Detail'),ASI_KOR_POSM_Order_Request__c = POSM_Header.id, ASI_KOR_SubBrand__c=SubBrand.id,ASI_KOR_Item_Name__c = POSM_Product10.id);
            POSMLineList.add(POSM_Line9);
            ASI_KOR_POSM_Order_Detail__c POSM_Line10 = new ASI_KOR_POSM_Order_Detail__c(ASI_KOR_UnitCost__c=10,ASI_KOR_Quantity__c=10,recordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_POSM_Order_Detail__cASI_MFM_KR_HV_POSM_Order_Detail'),ASI_KOR_POSM_Order_Request__c = POSM_Header.id, ASI_KOR_SubBrand__c=SubBrand.id,ASI_KOR_Item_Name__c = POSM_Product11.id);
            POSMLineList.add(POSM_Line10);
            
            insert POSMLineList;
            
            test.startTest(); 
            
            POSM_Header.ASI_KOR_Status__c='Approved';
            update POSM_Header;
            
            List<string> deletelist = new List<string>();
            
            ApexPages.standardSetController sc = new ApexPages.standardSetController(POSMLineList);  
            PageReference ManageAllPage = Page.ASI_MFM_KR_POSMManageAllPage;
            Test.setCurrentPage(ManageAllPage);
            ApexPages.currentPage().getParameters().put('id', POSM_Header.ID);  
            
            
            Test.setCurrentPageReference(ManageAllPage);
            
            ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(POSM_Header);        
            ASI_MFM_KR_POSMManageAllController2 ManageAllController = new ASI_MFM_KR_POSMManageAllController2(sc);    
            ManageAllController.init();
            
            String RemoteStr= ASI_MFM_KR_POSMManageAllController2.UpdateLineItem(POSMLineList,deletelist);
            List<ASI_MFM_AP_Code__c> remo1= ASI_MFM_KR_POSMManageAllController2.findList('ASI_MFM_AP_Code__c','ID','WHERE RecordType.DeveloperName != null');
            
            test.stopTest();
        }
    }
    
    
    
    static testMethod void KR_HVPOSM_ApprovalEmailTest(){
        //Test class ASI_MFM_KR_HVPOSM_ApprovalEmailCtrl 
        map<string, id> rt_map = ASI_MFM_Function.getRecordTypeId('ASI_KOR_POSM_Order_Request__c'); 
        rt_map = ASI_MFM_Function.getRecordTypeId('Account');
        Account acc1 = new Account(recordTypeId=rt_map.get('ASI_KOR_Venue'),Name='Name1');          
        insert acc1;
        
        ASI_KOR_POSM_Product__c POSM_Product = new ASI_KOR_POSM_Product__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_POSM_Product__cASI_KOR_POSM_Product'), Name='TestProduct');
        insert POSM_Product;
        
        ASI_KOR_POSM_Order_Request__c POSM_Header= new ASI_KOR_POSM_Order_Request__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_POSM_Order_Request__cASI_KOR_New_High_Value_POSM_Request'),ASI_KOR_POSM_TO_Venue__c=acc1.id, ASI_KOR_Status__c='Draft');
        insert POSM_Header; 
        
        ASI_MFM_Sub_brand__c SubBrand = new ASI_MFM_Sub_brand__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_KR_Sub_Brand'), Name='TestSubBrand',ASI_MFM_Sub_brand_Code__c='Code');
        insert SubBrand;    
        
        
        
        test.startTest(); 
        
        ASI_KOR_POSM_Order_Detail__c POSM_Line = new ASI_KOR_POSM_Order_Detail__c(ASI_KOR_Quantity__c=10,recordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_POSM_Order_Detail__cASI_MFM_KR_HV_POSM_Order_Detail'),ASI_KOR_POSM_Order_Request__c = POSM_Header.id, ASI_KOR_SubBrand__c=SubBrand.id,ASI_KOR_Item_Name__c = POSM_Product.id);
        insert POSM_Line;
        
        ASI_MFM_KR_HVPOSM_ApprovalEmailCtrl ext = new ASI_MFM_KR_HVPOSM_ApprovalEmailCtrl();
        ext.receiptID=POSM_Header.Id;
        boolean TestFlag=ext.init();
        
        test.stopTest();
        
    }
    
    
    
    
    
    static testMethod void POSM_TriggerClass_Test(){
        //Create an Account(Venue)
        map<string, id> rt_map = ASI_MFM_Function.getRecordTypeId('ASI_KOR_POSM_Order_Request__c'); 
        rt_map = ASI_MFM_Function.getRecordTypeId('Account');
        Account acc1 = new Account(recordTypeId=rt_map.get('ASI_KOR_Venue'),Name='Name1');          
        insert acc1;
        
        ASI_KOR_POSM_Order_Request__c POSM_Header= new ASI_KOR_POSM_Order_Request__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_POSM_Order_Request__cASI_KOR_New_POSM_Request'),ASI_KOR_POSM_TO_Venue__c=acc1.id, ASI_KOR_Status__c='Draft');
        insert POSM_Header; 
        ASI_MFM_Sub_brand__c SubBrand = new ASI_MFM_Sub_brand__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_KR_Sub_Brand'), Name='TestSubBrand',ASI_MFM_Sub_brand_Code__c='Code');
        insert SubBrand;    
        
        ASI_KOR_POSM_Product__c POSM_Product = new ASI_KOR_POSM_Product__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_POSM_Product__cASI_KOR_POSM_Product'), Name='TestProduct');
        insert POSM_Product;
        
        test.startTest(); 
        
        ASI_KOR_POSM_Order_Detail__c POSM_Line = new ASI_KOR_POSM_Order_Detail__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_POSM_Order_Detail__cASI_KOR_POSM_Order_Detail'),ASI_KOR_POSM_Order_Request__c = POSM_Header.id, ASI_KOR_SubBrand__c=SubBrand.id,ASI_KOR_Item_Name__c = POSM_Product.id);
        insert POSM_Line;
        
        ASI_KR_POSM_ApprovalEmailController ext = new ASI_KR_POSM_ApprovalEmailController();
        ext.posmlineID=POSM_Line.id;
        ext.init();
        test.stopTest();
        
    }
    
    
    static testMethod void SubmitForApproval_Test_WithoutAttachment(){ //1 line: No Attachment        
        //Create an Account(Venue)
        map<string, id> rt_map = ASI_MFM_Function.getRecordTypeId('ASI_KOR_POSM_Order_Request__c'); 
        rt_map = ASI_MFM_Function.getRecordTypeId('Account');
        Account acc1 = new Account(recordTypeId=rt_map.get('ASI_KOR_Venue'),Name='Name1');          
        insert acc1;
        
        ASI_KOR_POSM_Order_Request__c POSM_Header = new ASI_KOR_POSM_Order_Request__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_POSM_Order_Request__cASI_KOR_New_POSM_Request'),ASI_KOR_POSM_TO_Venue__c=acc1.id, ASI_KOR_Status__c='Draft');
        insert POSM_Header;    
        
        ASI_MFM_Sub_brand__c SubBrand = new ASI_MFM_Sub_brand__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_KR_Sub_Brand'), Name='TestSubBrand',ASI_MFM_Sub_brand_Code__c='Code');
        insert SubBrand;    
        
        ASI_KOR_POSM_Product__c POSM_Product = new ASI_KOR_POSM_Product__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_POSM_Product__cASI_KOR_POSM_Product'), Name='TestProduct');
        insert POSM_Product;
        
        ASI_KOR_POSM_Order_Detail__c POSM_Line = new ASI_KOR_POSM_Order_Detail__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_POSM_Order_Detail__cASI_KOR_POSM_Order_Detail'),ASI_KOR_POSM_Order_Request__c = POSM_Header.id, ASI_KOR_SubBrand__c=SubBrand.id,ASI_KOR_Item_Name__c = POSM_Product.id);
        insert POSM_Line;
        
        test.startTest();
        PageReference SetStatusPage = Page.ASI_MFM_KR_POSMSubmitPage;
        Test.setCurrentPage(SetStatusPage);    
        ApexPages.currentPage().getParameters().put('ID', POSM_Header.ID);
        
        ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(POSM_Header);        
        ASI_MFM_KR_POSMSubmitController SetStatusController = new ASI_MFM_KR_POSMSubmitController(stdController);
        SetStatusController.setStatus();
        POSM_Header.ASI_KOR_Status__c='Submitted';
        UPDATE POSM_Header; 
        test.stopTest();
        
        
    }
    
    static testMethod void SubmitForApproval_Test_WithAttachment(){ //1 Line, 1 Attachment ==> Normal Case
        
        
        //Create an Account(Venue)
        map<string, id> rt_map = ASI_MFM_Function.getRecordTypeId('ASI_KOR_POSM_Order_Request__c'); 
        rt_map = ASI_MFM_Function.getRecordTypeId('Account');
        Account acc1 = new Account(recordTypeId=rt_map.get('ASI_KOR_Venue'),Name='Name1');          
        insert acc1;
        
        ASI_KOR_POSM_Order_Request__c POSM_Header = new ASI_KOR_POSM_Order_Request__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_POSM_Order_Request__cASI_KOR_New_POSM_Request'),ASI_KOR_POSM_TO_Venue__c=acc1.id, ASI_KOR_Status__c='Draft');
        insert POSM_Header;    
        
        ASI_MFM_Sub_brand__c SubBrand = new ASI_MFM_Sub_brand__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_KR_Sub_Brand'), Name='TestSubBrand',ASI_MFM_Sub_brand_Code__c='Code');
        insert SubBrand;    
        
        ASI_KOR_POSM_Product__c POSM_Product = new ASI_KOR_POSM_Product__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_POSM_Product__cASI_KOR_POSM_Product'), Name='TestProduct');
        insert POSM_Product;
        
        ASI_KOR_POSM_Order_Detail__c POSM_Line = new ASI_KOR_POSM_Order_Detail__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_POSM_Order_Detail__cASI_KOR_POSM_Order_Detail'),ASI_KOR_POSM_Order_Request__c = POSM_Header.id,ASI_KOR_SubBrand__c=SubBrand.id,ASI_KOR_Item_Name__c = POSM_Product.id);
        insert POSM_Line;
        
        attachment Atth = new attachment(parentid=POSM_Line.id,Name='Attachment Name',Body=Blob.valueOf('Unit Test Attachment Body'));
        insert atth;  
        
        //Start Test
        test.startTest();
        PageReference SetStatusPage = Page.ASI_MFM_KR_POSMSubmitPage;
        Test.setCurrentPage(SetStatusPage);    
        ApexPages.currentPage().getParameters().put('ID', POSM_Header.ID);
        
        //Case 1
        ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(POSM_Header); 
        ASI_MFM_KR_POSMSubmitController SetStatusController = new ASI_MFM_KR_POSMSubmitController(stdController);
        SetStatusController.setStatus();
        
        POSM_Header.ASI_KOR_Status__c='Submitted';
        UPDATE POSM_Header;         
        test.stopTest();
        //End Test
        
    }
    
    
    static testMethod void SubmitForApproval_Test_WithAttachment_2(){ //2 Line, Only One Line Has Attachmnet
        
        
        //Create an Account(Venue)
        map<string, id> rt_map = ASI_MFM_Function.getRecordTypeId('ASI_KOR_POSM_Order_Request__c'); 
        rt_map = ASI_MFM_Function.getRecordTypeId('Account');
        Account acc1 = new Account(recordTypeId=rt_map.get('ASI_KOR_Venue'),Name='Name1');          
        insert acc1;
        
        ASI_KOR_POSM_Order_Request__c POSM_Header = new ASI_KOR_POSM_Order_Request__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_POSM_Order_Request__cASI_KOR_New_POSM_Request'),ASI_KOR_POSM_TO_Venue__c=acc1.id, ASI_KOR_Status__c='Draft');
        insert POSM_Header;    
        
        ASI_MFM_Sub_brand__c SubBrand = new ASI_MFM_Sub_brand__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_KR_Sub_Brand'), Name='TestSubBrand',ASI_MFM_Sub_brand_Code__c='Code');
        insert SubBrand;    
        
        ASI_KOR_POSM_Product__c POSM_Product = new ASI_KOR_POSM_Product__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_POSM_Product__cASI_KOR_POSM_Product'), Name='TestProduct');
        insert POSM_Product;
        
        ASI_KOR_POSM_Order_Detail__c POSM_Line = new ASI_KOR_POSM_Order_Detail__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_POSM_Order_Detail__cASI_KOR_POSM_Order_Detail'),ASI_KOR_POSM_Order_Request__c = POSM_Header.id, ASI_KOR_SubBrand__c=SubBrand.id,ASI_KOR_Item_Name__c = POSM_Product.id);
        insert POSM_Line;
        
        ASI_KOR_POSM_Order_Detail__c POSM_Line2 = new ASI_KOR_POSM_Order_Detail__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_POSM_Order_Detail__cASI_KOR_POSM_Order_Detail'), ASI_KOR_POSM_Order_Request__c = POSM_Header.id, ASI_KOR_SubBrand__c=SubBrand.id,ASI_KOR_Item_Name__c = POSM_Product.id);
        insert POSM_Line2;
        
        attachment Atth = new attachment(parentid=POSM_Line.id,Name='Attachment Name',Body=Blob.valueOf('Unit Test Attachment Body'));
        insert atth;  
        
        //Start Test
        test.startTest();
        PageReference SetStatusPage = Page.ASI_MFM_KR_POSMSubmitPage;
        Test.setCurrentPage(SetStatusPage);    
        ApexPages.currentPage().getParameters().put('ID', POSM_Header.ID);
        ApexPages.Standardcontroller stdController2 = new ApexPages.Standardcontroller(POSM_Header); 
        ASI_MFM_KR_POSMSubmitController SetStatusController2 = new ASI_MFM_KR_POSMSubmitController(stdController2);
        SetStatusController2.setStatus();
        POSM_Header.ASI_KOR_Status__c='Submitted';
        UPDATE POSM_Header; 
        test.stopTest();
        //End Test
        
    }
    
    
    static testMethod void SubmitForApproval_Test_WithoutLine(){ //No POSM Line
        //Create an Account(Venue)
        map<string, id> rt_map = ASI_MFM_Function.getRecordTypeId('ASI_KOR_POSM_Order_Request__c'); 
        rt_map = ASI_MFM_Function.getRecordTypeId('Account');
        Account acc1 = new Account(recordTypeId=rt_map.get('ASI_KOR_Venue'),Name='Name1');          
        insert acc1;
        
        ASI_KOR_POSM_Order_Request__c POSM_Header = new ASI_KOR_POSM_Order_Request__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_POSM_Order_Request__cASI_KOR_New_POSM_Request'),ASI_KOR_POSM_TO_Venue__c=acc1.id, ASI_KOR_Status__c='Draft');
        insert POSM_Header;    
        
        ASI_MFM_Sub_brand__c SubBrand = new ASI_MFM_Sub_brand__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_KR_Sub_Brand'), Name='TestSubBrand',ASI_MFM_Sub_brand_Code__c='Code');
        insert SubBrand;    
        
        ASI_KOR_POSM_Product__c POSM_Product = new ASI_KOR_POSM_Product__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_POSM_Product__cASI_KOR_POSM_Product'), Name='TestProduct');
        insert POSM_Product;
        //Start Test
        test.startTest();
        PageReference SetStatusPage = Page.ASI_MFM_KR_POSMSubmitPage;
        Test.setCurrentPage(SetStatusPage);    
        ApexPages.currentPage().getParameters().put('ID', POSM_Header.ID);
        
        ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(POSM_Header);        
        ASI_MFM_KR_POSMSubmitController SetStatusController = new ASI_MFM_KR_POSMSubmitController(stdController);
        SetStatusController.setStatus();
        POSM_Header.ASI_KOR_Status__c='Submitted';
        UPDATE POSM_Header; 
        test.stopTest();
        //End Test
        
    }
    
    //POSM Manage All
    static testMethod void POSM_ManageAll_test(){
        
        map<string, id> rt_map = ASI_MFM_Function.getRecordTypeId('ASI_KOR_POSM_Order_Request__c'); 
        rt_map = ASI_MFM_Function.getRecordTypeId('Account');
        Account acc1 = new Account(recordTypeId=rt_map.get('ASI_KOR_Venue'),Name='Name1');          
        insert acc1;
        
        List<ASI_KOR_POSM_Order_Request__c> POSM_Headers = new List<ASI_KOR_POSM_Order_Request__c>();
        List<ASI_KOR_POSM_Order_Detail__c> POSM_Line_List = new List<ASI_KOR_POSM_Order_Detail__c>();
        
        ASI_KOR_POSM_Order_Request__c POSM_Header = new ASI_KOR_POSM_Order_Request__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_POSM_Order_Request__cASI_KOR_New_POSM_Request'),ASI_KOR_POSM_TO_Venue__c=acc1.id, ASI_KOR_Status__c='Draft');
        insert POSM_Header;  
        POSM_Headers.add(POSM_Header);
        
        ASI_MFM_Sub_brand__c SubBrand = new ASI_MFM_Sub_brand__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_KR_Sub_Brand'), Name='TestSubBrand',ASI_MFM_Sub_brand_Code__c='Code');
        insert SubBrand;    
        
        ASI_KOR_POSM_Product__c POSM_Product = new ASI_KOR_POSM_Product__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_POSM_Product__cASI_KOR_POSM_Product'), Name='TestProduct', ASI_MFM_UnitCost__c = 10, ASI_MFM_Sub_Brand__c=SubBrand.id);
        insert POSM_Product;
        
        ASI_KOR_POSM_Order_Detail__c POSM_Line = new ASI_KOR_POSM_Order_Detail__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_POSM_Order_Detail__cASI_KOR_POSM_Order_Detail'),ASI_KOR_POSM_Order_Request__c = POSM_Header.id, ASI_KOR_SubBrand__c=SubBrand.id,ASI_KOR_Quantity__c=10,ASI_KOR_Supplier__c = acc1.id,ASI_KOR_UnitCost__c = 100,ASI_KOR_Item_Name__c = POSM_Product.id,ASI_MFM_KR_Supplier_Email__c = 'test@gmail.com');
        insert POSM_Line;
        POSM_Line_List.add(POSM_Line);
        
        ASI_KOR_POSM_Order_Detail__c POSM_Line2 = new ASI_KOR_POSM_Order_Detail__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_POSM_Order_Detail__cASI_KOR_POSM_Order_Detail'), ASI_KOR_POSM_Order_Request__c = POSM_Header.id,ASI_KOR_SubBrand__c=SubBrand.id,ASI_KOR_Quantity__c=10,ASI_KOR_Supplier__c = acc1.id,ASI_KOR_UnitCost__c = 100,ASI_KOR_Item_Name__c = POSM_Product.id,ASI_MFM_KR_Supplier_Email__c = 'test@gmail.com');
        
        attachment Atth = new attachment(parentid=POSM_Line.id,Name='Attachment Name',Body=Blob.valueOf('Unit Test Attachment Body'));
        insert atth;  
        
        //Start Test
        
        test.startTest();
        
        ApexPages.standardSetController sc = new ApexPages.standardSetController(POSM_Line_List);  
        PageReference ManageAllPage = Page.ASI_MFM_KR_POSMManageAllPage;
        Test.setCurrentPage(ManageAllPage);
        ApexPages.currentPage().getParameters().put('id', POSM_Header.ID);  
        
        
        Test.setCurrentPageReference(ManageAllPage);
        
        ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(POSM_Header);        
        ASI_MFM_KR_POSMManageAllController ManageAllController = new ASI_MFM_KR_POSMManageAllController(sc);    
        
        ManageAllController.init();
        
        System.currentPageReference().getParameters().put('PARAM_clone_ID', (String)POSM_Line.id);
        ManageAllController.cloneLine();
        ManageAllController.saveLinetems();
        ManageAllController.addLineItem(); 
        System.currentPageReference().getParameters().put('PARAM_Line_ID', (String)POSM_Line.id);
        ManageAllController.removePOSMLine();
        
        ManageAllController.sendEmail();
        ManageAllController.sendEmail2();
        //Test RemoteAction
        List<ASI_KOR_POSM_Product__c> Productremo= ASI_MFM_KR_POSMManageAllController.findPOSMproduct('ASI_KOR_POSM_Product__c','WHERE ID != NULL');
        List<Account> Accountremo= ASI_MFM_KR_POSMManageAllController.findSObjects('Account','WHERE ID != NULL');
        test.stopTest();
        //End Test
        
    }
    
    
    static testMethod void POSM_ManageAll_test_WithOutLineValue(){
        
        map<string, id> rt_map = ASI_MFM_Function.getRecordTypeId('ASI_KOR_POSM_Order_Request__c'); 
        rt_map = ASI_MFM_Function.getRecordTypeId('Account');
        Account acc1 = new Account(recordTypeId=rt_map.get('ASI_KOR_Venue'),Name='Name1');          
        insert acc1;
        
        List<ASI_KOR_POSM_Order_Request__c> POSM_Headers = new List<ASI_KOR_POSM_Order_Request__c>();
        List<ASI_KOR_POSM_Order_Detail__c> POSM_Line_List = new List<ASI_KOR_POSM_Order_Detail__c>();
        
        ASI_KOR_POSM_Order_Request__c POSM_Header = new ASI_KOR_POSM_Order_Request__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_POSM_Order_Request__cASI_KOR_New_POSM_Request'),ASI_KOR_POSM_TO_Venue__c=acc1.id, ASI_KOR_Status__c='Draft');
        insert POSM_Header;  
        POSM_Headers.add(POSM_Header);
        
        ASI_MFM_Sub_brand__c SubBrand = new ASI_MFM_Sub_brand__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_KR_Sub_Brand'), Name='TestSubBrand',ASI_MFM_Sub_brand_Code__c='Code');
        insert SubBrand;    
        
        ASI_KOR_POSM_Product__c POSM_Product = new ASI_KOR_POSM_Product__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_POSM_Product__cASI_KOR_POSM_Product'), Name='TestProduct', ASI_MFM_UnitCost__c = 10, ASI_MFM_Sub_Brand__c=SubBrand.id);
        insert POSM_Product;
        
        ASI_KOR_POSM_Order_Detail__c POSM_Line = new ASI_KOR_POSM_Order_Detail__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_POSM_Order_Detail__cASI_KOR_POSM_Order_Detail'), ASI_KOR_POSM_Order_Request__c = POSM_Header.id,  ASI_KOR_SubBrand__c=SubBrand.id, ASI_KOR_Quantity__c=10,ASI_KOR_Supplier__c = acc1.id,ASI_KOR_UnitCost__c = 100,ASI_KOR_Item_Name__c = POSM_Product.id,ASI_MFM_KR_Supplier_Email__c = 'test@gmail.com');
        insert POSM_Line;
        POSM_Line_List.add(POSM_Line);
        
        ASI_KOR_POSM_Order_Detail__c POSM_Line2 = new ASI_KOR_POSM_Order_Detail__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_POSM_Order_Detail__cASI_KOR_POSM_Order_Detail'),ASI_KOR_POSM_Order_Request__c = POSM_Header.id, ASI_KOR_SubBrand__c=SubBrand.id,ASI_KOR_Quantity__c=10,ASI_KOR_Supplier__c = acc1.id, ASI_KOR_UnitCost__c = 100,ASI_KOR_Item_Name__c = POSM_Product.id,ASI_MFM_KR_Supplier_Email__c = 'test@gmail.com');
        insert POSM_Line2;
        POSM_Line_List.add(POSM_Line2);  
        
        //Start Test
        
        test.startTest();
        
        ApexPages.standardSetController sc = new ApexPages.standardSetController(POSM_Line_List);  
        PageReference ManageAllPage = Page.ASI_MFM_KR_POSMManageAllPage;
        Test.setCurrentPage(ManageAllPage);
        ApexPages.currentPage().getParameters().put('id', POSM_Header.ID);  
        Test.setCurrentPageReference(ManageAllPage);
        
        ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(POSM_Header);        
        ASI_MFM_KR_POSMManageAllController ManageAllController = new ASI_MFM_KR_POSMManageAllController(sc);    
        
        ManageAllController.init();
        
        ManageAllController.addLineItem(); 
        System.currentPageReference().getParameters().put('PARAM_clone_ID', (String)POSM_Line.id);
        ManageAllController.cloneLine();
        ManageAllController.saveLinetems();
        System.currentPageReference().getParameters().put('PARAM_Line_ID', (String)POSM_Line.id);
        ManageAllController.removePOSMLine();
        
        ManageAllController.sendEmail();
        
        //Test RemoteAction
        List<ASI_KOR_POSM_Product__c> Productremo= ASI_MFM_KR_POSMManageAllController.findPOSMproduct('ASI_KOR_POSM_Product__c','WHERE ID != NULL');
        List<Account> Accountremo= ASI_MFM_KR_POSMManageAllController.findSObjects('Account','WHERE ID != NULL');
        test.stopTest();
        //End Test
        
    }
    //End of POSM Manage All
    
    //POSM Upload Attachment Controller
    static testMethod void POSM_Attachment_Test(){
        
        map<string, id> rt_map = ASI_MFM_Function.getRecordTypeId('ASI_KOR_POSM_Order_Request__c'); 
        rt_map = ASI_MFM_Function.getRecordTypeId('Account');
        Account acc1 = new Account(recordTypeId=rt_map.get('ASI_KOR_Venue'),Name='Name1');          
        insert acc1;
        
        List<ASI_KOR_POSM_Order_Request__c> POSM_Headers = new List<ASI_KOR_POSM_Order_Request__c>();
        List<ASI_KOR_POSM_Order_Detail__c> POSM_Line_List = new List<ASI_KOR_POSM_Order_Detail__c>();
        
        ASI_KOR_POSM_Order_Request__c POSM_Header = new ASI_KOR_POSM_Order_Request__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_POSM_Order_Request__cASI_KOR_New_POSM_Request'),ASI_KOR_POSM_TO_Venue__c=acc1.id, ASI_KOR_Status__c='Draft');
        insert POSM_Header;  
        POSM_Headers.add(POSM_Header);
        
        ASI_MFM_Sub_brand__c SubBrand = new ASI_MFM_Sub_brand__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_KR_Sub_Brand'), Name='TestSubBrand',ASI_MFM_Sub_brand_Code__c='Code');
        insert SubBrand;    
        
        ASI_KOR_POSM_Product__c POSM_Product = new ASI_KOR_POSM_Product__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_POSM_Product__cASI_KOR_POSM_Product'), Name='TestProduct', ASI_MFM_UnitCost__c = 10, ASI_MFM_Sub_Brand__c=SubBrand.id);
        insert POSM_Product;
        
        ASI_KOR_POSM_Order_Detail__c POSM_Line = new ASI_KOR_POSM_Order_Detail__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_POSM_Order_Detail__cASI_KOR_POSM_Order_Detail'), ASI_KOR_POSM_Order_Request__c = POSM_Header.id, ASI_KOR_SubBrand__c=SubBrand.id,ASI_KOR_Quantity__c=10,ASI_KOR_Supplier__c = acc1.id,ASI_KOR_UnitCost__c = 100,ASI_KOR_Item_Name__c = POSM_Product.id,ASI_MFM_KR_Supplier_Email__c = 'test@gmail.com');
        insert POSM_Line;
        POSM_Line_List.add(POSM_Line);
        
        attachment Atth = new attachment(parentid=POSM_Line.id,Name='Attachment Name',Body=Blob.valueOf('Unit Test Attachment Body'));
        insert atth;
        
        test.startTest();
        
        PageReference UploadAttachPage = Page.ASI_MFM_KR_POSM_UploadAttachPage;
        Test.setCurrentPage(UploadAttachPage);
        ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(POSM_Header);        
        ASI_MFM_KR_POSM_UploadAttachController UploadAttachController = new ASI_MFM_KR_POSM_UploadAttachController(stdController);
        UploadAttachController.init();
        System.currentPageReference().getParameters().put('PARAM_Line_ID', (String)atth.id);
        UploadAttachController.deleteAtt();
        
        test.stopTest();
    }
    
    
    
}