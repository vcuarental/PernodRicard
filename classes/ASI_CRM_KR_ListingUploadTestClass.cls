@isTest
public class ASI_CRM_KR_ListingUploadTestClass {
	 static testMethod void ASI_CRM_KR_ListedPriceUploadCtrlTest1(){  //Normal Case
        
        //Account - Venue
        List<Account> AccountList = new List<Account> ();
        Account acc = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_KOR_Venue'),name = 'Venue1',ASI_KOR_Customer_Code__c='11111',ASI_KOR_Venue_Status__c='Active');
        AccountList.add(acc);
        Account acc1 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_KOR_Venue'),name = 'Venue2',ASI_KOR_Customer_Code__c='22222',ASI_KOR_Venue_Status__c='Active');
        AccountList.add(acc1);
        Account acc2 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_KOR_Venue'),name = 'Venue3',ASI_KOR_Customer_Code__c='33333',ASI_KOR_Venue_Status__c='Active');
        AccountList.add(acc2);
        insert AccountList;
        
        //Sub Brand
        ASI_KOR_Sub_Brand__c SubBrand = new ASI_KOR_Sub_Brand__c(ASI_KOR_Sub_Brand_Code__c='Test',ASI_KOR_Brand_Code__c='Test');
        insert SubBrand;
         
        //Item Group 
        List<ASI_KOR_Item_Group__c> ItemGroupList = new List<ASI_KOR_Item_Group__c> ();
        ASI_KOR_Item_Group__c ItemGroup1 = new ASI_KOR_Item_Group__c(ASI_KOR_Item_Group_Name__c='A12345', ASI_KOR_Item_Group_Code__c='A12345',
                                                                    ASI_KOR_Sub_Brand__c=SubBrand.id,ASI_KOR_Description__c='Test',ASI_CRM_KR_Priority_Item__c =true, ASI_KOR_Active__c= true);
        
        ItemGroupList.add(ItemGroup1);
        
        ASI_KOR_Item_Group__c ItemGroup2 = new ASI_KOR_Item_Group__c(ASI_KOR_Item_Group_Name__c='B12345', ASI_KOR_Item_Group_Code__c='B12345',
                                                                    ASI_KOR_Sub_Brand__c=SubBrand.id,ASI_KOR_Description__c='Test',ASI_CRM_KR_Priority_Item__c =true, ASI_KOR_Active__c= true);
        
        ItemGroupList.add(ItemGroup2);
        insert ItemGroupList;
         
         
         //Listed Menu Price Header: ASI_CRM_KR_Listed_Menu_Price__c 
        List<ASI_CRM_KR_Listed_Menu_Price__c> HeaderList = new List<ASI_CRM_KR_Listed_Menu_Price__c>();
        ASI_CRM_KR_Listed_Menu_Price__c Header1 = new ASI_CRM_KR_Listed_Menu_Price__c(ASI_CRM_KR_Quarter__c= 'Q1', ASI_CRM_KR_Fiscal_Year__c= 'FY1516', ASI_CRM_KR_Venue__c=acc.ID);
        HeaderList.add(Header1);
        insert HeaderList;
        
        //Temp Data: ASI_CRM_KR_TempListedMenuPrice__c
        List<ASI_CRM_KR_TempListedMenuPrice__c> TempDataList = new List<ASI_CRM_KR_TempListedMenuPrice__c> ();
        ASI_CRM_KR_TempListedMenuPrice__c TempData1 = new ASI_CRM_KR_TempListedMenuPrice__c(ASI_CRM_KR_Fiscal_Year__c='FY1516', ASI_CRM_KR_Item_Group_Code__c=ItemGroup1.ID,
                                                                    						ASI_CRM_KR_Listed_Price__c = 1, ASI_CRM_KR_Quarter__c='Q1', ASI_CRM_KR_Venue__c=acc.ID,
                                                                                           ASI_CRM_KR_Unique_ID__c = 'FY1516&Q1&'+acc.ID+'&'+ItemGroup1.ID); 
        TempDataList.add(TempData1); 
        
        ASI_CRM_KR_TempListedMenuPrice__c TempData2 = new ASI_CRM_KR_TempListedMenuPrice__c(ASI_CRM_KR_Fiscal_Year__c='FY1516', ASI_CRM_KR_Item_Group_Code__c=ItemGroup1.ID,
                                                                    						ASI_CRM_KR_Listed_Price__c = 1, ASI_CRM_KR_Quarter__c='Q2', ASI_CRM_KR_Venue__c=acc.ID,
                                                                                           ASI_CRM_KR_Unique_ID__c = 'FY1516&Q2&'+acc.ID+'&'+ItemGroup1.ID);
        TempDataList.add(TempData2); 
         
        ASI_CRM_KR_TempListedMenuPrice__c TempData3 = new ASI_CRM_KR_TempListedMenuPrice__c(ASI_CRM_KR_Fiscal_Year__c='FY1516', ASI_CRM_KR_Item_Group_Code__c=ItemGroup1.ID,
                                                                    						ASI_CRM_KR_Listed_Price__c = 1, ASI_CRM_KR_Quarter__c='Q3', ASI_CRM_KR_Venue__c=acc.ID,
                                                                                           ASI_CRM_KR_Unique_ID__c = 'FY1516&Q3&'+acc.ID+'&'+ItemGroup1.ID);
        TempDataList.add(TempData3); 
        
        ASI_CRM_KR_TempListedMenuPrice__c TempData4 = new ASI_CRM_KR_TempListedMenuPrice__c(ASI_CRM_KR_Fiscal_Year__c='FY1516', ASI_CRM_KR_Item_Group_Code__c=ItemGroup1.ID,
                                                                    						ASI_CRM_KR_Listed_Price__c = 1, ASI_CRM_KR_Quarter__c='Q4', ASI_CRM_KR_Venue__c=acc.ID,
                                                                                           ASI_CRM_KR_Unique_ID__c = 'FY1516&Q4&'+acc.ID+'&'+ItemGroup1.ID);
        TempDataList.add(TempData4);
        
        ASI_CRM_KR_TempListedMenuPrice__c TempData5 = new ASI_CRM_KR_TempListedMenuPrice__c(ASI_CRM_KR_Fiscal_Year__c='FY1516', ASI_CRM_KR_Item_Group_Code__c=ItemGroup2.ID,
                                                                    						ASI_CRM_KR_Listed_Price__c = 1, ASI_CRM_KR_Quarter__c='Q4', ASI_CRM_KR_Venue__c=acc.ID,
                                                                                           ASI_CRM_KR_Unique_ID__c = 'FY1516&Q4&'+acc.ID+'&'+ItemGroup2.ID);
        TempDataList.add(TempData5); 
        
        ASI_CRM_KR_TempListedMenuPrice__c TempData6 = new ASI_CRM_KR_TempListedMenuPrice__c(ASI_CRM_KR_Fiscal_Year__c='FY1516', ASI_CRM_KR_Item_Group_Code__c=ItemGroup2.ID,
                                                                    						ASI_CRM_KR_Listed_Price__c = 1, ASI_CRM_KR_Quarter__c='Q1', ASI_CRM_KR_Venue__c=acc.ID,
                                                                                           ASI_CRM_KR_Unique_ID__c = 'FY1516&Q1&'+acc.ID+'&'+ItemGroup2.ID);
        TempDataList.add(TempData6); 
        
        insert TempDataList;
        
       
         
        //Start Test:
         Test.startTest();
         	ASI_CRM_KR_ListedPriceUploadCtrl con = new ASI_CRM_KR_ListedPriceUploadCtrl();
         	ASI_MFM_Mass_Upload_Log__c MFMlog= new ASI_MFM_Mass_Upload_Log__c();
         	insert MFMlog;
         
         	Id BatchId ;
         
         	con.retrievePriorityItemReport('KR_CRM_Item_Group_PriorityItem');
         	con.retrievePriorityItemReport('ASI_CRM_KR_TempListedMenuPriceReport');
         	
         	con.generateHeader();
         	//ASI_CRM_KR_ListingUploadBatch batch = new ASI_CRM_KR_ListingUploadBatch(MFMlog);
         	BatchId = Database.executeBatch(new ASI_CRM_KR_ListingUploadBatch(MFMlog),500); 
         	//BatchId = Database.executeBatch(batch,1); 
         	  
             
         	//con.deleteUploads();
         
         	
         Test.stopTest();
        //End Test.
     }
     
