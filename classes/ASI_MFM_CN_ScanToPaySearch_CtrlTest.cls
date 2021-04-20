@isTest
Private class ASI_MFM_CN_ScanToPaySearch_CtrlTest {
    private static testmethod void testMethod1(){
      ASI_MFM_Market_Strategy__c ms = new ASI_MFM_Market_Strategy__c(Name='99999 Malibu', ASI_MFM_Active__c=true, ASI_MFM_Fiscal_Year__c='FY1213');        
      list<User> users = new list<User>();
     //  List<User> lstUsr = new List<User>();
      User User1 = new User(managerid = UserInfo.getUserId(), ASI_MFM_Team__c = 'ABCD', ASI_MFM_Country__c ='CN', alias = 'test99',ASI_MFM_Bypass_Callouts__c = true, email='test99' + '@dev.com', emailencodingkey='UTF-8', firstname='test99', lastname='Testing', languagelocalekey='en_US', localesidkey='en_US', timezonesidkey='Europe/London', username='test99' + '@pernod-ricard.com',ProfileId = UserInfo.getProfileId(), UserRoleId = UserInfo.getUserRoleId(), isActive=true);
      User User2 = new User(managerid = UserInfo.getUserId(), ASI_MFM_Team__c = 'ABCD', ASI_MFM_Country__c ='CN', alias = 'tes99',ASI_MFM_Bypass_Callouts__c = true, email='tes99' + '@dev.com', emailencodingkey='UTF-8', firstname='tes99', lastname='Testing', languagelocalekey='en_US', localesidkey='en_US', timezonesidkey='Europe/London', username='tes99' + '@pernod-ricard.com',ProfileId = UserInfo.getProfileId(), UserRoleId = UserInfo.getUserRoleId(), isActive=true);
      users.add(user2);
      users.add(user1);
      insert users;
      user1 = [SELECT Id, Name, ManagerId, ASI_MFM_Bypass_Callouts__c, ASI_MFM_Country__c, UserRole.DeveloperName 
                          FROM User
                          WHERE id =: user1.id 
                          LIMIT 1];
      user2 = [SELECT Id, Name, ManagerId, ASI_MFM_Bypass_Callouts__c, ASI_MFM_Country__c, UserRole.DeveloperName 
                          FROM User
                          WHERE id =: user2.id 
                          LIMIT 1];

      System.runAs(user1){       
          String strRTID;
          
          list<ASI_MFM_Prefix__c> prefixs = new list<ASI_MFM_Prefix__c>();
          prefixs.add(new ASI_MFM_Prefix__c(Name='CN',ASI_MFM_Module__c='Plan',Plan_Type__c='Allowance & Discount Spending Form'
          ,ASI_MFM_Fiscal_year__c='FY1314',ownerId = user1.id));
          
          //create prefix po
          strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_Prefix__c','ASI_MFM_CN_Prefix');
          prefixs.add(new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO', recordTypeId=strRTID,
                                                      ASI_MFM_Fiscal_year__c='FY1314', ASI_MFM_Next_Number__c=86));
          insert prefixs;
          
          list<ASI_MFM_Role_Prefix_Relationship__c> prefixChilds = new list<ASI_MFM_Role_Prefix_Relationship__c>();
          prefixChilds.Add(new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c = prefixs[0].Id,
          ASI_MFM_Role_Name__c =user1.userRole.developerName));            
          prefixChilds.Add(new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c = prefixs[1].Id,
          ASI_MFM_Role_Name__c =user1.userRole.developerName));            
          
          insert prefixChilds;

          strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_A_C_Code__c','ASI_MFM_CN_A_C_Code');
          list<ASI_MFM_A_C_Code__c> acs = new list<ASI_MFM_A_C_Code__c>();
          acs.add(new ASI_MFM_A_C_Code__c(recordtypeid=strRTId, name='testAC1', ASI_MFM_A_C_Code__c = '5600.000'));
          acs.add(new ASI_MFM_A_C_Code__c(recordtypeid=strRTId, name='testAC2', ASI_MFM_A_C_Code__c = '5600.300'));
          acs.add(new ASI_MFM_A_C_Code__c(name='testAC', recordtypeid=strRTId ));
          insert acs;
          
          strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_PP_Category__c','ASI_MFM_CN_PP_Category');   
          ASI_MFM_PP_Category__c ppc = new ASI_MFM_PP_Category__c(recordtypeid=strRTId , Name='NTMCD - KTV Promotion', ASI_MFM_External_ID__c='NTMCD - KTV Promotion (CN)1');
          insert ppc;
          
          strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_PP_Category_A_C__c','ASI_MFM_CN_PP_Category_A_C'); 
          list<ASI_MFM_PP_Category_A_C__c> ppcacs = new list<ASI_MFM_PP_Category_A_C__c>();
          ppcacs.add(new ASI_MFM_PP_Category_A_C__c(ASI_MFM_External_ID__c='test', recordtypeid=strRTId , ASI_MFM_A_C_Code__c=acs[0].id, ASI_MFM_PP_Category__c=ppc.id));
          ppcacs.add(new ASI_MFM_PP_Category_A_C__c(ASI_MFM_External_ID__c='test2', recordtypeid=strRTId , ASI_MFM_A_C_Code__c=acs[1].id,ASI_MFM_PP_Category__c=ppc.id));
          insert ppcacs; 
          
          ASI_MFM_Market_Strategy__c mms = new ASI_MFM_Market_Strategy__c(name='12004 Chivas', ASI_MFM_External_ID__c='120041',ASI_MFM_Fiscal_Year__c='FY1213', ASI_MFM_Sub_brand__c='CH2,CH3,CHF,CHU');
          insert mms;
          
          strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_Plan__c','ASI_MFM_CN_Plan'); 
          
          List<ASI_MFM_Plan__c> planList = new List<ASI_MFM_Plan__c>();
          
          ASI_MFM_Plan__c Plan1 = new ASI_MFM_Plan__c(Name='CNM131',ASI_MFM_Prefix__c=prefixs[0].Id
          ,recordTypeId=strRTId ,
          ASI_MFM_End_Date__c = Date.today().addMonths(1), ASI_MFM_Plan_Description__c='testDescription', 
          ASI_MFM_Plan_Name__c='plannameTest', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Budget_Owner__c=user1.id, 
          ASI_MFM_PP_Category__c = ppc.id, ASI_MFM_Market_Strategy__c=mms.id, ASI_MFM_Status__c='Final', OwnerId =user1.id);
          
          ASI_MFM_Plan__c Plan2 = new ASI_MFM_Plan__c(Name='CNM131',ASI_MFM_Prefix__c=prefixs[0].Id
                                                      ,recordTypeId=strRTId ,
                                                      ASI_MFM_End_Date__c = Date.today().addMonths(1), ASI_MFM_Plan_Description__c='testDescription', 
                                                      ASI_MFM_Plan_Name__c='plannameTest', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Budget_Owner__c=user1.id, 
                                                      ASI_MFM_PP_Category__c = ppc.id, ASI_MFM_Market_Strategy__c=mms.id, ASI_MFM_Status__c='Final', OwnerId =user1.id);
          
          planList.add(plan1);
          planList.add(plan2);
          
          insert planList;
          
          
          //create brand
          strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_Brand__c','ASI_MFM_CN_Brand');
          ASI_MFM_Brand__c brand = new ASI_MFM_Brand__c(name='brandname',Recordtypeid=strRTId);
          insert brand; 
   
          list<ASI_MFM_Sub_brand__c> subBrands = new list<ASI_MFM_Sub_brand__c>();
          //create sub brand
          strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_Sub_brand__c','ASI_MFM_CN_Sub_Brand');
          subBrands.add(new ASI_MFM_Sub_brand__c(Name='subBrand1' ,recordTypeId=strRTId, ASI_MFM_Brand__c=brand.id,ASI_MFM_Sub_brand_Code__c = 'subBrand1'));
          subBrands.add(new ASI_MFM_Sub_brand__c(Name='subBrand2' ,recordTypeId=strRTId, ASI_MFM_Sub_brand_Code__c = 'subBrand2'));
          subBrands.add(new ASI_MFM_Sub_brand__c(Name='testSb',recordtypeid=strRTId,ASI_MFM_Brand__c=brand.id, ASI_MFM_Sub_brand_Code__c = 'testSb'));
          insert subBrands;
                     
          list<Account> accs = new list<Account>();
          
          strRTId = ASI_MFM_Function.checkRecordType('Account','ASI_MFM_CN_Outlet'); 
          accs.add(new Account(recordTypeId=strRTId ,Name='Name3',ASI_MFM_Customer_Supplier_Number__c='1234'));
          
           //ASI_MFM_CN_Supplier 
          strRTId = ASI_MFM_Function.checkRecordType('Account','ASI_MFM_CN_Supplier'); 
          accs.add(new Account(Name='TestAcc', recordTypeId=strRTId , ASI_MFM_Customer_Supplier_Number__c='123',
                                  ASI_MFM_Customer_Supplier_Name__c='SupplierName'));
          insert accs;
          
          strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_Plan_Line_Item__c','ASI_MFM_CN_Plan_Line_Item');
          ASI_MFM_Plan_Line_Item__c planLineItem1 = new ASI_MFM_Plan_Line_Item__c(ASI_MFM_Plan__c = Plan1.id
          ,ASI_MFM_Sub_brand_Code__c = subBrands[2].id,ASI_MFM_List_Item_Description__c='hello1'
          ,recordTypeId=strRTId , ASI_MFM_Total_Cost__c =120000,
          ASI_MFM_A_C_Code__c=acs[2].id
          );
          insert planLineItem1; 
          
          //create BU Code
          strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_BU__c','ASI_MFM_CN_BU');
          ASI_MFM_BU__c bu = new ASI_MFM_BU__c(Name='BUCode', ASI_MFM_BU_Code__c=strRTId , ASI_MFM_CN_Country__c='CN',
                                              ASI_MFM_Base_Currency__c='RMB');
          insert bu;
          
          
          
          //create exchange rate reference
          ASI_MFM_Exchange_Rate__c ex = new ASI_MFM_Exchange_Rate__c(ASI_MFM_Country__c='CN',ASI_MFM_Effective_Date__c=Date.valueof('2014-01-01'),
                                                                     ASI_MFM_Exchange_Rate__c=7.77500, ASI_MFM_Counter_Currency__c='USD', ASI_MFM_Base_Currency__c='RMB',
                                                                     ASI_MFM_Application__c='MFM' );
          insert ex;
          
          //create po
          strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_PO__c','ASI_MFM_CN_PO');
          ASI_MFM_PO__c po = new ASI_MFM_PO__c(Name='PO11111'
                                              , RecordTypeId=strRTId 
                                              , ASI_MFM_Prefix__c=prefixs[1].id
                                              , ASI_MFM_Remarks__c='Remarks'
                                              , ASI_MFM_BU_Code__c=bu.id, ASI_MFM_Supplier_Name__c=accs[1].id, ASI_MFM_Currency__c='USD'
                                              , ASI_MFM_PO_Start_Date__c=Date.valueof('2014-04-01'),ASI_MFM_PO_End_Date__c=Date.valueof('2014-04-30')
                                              , ASI_MFM_Budget_Owner__c =user1.id, ASI_MFM_Plan__c=Plan1.id, ASI_MFM_PO_Original_Amount__c=721
                                              , ASI_MFM_CN_BU_Picklist__c='PRCN'
                                              , ASI_MFM_PO_Type__c='Other'
                                              , ASI_MFM_PO_Channel__c='VIP'
                                              , ownerId = user1.id
                                              , ASI_MFM_Supplier_eMail_Sent__c = false);
          insert po;
          
          
          //create po line item
          strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_PO_Line_Item__c','ASI_MFM_CN_PO_Line_Item');
          ASI_MFM_PO_Line_Item__c poli = new ASI_MFM_PO_Line_Item__c(RecordTypeId=strRTId
                                                                      , ASI_MFM_PO__c=po.id
                                                                      , ASI_MFM_G_L_Date__c=date.valueof('2014-04-03')
                                                                      , ASI_MFM_Sub_brand_Code__c=subBrands[2].id
                                                                     , ASI_MFM_A_C_Code__c = acs[2].id
                                                                     , ASI_MFM_Customer_Name__c=accs[0].id  );
          insert poli;
          
          //create fix approval route
          strRTId = Global_recordTypeCache.getRtId('ASI_CRM_Fix_Approval_Route__cASI_CRM_CN_Fix_Approval_Route');
          ASI_CRM_Fix_Approval_Route__c fapp = new ASI_CRM_Fix_Approval_Route__c(RecordTypeId = strRTId, OwnerId = user1.id, ASI_CRM_CN_Alternative_Approver__c = user1.id, ASI_CRM_Supplier__c = accs[1].id, ASI_CRM_MY_Sub_Brand__c = subBrands[0].id, ASI_CRM_CN_Type__c='PO ScanToPay');
          insert fapp;
          
          Test.startTest();   
          ASI_MFM_CN_ScanToPaySearch_Ctrl con = new ASI_MFM_CN_ScanToPaySearch_Ctrl();

          Map<String, Map<String, String>> myMapInput = new Map<String, Map<String, String>>();
          Map<String, String> myMap = new Map<String, String>();

          myMap.put('SubBrand_inVal',subBrands[2].id);
          myMap.put('SubBrandCodes_inVal','subBrand1,subBrand2,testSb');
          myMap.put('Brand_inVal',brand.id);
          myMap.put('PONum_inVal','');
          myMap.put('Plan_inVal',Plan1.id);
          myMap.put('OriAmt_inVal','');
          myMap.put('BudgetOwner_inVal',user1.id);
          myMap.put('Supplier_inVal',accs[1].id);
          myMap.put('SupplierCodes_inVal','1234,123');
          myMap.put('Owner_inVal',user1.id);
          myMap.put('POChannel_inVal','VIP');
          myMap.put('FY_inVal','FY1314');
          myMap.put('POType_inVal','Other');
          myMap.put('BU_inVal','PRCN');
          myMap.put('EmailSent_inVal','false');
          myMapInput.put('criteriaArray', myMap);
          system.debug(JSON.serialize(myMapInput));                                                                     
          List<ASI_MFM_CN_ScanToPaySearch_Ctrl.POSearchResultWrapper> rt_search = ASI_MFM_CN_ScanToPaySearch_Ctrl.search(0, 20, 20, JSON.serialize(myMapInput));


          
          // {"criteriaArray":{"Plan_inVal":"000000000000000"}}
          // {"criteriaArray":{"PONum_inVal":"","Plan_inVal":"000000000000000","OriAmt_inVal":"","BudgetOwner_inVal":"000000000000000","Supplier_inVal":"000000000000000","Owner_inVal":"005M0000004uWIP","SubBrand_inVal":"PPS, CH2","POChannel_inVal":"","Brand_inVal":"000000000000000","FY_inVal":&
    
          List<Id> myIdInput = new List<Id>();
          myIdInput.add(po.Id);
          ASI_MFM_CN_ScanToPaySearch_Ctrl.SaveResult rt_sendEmail = ASI_MFM_CN_ScanToPaySearch_Ctrl.sendEmail(myIdInput);
          test.stopTest();
    }
  }
}