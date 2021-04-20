/*
Test:
1. ASI_CRM_KR_ListViewInput	   <ListViewInput_Test_1>
*/
/*********************************************************************************
* Name:        ASI_CRM_KR_SIT_TestClass
* Description: test class for ASI_CRM_KR_ItemUploadCtrl, ASI_CRM_KR_ItemUploadBatch
*
* Version History
*  Date             Developer               Comments
*  ---------------  --------------------    --------------------------------------------------------------------------------
*  ???				???						Created
*  2018-07-27       Vincent Lam             [VL 1.0] The existing test class has no coverage on ASI_CRM_KR_ItemUploadCtrl
*********************************************************************************/

@istest
public class ASI_CRM_KR_SIT_TestClass {
    static testMethod void ListViewInput_Test_1() {
        
        
        //Update User Information 
        user TestingUser = [select ASI_MFM_Country__c,CompanyName from user where id = :userInfo.getUserId() limit 1]; 
        TestingUser.ASI_MFM_Country__c = 'KR';
        TestingUser.CompanyName = 'Pernod Ricard Korea';
        update TestingUser;
        
        System.runAs(TestingUser){
            
            //Insert Account: Venue recordtype
            Account WS = new Account(recordTypeId=Global_RecordTypeCache.getRtId('AccountASI_KOR_Wholesaler'),
                                     Name='WS Testing Account',
                                     ASI_KOR_Wholesaler_Channel__c = 'TOT',
                                     ASI_KOR_Customer_Code__c = '012344567890'
                                    );       
            insert WS;
        }
    }
    
    /* [VL 1.0] BEGIN */
    @testSetup static void setupData(){
        string rtId_wholesaler = Global_RecordTypeCache.getRtId('AccountASI_KOR_Wholesaler');
        
        // insert wholesaler
        list<account> list_a = new list<account>();
        Account WST1 = new Account(recordTypeId=rtId_wholesaler,
                                   Name='WS Testing Account1',
                                   ASI_KOR_Wholesaler_Channel__c = 'TOT',
                                   ASI_KOR_Customer_Code__c = '01234567890',
                                   ASI_KOR_Grade__c = 'T1',
                                   ASI_LUX_Le_Cercle_Member__c = true,
                                   ASI_KOR_Venue_Status__c  = 'Active'
                                  );     
        list_a.add(WST1);
        Account WST3 = new Account(recordTypeId=rtId_wholesaler,
                                   Name='WS gTestin Account2',
                                   ASI_KOR_Wholesaler_Channel__c = 'TOT',
                                   ASI_KOR_Customer_Code__c = '1110390',
                                   ASI_KOR_Grade__c = 'T3',
                                   ASI_LUX_Le_Cercle_Member__c = true,
                                   ASI_KOR_Venue_Status__c  = 'Active'
                                  );
        list_a.add(WST3);
        insert list_a;
        
        // create item group
        ASI_KOR_Brand__c brand = new ASI_KOR_Brand__c(
            Name = 'Test Brand', 
            ASI_KOR_Brand_Code__c = 'BC0001'
            
        );
        
        insert brand;
        
        ASI_KOR_Sub_Brand__c subBrand = new ASI_KOR_Sub_Brand__c (
            Name =  'Test Sub-Brand', 
            ASI_KOR_Brand_Code__c = 'SBC', 
            ASI_KOR_Sub_Brand_Code__c = 'SBC', 
            ASI_KOR_Brand__c = brand.Id
        );
        
        insert subBrand;
        
        ASI_KOR_Item_Group__c itemGroup1 = new ASI_KOR_Item_Group__c(
            Name = 'IMNE45',
            ASI_KOR_Item_Group_Code__c = 'IMNE45',
            ASI_KOR_Item_Group_Name__c = 'BIS Imperial Neon 45cl',
            ASI_KOR_VMS_Item_Group_Code__c = 'IMNE_450',
            ASI_KOR_Standard_Bottle_Size__c = 450,
            ASI_KOR_Sub_Brand__c = subBrand.Id,
            ASI_CRM_KR_StockInTradeSIT__c = true,
            ASI_KOR_Active__c = true
            
        );
        insert itemGroup1;
        
        ASI_KOR_Item_Group__c itemGroup2 = new ASI_KOR_Item_Group__c(
            Name = 'IMNE45a',
            ASI_KOR_Item_Group_Code__c = 'IMNE45a',
            ASI_KOR_Item_Group_Name__c = 'BIS Imperial Neon 45cl',
            ASI_KOR_VMS_Item_Group_Code__c = 'IMNE_450',
            ASI_KOR_Standard_Bottle_Size__c = 450,
            ASI_KOR_Sub_Brand__c = subBrand.Id,
            ASI_CRM_KR_StockInTradeSIT__c = true,
            ASI_KOR_Active__c = true
            
        );
        insert itemGroup2;
        
        // insert last month T3 SIT
        ASI_KOR_Stock_In_Trade__c sit = new ASI_KOR_Stock_In_Trade__c(
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_KOR_Stock_In_Trade__cASI_KOR_SIT_Editable'),
            ASI_KOR_Wholesaler__c = WST3.id,
            ASI_KOR_Status__c = 'Editable',
            ASI_KOR_Year__c = String.valueOf(system.today().addmonths(-1).year()),
            ASI_KOR_Month__c = Datetime.newInstance(system.today().addmonths(-1), Time.newInstance(0,0,0,0)).format('MMMM')
        );
        insert sit;
        
        // insert last month T3 SIT line
        ASI_KOR_WS_Stock_In_Trade_Detail__c sitLine = new ASI_KOR_WS_Stock_In_Trade_Detail__c (
            Stock_In_Trade__c = sit.id,
            ASI_KOR_WS_SIT_End_Stock__c = 10,
            ASI_KOR_Item_Group_Code__c = itemGroup1.id
        );
        insert sitLine;
        
        sit.ASI_KOR_Status__c = 'Locked';
        sit.recordtypeid = Global_RecordTypeCache.getRtId('ASI_KOR_Stock_In_Trade__cASI_KOR_SIT_Locked');
        update sit;
        
        // insert this month T1 SIT
        ASI_KOR_Stock_In_Trade__c sit1 = new ASI_KOR_Stock_In_Trade__c(
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_KOR_Stock_In_Trade__cASI_KOR_SIT_Editable'),
            ASI_KOR_Wholesaler__c = WST1.id,
            ASI_KOR_Status__c = 'Editable',
            ASI_KOR_Year__c = String.valueOf(system.today().year()),
            ASI_KOR_Month__c = Datetime.newInstance(system.today(), Time.newInstance(0,0,0,0)).format('MMMM')
        );
        insert sit1;
        
        // insert this month T1 SIT line
        ASI_KOR_WS_Stock_In_Trade_Detail__c sitLine1 = new ASI_KOR_WS_Stock_In_Trade_Detail__c (
            Stock_In_Trade__c = sit1.id,
            ASI_KOR_WS_SIT_End_Stock__c = 10,
            ASI_KOR_Item_Group_Code__c = itemGroup1.id
        );
        insert sitLine1;
        
        // insert this month temp SIT
        ASI_CRM_KR_Temp_SIT__c sitTemp1 = new ASI_CRM_KR_Temp_SIT__c (
            ASI_CRM_KR_Year__c = String.valueOf(system.today().year()),
            ASI_CRM_KR_Month__c = Datetime.newInstance(system.today(), Time.newInstance(0,0,0,0)).format('MMM'),
            ASI_CRM_KR_WS_CRM_No__c = WST1.id,
            ASI_CRM_KR_End_Stock_Case__c = 10,
            ASI_CRM_KR_Item_Group_Code__c = itemGroup1.id,
            RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_KR_Temp_SIT__cASI_CRM_KR_SIT'),
            ASI_CRM_KR_Status__c = 'Editable'
        );
        insert sitTemp1;
        
        ASI_CRM_KR_Temp_SIT__c sitTemp2 = new ASI_CRM_KR_Temp_SIT__c (
            ASI_CRM_KR_Year__c = String.valueOf(system.today().year()),
            ASI_CRM_KR_Month__c = Datetime.newInstance(system.today(), Time.newInstance(0,0,0,0)).format('MMM'),
            ASI_CRM_KR_WS_CRM_No__c = WST1.id,
            ASI_CRM_KR_End_Stock_Case__c = 10,
            ASI_CRM_KR_Item_Group_Code__c = itemGroup2.id,
            RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_KR_Temp_SIT__cASI_CRM_KR_SIT'),
            ASI_CRM_KR_Status__c = 'Editable'
        );
        insert sitTemp2;
        
        
    }
    