      static testMethod void ASI_CRM_KR_ListedPriceUploadCtrlTest2(){  
          
          //Start Test:
         Test.startTest();
            
         	ASI_CRM_KR_ListedPriceUploadCtrl con = new ASI_CRM_KR_ListedPriceUploadCtrl();
         	ASI_MFM_Mass_Upload_Log__c MFMlog= new ASI_MFM_Mass_Upload_Log__c();
         	insert MFMlog;
         
         	Id BatchId ;

         	con.retrievePriorityItemReport('KR_CRM_Item_Group_PriorityItem');
         	con.retrievePriorityItemReport('ASI_CRM_KR_TempListedMenuPriceReport');
         	
         	con.generateHeader();
         	
         	ASI_CRM_KR_ListingUploadBatch batch = new ASI_CRM_KR_ListingUploadBatch(MFMlog);
         	//BatchId = Database.executeBatch(new ASI_CRM_KR_ListingUploadBatch(MFMlog),500); 
         	BatchId = Database.executeBatch(batch,1); 
         	  
            String[] myArray = new List<String>();
            for(String stringtest : con.GenStatusMsgs){
               myArray.add(stringtest);
            }
            
            
         	//con.deleteUploads();
         	//con.deleteUploads();
         	//List<string> stringtest = new List<string>();
            //con.GenStatusMsgs;
         	
         Test.stopTest();
        //End Test.
          
      }
      
