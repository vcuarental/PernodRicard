/*Developed by StellaLi
Test Class for ASI_CRM_CN_Upsert_Customer
*/
@isTest(SeeAllData=true)
private class ASI_CRM_CN_UpsertCustomer_WebserviceTest{
    private Class Customer{
        private list <CustomerStructure> Customerlist{set;get;}    
    }
    
    @isTest static void ASI_CRM_CN_Upsert_Customer() {
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();      
        
        /*insert account*/
        Id rt1 = Global_RecordTypeCache.getRtId('AccountASI_CRM_CN_Wholesales_CN');
        Account a = new Account(Name='TEST', RecordTypeId=rt1);
        insert a;
        
        /*insert customer*/   
        ASI_CRM_Region__c region = new ASI_CRM_Region__c (Name='TEST',RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Region__cASI_CRM_CN_Region'));
        insert region;
        
        ASI_CRM_Division__c division = new ASI_CRM_Division__c(Name='TEST', ASI_CRM_Region__c=region.Id,RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Division__cASI_CRM_CN_Region'));
        insert division;
        
        
        ASI_CRM_CN_Area__c area = new ASI_CRM_CN_Area__c(Name='TEST', ASI_CRM_English_Name__c='TEST', ASI_CRM_Division__c=division.Id,RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_CN_Area__cASI_CRM_CN_Area'));
        insert area;
        
        ASI_CRM_City__c city = new ASI_CRM_City__c(Name='TEST',ASI_CRM_CN_City_Code__c='TESTCITY', ASI_CRM_CN_Area__c=area.Id,RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_City__cASI_CRM_CN_City'));
        insert city;
        
        ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(ASI_CRM_CN_On_Off__c='OFF',RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_Channel'));
        insert channel;
        
        ASI_MFM_Sub_Channel__c subChannel = new ASI_MFM_Sub_Channel__c(ASI_CRM_CN_Channel__c=channel.Id,RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_Channel__cASI_MFM_CN_Sub_Channel'));
        insert subChannel;        
        
        ASI_CRM_CN_Channel__c newChannel = new ASI_CRM_CN_Channel__c(ASI_CRM_For_Outlet__c = true, Name='Bar',RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'));
        insert newChannel;
        
        Id rtWS = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS');
        Id rtOutlet = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN');
        ASI_CRM_AccountsAdditionalField__c testWSCustomer=  new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium', Name='TEST',RecordTypeId= rtWS,ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_Sub_Channel__c=subChannel.Id, ASI_CRM_CN_NewChannel__c = newChannel.Id, ASI_CRM_CN_Energy__c = 'High Energy');
        insert testWSCustomer;
        ASI_CRM_AccountsAdditionalField__c testOutletCustomer=  new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium', Name='TEST',RecordTypeId= rtOutlet ,ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_Sub_Channel__c=subChannel.Id, ASI_CRM_CN_NewChannel__c = newChannel.Id, ASI_CRM_CN_Energy__c = 'High Energy');
        insert testOutletCustomer;
        
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, mock);
        
        Test.startTest(); 
        /*updatetest-WS*/
        // string record1 = '{"Customerlist":[{"RecordID":"'+ testWSCustomer.id +'","Sub_Channel":"'+subChannel.id+'","RecordType":"'+ rtWS +'","Local_Update_Time":"2014/11/30 14:20","Business_License_Expire_Date":"2018/11/28","Warehouse_Email":"a@b.com","Effective_From":"2014/11/30","Effective_To":"2014/12/11","Inactive_Flag":true,"Dummy_Outlet_Flag":true,"IHBR_Outlet":true,"Require_Visit":true,"Cap_Collection":true,"Same_as_above_CAP":true,"PRC_Direct_Sales_Flag":true,"Group_Price_PR_Direct":true,"Same_as_above_PR_Direct":true,"VAT_Invoice_Application":true,"Business_License_uploading_Y":true,"Same_as_above_Brand_T1":true,"Scan_Device_Application":true,"Chi_Name":"Test22","Eng_Name":"Name22","Legal_Name":"TN22","City":"'+city.id+'","KA_Account":"METRO","Phone_Number":"47124712","Fax_Number":"12341234","Contact_Person":"Li","Position":"Consultant","Tel":"48324832","Address":"California","Image":"Iconic","CR12_Btl_per_month":"73","Energy":"High","Address_CAP":"Cali","Tel_Cap":"1234564","Frequency_CAP":"45","Bank":"HS","Bank_Account":"HS123","Tax_Registration_Number":"123452","Phone_Number_PR_Direct":"6666666","Estimated_Annual_Order_Amount_in_CNY":"4567","Proposed_Credit_Term_Days":"21","Group_Name_PR_Direct":"AVC","Address_PR_Direct":"Cali2","ON_CO_P":"5","Chinese_Rest_P":"5","TOT_P":"5","Bulkpurchase_P":"5","LY_Operating_Income_RMB":"12345","ON_NCO_P":"5","Hotel_P":"5","MOT_P":"5","T3_P":"5","Credit_Terms_days":"31","IS_P":"10","Beer_P":"10","Other_Spirits_P":"10","Wine_P":"10","Baijiu_P":"10","Others_P":"10","Brand_T1_Group":"Local Wine","Discount_Brand_T1_P":"0.8","Phone_Number_Brand_T1":"12222220","Address_Brand_T1":"cali2","Warehouse_Tel":"2345677","Warehouse_Address1":"cali4","Warehouse_Address2":"cali5"}]}';
        string record1 = '{"Customerlist":[{"RecordID":"'+ testWSCustomer.id +'","commercialTeam":"Premium","RecordType":"'+ rtWS +'","Sub_Channel":"'+subChannel.id+'","Local_Update_Time":"2014/11/30 14:20","Business_License_Expire_Date":"2018/11/28","Warehouse_Email":"a@b.com","Effective_From":"2014/11/30","Effective_To":"2014/12/11","Inactive_Flag":true,"Dummy_Outlet_Flag":null,"IHBR_Outlet":false,"Require_Visit":true,"Cap_Collection":true,"Same_as_above_CAP":true,"PRC_Direct_Sales_Flag":true,"Group_Price_PR_Direct":true,"Same_as_above_PR_Direct":true,"VAT_Invoice_Application":true,"Business_License_uploading_Y":true,"Same_as_above_Brand_T1":true,"Scan_Device_Application":true,"Parent_Outlet":"","Chi_Name":"t151","Eng_Name":"t544","Legal_Name":"t533","City":"'+city.id+'","KA_Account":"METRO","Phone_Number":"47124712","Fax_Number":"12341234","Position":"Consultant","Tel":"48324832","Address":"California","Image":"Iconic","CR12_Btl_per_month":"73","Energy":"High","Address_CAP":"Cali","Tel_Cap":"1234564","Frequency_CAP":"45","Bank":"HS","Bank_Account":"HS123","Tax_Registration_Number":"123452","Phone_Number_PR_Direct":"6666666","Estimated_Annual_Order_Amount_in_CNY":"4567","Proposed_Credit_Term_Days":"21","Group_Name_PR_Direct":"AVC","Address_PR_Direct":"Cali2","ON_CO_P":"5","Chinese_Rest_P":"5","TOT_P":"5","Bulkpurchase_P":"5","LY_Operating_Income_RMB":"12345","ON_NCO_P":"5","Hotel_P":"5","MOT_P":"5","T3_P":"5","Credit_Terms_days":"31","IS_P":"10","Beer_P":"10","Other_Spirits_P":"10","Wine_P":"10","Baijiu_P":"10","Others_P":"10","Brand_T1_Group":"Local Wine","Discount_Brand_T1_P":"0.8","Phone_Number_Brand_T1":"12222220","Address_Brand_T1":"cali2","Warehouse_Tel":"2345677","T1_WS":"","PG_Head":"","Warehouse_Address1":"cali4","Warehouse_Address2":"cali5","Contact_Person":"","Contact_Person_CAP":""}]}';
        ASI_CRM_CN_Upsert_Customer.UpsertCustomer(record1);
        /*updatetest-Outlet*/
        string record4= '{"Customerlist":[{"RecordID":"'+ testOutletCustomer.id +'","commercialTeam":"Premium","RecordType":"'+ rtOutlet +'","Sub_Channel":"'+subChannel.id+'","Local_Update_Time":"2014/11/30 14:20","Business_License_Expire_Date":"2018/11/28","Warehouse_Email":"a@b.com","Effective_From":"2014/11/30","Effective_To":"2014/12/11","Inactive_Flag":true,"Dummy_Outlet_Flag":null,"IHBR_Outlet":false,"Require_Visit":true,"Cap_Collection":true,"Same_as_above_CAP":true,"PRC_Direct_Sales_Flag":true,"Group_Price_PR_Direct":true,"Same_as_above_PR_Direct":true,"VAT_Invoice_Application":true,"Business_License_uploading_Y":true,"Same_as_above_Brand_T1":true,"Scan_Device_Application":true,"Parent_Outlet":"","Chi_Name":"t112","Eng_Name":"t424","Legal_Name":"t233","City":"'+city.id+'","KA_Account":"METRO","Phone_Number":"47124712","Fax_Number":"12341234","Position":"Consultant","Tel":"48324832","Address":"California","Image":"Iconic","CR12_Btl_per_month":"73","Energy":"High","Address_CAP":"Cali","Tel_Cap":"1234564","Frequency_CAP":"45","Bank":"HS","Bank_Account":"HS123","Tax_Registration_Number":"123452","Phone_Number_PR_Direct":"6666666","Estimated_Annual_Order_Amount_in_CNY":"4567","Proposed_Credit_Term_Days":"21","Group_Name_PR_Direct":"AVC","Address_PR_Direct":"Cali2","ON_CO_P":"5","Chinese_Rest_P":"5","TOT_P":"5","Bulkpurchase_P":"5","LY_Operating_Income_RMB":"12345","ON_NCO_P":"5","Hotel_P":"5","MOT_P":"5","T3_P":"5","Credit_Terms_days":"31","IS_P":"10","Beer_P":"10","Other_Spirits_P":"10","Wine_P":"10","Baijiu_P":"10","Others_P":"10","Brand_T1_Group":"Local Wine","Discount_Brand_T1_P":"0.8","Phone_Number_Brand_T1":"12222220","Address_Brand_T1":"cali2","Warehouse_Tel":"2345677","T1_WS":"","PG_Head":"","Warehouse_Address1":"cali4","Warehouse_Address2":"cali5","Contact_Person":"","Contact_Person_CAP":""}]}';
        //string record4 = '{"Customerlist":[{"RecordID":"'+ testOutletCustomer.id +'","Sub_Channel":"'+subChannel.id+'","RecordType":"'+ rtOutlet +'","Local_Update_Time":"2014/11/30 14:20","Business_License_Expire_Date":"2018/11/28","Warehouse_Email":"a@b.com","Effective_From":"2014/11/30","Effective_To":"2014/12/11","Inactive_Flag":true,"Dummy_Outlet_Flag":true,"IHBR_Outlet":true,"Require_Visit":true,"Cap_Collection":true,"Same_as_above_CAP":true,"PRC_Direct_Sales_Flag":true,"Group_Price_PR_Direct":true,"Same_as_above_PR_Direct":true,"VAT_Invoice_Application":true,"Business_License_uploading_Y":true,"Same_as_above_Brand_T1":true,"Scan_Device_Application":true,"Chi_Name":"Test222","Eng_Name":"Name222","Legal_Name":"TN222","City":"'+city.id+'","KA_Account":"METRO","Phone_Number":"47124712","Fax_Number":"12341234","Contact_Person":"Li","Position":"Consultant","Tel":"48324832","Address":"California","Image":"Iconic","CR12_Btl_per_month":"73","Energy":"High","Address_CAP":"Cali","Tel_Cap":"1234564","Frequency_CAP":"45","Bank":"HS","Bank_Account":"HS123","Tax_Registration_Number":"123452","Phone_Number_PR_Direct":"6666666","Estimated_Annual_Order_Amount_in_CNY":"4567","Proposed_Credit_Term_Days":"21","Group_Name_PR_Direct":"AVC","Address_PR_Direct":"Cali2","ON_CO_P":"5","Chinese_Rest_P":"5","TOT_P":"5","Bulkpurchase_P":"5","LY_Operating_Income_RMB":"12345","ON_NCO_P":"5","Hotel_P":"5","MOT_P":"5","T3_P":"5","Credit_Terms_days":"31","IS_P":"10","Beer_P":"10","Other_Spirits_P":"10","Wine_P":"10","Baijiu_P":"10","Others_P":"10","Brand_T1_Group":"Local Wine","Discount_Brand_T1_P":"0.8","Phone_Number_Brand_T1":"12222220","Address_Brand_T1":"cali2","Warehouse_Tel":"2345677","Warehouse_Address1":"cali4","Warehouse_Address2":"cali5"}]}';
        ASI_CRM_CN_Upsert_Customer.UpsertCustomer(record4);
        
        /*Inserttest-WS*/
        string record2 = '{"Customerlist":[{"RecordID":"","commercialTeam":"Premium","RecordType":"'+ rtWS +'","Sub_Channel":"'+subChannel.id+'","Local_Update_Time":"2014/11/30 14:20","Business_License_Expire_Date":"2018/11/28","Warehouse_Email":"a@b.com","Effective_From":"2014/11/30","Effective_To":"2014/12/11","Inactive_Flag":true,"Dummy_Outlet_Flag":null,"IHBR_Outlet":false,"Require_Visit":true,"Cap_Collection":true,"Same_as_above_CAP":true,"PRC_Direct_Sales_Flag":true,"Group_Price_PR_Direct":true,"Same_as_above_PR_Direct":true,"VAT_Invoice_Application":true,"Business_License_uploading_Y":true,"Same_as_above_Brand_T1":true,"Scan_Device_Application":true,"Parent_Outlet":"","Chi_Name":"t111","Eng_Name":"t414","Legal_Name":"t133","City":"'+city.id+'","KA_Account":"METRO","Phone_Number":"47124712","Fax_Number":"12341234","Position":"Consultant","Tel":"48324832","Address":"California","Image":"Iconic","CR12_Btl_per_month":"73","Energy":"High","Address_CAP":"Cali","Tel_Cap":"1234564","Frequency_CAP":"45","Bank":"HS","Bank_Account":"HS123","Tax_Registration_Number":"123452","Phone_Number_PR_Direct":"6666666","Estimated_Annual_Order_Amount_in_CNY":"4567","Proposed_Credit_Term_Days":"21","Group_Name_PR_Direct":"AVC","Address_PR_Direct":"Cali2","ON_CO_P":"5","Chinese_Rest_P":"5","TOT_P":"5","Bulkpurchase_P":"5","LY_Operating_Income_RMB":"12345","ON_NCO_P":"5","Hotel_P":"5","MOT_P":"5","T3_P":"5","Credit_Terms_days":"31","IS_P":"10","Beer_P":"10","Other_Spirits_P":"10","Wine_P":"10","Baijiu_P":"10","Others_P":"10","Brand_T1_Group":"Local Wine","Discount_Brand_T1_P":"0.8","Phone_Number_Brand_T1":"12222220","Address_Brand_T1":"cali2","Warehouse_Tel":"2345677","T1_WS":"","PG_Head":"","Warehouse_Address1":"cali4","Warehouse_Address2":"cali5","Contact_Person":"","Contact_Person_CAP":""}]}';
        ASI_CRM_CN_Upsert_Customer.UpsertCustomer(record2);
        /*Inserttest-Outlet*/
        string record3 = '{"Customerlist":[{"RecordID":"","commercialTeam":"Premium","RecordType":"'+ rtOutlet +'","Sub_Channel":"'+subChannel.id+'","Local_Update_Time":"2014/11/30 14:20","Business_License_Expire_Date":"2018/11/28","Warehouse_Email":"a@b.com","Effective_From":"2014/11/30","Effective_To":"2014/12/11","Inactive_Flag":true,"Dummy_Outlet_Flag":null,"IHBR_Outlet":false,"Require_Visit":true,"Cap_Collection":true,"Same_as_above_CAP":true,"PRC_Direct_Sales_Flag":true,"Group_Price_PR_Direct":true,"Same_as_above_PR_Direct":true,"VAT_Invoice_Application":true,"Business_License_uploading_Y":true,"Same_as_above_Brand_T1":true,"Scan_Device_Application":true,"Parent_Outlet":"","Chi_Name":"t116","Eng_Name":"t464","Legal_Name":"t363","City":"'+city.id+'","KA_Account":"METRO","Phone_Number":"47124712","Fax_Number":"12341234","Position":"Consultant","Tel":"48324832","Address":"California","Image":"Iconic","CR12_Btl_per_month":"73","Energy":"High","Address_CAP":"Cali","Tel_Cap":"1234564","Frequency_CAP":"45","Bank":"HS","Bank_Account":"HS123","Tax_Registration_Number":"123452","Phone_Number_PR_Direct":"6666666","Estimated_Annual_Order_Amount_in_CNY":"4567","Proposed_Credit_Term_Days":"21","Group_Name_PR_Direct":"AVC","Address_PR_Direct":"Cali2","ON_CO_P":"5","Chinese_Rest_P":"5","TOT_P":"5","Bulkpurchase_P":"5","LY_Operating_Income_RMB":"12345","ON_NCO_P":"5","Hotel_P":"5","MOT_P":"5","T3_P":"5","Credit_Terms_days":"31","IS_P":"10","Beer_P":"10","Other_Spirits_P":"10","Wine_P":"10","Baijiu_P":"10","Others_P":"10","Brand_T1_Group":"Local Wine","Discount_Brand_T1_P":"0.8","Phone_Number_Brand_T1":"12222220","Address_Brand_T1":"cali2","Warehouse_Tel":"2345677","T1_WS":"","PG_Head":"","Warehouse_Address1":"cali4","Warehouse_Address2":"cali5","Contact_Person":"","Contact_Person_CAP":""}]}';
        ASI_CRM_CN_Upsert_Customer.UpsertCustomer(record3);
        Test.stopTest();
        
        
        
        
        
        
    }
    private with sharing class CustomerStructure{
        private string RecordType{set;get;} 
        private string RecordID{set;get;} 
        private string Local_Update_Time{set;get;} 
        private string Chi_Name{set;get;} 
        private string Eng_Name{set;get;} 
        private string Legal_Name{set;get;} 
        private string City{set;get;} 
        private Boolean Inactive_Flag{set;get;} 
        private string Parent_Outlet{set;get;} 
        private Boolean Dummy_Outlet_Flag{set;get;} 
        private string KA_Account{set;get;} 
        private Boolean IHBR_Outlet{set;get;} 
        private Boolean Require_Visit{set;get;} 
        private string Phone_Number{set;get;} 
        private string Fax_Number{set;get;} 
        private string Email{set;get;} 
        private string Contact_Person{set;get;} 
        private string Position{set;get;} 
        private string Tel{set;get;} 
        private string Address{set;get;} 
        private string Sub_Channel{set;get;} 
        private string Image{set;get;} 
        private Decimal CR12_Btl_per_month{set;get;} 
        private string Energy{set;get;} 
        private string PG_Head{set;get;} 
        private Boolean Cap_Collection{set;get;} 
        private string Address_CAP{set;get;} 
        private string Contact_Person_CAP{set;get;} 
        private Boolean Same_as_above_CAP{set;get;} 
        private string Tel_Cap{set;get;}
        private Decimal Frequency_CAP{set;get;} 
        private Boolean PRC_Direct_Sales_Flag{set;get;}
        private string Bank{set;get;} 
        private string Bank_Account{set;get;}
        private string Tax_Registration_Number{set;get;}
        private string Business_License_Expire_Date{set;get;} 
        private Boolean Group_Price_PR_Direct{set;get;}
        private Boolean Same_as_above_PR_Direct{set;get;}
        private string Phone_Number_PR_Direct{set;get;} 
        private Boolean VAT_Invoice_Application{set;get;} 
        private Decimal Estimated_Annual_Order_Amount_in_CNY{set;get;}
        private Decimal Proposed_Credit_Term_Days{set;get;} 
        private Boolean Business_License_uploading_Y{set;get;} 
        private string Group_Name_PR_Direct{set;get;}
        private string Address_PR_Direct{set;get;} 
        private string T1_WS{set;get;} 
        private Decimal ON_CO_P{set;get;}
        private Decimal  Chinese_Rest_P{set;get;} 
        private Decimal TOT_P{set;get;}
        private Decimal Bulkpurchase_P{set;get;}
        private Decimal LY_Operating_Income_RMB{set;get;} 
        private Decimal ON_NCO_P{set;get;}
        private Decimal Hotel_P{set;get;}
        private Decimal MOT_P{set;get;} 
        private Decimal T3_P{set;get;}
        private Decimal Credit_Terms_days{set;get;} 
        private Decimal IS_P{set;get;} 
        private Decimal Beer_P{set;get;} 
        private Decimal Other_Spirits_P{set;get;} 
        private Decimal Wine_P{set;get;} 
        private Decimal Baijiu_P{set;get;} 
        private Decimal Others_P{set;get;} 
        private string Brand_T1_Group{set;get;} 
        private string Effective_From{set;get;} 
        private string Effective_To{set;get;} 
        // private Decimal Proposed_Credit_Term_Days1{set;get;} 
        private Decimal Discount_Brand_T1_P{set;get;}
        private Boolean Same_as_above_Brand_T1{set;get;} 
        private string Phone_Number_Brand_T1{set;get;}   
        private string Address_Brand_T1{set;get;} 
        private Boolean Scan_Device_Application{set;get;} 
        private string Warehouse_Contact_Person{set;get;} 
        private string Warehouse_Tel{set;get;} 
        private string Covered_City{set;get;}
        private string Warehouse_Address1{set;get;} 
        private string Warehouse_Address2{set;get;} 
        private string Warehouse_Email{set;get;}
        //Leo@Elufa
        private string website{set;get;}
        private string district{set;get;}
        private Decimal postCode{set;get;}
        private Double latitude{set;get;}
        private Double longitude{set;get;}
        private string newChannel{set;get;}
        private string prosChannel{set;get;}
        private string outletCapacity{set;get;}
        private Boolean vipCorner{set;get;}
        private String sizeSQM{set;get;}
        private Decimal rating{set;get;}
        private Decimal prcVolumn{set;get;}
        private String isVolumn{set;get;}
        private String occupancyRate{set;get;}
        private Boolean dedicatedService{set;get;}
        private Decimal popularity{set;get;}
        private Boolean careerBartender{set;get;}
        private Decimal cocktailPrice{set;get;}
        private string outlettype{set;get;}
        private Boolean backbar{set;get;}
        private Decimal beerPrice{set;get;}
        private Decimal numRoom{set;get;}
        private Boolean hostesses{set;get;}
        private Decimal tipsPrice{set;get;}
        private String rtdVolumn{set;get;}
        private Boolean supermarket{set;get;}
        private Decimal roomPrice{set;get;}
        private Decimal x12BtBeerPrice{set;get;}
        private string typeRestaurant{set;get;}
        private Decimal spendPerHead{set;get;}
        private String typeCuisine{set;get;}
        private string brand{set;get;}
        private Decimal guestRoomPrice{set;get;}
        private String outletChannelType{set;get;}
        private String numOfStars{set;get;}
        private String kaAccountChain {set;get;}
        private Decimal sofaTablePrice {set;get;}
        private Boolean vipPrivateRoom {set;get;}
        private String channelStrategy {set;get;}
        private String commercialTeam {set;get;}
        private String newImage {set;get;}
        //Leo@Elufa
        
        public void replaceNull() {
            
            if(Parent_Outlet==null) Parent_Outlet= '';   
            if(PG_Head==null) PG_Head= ''; 
            if(T1_WS==null) T1_WS= ''; 
            if(City==null) City= ''; 
            if(City==null) City= ''; 
            if(Sub_Channel==null) Sub_Channel= ''; 
            if(Dummy_Outlet_Flag==null) Dummy_Outlet_Flag=null;
            if(Inactive_Flag==null) Inactive_Flag=null;
            if(IHBR_Outlet==null) IHBR_Outlet=null;
            if(Require_Visit==null) Require_Visit=null;
            if(Cap_Collection==null) Cap_Collection=null;
            if(Same_as_above_CAP==null) Same_as_above_CAP=null;
            if(PRC_Direct_Sales_Flag==null) PRC_Direct_Sales_Flag=null;
            if(Group_Price_PR_Direct==null) Group_Price_PR_Direct=null;
            if(Same_as_above_PR_Direct==null) Same_as_above_PR_Direct=null;
            if(VAT_Invoice_Application==null) VAT_Invoice_Application=null;
            if(Business_License_uploading_Y==null) Business_License_uploading_Y=null;
            if(Same_as_above_Brand_T1==null) Same_as_above_Brand_T1=null;
            if(Scan_Device_Application==null) Scan_Device_Application=null;
        }    
    }
    
}