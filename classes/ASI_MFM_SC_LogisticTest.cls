@istest
public class ASI_MFM_SC_LogisticTest {

    public static string getFiscalYear(){
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
    
    public static ASI_MFM_A_C_Code__c createACCode()
    {
        ASI_MFM_A_C_Code__c acCode = new ASI_MFM_A_C_Code__c(
            Name='test',
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_SC_A_C_Code')
        );
        insert acCode;
        return acCode;
    }


    public static ASI_MFM_AP_Code__c createAPCode()
    {
         ASI_MFM_AP_Code__c apCode = new ASI_MFM_AP_Code__c(
             Name='test',
             ASI_MFM_Inactive__c=false,
             recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_AP_Code__cASI_MFM_SC_AP_Code'),
             ASI_MFM_A_C_Code__c = createACCode().id
         );
         insert apCode;
         return apCode;
    }
        
    public static ASI_MFM_BU__c createBUCode()
    {
        ASI_MFM_BU__c buCode = new ASI_MFM_BU__c(
            Name='test',
            ASI_MFM_Inactive__c=false,
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_BU__cASI_MFM_SC_BU'),
            ASI_MFM_BU_Mapping__c = '326HK',
            ASI_MFM_Is_Logsitic_BU__c = true,
            ASI_MFM_BU_Code__c = '3264P99901'
            
        );
        insert buCode;
        return buCode;
    }
    
    //Supplier    
    public static Account createAccSupplier ()
    {
        Account acc = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_SC_Supplier'), Name='test');
        insert acc;
        return acc;
    }
    
    //Subledger    
    public static Account createAccSubledger  ()
    {
        Account acc = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_HK_Subleger'), Name='test');
        insert acc;
        return acc;
    }
    
    public static ASI_MFM_Prefix__c createPrefix (String module,String DeveloperName)
    {
        ASI_MFM_Prefix__c prefix = new ASI_MFM_Prefix__c
        (
            Name = module,
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_SC_Prefix'),
            ASI_MFM_Module__c = module,
            ASI_MFM_Fiscal_year__c = getFiscalYear(),
            ASI_MFM_Inactive__c=false
        );
        insert prefix;

        ASI_MFM_Role_Prefix_Relationship__c rel = new ASI_MFM_Role_Prefix_Relationship__c
        (
            ASI_MFM_Prefix__c = prefix.id,
            ASI_MFM_Role_Name__c = DeveloperName
        );
        insert rel;
        return prefix;
    }
    
    public static ASI_MFM_Plan__c createPlan(id prefixid ){
        ASI_MFM_Plan__c plan = new ASI_MFM_Plan__c( Name = 'test',
                                                        recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_SC_Plan'),
                                                        ASI_MFM_Start_Date__c =date.today(),
                                                        ASI_MFM_End_Date__c =date.today(),
                                                        ASI_MFM_Prefix__c = prefixid, 
                                                        ASI_MFM_Status__c='Final',   
                                                        ASI_MFM_Currency__c='HKD',
                                                        ASI_MFM_Plan_Type__c='OPEX');
        insert plan;        
        return plan;
    }
    
    public static ASI_MFM_Plan_Line_Item__c createPlanLine(id headerid, id apcodeid ){
        ASI_MFM_Plan_Line_Item__c planLine = new ASI_MFM_Plan_Line_Item__c (ASI_MFM_Plan__c = headerid,
                                                                                 recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_SC_Plan_Line_Item'),
                                                                                 ASI_MFM_Total_Cost__c=100000,
                                                                                 asi_mfm_ap_code__c=apcodeid
                                                                                 );
        insert planLine;
        return planLine;
    }
    
    public static ASI_MFM_PO__c createPO(String name, id prefixid, id planid , id supplierid){
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(Name = name,
                                                 ASI_MFM_SC_Supplier_Name__c = supplierid,
                                                 ASI_MFM_PO_Raised_Date__c = date.today(), 
                                                 ASI_MFM_PO_Start_Date__c =date.today(),
                                                 ASI_MFM_PO_End_Date__c =date.today(),                                              
                                                 ASI_MFM_Status__c = 'Final',
                                                 ASI_MFM_Prefix__c = prefixid,
                                                 ASI_MFM_Plan__c = planid,
                                                 ASI_MFM_Currency__c='USD',
                                                 recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_SC_PO'));
            insert po;  
            return po;
    }
    
    public static ASI_MFM_PO_Line_Item__c createPoLine(id headerid, id apcodeid, id buid , id subledgerid){
        ASI_MFM_PO_Line_Item__c po_line = new ASI_MFM_PO_Line_Item__c (recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_SC_PO_Line_Item'),
                                                                           ASI_MFM_PO__c = headerid,                                                                             
                                                                           ASI_MFM_Amount__c = 1000,
                                                                           asi_mfm_ap_code__c=apcodeid,
                                                                           ASI_MFM_BU_Code__c=buid,
                                                                           ASI_MFM_SC_Subledger__c=subledgerid
                                                                          );
            
            insert po_line;
        ASI_MFM_PO_Line_Item__c po_line2 = new ASI_MFM_PO_Line_Item__c (recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_SC_PO_Line_Item'),
                ASI_MFM_PO__c = headerid,
                ASI_MFM_Amount__c = 1000,
                asi_mfm_ap_code__c=apcodeid,
                ASI_MFM_BU_Code__c=buid,
                ASI_MFM_SC_Subledger__c=subledgerid
        );

        insert po_line2;
        return po_line;
    }
    
    public static ASI_MFM_Payment__c createPayment(id prefixid, id poid , id supplierid){
        ASI_MFM_Payment__c PaymentHeader = new ASI_MFM_Payment__c (ASI_MFM_Status__c = 'Draft',
                                                                       ASI_MFM_Prefix__c = prefixid,
                                                                       ASI_MFM_SC_Supplier_Name__c = supplierid,
                                                                       ASI_MFM_Currency__c='USD',
                                                                       recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_SC_Payment'),
                                                                       ASI_MFM_PO__c = poid);  
            
            insert PaymentHeader; 
            return PaymentHeader;
    }
    
    public testMethod static void testMassUpload(){
        userrole Role_Test= new userrole(Name='XXXTrade Marketing',developerName = 'test');
        insert Role_Test;
        
        user u = [select userRole.developerName, ASI_MFM_Country__c,UserRoleid,CompanyName from user where id = :userInfo.getUserId() limit 1]; 
        u.ASI_MFM_Country__c = 'SC';
        u.UserRoleid =Role_Test.id;
        u.CompanyName = 'Pernod Ricard Hong Kong';
        update u;
        
        System.runAs(u){ 

            ASI_MFM_AP_Code__c  AP_Code = createAPCode();            
            ASI_MFM_BU__c  BU_Code = createBUCode();
                        
            ASI_MFM_Prefix__c prefixPLAN = createPrefix ('Plan',Role_Test.DeveloperName);                                 
            ASI_MFM_Prefix__c prefixPO = createPrefix ('PO',Role_Test.DeveloperName);
            ASI_MFM_Prefix__c prefixPayment = createPrefix ('Payment',Role_Test.DeveloperName);
            
            ASI_MFM_Plan__c plan = createPlan(prefixPLAN.id);
            ASI_MFM_Plan_Line_Item__c planLine1 = createPlanLine(plan.id, AP_Code.id);

  
        test.startTest();
                 
        
        
            Account acc1 = createAccSupplier();            
            Account acc2 = createAccSubledger();           
                                   
            ASI_MFM_PO__c po = createPO('test893765', prefixPO.id, plan.id , acc1.id);
            ASI_MFM_PO_Line_Item__c po_line = createPoLine(po.id,AP_Code.id,BU_Code.id, acc2.id);
               
            ASI_MFM_Payment__c PaymentHeader = createPayment(prefixPayment.id,po.id,acc1.id);

        
        PageReference PaymentPage = Page.ASI_MFM_SC_LogisticPayDetailMassUpload;
        Test.setCurrentPage(PaymentPage);
        apexpages.currentPage().getParameters().put('PayHeader', PaymentHeader.id);
        apexpages.currentPage().getParameters().put('PoHeader', po.name);
        
        ASI_MFM_SC_LogisticDetailMassUploadCtrl controller = new ASI_MFM_SC_LogisticDetailMassUploadCtrl();
        controller.namefile = 'test.csv';
        String csv = 'BU,cost centre,Customer,Country,Job Type,Inv Date (YYYY-MM-DD),Invoice No.,Job No,Customer Name,PO No,Shipping/Delivery - Sea 5320.01,Shipping/Delivery - Air 5320.02,Shipping/Delivery - Truck 5320,Warehousing - Storage / Duty 5310,Shipping/Delivery - Inter-site 5320.03,Warehousing - Labour Stamping 5310.03,Warehousing - Labour Rework 5310.04,Shipping/Delivery - Transp. Materials  5320.04,Shipping/Delivery - Other cost  5320.05,Accrued handling cost (D/F Handling) 2220.04,Warehousing - Storage / Duty 5310,Warehousing - POS Storage 5310.01,Other income and expenses 9095.0107,Suspense 1270.06,Remark for Suspense,Breakage/Shortage (Damage) 3030,Grand Total,Payment List Item Description\r\n';
        csv += '326,HK,ddf,HK,ddd,2019-08-30,123,1,Fanny,123,1.1,1.2,1.3,1.4,1.5,1.6,1.7,1.8,1.9,2,2.1,2.2,2.3,2.4,REMARKS,2.5,,\r\n';
        csv += '326,HK,ddf,HK,ddd,2019-08-30,123,1,Fanny,123,1.1,1.2,1.3,1.4,1.5,1.6,1.7,1.8,1.9,2,2.1,2.2,2.3,2.4,REMARKS,2.5,,\r\n';
        controller.contentFile = blob.valueOf(csv);
            System.debug('PaymentHeader.id::'+ PaymentHeader.id + ',,po.name::'+ po.name);
        controller.payheaderId =  PaymentHeader.id;
		controller.poHeaderName = po.name;
        controller.uploadcsv();
        String[] msgs = controller.StatusMsgs;
          
        test.stopTest();
        }
    }
    
    
}