      static testMethod void ASI_CRM_KR_ListedPriceUploadCtrlTest3(){  
          
          //Start Test:
         Test.startTest();
            PageReference UploadPage = Page.ASI_CRM_KR_ListedMenuPriceUploadPage;
            Test.setCurrentPage(UploadPage);
            
         	ASI_CRM_KR_ListedPriceUploadCtrl con = new ASI_CRM_KR_ListedPriceUploadCtrl();
         	ASI_MFM_Mass_Upload_Log__c MFMlog= new ASI_MFM_Mass_Upload_Log__c();
         	insert MFMlog;
         
         	Id BatchId ;

         	con.retrievePriorityItemReport('KR_CRM_Item_Group_PriorityItem');
         	con.retrievePriorityItemReport('ASI_CRM_KR_TempListedMenuPriceReport');
         	
         	String[] myArray = new List<String>();
            for(String stringtest : con.GenStatusMsgs){
               myArray.add(stringtest);
            }
            
         	con.generateHeader();
         	//ASI_CRM_KR_ListingUploadBatch batch = new ASI_CRM_KR_ListingUploadBatch(MFMlog);
         	
            for(String stringtest1 : con.GenStatusMsgs){
               myArray.add(stringtest1);
            }
            
         	BatchId = Database.executeBatch(new ASI_CRM_KR_ListingUploadBatch(MFMlog),500); 
         	//BatchId = Database.executeBatch(batch,1); 
         	
            for(String stringtest2 : con.GenStatusMsgs){
               myArray.add(stringtest2);
            }  
           
            
         	//con.deleteUploads();
            con.generateHeader();
         	con.deleteUploads();
         	
         Test.stopTest();
        //End Test.
          
      }
      
