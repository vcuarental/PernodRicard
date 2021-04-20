/*
Test:
1. ASI_CRM_KR_ListedMenuPriceMgtAllCtrl	   <ListedMenuPrice_Test_1>
*/

@istest

public class ASI_CRM_KR_ListedMenuPrice_TestClass {
    static testMethod void ListedMenuPrice_Test_1() {
        
        //Update User Information 
        user TestingUser = [select ASI_MFM_Country__c,CompanyName from user where id = :userInfo.getUserId() limit 1]; 
        TestingUser.ASI_MFM_Country__c = 'KR';
        TestingUser.CompanyName = 'Pernod Ricard Korea';
        update TestingUser;
        
        System.runAs(TestingUser){
            
            //Insert Account: Venue recordtype
            Account Venue = new Account(recordTypeId=Global_RecordTypeCache.getRtId('AccountASI_KOR_Venue'),
                                        Name='Venue Testing Account',
                                        ASI_KOR_Wholesaler_Channel__c = 'TOT'
                                       );       
            insert Venue;
            
            //Insert Header record
            List<ASI_CRM_KR_Listed_Menu_Price__c> HeaderList = new List<ASI_CRM_KR_Listed_Menu_Price__c>();
            ASI_CRM_KR_Listed_Menu_Price__c PriceHeaderQ3 = new ASI_CRM_KR_Listed_Menu_Price__c(ASI_CRM_KR_Venue__c = Venue.id,
                                                                                                ASI_CRM_KR_Quarter__c = 'Q3',
                                                                                                ASI_CRM_KR_Fiscal_Year__c = 'FY1516',
                                                                                                recordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_KR_Listed_Menu_Price__cASI_CRM_KR'));
            
            
            HeaderList.add(PriceHeaderQ3);
            
            ASI_CRM_KR_Listed_Menu_Price__c PriceHeader = new ASI_CRM_KR_Listed_Menu_Price__c(ASI_CRM_KR_Venue__c = Venue.id,
                                                                                              ASI_CRM_KR_Quarter__c = 'Q4',
                                                                                              ASI_CRM_KR_Fiscal_Year__c = 'FY1516',
                                                                                              recordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_KR_Listed_Menu_Price__cASI_CRM_KR'));
            
            HeaderList.add(PriceHeader);
            insert HeaderList;
            
            
            
            //Insert KOR Sub-brand
            ASI_KOR_Sub_Brand__c SubBrand = new ASI_KOR_Sub_Brand__c(ASI_KOR_Brand_Name__c = 'KOR Brand Name',
                                                                     ASI_KOR_Name_Kor__c = 'KOR Brand Name',
                                                                     ASI_KOR_Sub_Brand_Code__c = '88123');
            insert SubBrand;
            
            
            
            //Insert Item Group
            List<ASI_KOR_Item_Group__c> ItemList = new List<ASI_KOR_Item_Group__c>();
            
            
            ASI_KOR_Item_Group__c Item1 = new ASI_KOR_Item_Group__c(ASI_KOR_Item_Group_Code__c ='Code A',
                                                                    ASI_KOR_Name_Kor__c = 'Name 1',
                                                                    ASI_CRM_KR_Priority_Item__c = true,
                                                                    ASI_KOR_Sub_Brand__c = SubBrand.id
                                                                   );
            
            ItemList.add(Item1);
            
            ASI_KOR_Item_Group__c Item2 = new ASI_KOR_Item_Group__c(ASI_KOR_Item_Group_Code__c ='Code B',
                                                                    ASI_KOR_Name_Kor__c = 'Name 2',
                                                                    ASI_CRM_KR_Priority_Item__c = true,
                                                                    ASI_KOR_Sub_Brand__c = SubBrand.id
                                                                   );
            
            ItemList.add(Item2);
            
            insert ItemList;
            
            
            //Insert Lines record
            List<ASI_KOR_Venue_Listed_Menu_Product__c> MenuPriceList = new List<ASI_KOR_Venue_Listed_Menu_Product__c>();
            ASI_KOR_Venue_Listed_Menu_Product__c LstQuarter_PriceLine = new ASI_KOR_Venue_Listed_Menu_Product__c(ASI_KOR_Item_Group_Code__c = Item1.id,
                                                                                                                 ASI_KOR_Listed_Price__c = 100,
                                                                                                                 ASI_CRM_KR_Listed_Menu_Product_Header__c = PriceHeaderQ3.id,
                                                                                                                 ASI_KOR_ListedMenuProduct_to_Venue_Link__c = Venue.id
                                                                                                                );
            MenuPriceList.add(LstQuarter_PriceLine);   
            
            ASI_KOR_Venue_Listed_Menu_Product__c Existing_PriceLine = new ASI_KOR_Venue_Listed_Menu_Product__c(ASI_KOR_Item_Group_Code__c = Item1.id,
                                                                                                               ASI_KOR_Listed_Price__c = 100,
                                                                                                               ASI_CRM_KR_Listed_Menu_Product_Header__c = PriceHeader.id,
                                                                                                               ASI_KOR_ListedMenuProduct_to_Venue_Link__c = Venue.id
                                                                                                              );
            MenuPriceList.add(Existing_PriceLine);                                                                                 
            insert MenuPriceList; 
            
            
            
            
            Test.startTest();  
            //ApexPages.standardSetController sc = new ApexPages.standardSetController(Venue);
            PageReference PricePage = Page.ASI_CRM_KR_ListedMenuPriceMgtAllPage;
            Test.setCurrentPageReference(PricePage);
            Map<String, String> pageParams = PricePage.getParameters();
            pageParams.put('id', PriceHeader.Id);
            
            ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(PriceHeader);
            ASI_CRM_KR_ListedMenuPriceMgtAllCtrl Ctrl  = new ASI_CRM_KR_ListedMenuPriceMgtAllCtrl(stdController);
            
            Ctrl.init();
            
            //Call saveLinetems Method:
            pageParams.put('IS_QUICK_SAVE', 'true');
            Ctrl.saveLinetems();
            
            //Call addLineItem Method:
            pageParams.put('PARAM_POLINE_SOURCE_ITEM_ID', 'Code B');
            Ctrl.addLineItem();
            pageParams.put('PARAM_POLINE_SOURCE_ITEM_ID', 'Code B');
            
            //Call removeLine Method:
            pageParams.put('PARAM_PRICELINE_SOURCE_ITEM_ID', Existing_PriceLine.Id);
            Ctrl.removeLine();
            
            //Call CloneFromLastQuarter Method:\
            Ctrl.CloneFromLastQuarter();
            
            Ctrl.cancel();
            
            Test.stopTest();
        }
        
    }
    
    static testMethod void ListedMenuPrice_Test_2() {
        
        //Update User Information 
        user TestingUser = [select ASI_MFM_Country__c,CompanyName from user where id = :userInfo.getUserId() limit 1]; 
        TestingUser.ASI_MFM_Country__c = 'KR';
        TestingUser.CompanyName = 'Pernod Ricard Korea';
        update TestingUser;
        
        System.runAs(TestingUser){
            
            //Insert Account: Venue recordtype
            Account Venue = new Account(recordTypeId=Global_RecordTypeCache.getRtId('AccountASI_KOR_Venue'),
                                        Name='Venue Testing Account',
                                        ASI_KOR_Wholesaler_Channel__c = 'TOT'
                                       );       
            insert Venue;
            
            //Insert Header record
            ASI_CRM_KR_Listed_Menu_Price__c PriceHeader = new ASI_CRM_KR_Listed_Menu_Price__c(ASI_CRM_KR_Venue__c = Venue.id,
                                                                                              ASI_CRM_KR_Quarter__c = 'Q4',
                                                                                              ASI_CRM_KR_Fiscal_Year__c = 'FY1516',
                                                                                              recordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_KR_Listed_Menu_Price__cASI_CRM_KR'));
            
            insert PriceHeader;
            
            //Insert KOR Sub-brand
            ASI_KOR_Sub_Brand__c SubBrand = new ASI_KOR_Sub_Brand__c(ASI_KOR_Brand_Name__c = 'KOR Brand Name',
                                                                     ASI_KOR_Name_Kor__c = 'KOR Brand Name',
                                                                     ASI_KOR_Sub_Brand_Code__c = '88123');
            insert SubBrand;
            
            
            
            //Insert Item Group
            List<ASI_KOR_Item_Group__c> ItemList = new List<ASI_KOR_Item_Group__c>();
            ASI_KOR_Item_Group__c Item1 = new ASI_KOR_Item_Group__c(ASI_KOR_Item_Group_Code__c ='Code A',
                                                                    ASI_KOR_Name_Kor__c = 'Name 1',
                                                                    ASI_CRM_KR_Priority_Item__c = true,
                                                                    ASI_KOR_Sub_Brand__c = SubBrand.id
                                                                   );
            
            ItemList.add(Item1);
            
            ASI_KOR_Item_Group__c Item2 = new ASI_KOR_Item_Group__c(ASI_KOR_Item_Group_Code__c ='Code B',
                                                                    ASI_KOR_Name_Kor__c = 'Name 2',
                                                                    ASI_CRM_KR_Priority_Item__c = true,
                                                                    ASI_KOR_Sub_Brand__c = SubBrand.id
                                                                   );
            
            ItemList.add(Item2);
            
            insert ItemList;
            
            
            //Insert Lines record
            //List<ASI_CRM_KR_Listed_Menu_Price__c> MenuPriceList = new List<ASI_CRM_KR_Listed_Menu_Price__c>();
            ASI_KOR_Venue_Listed_Menu_Product__c Existing_PriceLine = new ASI_KOR_Venue_Listed_Menu_Product__c(ASI_KOR_Item_Group_Code__c = Item1.id,
                                                                                                               ASI_KOR_Listed_Price__c = 100,
                                                                                                               ASI_CRM_KR_Listed_Menu_Product_Header__c = PriceHeader.id,
                                                                                                               ASI_KOR_ListedMenuProduct_to_Venue_Link__c = Venue.id
                                                                                                              );
            //MenuPriceList.add(PriceRecord);                                                                                 
            insert Existing_PriceLine;
            
            
            
            
            Test.startTest();  
            //ApexPages.standardSetController sc = new ApexPages.standardSetController(Venue);
            PageReference PricePage = Page.ASI_CRM_KR_ListedMenuPriceMgtAllPage;
            Test.setCurrentPageReference(PricePage);
            Map<String, String> pageParams = PricePage.getParameters();
            pageParams.put('id', PriceHeader.Id);
            
            ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(PriceHeader);
            ASI_CRM_KR_ListedMenuPriceMgtAllCtrl Ctrl  = new ASI_CRM_KR_ListedMenuPriceMgtAllCtrl(stdController);
            
            Ctrl.init();
            
            //Call addLineItem Method:
            pageParams.put('PARAM_POLINE_SOURCE_ITEM_ID', 'Code B');
            Ctrl.addLineItem();
            pageParams.put('PARAM_POLINE_SOURCE_ITEM_ID', 'Code B');
            
            //Call removeLine Method:
            pageParams.put('PARAM_PRICELINE_SOURCE_ITEM_ID', Existing_PriceLine.Id);
            Ctrl.removeLine();
            
            //Call CloneFromLastQuarter Method:\
            Ctrl.CloneFromLastQuarter();
            
            //Call saveLinetems Method:
            pageParams.put('IS_QUICK_SAVE', 'true');
            Ctrl.saveLinetems();
            
            Ctrl.cancel();
            
            Test.stopTest();
        }
        
    }
}