    @isTest 
    public static void testSITCSVCtrl(){
        test.startTest();

        PageReference pageRef = new Pagereference('/apex/ASI_CRM_KR_ItemUploadPage2');
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('Year', '2030');
        ApexPages.currentPage().getParameters().put('Month', 'May');
        ASI_CRM_KR_SITCSVCtrl con = new ASI_CRM_KR_SITCSVCtrl();
        con.init();
        
        
        test.stopTest();
    }
    
    @isTest 
    public static void testItemUploadCtrl(){
        //
        test.startTest();
        ASI_CRM_KR_ItemUploadCtrl tmpClass = new ASI_CRM_KR_ItemUploadCtrl();
        tmpClass.getYears();
        tmpClass.getMonths();
        tmpClass.generateHeader();
        
        PageReference pageRef = new Pagereference('/apex/ASI_CRM_KR_ItemUploadPage2');
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('Year', '2030');
        ApexPages.currentPage().getParameters().put('Month', 'May');
        tmpClass.download_EXCEL();
        tmpClass.GoToPage1();
        tmpClass.getSelectedEXCELDownloadUrl();
        tmpClass.getPage2();
        String[] myArray = new List<String>();
        for(String stringtest : tmpClass.GenStatusMsgs){
            myArray.add(stringtest);
        }
        test.stopTest();
        
    }
    
    @isTest 
    public static void testItemUploadCtrlDelete(){
        
        test.startTest();
        ASI_CRM_KR_ItemUploadCtrl tmpClass = new ASI_CRM_KR_ItemUploadCtrl();
        tmpClass.deleteUploads();
        
        test.stopTest();
        
    }
    /* [VL 1.0] END */
}