      static testMethod void ASI_CRM_KR_ListedPriceUploadCtrlTest4(){  //Normal Case
        
        //Account - Venue
        List<Account> AccountList = new List<Account> ();
        Account acc = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_KOR_Venue'),name = 'Venue1',ASI_KOR_Customer_Code__c='11111',ASI_KOR_Venue_Status__c='Active');
        AccountList.add(acc);
        Account acc1 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_KOR_Venue'),name = 'Venue2',ASI_KOR_Customer_Code__c='22222',ASI_KOR_Venue_Status__c='Active');
        AccountList.add(acc1);
        Account acc2 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_KOR_Venue'),name = 'Venue3',ASI_KOR_Customer_Code__c='33333',ASI_KOR_Venue_Status__c='Active');
        AccountList.add(acc2);
        insert AccountList;
        
        //Sub Brand
        ASI_KOR_Sub_Brand__c SubBrand = new ASI_KOR_Sub_Brand__c(ASI_KOR_Sub_Brand_Code__c='Test',ASI_KOR_Brand_Code__c='Test');
        insert SubBrand;
         
        //Item Group 
        List<ASI_KOR_Item_Group__c> ItemGroupList = new List<ASI_KOR_Item_Group__c> ();
        ASI_KOR_Item_Group__c ItemGroup1 = new ASI_KOR_Item_Group__c(ASI_KOR_Item_Group_Name__c='A12345', ASI_KOR_Item_Group_Code__c='A12345',
                                                                    ASI_KOR_Sub_Brand__c=SubBrand.id,ASI_KOR_Description__c='Test',ASI_CRM_KR_Priority_Item__c =true, ASI_KOR_Active__c= true);
        
        ItemGroupList.add(ItemGroup1);
        
        ASI_KOR_Item_Group__c ItemGroup2 = new ASI_KOR_Item_Group__c(ASI_KOR_Item_Group_Name__c='B12345', ASI_KOR_Item_Group_Code__c='B12345',
                                                                    ASI_KOR_Sub_Brand__c=SubBrand.id,ASI_KOR_Description__c='Test',ASI_CRM_KR_Priority_Item__c =true, ASI_KOR_Active__c= true);
        
        ItemGroupList.add(ItemGroup2);
        insert ItemGroupList;
         
        //Listed Menu Price Header: ASI_CRM_KR_Listed_Menu_Price__c 
        List<ASI_CRM_KR_Listed_Menu_Price__c> HeaderList = new List<ASI_CRM_KR_Listed_Menu_Price__c>();
        ASI_CRM_KR_Listed_Menu_Price__c Header1 = new ASI_CRM_KR_Listed_Menu_Price__c(ASI_CRM_KR_Quarter__c= 'Q1', ASI_CRM_KR_Fiscal_Year__c= 'FY1516', ASI_CRM_KR_Venue__c=acc.ID);
        HeaderList.add(Header1);
        insert HeaderList;
        
        //Temp Data: ASI_CRM_KR_TempListedMenuPrice__c
        List<ASI_CRM_KR_TempListedMenuPrice__c> TempDataList = new List<ASI_CRM_KR_TempListedMenuPrice__c> ();
        ASI_CRM_KR_TempListedMenuPrice__c TempData1 = new ASI_CRM_KR_TempListedMenuPrice__c(ASI_CRM_KR_Fiscal_Year__c='FY1516', ASI_CRM_KR_Item_Group_Code__c=ItemGroup2.ID,
                                                                    						ASI_CRM_KR_Listed_Price__c = 1, ASI_CRM_KR_Quarter__c='Q1', ASI_CRM_KR_Venue__c=acc.ID,
                                                                                           ASI_CRM_KR_Unique_ID__c = 'FY1516&Q1&'+acc.ID+'&'+ItemGroup2.ID);
        TempDataList.add(TempData1); 
        
        ASI_CRM_KR_TempListedMenuPrice__c TempData2 = new ASI_CRM_KR_TempListedMenuPrice__c(ASI_CRM_KR_Fiscal_Year__c='FY1516', ASI_CRM_KR_Item_Group_Code__c=ItemGroup1.ID,
                                                                    						ASI_CRM_KR_Listed_Price__c = 1, ASI_CRM_KR_Quarter__c='Q1', ASI_CRM_KR_Venue__c=acc.ID,
                                                                                           ASI_CRM_KR_Unique_ID__c = 'FY1516&Q1&'+acc.ID+'&'+ItemGroup1.ID);
        TempDataList.add(TempData2); 
        
        insert TempDataList;
        
       
         
        //Start Test:
         Test.startTest();
         	ASI_CRM_KR_ListedPriceUploadCtrl con = new ASI_CRM_KR_ListedPriceUploadCtrl();
         	ASI_MFM_Mass_Upload_Log__c MFMlog= new ASI_MFM_Mass_Upload_Log__c();
         	insert MFMlog;
         
         	Id BatchId ;
         
         	con.retrievePriorityItemReport('KR_CRM_Item_Group_PriorityItem');
         	con.retrievePriorityItemReport('ASI_CRM_KR_TempListedMenuPriceReport');
         	
         	con.generateHeader();
         	//ASI_CRM_KR_ListingUploadBatch batch = new ASI_CRM_KR_ListingUploadBatch(MFMlog);
         	
         	BatchId = Database.executeBatch(new ASI_CRM_KR_ListingUploadBatch(MFMlog),500);   
         	//BatchId = Database.executeBatch(batch,1); 
         	  
             
         	//con.deleteUploads();
         
         	
         Test.stopTest();
        //End Test.
     }
     
