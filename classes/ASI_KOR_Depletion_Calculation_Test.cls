@isTest
public class ASI_KOR_Depletion_Calculation_Test
{    
    private static Account testAccount{get; set;}
    private static ASI_KOR_Brand__c testBrand{get; set;}
    private static ASI_KOR_Sub_Brand__c testSubBrand{get; set;}
    private static ASI_KOR_Item_Group__c testItemGroup{get; set;}
    private static ASI_KOR_Venue_Depletion_Detail__c testDetail{get; set;}
    
    

    private static void init(){
        testAccount = new Account();
        testAccount.Name = 'Test';
        insert testAccount;
        
        ASI_KOR_Venue_Depletion__c testDepletion = new ASI_KOR_Venue_Depletion__c();
        testDepletion.ASI_KOR_Venue__c = testAccount.ID;
        /* Patched by Vincent 20160202 BEGIN 
        testDepletion.ASI_KOR_Month__c = 'November';
        */
        testDepletion.ASI_KOR_Month__c = 'October';
        /* Patched by Vincent 20160202 END */
        testDepletion.ASI_KOR_Year__c = '2014';
        testDepletion.ASI_KOR_Status__c = 'Editable';
        
        insert testDepletion;
        
        testBrand = new ASI_KOR_Brand__c();
        testBrand.Name = 'Test-Brand';
        
        insert testBrand;
        
        testSubBrand = new ASI_KOR_Sub_Brand__c();
        testSubBrand.Name = 'Test Sub Brand';
        testSubBrand.ASI_KOR_Brand__c = testBrand.ID;
        testSubBrand.ASI_KOR_Sub_Brand_Code__c = 'SubCode12';
        
        insert testSubBrand;
        testItemGroup = new ASI_KOR_Item_Group__c();
        testItemGroup.ASI_KOR_Sub_Brand__c = testSubBrand.ID;
        
        insert testItemGroup;
        testDetail = new ASI_KOR_Venue_Depletion_Detail__c();
        testDetail.ASI_KOR_Item_Group_Code__c = testItemGroup.ID;
        testDetail.ASI_KOR_Venue_Depl_Info_Depletion_Volume__c = 12541;
        testDetail.ASI_KOR_Venue_Depl_Info_Depletion_Case__c = 123;
        /* Patched by Vincent 20160202 BEGIN */
        testDetail.ASI_KOR_Venue_Depl_Info_Promotion_Amount__c = 5678;
        /* Patched by Vincent 20160202 END */
        testDetail.ASI_KOR_Venue_Depletion__c = testDepletion.id;
        
        
        insert testDetail;
      
        
        ASI_KOR_NSD_Payment_Settlement_Header__c testHeader = new ASI_KOR_NSD_Payment_Settlement_Header__c();
        testHeader.ASI_KOR_Month__c = '11';
        testHeader.ASI_KOR_Year__c = '2014';
        testHeader.ASI_KOR_SYS_Cut_off_Date__c =  Date.today();
        
        insert testHeader;
    
    
    }
    
    
    @isTest
    public static void testActualVol()
    {  
        init();
        test.startTest();
        ASI_KOR_Payment_Settlement_Detail_ActVol.getVolumeByCase(testBrand.ID, testAccount.ID , '2014' , '11');
        ASI_KOR_Payment_Settlement_Detail_ActVol.getVolumeByBottle(testBrand.ID, testAccount.ID , '2014' , '11');
        test.stopTest();
    }  
    
    @isTest
    public static void testL3M()
    {  
        init();
        test.startTest();
        /* Patched by Vincent 20160202 BEGIN 
        Date myDate= Date.newInstance(14, 11, 1);
        */
        Date myDate= Date.newInstance(2014, 11, 1);
        /* Patched by Vincent 20160202 END */
        ASI_KOR_Last_3_Month_Average_Calculation.averageBottles(testBrand.ID, testAccount.ID,myDate );
        ASI_KOR_Last_3_Month_Average_Calculation.averageCases(testBrand.ID, testAccount.ID,myDate );
        ASI_KOR_Last_3_Month_Average_Calculation.averageUnitCostByBottles(testBrand.ID, testAccount.ID,myDate );
        ASI_KOR_Last_3_Month_Average_Calculation.averageUnitCostByCases(testBrand.ID, testAccount.ID,myDate );
        test.stopTest();
    }  

}