@isTest
/*********************************************************************
* Test class: ASI_CRM_KR_ListedMenuPrice_TriggerClass
* 			  ASI_CRM_KR_COGS_TriggerClass
* 			  ASI_CRM_KR_ListViewInput
* ******************************************************************/


public class ASI_CRM_KR_TestClass {
    
    //ASI_CRM_KR_ListViewInput
    static testMethod void ASI_CRM_KR_ListViewInputTest(){
        
        Date todaydate =system.today();
        
        //Account
        List<Account> AccountList = new List<Account> ();
        Account acc = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_KOR_Wholesaler'),name = 'Wholesaler',ASI_KOR_Customer_Code__c='123',ASI_KOR_Venue_Status__c='Active', ASI_KOR_Grade__c='T1');
        AccountList.add(acc);
        Account acc1 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_KOR_Wholesaler'),name = 'Wholesaler123',ASI_KOR_Customer_Code__c='18232131',ASI_KOR_Venue_Status__c='Active', ASI_KOR_Grade__c='T2');
        AccountList.add(acc1);
        Account acc2 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_KOR_Wholesaler'),name = 'WholesalerFailed',ASI_KOR_Customer_Code__c='1234',ASI_KOR_Venue_Status__c='Active', ASI_KOR_Grade__c='T3');
        AccountList.add(acc2);
        insert AccountList;
        
        List<string> AccIDList = new List<String>();
        for(Account ac:AccountList){
            AccIDList.add(string.valueOf(ac.id));
        }
        
        ASI_KOR_Sub_Brand__c SubBrand = new ASI_KOR_Sub_Brand__c(ASI_KOR_Sub_Brand_Code__c='Test',ASI_KOR_Brand_Code__c='Test');
        insert SubBrand;
        
        List<ASI_KOR_Item_Group__c> ItemGroupList = new List<ASI_KOR_Item_Group__c> ();
        
        ASI_KOR_Item_Group__c ItemGroup = new ASI_KOR_Item_Group__c(ASI_KOR_Sub_Brand__c=SubBrand.id,ASI_KOR_Description__c='Test',ASI_CRM_KR_StockInTradeSIT__c =true);
        ItemGroupList.add(ItemGroup);
         ASI_KOR_Item_Group__c ItemGroup2 = new ASI_KOR_Item_Group__c(ASI_KOR_Sub_Brand__c=SubBrand.id,ASI_KOR_Description__c='Test 2',ASI_CRM_KR_StockInTradeSIT__c =true);
        ItemGroupList.add(ItemGroup2);
        insert ItemGroupList;
            
        //Stock In Trade Header
        
        List<ASI_KOR_Stock_In_Trade__c> SITheaders = new List<ASI_KOR_Stock_In_Trade__c> ();// ,ASI_KOR_Sys_Stock_in_trade_header_ID__c=acc.id
        ASI_KOR_Stock_In_Trade__c sit = new ASI_KOR_Stock_In_Trade__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_Stock_In_Trade__cASI_KOR_SIT_Editable'),ASI_KOR_Month__c=String.valueOf(Date.today().month()).leftPad(2).replace(' ', '0'),ASI_KOR_Year__c=string.valueof(Date.today().year()),ASI_KOR_Wholesaler__c =acc.id ,ASI_KOR_Status__c='Editable');
        SITheaders.add(sit);
        
        insert SITheaders;
      
        
        //Stock In Trade Detail  year +'_'+ month + '_' + customerMap.get(sitHeader.ASI_KOR_Wholesaler__c).ASI_KOR_Customer_Code__c
        List<ASI_KOR_WS_Stock_In_Trade_Detail__c> StockInTradeDetailList = new List<ASI_KOR_WS_Stock_In_Trade_Detail__c>();
        string HeaderIDUpload= 'Test';//string.valueOf(todaydate.year()) +'_'+ string.valueOf(todaydate.month()) + '_123'; // '2016_5_123';// ,ASI_CRM_KR_HeaderID_Upload__c=Id.valueOf(HeaderIDUpload)
        ASI_KOR_WS_Stock_In_Trade_Detail__c wssitd= new ASI_KOR_WS_Stock_In_Trade_Detail__c(ASI_KOR_Item_Group_Code__c=ItemGroup.id,Stock_In_Trade__c=sit.id);
        StockInTradeDetailList.add(wssitd);
        insert StockInTradeDetailList;
        
        Test.startTest();
            //sit.ASI_KOR_Sys_Stock_in_trade_header_ID__c=acc1.id;
            ASI_CRM_KR_ListViewInput con = new ASI_CRM_KR_ListViewInput();
        
            List<String> NullList = new List<String>();
            String Msg= ASI_CRM_KR_ListViewInput.saveSITRecords(NullList,AccIDList,SITheaders,StockInTradeDetailList,string.valueOf(todaydate.year()) ,String.valueOf(Date.today().month()).leftPad(2).replace(' ', '0'));//string.valueOf(todaydate.year()) ,string.valueOf(todaydate.month())
        	
        	con.AcctNamefilter.ASI_CRM_Account__c=acc.id;
        	con.ItemCodefilter.ASI_KOR_Item_Group_Code__c=ItemGroup.id;
        	PageReference rf1= con.runQuery();
         
        	con.AcctNamefilter.ASI_CRM_Account__c=acc2.id;
        	PageReference rf2= con.runQuery();
        
        	con.CustomerMapping.clear();
        	PageReference rf3= con.runQuery();
            
            List<ASI_KOR_WS_Stock_In_Trade_Detail__c> SITDList = new List<ASI_KOR_WS_Stock_In_Trade_Detail__c>();
            HeaderIDUpload= string.valueOf(todaydate.year()) +'_'+ string.valueOf(todaydate.month()) + '_123'; //'Test';//string.valueOf(todaydate.year()) +'_'+ string.valueOf(todaydate.month()) + '_123'; // '2016_5_123';// ,ASI_CRM_KR_HeaderID_Upload__c=Id.valueOf(HeaderIDUpload)
            ASI_KOR_WS_Stock_In_Trade_Detail__c wssitd2= new ASI_KOR_WS_Stock_In_Trade_Detail__c(ASI_KOR_WS_SIT_End_Stock__c=10,ASI_KOR_Item_Group_Code__c=ItemGroup2.id,Stock_In_Trade__c=sit.id,ASI_CRM_KR_HeaderID_Upload__c=string.valueOf(acc.id));
            SITDList.add(wssitd2);
        	//ASI_KOR_WS_Stock_In_Trade_Detail__c wssitd3= new ASI_KOR_WS_Stock_In_Trade_Detail__c(ASI_KOR_WS_SIT_End_Stock__c=0,ASI_KOR_Item_Group_Code__c=ItemGroup.id,Stock_In_Trade__c=sit.id,ASI_CRM_KR_HeaderID_Upload__c=string.valueOf(acc1.id));
            //SITDList.add(wssitd3);
        	insert SITDList;	
        	// StockInTradeDetailList
        	Msg= ASI_CRM_KR_ListViewInput.saveSITRecords(NullList,AccIDList,SITheaders,SITDList,string.valueOf(todaydate.year()) ,String.valueOf(Date.today().month()).leftPad(2).replace(' ', '0'));//string.valueOf(todaydate.year()) ,string.valueOf(todaydate.month())
        	
        
        Test.stopTest();
    }
    
    
   
    static testMethod void ASI_CRM_KR_COGS_TriggerClassTest(){
        Account acc = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_KOR_Venue'),name = 'Venue');
        insert acc;
        ASI_KOR_Sub_Brand__c sb = new ASI_KOR_Sub_Brand__c(ASI_KOR_Sub_Brand_Code__c='Test',ASI_KOR_Active_for_A_P__c=true);
        insert sb;
        ASI_CRM_KR_COGS__c COGS = new ASI_CRM_KR_COGS__c(ASI_CRM_KR_Account__c=acc.id,ASI_CRM_KR_SubBrand__c=sb.id,ASI_CRM_KR_Volume__c=12);
        insert COGS;
        
    }
    
    static testMethod void ASI_CRM_KR_ListedMenuPrice_TriggerClassTest(){
        //Test class: ASI_CRM_KR_ListedMenuPrice_TriggerClass
        Account acc = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_KOR_Venue'),name = 'Venue');
        insert acc;
        
        ASI_CRM_KR_Listed_Menu_Price__c lmp=new ASI_CRM_KR_Listed_Menu_Price__c(ASI_CRM_KR_Venue__c=acc.id);
        insert lmp;
    }
    
}