     static testMethod void ASI_CRM_KR_ListedPriceUploadCtrlTest5(){  
        
        //Account - Venue
        List<Account> AccountList = new List<Account> ();
        Account acc = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_KOR_Venue'),name = 'Venue1',ASI_KOR_Customer_Code__c='11111',ASI_KOR_Venue_Status__c='Active');
        AccountList.add(acc);
        Account acc1 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_KOR_Venue'),name = 'Venue2',ASI_KOR_Customer_Code__c='22222',ASI_KOR_Venue_Status__c='Active');
        AccountList.add(acc1);
        Account acc2 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_KOR_Venue'),name = 'Venue3',ASI_KOR_Customer_Code__c='33333',ASI_KOR_Venue_Status__c='Active');
        AccountList.add(acc2);
        insert AccountList;
        
        //Sub Brand
        ASI_KOR_Sub_Brand__c SubBrand = new ASI_KOR_Sub_Brand__c(ASI_KOR_Sub_Brand_Code__c='Test',ASI_KOR_Brand_Code__c='Test');
        insert SubBrand;
         
        //Item Group 
        List<ASI_KOR_Item_Group__c> ItemGroupList = new List<ASI_KOR_Item_Group__c> ();
        ASI_KOR_Item_Group__c ItemGroup1 = new ASI_KOR_Item_Group__c(ASI_KOR_Item_Group_Name__c='A12345', ASI_KOR_Item_Group_Code__c='A12345',
                                                                    ASI_KOR_Sub_Brand__c=SubBrand.id,ASI_KOR_Description__c='Test',ASI_CRM_KR_Priority_Item__c =true, ASI_KOR_Active__c= true);
        
        ItemGroupList.add(ItemGroup1);
        
        ASI_KOR_Item_Group__c ItemGroup2 = new ASI_KOR_Item_Group__c(ASI_KOR_Item_Group_Name__c='B12345', ASI_KOR_Item_Group_Code__c='B12345',
                                                                    ASI_KOR_Sub_Brand__c=SubBrand.id,ASI_KOR_Description__c='Test',ASI_CRM_KR_Priority_Item__c =true, ASI_KOR_Active__c= true);
        
        ItemGroupList.add(ItemGroup2);
        insert ItemGroupList;
         
        //Listed Menu Price Header: ASI_CRM_KR_Listed_Menu_Price__c 
        List<ASI_CRM_KR_Listed_Menu_Price__c> HeaderList = new List<ASI_CRM_KR_Listed_Menu_Price__c>();
        ASI_CRM_KR_Listed_Menu_Price__c Header1 = new ASI_CRM_KR_Listed_Menu_Price__c(ASI_CRM_KR_Quarter__c= 'Q1', ASI_CRM_KR_Fiscal_Year__c= 'FY1516', ASI_CRM_KR_Venue__c=acc.ID);
        HeaderList.add(Header1);
        insert HeaderList;
        
        //Temp Data: ASI_CRM_KR_TempListedMenuPrice__c
        List<ASI_CRM_KR_TempListedMenuPrice__c> TempDataList = new List<ASI_CRM_KR_TempListedMenuPrice__c> ();
        ASI_CRM_KR_TempListedMenuPrice__c TempData1 = new ASI_CRM_KR_TempListedMenuPrice__c(ASI_CRM_KR_Fiscal_Year__c='FY1516', ASI_CRM_KR_Item_Group_Code__c=ItemGroup2.ID,
                                                                    						ASI_CRM_KR_Listed_Price__c = 1, ASI_CRM_KR_Quarter__c='Q1', ASI_CRM_KR_Venue__c=acc.ID,
                                                                                           ASI_CRM_KR_Unique_ID__c = 'FY1516&Q1&'+acc.ID+'&'+ItemGroup2.ID);
        TempDataList.add(TempData1); 
        
        ASI_CRM_KR_TempListedMenuPrice__c TempData2 = new ASI_CRM_KR_TempListedMenuPrice__c(ASI_CRM_KR_Fiscal_Year__c='FY1516', ASI_CRM_KR_Item_Group_Code__c=ItemGroup1.ID,
                                                                    						ASI_CRM_KR_Listed_Price__c = 1, ASI_CRM_KR_Quarter__c='Q1', ASI_CRM_KR_Venue__c=acc.ID,
                                                                                           ASI_CRM_KR_Unique_ID__c = 'FY1516&Q1&'+acc.ID+'&'+ItemGroup1.ID);
        TempDataList.add(TempData2); 
        
        insert TempDataList;
        
       
         
        //Start Test:
         Test.startTest();
         	ASI_CRM_KR_ListedPriceUploadCtrl con = new ASI_CRM_KR_ListedPriceUploadCtrl();
         	
         
         	con.deleteUploads();
         
         	
         Test.stopTest();
        //End Test.
     }
     /*
      static testMethod void ASI_CRM_KR_ListedPriceUploadCtrlTest6(){   //GenStatusMsgs
          
          //Start Test:
         Test.startTest();
            PageReference UploadPage = Page.ASI_CRM_KR_ListedMenuPriceUploadPage;
            Test.setCurrentPage(UploadPage);
            
         	ASI_CRM_KR_ListedPriceUploadCtrl con = new ASI_CRM_KR_ListedPriceUploadCtrl();
         	ASI_MFM_Mass_Upload_Log__c MFMlog= new ASI_MFM_Mass_Upload_Log__c();
         	insert MFMlog;
         
         	Id BatchId ;

         	con.retrievePriorityItemReport('KR_CRM_Item_Group_PriorityItem');
         	con.retrievePriorityItemReport('ASI_CRM_KR_TempListedMenuPriceReport');
         	
         	String[] myArray = new List<String>();
            for(String stringtest : con.GenStatusMsgs){
               myArray.add(stringtest);
            }
            
         	con.generateHeader();
         	//ASI_CRM_KR_ListingUploadBatch batch = new ASI_CRM_KR_ListingUploadBatch(MFMlog);
         	
            for(String stringtest1 : con.GenStatusMsgs){
               myArray.add(stringtest1);
            }
            con.DeletePermission = false;
         	BatchId = Database.executeBatch(new ASI_CRM_KR_ListingUploadBatch(MFMlog),500); 
         	//BatchId = Database.executeBatch(batch,1); 
         	con.DeletePermission = false;
            for(String stringtest2 : con.GenStatusMsgs){
               myArray.add(stringtest2);
            }  
           
            
         	
            con.generateHeader();
            con.DeletePermission = false;
         
         	
         Test.stopTest();
        //End Test.
          
      }
      */
       static testMethod void ASI_CRM_KR_ListedPriceUploadCtrlTest7(){   //GenStatusMsgs
          
          //Account - Venue
        List<Account> AccountList = new List<Account> ();
        Account acc = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_KOR_Venue'),name = 'Venue1',ASI_KOR_Customer_Code__c='11111',ASI_KOR_Venue_Status__c='Active');
        AccountList.add(acc);
        insert AccountList;
        
        //Sub Brand
        ASI_KOR_Sub_Brand__c SubBrand = new ASI_KOR_Sub_Brand__c(ASI_KOR_Sub_Brand_Code__c='Test',ASI_KOR_Brand_Code__c='Test');
        insert SubBrand;
         
        //Item Group 
        List<ASI_KOR_Item_Group__c> ItemGroupList = new List<ASI_KOR_Item_Group__c> ();
        ASI_KOR_Item_Group__c ItemGroup2 = new ASI_KOR_Item_Group__c(ASI_KOR_Item_Group_Name__c='B12345', ASI_KOR_Item_Group_Code__c='B12345',
                                                                    ASI_KOR_Sub_Brand__c=SubBrand.id,ASI_KOR_Description__c='Test',ASI_CRM_KR_Priority_Item__c =true, ASI_KOR_Active__c= true);
        
        ItemGroupList.add(ItemGroup2);
        insert ItemGroupList;
         
        
        //Temp Data: ASI_CRM_KR_TempListedMenuPrice__c
        List<ASI_CRM_KR_TempListedMenuPrice__c> TempDataList = new List<ASI_CRM_KR_TempListedMenuPrice__c> ();
        ASI_CRM_KR_TempListedMenuPrice__c TempData1 = new ASI_CRM_KR_TempListedMenuPrice__c(ASI_CRM_KR_Fiscal_Year__c='FY1516', ASI_CRM_KR_Item_Group_Code__c=ItemGroup2.ID,
                                                                    						ASI_CRM_KR_Listed_Price__c = 1, ASI_CRM_KR_Quarter__c='Q1', ASI_CRM_KR_Venue__c=acc.ID,
                                                                                           ASI_CRM_KR_Unique_ID__c = 'FY1516&Q1&'+acc.ID+'&'+ItemGroup2.ID);
        TempDataList.add(TempData1); 
        
        insert TempDataList;
        
          //Start Test:
         Test.startTest();
            PageReference UploadPage = Page.ASI_CRM_KR_ListedMenuPriceUploadPage;
            Test.setCurrentPage(UploadPage);
            
         	ASI_CRM_KR_ListedPriceUploadCtrl con = new ASI_CRM_KR_ListedPriceUploadCtrl();
         	ASI_MFM_Mass_Upload_Log__c MFMlog= new ASI_MFM_Mass_Upload_Log__c();
         	insert MFMlog;
            con.MFMlog = MFMlog;
         	Id BatchId ;

         	con.retrievePriorityItemReport('KR_CRM_Item_Group_PriorityItem');
         	con.retrievePriorityItemReport('ASI_CRM_KR_TempListedMenuPriceReport');
         	
         	String[] myArray = new List<String>();
            for(String stringtest : con.GenStatusMsgs){
               myArray.add(stringtest);
            }
            
         	con.generateHeader();
         	//ASI_CRM_KR_ListingUploadBatch batch = new ASI_CRM_KR_ListingUploadBatch(MFMlog);
         	
            for(String stringtest1 : con.GenStatusMsgs){
               myArray.add(stringtest1);
            }
            con.DeletePermission = false;
         	BatchId = Database.executeBatch(new ASI_CRM_KR_ListingUploadBatch(MFMlog),500); 
         	//BatchId = Database.executeBatch(batch,1); 
         	con.DeletePermission = false;
            for(String stringtest2 : con.GenStatusMsgs){
               myArray.add(stringtest2);
            }  
            
            list<AsyncApexJob> aajs = [SELECT Id, Status, ExtendedStatus FROM AsyncApexJob WHERE ID =: con.BatchId  ];
            
            con.BatchId = BatchId;
            con.MFMlog = MFMlog;
         	
         	for(String stringtest3 : con.GenStatusMsgs){
               myArray.add(stringtest3);
            } 
        
         	//system.assertEquals(aajs,null);
            con.DeletePermission = false;
         
         	
         Test.stopTest();
        //End Test.
          
      }
      
     static testMethod void ASI_CRM_KR_ListedPriceUploadCtrlTest8(){   //GenStatusMsgs
          
        
          //Start Test:
         Test.startTest();
            PageReference UploadPage = Page.ASI_CRM_KR_ListedMenuPriceUploadPage;
            Test.setCurrentPage(UploadPage);
            
         	ASI_CRM_KR_ListedPriceUploadCtrl con = new ASI_CRM_KR_ListedPriceUploadCtrl();
         	
         
         	
         	con.deleteUploads();
         	String[] myArray = new List<String>();
            for(String stringtest : con.GenStatusMsgs){
               myArray.add(stringtest);
            }
            
         	
            for(String stringtest2 : con.GenStatusMsgs){
               myArray.add(stringtest2);
            }  

         	for(String stringtest3 : con.GenStatusMsgs){
               myArray.add(stringtest3);
            } 
          
         	//system.assertEquals(aajs,null);
           
         
         	
         Test.stopTest();
        //End Test.
          
      }
}