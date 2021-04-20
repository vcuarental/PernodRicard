@isTest
public with sharing class ASI_MFM_SG_BA_F_PO_TestClass {
    private static string getFiscalYear(){
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
    
    static testMethod void BAVerifyTest1()
    {
        //Set User
        user u = [select userRole.developerName, ASI_MFM_Country__c from user where id = :userInfo.getUserId()];
        u.ASI_MFM_Country__c = 'SG';
        update u;
        ASI_MFM_Exchange_Rate__c xr = new ASI_MFM_Exchange_Rate__c(ASI_MFM_Application__c='MFM', ASI_MFM_Base_Currency__c='SGD',
                                                                   ASI_MFM_Counter_Currency__c='USD', ASI_MFM_Country__c='SG', ASI_MFM_Effective_Date__c=date.today(), ASI_MFM_Exchange_Rate__c=1.23);
        insert xr;         
        //Set Plan prefix
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c=getFiscalYear());
        insert px;
        
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        
        
        ASI_MFM_Plan__c p1 = new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_SG_Plan'), ASI_MFM_Prefix__c=px.id, ASI_MFM_Start_Date__c=date.today(), ASI_MFM_End_Date__c=date.today(),
                                                 ASI_MFM_Plan_Description__c='planDescription', ASI_MFM_Plan_Name__c='testplanName', ASI_MFM_Status__c = 'Final');
        insert p1;
        //Set PO
        px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO',ASI_MFM_Location__c='Singapore');
        insert px;
        
        pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        //Set   Route Type
        ASI_MFM_Route_Type__c rt = new ASI_MFM_Route_Type__c(name='test', ASI_MFM_Module__c='PO');
        insert rt;
        
        ASI_MFM_Brand_Route_Type_Map__c rtm = new ASI_MFM_Brand_Route_Type_Map__c(ASI_MFM_Route_Type__c=rt.id, ASI_MFM_Prefix__c=px.id);
        insert rtm;
        
        List<ASI_MFM_Route_Rule_Detail__c> rrdlist = new List<ASI_MFM_Route_Rule_Detail__c>();
        rrdlist.add(new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id, ASI_MFM_Sequence__c=0));
        rrdlist.add(new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id, ASI_MFM_Sequence__c=1));
        
        insert rrdlist;

        Account acc2 = new Account(recordTypeId=Global_RecordTypeCache.getRtId('AccountASI_MFM_SG_Customer'),Name='Name3');           
        insert acc2;
        
        Account acc1 = new Account(recordTypeId=Global_RecordTypeCache.getRtId('AccountASI_CRM_SG_Supplier'),Name='Name2');          
        insert acc1;
        
        // Set PO 
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_SG_PO'), ASI_MFM_Prefix__c=px.id, ASI_MFM_Plan__c=p1.id, ASI_MFM_PO_Raised_Date__c=date.today(),
                                             ASI_MFM_Currency__c='SGD', ASI_MFM_PO_Start_Date__c=date.today(), ASI_MFM_PO_End_Date__c=date.today(), ASI_MFM_Supplier_Name__c = acc1.id, ASI_MFM_Status__c = 'Final');
        insert po;

        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC', recordtypeid=Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_SG_A_C_Code'), ASI_MFM_Market__c = 'Singapore');
        insert ac;
        
        ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(name='testSubBrand');
        insert sub;
        
        list<ASI_MFM_PO_Line_Item__c> poLineItems = new list<ASI_MFM_PO_Line_Item__c>();
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_SG_PO_Line_Item'), ASI_MFM_PO__c=po.id, ASI_MFM_Amount__c=10, 
                                                                  ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id, ASI_MFM_G_L_Date__c = Date.today());
        poLineItems.add(poi);
        insert poLineItems;

        test.startTest();
        
        ASI_MFM_SG_BAVerifyLWCController.getPlanLine(
            null, null, null, null, null, null, 
            null, null, null, null, null, null, null, null, null, 1, 30
        );

        ASI_MFM_SG_BAVerifyLWCController.getPlanLine(
            '1', '1', '1', 'SG,CA,LA,MM', '1', '1', 
            '1', '1', '1', System.today(), System.today(), System.today(), System.today(), null, null, 1, 30
        );

        // String planLinesStr = JSON.serialize(poLineItems);
        // List<String> poList = new List<String>();
        // poList.add(po.Name);
        
        // ASI_MFM_SG_BAVerifyLWCController.savePlanLine(planLinesStr, System.today(), poList);

        Test.stopTest();
    }

    static testMethod void BAVerifyTest2()
    {
        //Set User
        user u = [select userRole.developerName, ASI_MFM_Country__c from user where id = :userInfo.getUserId()];
        u.ASI_MFM_Country__c = 'SG';
        update u;
        ASI_MFM_Exchange_Rate__c xr = new ASI_MFM_Exchange_Rate__c(ASI_MFM_Application__c='MFM', ASI_MFM_Base_Currency__c='SGD',
                                                                   ASI_MFM_Counter_Currency__c='USD', ASI_MFM_Country__c='SG', ASI_MFM_Effective_Date__c=date.today(), ASI_MFM_Exchange_Rate__c=1.23);
        insert xr;         
        //Set Plan prefix
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c=getFiscalYear());
        insert px;
        
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        
        
        ASI_MFM_Plan__c p1 = new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_SG_Plan'), ASI_MFM_Prefix__c=px.id, ASI_MFM_Start_Date__c=date.today(), ASI_MFM_End_Date__c=date.today(),
                                                 ASI_MFM_Plan_Description__c='planDescription', ASI_MFM_Plan_Name__c='testplanName', ASI_MFM_Status__c = 'Final');
        insert p1;
        //Set PO
        px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO',ASI_MFM_Location__c='Singapore');
        insert px;
        
        pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        //Set   Route Type
        ASI_MFM_Route_Type__c rt = new ASI_MFM_Route_Type__c(name='test', ASI_MFM_Module__c='PO');
        insert rt;
        
        ASI_MFM_Brand_Route_Type_Map__c rtm = new ASI_MFM_Brand_Route_Type_Map__c(ASI_MFM_Route_Type__c=rt.id, ASI_MFM_Prefix__c=px.id);
        insert rtm;
        
        List<ASI_MFM_Route_Rule_Detail__c> rrdlist = new List<ASI_MFM_Route_Rule_Detail__c>();
        rrdlist.add(new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id, ASI_MFM_Sequence__c=0));
        rrdlist.add(new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id, ASI_MFM_Sequence__c=1));
        
        insert rrdlist;

        Account acc2 = new Account(recordTypeId=Global_RecordTypeCache.getRtId('AccountASI_MFM_SG_Customer'),Name='Name3');           
        insert acc2;
        
        Account acc1 = new Account(recordTypeId=Global_RecordTypeCache.getRtId('AccountASI_CRM_SG_Supplier'),Name='Name2');          
        insert acc1;
        
        // Set PO 
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_SG_PO'), ASI_MFM_Prefix__c=px.id, ASI_MFM_Plan__c=p1.id, ASI_MFM_PO_Raised_Date__c=date.today(),
                                             ASI_MFM_Currency__c='SGD', ASI_MFM_PO_Start_Date__c=date.today(), ASI_MFM_PO_End_Date__c=date.today(), ASI_MFM_Supplier_Name__c = acc1.id);
        insert po;

        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC', recordtypeid=Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_SG_A_C_Code'), ASI_MFM_Market__c = 'Singapore');
        insert ac;
        
        ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(name='testSubBrand');
        insert sub;
        
        list<ASI_MFM_PO_Line_Item__c> poLineItems = new list<ASI_MFM_PO_Line_Item__c>();
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_SG_PO_Line_Item'), ASI_MFM_PO__c=po.id, ASI_MFM_Amount__c=10, 
                                                                  ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id, ASI_MFM_G_L_Date__c = Date.today(), ASI_MFM_SG_BA_verify__c = true);
        ASI_MFM_PO_Line_Item__c poi2 = new ASI_MFM_PO_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_SG_PO_Line_Item'), ASI_MFM_PO__c=po.id, ASI_MFM_Amount__c=10, 
                                                                    ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id, ASI_MFM_G_L_Date__c = Date.today());
        poLineItems.add(poi);
        poLineItems.add(poi2);
        insert poLineItems;

        test.startTest();
        
        // ASI_MFM_SG_BAVerifyLWCController.getPlanLine(
        //     null, null, null, null, null, null, 
        //     null, null, null, null, null, null, null, null, null, 1, 30
        // );

        String planLinesStr = JSON.serialize(poLineItems);
        List<String> poList = new List<String>();
        poList.add(po.Name);
        
        ASI_MFM_SG_BAVerifyLWCController.savePlanLine(planLinesStr, System.today(), poList);

        Test.stopTest();
    }

    static testMethod void FVerifyTest1() {
        User thisUser = [SELECT ID, ASI_MFM_Country__c, userRole.Id, userRole.developerName FROM user WHERE ID = :userinfo.getUserID()];

        UserRole r = new UserRole(DeveloperName = 'MyCustomRole', Name = 'My Role');
        insert r;

        //New Test User
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User newUser1 = new User(profileId = p.Id, username = 'newUser1@newUser1234.com',email = 'newUser@newUser.com',emailencodingkey = 'UTF-8', localesidkey = 'en_US', languagelocalekey = 'en_US', timezonesidkey = 'America/Los_Angeles', alias = 'nuser', lastname = 'user', UserRoleId = r.Id);
        User newUser2 = new User(profileId = p.Id, username = 'newUser2@newUser1234.com',email = 'newUser@newUser.com',emailencodingkey = 'UTF-8', localesidkey = 'en_US', languagelocalekey = 'en_US', timezonesidkey = 'America/Los_Angeles', alias = 'nuser', lastname = 'user', UserRoleId = r.Id);
        User newUser3 = new User(profileId = p.Id, username = 'newUser3@newUser1234.com',email = 'newUser@newUser.com',emailencodingkey = 'UTF-8', localesidkey = 'en_US', languagelocalekey = 'en_US', timezonesidkey = 'America/Los_Angeles', alias = 'nuser', lastname = 'user');
        User newUser4 = new User(profileId = p.Id, username = 'newUser4@newUser1234.com',email = 'newUser@newUser.com',emailencodingkey = 'UTF-8', localesidkey = 'en_US', languagelocalekey = 'en_US', timezonesidkey = 'America/Los_Angeles', alias = 'nuser', lastname = 'user');
        User newUser5 = new User(profileId = p.Id, username = 'newUser5@newUser1234.com',email = 'newUser@newUser.com',emailencodingkey = 'UTF-8', localesidkey = 'en_US', languagelocalekey = 'en_US', timezonesidkey = 'America/Los_Angeles', alias = 'nuser', lastname = 'user');
        User newUser6 = new User(profileId = p.Id, username = 'newUser6@newUser1234.com',email = 'newUser@newUser.com',emailencodingkey = 'UTF-8', localesidkey = 'en_US', languagelocalekey = 'en_US', timezonesidkey = 'America/Los_Angeles', alias = 'nuser', lastname = 'user');
        User newUser7 = new User(profileId = p.Id, username = 'newUser7@newUser1234.com',email = 'newUser@newUser.com',emailencodingkey = 'UTF-8', localesidkey = 'en_US', languagelocalekey = 'en_US', timezonesidkey = 'America/Los_Angeles', alias = 'nuser', lastname = 'user');
        User newUser8 = new User(profileId = p.Id, username = 'newUser8@newUser1234.com',email = 'newUser@newUser.com',emailencodingkey = 'UTF-8', localesidkey = 'en_US', languagelocalekey = 'en_US', timezonesidkey = 'America/Los_Angeles', alias = 'nuser', lastname = 'user');
        User newUser9 = new User(profileId = p.Id, username = 'newUser9@newUser1234.com',email = 'newUser@newUser.com',emailencodingkey = 'UTF-8', localesidkey = 'en_US', languagelocalekey = 'en_US', timezonesidkey = 'America/Los_Angeles', alias = 'nuser', lastname = 'user');
        User newUser10 = new User(profileId = p.Id, username = 'newUser10@newUser1234.com',email = 'newUser@newUser.com',emailencodingkey = 'UTF-8', localesidkey = 'en_US', languagelocalekey = 'en_US', timezonesidkey = 'America/Los_Angeles', alias = 'nuser', lastname = 'user');
    
        List<User> newUserList = new List<User>();
        newUserList.add(newUser1);
        newUserList.add(newUser2);
        newUserList.add(newUser3);
        newUserList.add(newUser4);
        newUserList.add(newUser5);
        newUserList.add(newUser6);
        newUserList.add(newUser7);
        newUserList.add(newUser8);
        newUserList.add(newUser9);
        newUserList.add(newUser10);
        
        insert newUserList;
        
        System.runAs(newUser1){		
            //Prefix
            List<ASI_MFM_Prefix__c> PrefixList = new List<ASI_MFM_Prefix__c>();
            ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(	name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c=getFiscalYear(), 
                                                            recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_SG_Prefix'),
                                                            ASI_MFM_Location__c = 'Singapore'); // Insert Custom Fields & Relationships API Name   FY1415
            PrefixList.add(px);
            ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO');
            PrefixList.add(pxo);
            ASI_MFM_Prefix__c pxa = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Payment');
            PrefixList.add(pxa);
            insert PrefixList; 
            
            List<ASI_MFM_Role_Prefix_Relationship__c> RolePrefixList = new List<ASI_MFM_Role_Prefix_Relationship__c>();
            ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c = 'MyCustomRole');
            RolePrefixList.add(pr);
            ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c = 'MyCustomRole');
            RolePrefixList.add(pro); 
            
            ASI_MFM_Role_Prefix_Relationship__c pra = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Role_Name__c = thisUser.userRole.developerName);
            ASI_MFM_Role_Prefix_Relationship__c pra2 = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Role_Name__c = r.DeveloperName);
            RolePrefixList.add(pra);
            RolePrefixList.add(pra2);
            insert RolePrefixList;
            
            ASI_MFM_Brand__c brand = new ASI_MFM_Brand__c(Name ='Test', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Brand__cASI_CRM_SG_Brand'));
            insert brand;
            
            ASI_MFM_Sub_brand__c subbrand = new ASI_MFM_Sub_brand__c(Name = 'Test', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_CRM_SG_Sub_brand'),
                                                                    ASI_MFM_Brand__c = brand.Id);
            insert subbrand;
            
            ASI_MFM_Plan__c p1 = new ASI_MFM_Plan__c(	recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_SG_Plan'),
                                                        ASI_MFM_Prefix__c=px.id, ASI_MFM_Start_Date__c=date.today(), 
                                                        ASI_MFM_End_Date__c=date.today().addMonths(1),
                                                        ASI_MFM_Plan_Description__c='planDescription', ASI_MFM_Plan_Name__c='testplanName', 
                                                        ASI_MFM_Status__c = 'Final'
                                                    );
            insert p1;
            
            
            Account acc3 = new Account(		recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_CRM_SG_Supplier'),
                                            Name='Name3'); // ASI_CRM_SG_Supplier          
            insert acc3;
            
            ASI_MFM_PO__c po = new ASI_MFM_PO__c(	recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_SG_PO'),
                                                    ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Plan__c=p1.id, ASI_MFM_PO_Raised_Date__c=date.today(),
                                                    ASI_MFM_Currency__c='SGD');// ASI_MFM_Supplier_Name__c = acc1.id 
            insert po;
            
            //------------------------------------------Test start ---------------------------------------------
            
            ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(	recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_SG_PO_Line_Item'),
                                                                        ASI_MFM_PO__c=po.id, ASI_MFM_Amount__c=100,ASI_MFM_List_Item_Description__c='testDescription', 
                                                                        ASI_MFM_G_L_Date__c = Date.today(), ASI_MFM_Sub_brand_Code__c = subbrand.Id); //ASI_MFM_Customer_Name__c=acc2.id, 
            insert poi;
            
            System.debug(Limits.getDMLRows());
            
            ASI_MFM_Route_Type__c rt = new ASI_MFM_Route_Type__c(name='test', ASI_MFM_Module__c='Payment');
            insert rt;
            
            ASI_MFM_Brand_Route_Type_Map__c rtm = new ASI_MFM_Brand_Route_Type_Map__c(ASI_MFM_Route_Type__c=rt.id, ASI_MFM_Prefix__c=pxa.id); // Note :use Payment Prefix
            insert rtm;
        
            // ASI MFM Route Rule Details Set Approver 
            List<ASI_MFM_Route_Rule_Detail__c> rrdlist = new List<ASI_MFM_Route_Rule_Detail__c>();
            rrdlist.add(new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=newUser1.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id, ASI_MFM_Sequence__c=0));
            rrdlist.add(new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=newUser2.id, ASI_MFM_Minimum_Amount__c=1, ASI_MFM_Route_Type__c=rt.id, ASI_MFM_Sequence__c=1));
            rrdlist.add(new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=newUser3.id, ASI_MFM_Minimum_Amount__c=2, ASI_MFM_Route_Type__c=rt.id, ASI_MFM_Sequence__c=2));
            rrdlist.add(new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=newUser4.id, ASI_MFM_Minimum_Amount__c=3, ASI_MFM_Route_Type__c=rt.id, ASI_MFM_Sequence__c=3));
            rrdlist.add(new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=newUser5.id, ASI_MFM_Minimum_Amount__c=4, ASI_MFM_Route_Type__c=rt.id, ASI_MFM_Sequence__c=4));
            rrdlist.add(new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=newUser6.id, ASI_MFM_Minimum_Amount__c=5, ASI_MFM_Route_Type__c=rt.id, ASI_MFM_Sequence__c=5));
            rrdlist.add(new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=newUser7.id, ASI_MFM_Minimum_Amount__c=6, ASI_MFM_Route_Type__c=rt.id, ASI_MFM_Sequence__c=6));
            rrdlist.add(new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=newUser8.id, ASI_MFM_Minimum_Amount__c=7, ASI_MFM_Route_Type__c=rt.id, ASI_MFM_Sequence__c=7));
            rrdlist.add(new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=newUser9.id, ASI_MFM_Minimum_Amount__c=8, ASI_MFM_Route_Type__c=rt.id, ASI_MFM_Sequence__c=8));
            rrdlist.add(new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=newUser10.id, ASI_MFM_Minimum_Amount__c=9, ASI_MFM_Route_Type__c=rt.id, ASI_MFM_Sequence__c=9));        
            insert rrdlist;

            Test.startTest(); 
            
            ASI_MFM_Payment__c py = new ASI_MFM_Payment__c(
                                                recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_SG_Payment'),													
                                                ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Payment_Date__c=date.today(),ASI_MFM_Currency__c='SGD', ASI_MFM_Payment_Amount__c=100,ASI_MFM_Send_Approval_Email__c=true,
                                                ASI_MFM_Status__c='Final',ASI_MFM_Supplier_Name__c = acc3.id);  //ASI_MFM_Payee__c ,ASI_MFM_Sys_Approver_1__c=u2.id     
            insert py;
            System.debug('After insert payment ' + Limits.getDMLRows());
            
            ASI_MFM_Payment_Line_Item__c pyi = new ASI_MFM_Payment_Line_Item__c(
                                                                    recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Line_Item__cASI_MFM_SG_Payment_Line_Item'),	
                                                                    ASI_MFM_Payment_Amount__c=10, ASI_MFM_PO_Line_Item__c=poi.id, ASI_MFM_Invoice_Date__c = date.today(), ASI_MFM_Payment__c=py.id,ASI_MFM_Invoice_Number__c = '123456');// 
            insert pyi;

            Attachment attachment = new Attachment(
                ParentID = py.ID,
                Name = 'test',
                Body = Blob.valueOf('Unit Test Attachment Body')
            );
            insert attachment;

            ASI_MFM_SG_FVerifyLWCController.getPaymentLine(
                null, null, null, null, null, null, null, null, null, null, null,
                null, 1, 30);

            ASI_MFM_SG_FVerifyLWCController.getPaymentLine(
                '1', '1', '1', '1', 'SG,CA,LA,MM', '1', '1', system.today(), system.today(), '1',
                null, null, 1, 30);
    
            // List<ASI_MFM_Payment_Line_Item__c> payList = new List<ASI_MFM_Payment_Line_Item__c>();
            // payList.add(pyi);
            // String paymentLinesStr = JSON.serialize(payList);
    
            // ASI_MFM_SG_FVerifyLWCController.savePaymentLine (paymentLinesStr);
    
            // Test ASI_MFM_MY_PORelatedPaymentsController 
            ASI_MFM_SG_PORelatedPaymentLWCController.getPayment(po.ID);
            
            test.stopTest(); 
        }
    }

    static testMethod void FVerifyTest2() {
        User thisUser = [SELECT ID, ASI_MFM_Country__c, userRole.Id, userRole.developerName FROM user WHERE ID = :userinfo.getUserID()];

        UserRole r = new UserRole(DeveloperName = 'MyCustomRole', Name = 'My Role');
        insert r;

        //New Test User
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User newUser1 = new User(profileId = p.Id, username = 'newUser1@newUser1234.com',email = 'newUser@newUser.com',emailencodingkey = 'UTF-8', localesidkey = 'en_US', languagelocalekey = 'en_US', timezonesidkey = 'America/Los_Angeles', alias = 'nuser', lastname = 'user', UserRoleId = r.Id);
        User newUser2 = new User(profileId = p.Id, username = 'newUser2@newUser1234.com',email = 'newUser@newUser.com',emailencodingkey = 'UTF-8', localesidkey = 'en_US', languagelocalekey = 'en_US', timezonesidkey = 'America/Los_Angeles', alias = 'nuser', lastname = 'user', UserRoleId = r.Id);
        User newUser3 = new User(profileId = p.Id, username = 'newUser3@newUser1234.com',email = 'newUser@newUser.com',emailencodingkey = 'UTF-8', localesidkey = 'en_US', languagelocalekey = 'en_US', timezonesidkey = 'America/Los_Angeles', alias = 'nuser', lastname = 'user');
        User newUser4 = new User(profileId = p.Id, username = 'newUser4@newUser1234.com',email = 'newUser@newUser.com',emailencodingkey = 'UTF-8', localesidkey = 'en_US', languagelocalekey = 'en_US', timezonesidkey = 'America/Los_Angeles', alias = 'nuser', lastname = 'user');
        User newUser5 = new User(profileId = p.Id, username = 'newUser5@newUser1234.com',email = 'newUser@newUser.com',emailencodingkey = 'UTF-8', localesidkey = 'en_US', languagelocalekey = 'en_US', timezonesidkey = 'America/Los_Angeles', alias = 'nuser', lastname = 'user');
        User newUser6 = new User(profileId = p.Id, username = 'newUser6@newUser1234.com',email = 'newUser@newUser.com',emailencodingkey = 'UTF-8', localesidkey = 'en_US', languagelocalekey = 'en_US', timezonesidkey = 'America/Los_Angeles', alias = 'nuser', lastname = 'user');
        User newUser7 = new User(profileId = p.Id, username = 'newUser7@newUser1234.com',email = 'newUser@newUser.com',emailencodingkey = 'UTF-8', localesidkey = 'en_US', languagelocalekey = 'en_US', timezonesidkey = 'America/Los_Angeles', alias = 'nuser', lastname = 'user');
        User newUser8 = new User(profileId = p.Id, username = 'newUser8@newUser1234.com',email = 'newUser@newUser.com',emailencodingkey = 'UTF-8', localesidkey = 'en_US', languagelocalekey = 'en_US', timezonesidkey = 'America/Los_Angeles', alias = 'nuser', lastname = 'user');
        User newUser9 = new User(profileId = p.Id, username = 'newUser9@newUser1234.com',email = 'newUser@newUser.com',emailencodingkey = 'UTF-8', localesidkey = 'en_US', languagelocalekey = 'en_US', timezonesidkey = 'America/Los_Angeles', alias = 'nuser', lastname = 'user');
        User newUser10 = new User(profileId = p.Id, username = 'newUser10@newUser1234.com',email = 'newUser@newUser.com',emailencodingkey = 'UTF-8', localesidkey = 'en_US', languagelocalekey = 'en_US', timezonesidkey = 'America/Los_Angeles', alias = 'nuser', lastname = 'user');
    
        List<User> newUserList = new List<User>();
        newUserList.add(newUser1);
        newUserList.add(newUser2);
        newUserList.add(newUser3);
        newUserList.add(newUser4);
        newUserList.add(newUser5);
        newUserList.add(newUser6);
        newUserList.add(newUser7);
        newUserList.add(newUser8);
        newUserList.add(newUser9);
        newUserList.add(newUser10);
        
        insert newUserList;
        
        System.runAs(newUser1){		
            //Prefix
            List<ASI_MFM_Prefix__c> PrefixList = new List<ASI_MFM_Prefix__c>();
            ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(	name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c=getFiscalYear(), 
                                                            recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_SG_Prefix'),
                                                            ASI_MFM_Location__c = 'Singapore'); // Insert Custom Fields & Relationships API Name   FY1415
            PrefixList.add(px);
            ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO');
            PrefixList.add(pxo);
            ASI_MFM_Prefix__c pxa = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Payment');
            PrefixList.add(pxa);
            insert PrefixList; 
            
            List<ASI_MFM_Role_Prefix_Relationship__c> RolePrefixList = new List<ASI_MFM_Role_Prefix_Relationship__c>();
            ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c = 'MyCustomRole');
            RolePrefixList.add(pr);
            ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c = 'MyCustomRole');
            RolePrefixList.add(pro); 
            
            ASI_MFM_Role_Prefix_Relationship__c pra = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Role_Name__c = thisUser.userRole.developerName);
            ASI_MFM_Role_Prefix_Relationship__c pra2 = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Role_Name__c = r.DeveloperName);
            RolePrefixList.add(pra);
            RolePrefixList.add(pra2);
            insert RolePrefixList;
            
            ASI_MFM_Brand__c brand = new ASI_MFM_Brand__c(Name ='Test', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Brand__cASI_CRM_SG_Brand'));
            insert brand;
            
            ASI_MFM_Sub_brand__c subbrand = new ASI_MFM_Sub_brand__c(Name = 'Test', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_CRM_SG_Sub_brand'),
                                                                    ASI_MFM_Brand__c = brand.Id);
            insert subbrand;
            
            ASI_MFM_Plan__c p1 = new ASI_MFM_Plan__c(	recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_SG_Plan'),
                                                        ASI_MFM_Prefix__c=px.id, ASI_MFM_Start_Date__c=date.today(), 
                                                        ASI_MFM_End_Date__c=date.today().addMonths(1),
                                                        ASI_MFM_Plan_Description__c='planDescription', ASI_MFM_Plan_Name__c='testplanName', 
                                                        ASI_MFM_Status__c = 'Final'
                                                    );
            insert p1;
            
            
            Account acc3 = new Account(		recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_CRM_SG_Supplier'),
                                            Name='Name3'); // ASI_CRM_SG_Supplier          
            insert acc3;
            
            ASI_MFM_PO__c po = new ASI_MFM_PO__c(	recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_SG_PO'),
                                                    ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Plan__c=p1.id, ASI_MFM_PO_Raised_Date__c=date.today(),
                                                    ASI_MFM_Currency__c='SGD');// ASI_MFM_Supplier_Name__c = acc1.id 
            insert po;
            
            //------------------------------------------Test start ---------------------------------------------
            
            ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(	recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_SG_PO_Line_Item'),
                                                                        ASI_MFM_PO__c=po.id, ASI_MFM_Amount__c=100,ASI_MFM_List_Item_Description__c='testDescription', 
                                                                        ASI_MFM_G_L_Date__c = Date.today(), ASI_MFM_Sub_brand_Code__c = subbrand.Id); //ASI_MFM_Customer_Name__c=acc2.id, 
            insert poi;
            
            System.debug(Limits.getDMLRows());
            
            ASI_MFM_Route_Type__c rt = new ASI_MFM_Route_Type__c(name='test', ASI_MFM_Module__c='Payment');
            insert rt;
            
            ASI_MFM_Brand_Route_Type_Map__c rtm = new ASI_MFM_Brand_Route_Type_Map__c(ASI_MFM_Route_Type__c=rt.id, ASI_MFM_Prefix__c=pxa.id); // Note :use Payment Prefix
            insert rtm;
        
            // ASI MFM Route Rule Details Set Approver 
            List<ASI_MFM_Route_Rule_Detail__c> rrdlist = new List<ASI_MFM_Route_Rule_Detail__c>();
            rrdlist.add(new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=newUser1.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id, ASI_MFM_Sequence__c=0));
            rrdlist.add(new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=newUser2.id, ASI_MFM_Minimum_Amount__c=1, ASI_MFM_Route_Type__c=rt.id, ASI_MFM_Sequence__c=1));
            rrdlist.add(new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=newUser3.id, ASI_MFM_Minimum_Amount__c=2, ASI_MFM_Route_Type__c=rt.id, ASI_MFM_Sequence__c=2));
            rrdlist.add(new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=newUser4.id, ASI_MFM_Minimum_Amount__c=3, ASI_MFM_Route_Type__c=rt.id, ASI_MFM_Sequence__c=3));
            rrdlist.add(new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=newUser5.id, ASI_MFM_Minimum_Amount__c=4, ASI_MFM_Route_Type__c=rt.id, ASI_MFM_Sequence__c=4));
            rrdlist.add(new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=newUser6.id, ASI_MFM_Minimum_Amount__c=5, ASI_MFM_Route_Type__c=rt.id, ASI_MFM_Sequence__c=5));
            rrdlist.add(new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=newUser7.id, ASI_MFM_Minimum_Amount__c=6, ASI_MFM_Route_Type__c=rt.id, ASI_MFM_Sequence__c=6));
            rrdlist.add(new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=newUser8.id, ASI_MFM_Minimum_Amount__c=7, ASI_MFM_Route_Type__c=rt.id, ASI_MFM_Sequence__c=7));
            rrdlist.add(new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=newUser9.id, ASI_MFM_Minimum_Amount__c=8, ASI_MFM_Route_Type__c=rt.id, ASI_MFM_Sequence__c=8));
            rrdlist.add(new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=newUser10.id, ASI_MFM_Minimum_Amount__c=9, ASI_MFM_Route_Type__c=rt.id, ASI_MFM_Sequence__c=9));        
            insert rrdlist;
            
            Test.startTest(); 

            ASI_MFM_Payment__c py = new ASI_MFM_Payment__c(
                                                recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_SG_Payment'),													
                                                ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Payment_Date__c=date.today(),ASI_MFM_Currency__c='SGD', ASI_MFM_Payment_Amount__c=100,ASI_MFM_Send_Approval_Email__c=true,
                                                ASI_MFM_Status__c='Final',ASI_MFM_Supplier_Name__c = acc3.id);  //ASI_MFM_Payee__c ,ASI_MFM_Sys_Approver_1__c=u2.id     
            insert py;
            System.debug('After insert payment ' + Limits.getDMLRows());

            ASI_MFM_Payment_Line_Item__c pyi = new ASI_MFM_Payment_Line_Item__c(
                                                                    recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Line_Item__cASI_MFM_SG_Payment_Line_Item'),	
                                                                    ASI_MFM_Payment_Amount__c=10, ASI_MFM_PO_Line_Item__c=poi.id, ASI_MFM_Invoice_Date__c = date.today(), ASI_MFM_Payment__c=py.id,ASI_MFM_Invoice_Number__c = '123456', ASI_MFM_Payment_Line_Item_Finance_Verify__c = true);// 
            insert pyi;
            
            // ASI_MFM_SG_FVerifyLWCController.getPaymentLine(
            //     null, null, null, null, null, null, null, null, null, null, null,
            //     null, 1, 30);
    
            List<ASI_MFM_Payment_Line_Item__c> payList = new List<ASI_MFM_Payment_Line_Item__c>();
            payList.add(pyi);
            String paymentLinesStr = JSON.serialize(payList);
    
            ASI_MFM_SG_FVerifyLWCController.savePaymentLine (paymentLinesStr);
    
            // Test ASI_MFM_MY_PORelatedPaymentsController 
            // ASI_MFM_SG_PORelatedPaymentLWCController.getPayment(po.ID);
            
            test.stopTest(); 
        }
    }
}