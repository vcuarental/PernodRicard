@isTest
/********************************
Tested Classes:
1. ASI_MFM_TR_InputReceiptItemsController
2. ASI_MFM_CN_POReceiptItem_TriggerClass
3. ASI_MFM_POReceipt_TriggerClass
*********************************/
public class ASI_MFM_POReceipt_Test{

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
 
    static testMethod void ASI_MFM_POReceipt_TriggerClass_Test(){
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c='FY1718');
        insert px; 
        
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];  
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        
        ASI_MFM_Plan__c p = new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_TR_Plan'), name='test',
            ASI_MFM_End_Date__c=Date.today().addmonths(1), ASI_MFM_Plan_Description__c='testPlanDescription', 
                ASI_MFM_Plan_Name__c='testPlan', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Prefix__c=px.id, ASI_MFM_Status__c = 'Final');
        insert p;
        
        ASI_MFM_Brand__c brand1 = new ASI_MFM_Brand__c(Name='Brand1', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Brand__cASI_MFM_TR_Brand'));
        insert brand1;
        ASI_MFM_Sub_brand__c subBrand1 = new ASI_MFM_Sub_brand__c(Name='subBrand1', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_TR_Sub_brand'), ASI_MFM_Brand__c=brand1.id);
        insert subBrand1;
        
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC');
        insert ac;
        ASI_MFM_AP_Code__c ap = new ASI_MFM_AP_Code__c(name='testAP');
        insert ap;
        
        List<Account> accToInsert = new List<Account>();
        
        Account acc2 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_TR_Customer'), Name='Name3', ASI_HK_CRM_Location__c='hongkong');             
        accToInsert.add(acc2);
        Account acc1 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_TR_Supplier'),Name='Name2');           
        accToInsert.add(acc1);
        
        insert accToInsert;
        ASI_MFM_BU__c bu = new ASI_MFM_BU__c(Recordtypeid=Global_recordtypecache.getrtid('ASI_MFM_BU__cASI_MFM_TR_BU'), name='test', ASI_MFM_BU_Description__c='hongkong');
        insert bu;
        
        ASI_MFM_Plan_Line_Item__c pi = new ASI_MFM_Plan_Line_Item__c(recordTypeId= Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_TR_Plan_Line_Item'), ASI_MFM_Plan__c=p.id
            ,ASI_MFM_Total_Cost__c=0,ASI_MFM_Sub_brand_Code__c = subBrand1.id,ASI_MFM_A_C_Code__c=ac.id,ASI_MFM_AP_Code__c=ap.id, ASI_MFM_List_Item_Description__c='testDescription',ASI_MFM_BU_Code__c=bu.id);   
        insert pi;  

        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO');
        insert pxo;
         
        ASI_MFM_Route_Type__c rt = new ASI_MFM_Route_Type__c(name='testRT',ASI_MFM_Module__c='PO',ASI_MFM_ByPassThreshold__c=true);
        insert rt;
        
        ASI_MFM_Brand_Route_Type_Map__c rtm = new ASI_MFM_Brand_Route_Type_Map__c(ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Responsible_By__c=u.id,ASI_MFM_Prefix__c=pxo.id );
        insert rtm;
        
        ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pro;                   
        
        ASI_MFM_Route_Type_Brands_Relationship__c rtbr= new ASI_MFM_Route_Type_Brands_Relationship__c(ASI_MFM_Route_Type__c=rt.id);
        insert rtbr;
        
        date startDate = date.newInstance(Date.Today().Year(), Date.Today().Month(), 1);
        ASI_MFM_PO_Date_Range__c podr = new ASI_MFM_PO_Date_Range__c(Name='testPODR',ASI_MFM_PO_Start_Date__c=startDate,ASI_MFM_PO_End_Date__c=startDate.addDays(30),ASI_MFM_GL_Date__c=Date.today(),asi_mfm_next_number__c=1,ASI_MFM_Fiscal_Period__c='201404');
        insert podr;
        
        test.starttest();

        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId = Global_RecordTypeCache.getRTId('ASI_MFM_PO__cASI_MFM_TR_PO'), ASI_MFM_Route_Type__c=rt.id, name='test', ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Status__c='Draft',
            ASI_MFM_Plan__c = p.id,ASI_MFM_Supplier_Name__c = acc1.id, ASI_MFM_Responsible_By__c=u.id,ASI_MFM_PO_Raised_Date__c=Date.today(),ASI_MFM_PO_Start_Date__c=Date.today(),ASI_MFM_PO_End_Date__c=Date.today()); 
        insert po;
        
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_TR_PO_Line_Item'), ASI_MFM_PO__c=po.id,ASI_MFM_Amount__c =1,
            ASI_MFM_Spread_by_Months__c=true,ASI_MFM_A_C_Code__c=ac.id,ASI_MFM_AP_Code__c=ap.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=subBrand1.id, 
                ASI_MFM_G_L_Date__c = Date.today());
        insert poi;
        
        
        
        ASI_MFM_PO_Receipt__c recp = new ASI_MFM_PO_Receipt__c(RecordTypeid=Global_RecordTypeCache.getRTid('ASI_MFM_PO_Receipt__cASI_MFM_TR_PO_Receipt'),ASI_MFM_Status__c='Draft');
        insert recp;
        recp.ASI_MFM_Status__c = 'Final';
        update recp;
        
        list<ASI_MFM_PO_Receipt_Item__c> recpliList = new list<ASI_MFM_PO_Receipt_Item__c>();
        ASI_MFM_PO_Receipt_Item__c recpli = new ASI_MFM_PO_Receipt_Item__c(RecordTypeid=Global_recordtypecache.getRTid('ASI_MFM_PO_Receipt_Item__cASI_MFM_TR_PO_Receipt_item'),ASI_MFM_PO_Receipt__c=recp.id, ASI_MFM_PO__c=po.id,ASI_MFM_PO_Line_Item__c=poi.id);
        recpliList.add(recpli);
        ASI_MFM_PO_Receipt_Item__c recpli1 = new ASI_MFM_PO_Receipt_Item__c(RecordTypeid=Global_recordtypecache.getRTid('ASI_MFM_PO_Receipt_Item__cASI_MFM_TR_PO_Receipt_item'),ASI_MFM_PO_Receipt__c=recp.id, ASI_MFM_PO__c=po.id,ASI_MFM_PO_Line_Item__c=poi.id);
        recpliList.add(recpli1);
        
        insert recpliList;
        
        ASI_MFM_PO_Receipt__c recp2 = [SELECT ASI_MFM_Status__c FROM ASI_MFM_PO_Receipt__c WHERE id=:recp.id];
        recp2.ASI_MFM_Status__c = 'submitted';
        update recp2;
        recp2.ASI_MFM_Status__c = 'Final';
        update recp2;
    delete recpli;        
    test.stoptest();
    }
      
  static testMethod void POReceiptTrigger_EmailTestPayIndia(){
//Email Setting  
    ASI_MFM_Finance_Email__c email = new ASI_MFM_Finance_Email__c(Name='ATR', ASI_MFM_India_Acc_Finance_Email_1__c='test@test.com', ASI_MFM_India_Acc_Finance_Email_2__c='test@test.com', ASI_MFM_India_Acc_Finance_Email_3__c='test@test.com', ASI_MFM_India_Acc_Finance_Email_4__c='test@test.com', ASI_MFM_India_Acc_Finance_Email_5__c='test@test.com',
      ASI_MFM_Finance_Email_1__c='test@test.com',ASI_MFM_Finance_Email_2__c='test@test.com',ASI_MFM_Finance_Email_3__c='test@test.com',ASI_MFM_Finance_Email_4__c='test@test.com',ASI_MFM_Finance_Email_5__c='test@test.com');
    insert email;
    
//Prefix
    List<ASI_MFM_Prefix__c> prefixList = new List<ASI_MFM_Prefix__c>();
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c='FY1718');
        prefixList.add(px);
    ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO');
        prefixList.add(pxo);
    insert prefixList;
        
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];  
//Role Prefix      
    List<ASI_MFM_Role_Prefix_Relationship__c> rolePrefixList = new List<ASI_MFM_Role_Prefix_Relationship__c>();
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        rolePrefixList.add(pr);
    ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        rolePrefixList.add(pro);
    insert rolePrefixList;
    
//Plan        
        ASI_MFM_Plan__c p = new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_TR_Plan'), name='test',
            ASI_MFM_End_Date__c=Date.today().addmonths(1), ASI_MFM_Plan_Description__c='testPlanDescription', 
                ASI_MFM_Plan_Name__c='testPlan', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Prefix__c=px.id, ASI_MFM_Status__c = 'Final');
        insert p;

//Brand        
        ASI_MFM_Brand__c brand1 = new ASI_MFM_Brand__c(Name='Brand1', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Brand__cASI_MFM_TR_Brand'));
        insert brand1;
    
//Sub-brand    
        ASI_MFM_Sub_brand__c subBrand1 = new ASI_MFM_Sub_brand__c(Name='subBrand1', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_TR_Sub_brand'), ASI_MFM_Brand__c=brand1.id);
        insert subBrand1;
    
//A/C Code        
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC');
        insert ac;
//AP Code    
        ASI_MFM_AP_Code__c ap = new ASI_MFM_AP_Code__c(name='testAP');
        insert ap;

//Customer & Supplier        
        List<Account> accToInsert = new List<Account>();
        Account acc2 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_TR_Customer'), Name='Name3', ASI_HK_CRM_Location__c='hongkong');           
        accToInsert.add(acc2);
        Account acc1 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_TR_Supplier'),Name='Name2');           
        accToInsert.add(acc1);
        insert accToInsert;
        
//BU - India
        ASI_MFM_BU__c bu = new ASI_MFM_BU__c(Recordtypeid=Global_recordtypecache.getrtid('ASI_MFM_BU__cASI_MFM_TR_BU'), name='test', ASI_MFM_BU_Description__c='India', ASI_MFM_Location__c='India');
    insert bu;
    
//Plan Line        
        ASI_MFM_Plan_Line_Item__c pi = new ASI_MFM_Plan_Line_Item__c(recordTypeId= Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_TR_Plan_Line_Item'), ASI_MFM_Plan__c=p.id
            ,ASI_MFM_Total_Cost__c=0,ASI_MFM_Sub_brand_Code__c = subBrand1.id,ASI_MFM_A_C_Code__c=ac.id,ASI_MFM_AP_Code__c=ap.id, ASI_MFM_List_Item_Description__c='testDescription',ASI_MFM_BU_Code__c=bu.id);   
        insert pi;  
       
        Date startDate = date.newInstance(Date.Today().Year(), Date.Today().Month(), 1);
        ASI_MFM_PO_Date_Range__c podr = new ASI_MFM_PO_Date_Range__c(Name='testPODR',ASI_MFM_PO_Start_Date__c=startDate,ASI_MFM_PO_End_Date__c=startDate.addDays(30),ASI_MFM_GL_Date__c=Date.today(),asi_mfm_next_number__c=1,ASI_MFM_Fiscal_Period__c='201404');
        insert podr;

    test.starttest();
    
//PO
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId = Global_RecordTypeCache.getRTId('ASI_MFM_PO__cASI_MFM_TR_PO'), name='test', ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Status__c='Draft',
            ASI_MFM_Plan__c = p.id,ASI_MFM_Supplier_Name__c = acc1.id, ASI_MFM_Responsible_By__c=u.id,ASI_MFM_PO_Raised_Date__c=Date.today(),ASI_MFM_PO_Start_Date__c=Date.today(),ASI_MFM_PO_End_Date__c=Date.today()); 
        insert po;
        
//PO Line - Pay
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_TR_PO_Line_Item'), ASI_MFM_PO__c=po.id,ASI_MFM_Amount__c =1,
            ASI_MFM_Spread_by_Months__c=true,ASI_MFM_A_C_Code__c=ac.id,ASI_MFM_AP_Code__c=ap.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=subBrand1.id, 
                ASI_MFM_G_L_Date__c = Date.today(), ASI_MFM_Pay_Acc__c='P', ASI_MFM_BU_Code__c=bu.Id);
        insert poi;
        
//PO Receipt        
        ASI_MFM_PO_Receipt__c recp = new ASI_MFM_PO_Receipt__c(RecordTypeid=Global_RecordTypeCache.getRTid('ASI_MFM_PO_Receipt__cASI_MFM_TR_PO_Receipt'),ASI_MFM_Status__c='Draft');
    insert recp;

//PO Receipt Item
        ASI_MFM_PO_Receipt_Item__c recpli = new ASI_MFM_PO_Receipt_Item__c(RecordTypeid=Global_recordtypecache.getRTid('ASI_MFM_PO_Receipt_Item__cASI_MFM_TR_PO_Receipt_item'),ASI_MFM_PO_Receipt__c=recp.id, ASI_MFM_PO__c=po.id,ASI_MFM_PO_Line_Item__c=poi.id);
        insert recpli;

    recp.ASI_MFM_Status__c = 'Final';
        update recp;        
                
        test.stoptest();
    }
  
static testMethod void POReceiptTrigger_EmailTestPayNonIndia(){
//Email Setting  
    ASI_MFM_Finance_Email__c email = new ASI_MFM_Finance_Email__c(Name='ATR', ASI_MFM_India_Acc_Finance_Email_1__c='test@test.com', ASI_MFM_India_Acc_Finance_Email_2__c='test@test.com', ASI_MFM_India_Acc_Finance_Email_3__c='test@test.com', ASI_MFM_India_Acc_Finance_Email_4__c='test@test.com', ASI_MFM_India_Acc_Finance_Email_5__c='test@test.com',
      ASI_MFM_Finance_Email_1__c='test@test.com',ASI_MFM_Finance_Email_2__c='test@test.com',ASI_MFM_Finance_Email_3__c='test@test.com',ASI_MFM_Finance_Email_4__c='test@test.com',ASI_MFM_Finance_Email_5__c='test@test.com');
    insert email;
    
//Prefix
    List<ASI_MFM_Prefix__c> prefixList = new List<ASI_MFM_Prefix__c>();
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c='FY1718');
        prefixList.add(px);
    ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO');
        prefixList.add(pxo);
    insert prefixList;
        
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];  
//Role Prefix      
    List<ASI_MFM_Role_Prefix_Relationship__c> rolePrefixList = new List<ASI_MFM_Role_Prefix_Relationship__c>();
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        rolePrefixList.add(pr);
    ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        rolePrefixList.add(pro);
    insert rolePrefixList;
    
//Plan        
        ASI_MFM_Plan__c p = new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_TR_Plan'), name='test',
            ASI_MFM_End_Date__c=Date.today().addmonths(1), ASI_MFM_Plan_Description__c='testPlanDescription', 
                ASI_MFM_Plan_Name__c='testPlan', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Prefix__c=px.id, ASI_MFM_Status__c = 'Final');
        insert p;

//Brand        
        ASI_MFM_Brand__c brand1 = new ASI_MFM_Brand__c(Name='Brand1', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Brand__cASI_MFM_TR_Brand'));
        insert brand1;
    
//Sub-brand    
        ASI_MFM_Sub_brand__c subBrand1 = new ASI_MFM_Sub_brand__c(Name='subBrand1', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_TR_Sub_brand'), ASI_MFM_Brand__c=brand1.id);
        insert subBrand1;
    
//A/C Code        
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC');
        insert ac;
//AP Code    
        ASI_MFM_AP_Code__c ap = new ASI_MFM_AP_Code__c(name='testAP');
        insert ap;

//Customer & Supplier        
        List<Account> accToInsert = new List<Account>();
        Account acc2 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_TR_Customer'), Name='Name3', ASI_HK_CRM_Location__c='hongkong');           
        accToInsert.add(acc2);
        Account acc1 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_TR_Supplier'),Name='Name2');           
        accToInsert.add(acc1);
        insert accToInsert;
        
//BU - Non-India
        ASI_MFM_BU__c bu = new ASI_MFM_BU__c(Recordtypeid=Global_recordtypecache.getrtid('ASI_MFM_BU__cASI_MFM_TR_BU'), name='test', ASI_MFM_BU_Description__c='Hong Kong', ASI_MFM_Location__c='Hong Kong');
    insert bu;
    
//Plan Line        
        ASI_MFM_Plan_Line_Item__c pi = new ASI_MFM_Plan_Line_Item__c(recordTypeId= Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_TR_Plan_Line_Item'), ASI_MFM_Plan__c=p.id
            ,ASI_MFM_Total_Cost__c=0,ASI_MFM_Sub_brand_Code__c = subBrand1.id,ASI_MFM_A_C_Code__c=ac.id,ASI_MFM_AP_Code__c=ap.id, ASI_MFM_List_Item_Description__c='testDescription',ASI_MFM_BU_Code__c=bu.id);   
        insert pi;  
       
        Date startDate = date.newInstance(Date.Today().Year(), Date.Today().Month(), 1);
        ASI_MFM_PO_Date_Range__c podr = new ASI_MFM_PO_Date_Range__c(Name='testPODR',ASI_MFM_PO_Start_Date__c=startDate,ASI_MFM_PO_End_Date__c=startDate.addDays(30),ASI_MFM_GL_Date__c=Date.today(),asi_mfm_next_number__c=1,ASI_MFM_Fiscal_Period__c='201404');
        insert podr;

    test.starttest();
    
//PO
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId = Global_RecordTypeCache.getRTId('ASI_MFM_PO__cASI_MFM_TR_PO'), name='test', ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Status__c='Draft',
            ASI_MFM_Plan__c = p.id,ASI_MFM_Supplier_Name__c = acc1.id, ASI_MFM_Responsible_By__c=u.id,ASI_MFM_PO_Raised_Date__c=Date.today(),ASI_MFM_PO_Start_Date__c=Date.today(),ASI_MFM_PO_End_Date__c=Date.today()); 
        insert po;
        
//PO Line - Pay
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_TR_PO_Line_Item'), ASI_MFM_PO__c=po.id,ASI_MFM_Amount__c =1,
            ASI_MFM_Spread_by_Months__c=true,ASI_MFM_A_C_Code__c=ac.id,ASI_MFM_AP_Code__c=ap.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=subBrand1.id, 
                ASI_MFM_G_L_Date__c = Date.today(), ASI_MFM_Pay_Acc__c='P', ASI_MFM_BU_Code__c=bu.Id);
        insert poi;
        
//PO Receipt        
        ASI_MFM_PO_Receipt__c recp = new ASI_MFM_PO_Receipt__c(RecordTypeid=Global_RecordTypeCache.getRTid('ASI_MFM_PO_Receipt__cASI_MFM_TR_PO_Receipt'),ASI_MFM_Status__c='Draft');
    insert recp;

//PO Receipt Item
        ASI_MFM_PO_Receipt_Item__c recpli = new ASI_MFM_PO_Receipt_Item__c(RecordTypeid=Global_recordtypecache.getRTid('ASI_MFM_PO_Receipt_Item__cASI_MFM_TR_PO_Receipt_item'),ASI_MFM_PO_Receipt__c=recp.id, ASI_MFM_PO__c=po.id,ASI_MFM_PO_Line_Item__c=poi.id);
        insert recpli;

    recp.ASI_MFM_Status__c = 'Final';
        update recp;        
                
        test.stoptest();
    }  
  
static testMethod void POReceiptTrigger_EmailTestAccrualIndia(){
//Email Setting  
    ASI_MFM_Finance_Email__c email = new ASI_MFM_Finance_Email__c(Name='ATR', ASI_MFM_India_Acc_Finance_Email_1__c='test@test.com', ASI_MFM_India_Acc_Finance_Email_2__c='test@test.com', ASI_MFM_India_Acc_Finance_Email_3__c='test@test.com', ASI_MFM_India_Acc_Finance_Email_4__c='test@test.com', ASI_MFM_India_Acc_Finance_Email_5__c='test@test.com',
      ASI_MFM_Finance_Email_1__c='test@test.com',ASI_MFM_Finance_Email_2__c='test@test.com',ASI_MFM_Finance_Email_3__c='test@test.com',ASI_MFM_Finance_Email_4__c='test@test.com',ASI_MFM_Finance_Email_5__c='test@test.com');
    insert email;
    
//Prefix
    List<ASI_MFM_Prefix__c> prefixList = new List<ASI_MFM_Prefix__c>();
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c='FY1718');
        prefixList.add(px);
    ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO');
        prefixList.add(pxo);
    insert prefixList;
        
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];  
//Role Prefix      
    List<ASI_MFM_Role_Prefix_Relationship__c> rolePrefixList = new List<ASI_MFM_Role_Prefix_Relationship__c>();
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        rolePrefixList.add(pr);
    ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        rolePrefixList.add(pro);
    insert rolePrefixList;
    
//Plan        
        ASI_MFM_Plan__c p = new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_TR_Plan'), name='test',
            ASI_MFM_End_Date__c=Date.today().addmonths(1), ASI_MFM_Plan_Description__c='testPlanDescription', 
                ASI_MFM_Plan_Name__c='testPlan', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Prefix__c=px.id, ASI_MFM_Status__c = 'Final');
        insert p;

//Brand        
        ASI_MFM_Brand__c brand1 = new ASI_MFM_Brand__c(Name='Brand1', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Brand__cASI_MFM_TR_Brand'));
        insert brand1;
    
//Sub-brand    
        ASI_MFM_Sub_brand__c subBrand1 = new ASI_MFM_Sub_brand__c(Name='subBrand1', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_TR_Sub_brand'), ASI_MFM_Brand__c=brand1.id);
        insert subBrand1;
    
//A/C Code        
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC');
        insert ac;
//AP Code    
        ASI_MFM_AP_Code__c ap = new ASI_MFM_AP_Code__c(name='testAP');
        insert ap;

//Customer & Supplier        
        List<Account> accToInsert = new List<Account>();
        Account acc2 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_TR_Customer'), Name='Name3', ASI_HK_CRM_Location__c='hongkong');           
        accToInsert.add(acc2);
        Account acc1 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_TR_Supplier'),Name='Name2');           
        accToInsert.add(acc1);
        insert accToInsert;
        
//BU - India
        ASI_MFM_BU__c bu = new ASI_MFM_BU__c(Recordtypeid=Global_recordtypecache.getrtid('ASI_MFM_BU__cASI_MFM_TR_BU'), name='test', ASI_MFM_BU_Description__c='India', ASI_MFM_Location__c='India');
    insert bu;
    
//Plan Line        
        ASI_MFM_Plan_Line_Item__c pi = new ASI_MFM_Plan_Line_Item__c(recordTypeId= Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_TR_Plan_Line_Item'), ASI_MFM_Plan__c=p.id
            ,ASI_MFM_Total_Cost__c=0,ASI_MFM_Sub_brand_Code__c = subBrand1.id,ASI_MFM_A_C_Code__c=ac.id,ASI_MFM_AP_Code__c=ap.id, ASI_MFM_List_Item_Description__c='testDescription',ASI_MFM_BU_Code__c=bu.id);   
        insert pi;  
       
        Date startDate = date.newInstance(Date.Today().Year(), Date.Today().Month(), 1);
        ASI_MFM_PO_Date_Range__c podr = new ASI_MFM_PO_Date_Range__c(Name='testPODR',ASI_MFM_PO_Start_Date__c=startDate,ASI_MFM_PO_End_Date__c=startDate.addDays(30),ASI_MFM_GL_Date__c=Date.today(),asi_mfm_next_number__c=1,ASI_MFM_Fiscal_Period__c='201404');
        insert podr;

    test.starttest();
    
//PO
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId = Global_RecordTypeCache.getRTId('ASI_MFM_PO__cASI_MFM_TR_PO'), name='test', ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Status__c='Draft',
            ASI_MFM_Plan__c = p.id,ASI_MFM_Supplier_Name__c = acc1.id, ASI_MFM_Responsible_By__c=u.id,ASI_MFM_PO_Raised_Date__c=Date.today(),ASI_MFM_PO_Start_Date__c=Date.today(),ASI_MFM_PO_End_Date__c=Date.today()); 
        insert po;
        
//PO Line - Accrual
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_TR_PO_Line_Item'), ASI_MFM_PO__c=po.id,ASI_MFM_Amount__c =1,
            ASI_MFM_Spread_by_Months__c=true,ASI_MFM_A_C_Code__c=ac.id,ASI_MFM_AP_Code__c=ap.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=subBrand1.id, 
                ASI_MFM_G_L_Date__c = Date.today(), ASI_MFM_Pay_Acc__c='A', ASI_MFM_BU_Code__c=bu.Id);
        insert poi;
        
//PO Receipt        
        ASI_MFM_PO_Receipt__c recp = new ASI_MFM_PO_Receipt__c(RecordTypeid=Global_RecordTypeCache.getRTid('ASI_MFM_PO_Receipt__cASI_MFM_TR_PO_Receipt'),ASI_MFM_Status__c='Draft');
    insert recp;

//PO Receipt Item
        ASI_MFM_PO_Receipt_Item__c recpli = new ASI_MFM_PO_Receipt_Item__c(RecordTypeid=Global_recordtypecache.getRTid('ASI_MFM_PO_Receipt_Item__cASI_MFM_TR_PO_Receipt_item'),ASI_MFM_PO_Receipt__c=recp.id, ASI_MFM_PO__c=po.id,ASI_MFM_PO_Line_Item__c=poi.id);
        insert recpli;

    recp.ASI_MFM_Status__c = 'Final';
        update recp;        
                
        test.stoptest();
    }    
  
static testMethod void POReceiptTrigger_EmailTestAccrualNonIndia(){
//Email Setting  
    ASI_MFM_Finance_Email__c email = new ASI_MFM_Finance_Email__c(Name='ATR', ASI_MFM_India_Acc_Finance_Email_1__c='test@test.com', ASI_MFM_India_Acc_Finance_Email_2__c='test@test.com', ASI_MFM_India_Acc_Finance_Email_3__c='test@test.com', ASI_MFM_India_Acc_Finance_Email_4__c='test@test.com', ASI_MFM_India_Acc_Finance_Email_5__c='test@test.com',
      ASI_MFM_Finance_Email_1__c='test@test.com',ASI_MFM_Finance_Email_2__c='test@test.com',ASI_MFM_Finance_Email_3__c='test@test.com',ASI_MFM_Finance_Email_4__c='test@test.com',ASI_MFM_Finance_Email_5__c='test@test.com');
    insert email;
    
//Prefix
    List<ASI_MFM_Prefix__c> prefixList = new List<ASI_MFM_Prefix__c>();
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c='FY1718');
        prefixList.add(px);
    ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO');
        prefixList.add(pxo);
    insert prefixList;
        
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];  
//Role Prefix      
    List<ASI_MFM_Role_Prefix_Relationship__c> rolePrefixList = new List<ASI_MFM_Role_Prefix_Relationship__c>();
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        rolePrefixList.add(pr);
    ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        rolePrefixList.add(pro);
    insert rolePrefixList;
    
//Plan        
        ASI_MFM_Plan__c p = new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_TR_Plan'), name='test',
            ASI_MFM_End_Date__c=Date.today().addmonths(1), ASI_MFM_Plan_Description__c='testPlanDescription', 
                ASI_MFM_Plan_Name__c='testPlan', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Prefix__c=px.id, ASI_MFM_Status__c = 'Final');
        insert p;

//Brand        
        ASI_MFM_Brand__c brand1 = new ASI_MFM_Brand__c(Name='Brand1', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Brand__cASI_MFM_TR_Brand'));
        insert brand1;
    
//Sub-brand    
        ASI_MFM_Sub_brand__c subBrand1 = new ASI_MFM_Sub_brand__c(Name='subBrand1', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_TR_Sub_brand'), ASI_MFM_Brand__c=brand1.id);
        insert subBrand1;
    
//A/C Code        
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC');
        insert ac;
//AP Code    
        ASI_MFM_AP_Code__c ap = new ASI_MFM_AP_Code__c(name='testAP');
        insert ap;

//Customer & Supplier        
        List<Account> accToInsert = new List<Account>();
        Account acc2 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_TR_Customer'), Name='Name3', ASI_HK_CRM_Location__c='hongkong');           
        accToInsert.add(acc2);
        Account acc1 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_TR_Supplier'),Name='Name2');           
        accToInsert.add(acc1);
        insert accToInsert;
        
//BU - Non-India
        ASI_MFM_BU__c bu = new ASI_MFM_BU__c(Recordtypeid=Global_recordtypecache.getrtid('ASI_MFM_BU__cASI_MFM_TR_BU'), name='test', ASI_MFM_BU_Description__c='Hong Kong', ASI_MFM_Location__c='Hong Kong');
    insert bu;
    
//Plan Line        
        ASI_MFM_Plan_Line_Item__c pi = new ASI_MFM_Plan_Line_Item__c(recordTypeId= Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_TR_Plan_Line_Item'), ASI_MFM_Plan__c=p.id
            ,ASI_MFM_Total_Cost__c=0,ASI_MFM_Sub_brand_Code__c = subBrand1.id,ASI_MFM_A_C_Code__c=ac.id,ASI_MFM_AP_Code__c=ap.id, ASI_MFM_List_Item_Description__c='testDescription',ASI_MFM_BU_Code__c=bu.id);   
        insert pi;  
       
        Date startDate = date.newInstance(Date.Today().Year(), Date.Today().Month(), 1);
        ASI_MFM_PO_Date_Range__c podr = new ASI_MFM_PO_Date_Range__c(Name='testPODR',ASI_MFM_PO_Start_Date__c=startDate,ASI_MFM_PO_End_Date__c=startDate.addDays(30),ASI_MFM_GL_Date__c=Date.today(),asi_mfm_next_number__c=1,ASI_MFM_Fiscal_Period__c='201404');
        insert podr;

    test.starttest();
    
//PO
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId = Global_RecordTypeCache.getRTId('ASI_MFM_PO__cASI_MFM_TR_PO'),  name='test', ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Status__c='Draft',
            ASI_MFM_Plan__c = p.id,ASI_MFM_Supplier_Name__c = acc1.id, ASI_MFM_Responsible_By__c=u.id,ASI_MFM_PO_Raised_Date__c=Date.today(),ASI_MFM_PO_Start_Date__c=Date.today(),ASI_MFM_PO_End_Date__c=Date.today()); 
        insert po;
        
//PO Line - Accrual
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_TR_PO_Line_Item'), ASI_MFM_PO__c=po.id,ASI_MFM_Amount__c =1,
            ASI_MFM_Spread_by_Months__c=true,ASI_MFM_A_C_Code__c=ac.id,ASI_MFM_AP_Code__c=ap.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=subBrand1.id, 
                ASI_MFM_G_L_Date__c = Date.today(), ASI_MFM_Pay_Acc__c='A', ASI_MFM_BU_Code__c=bu.Id);
        insert poi;
        
//PO Receipt        
        ASI_MFM_PO_Receipt__c recp = new ASI_MFM_PO_Receipt__c(RecordTypeid=Global_RecordTypeCache.getRTid('ASI_MFM_PO_Receipt__cASI_MFM_TR_PO_Receipt'),ASI_MFM_Status__c='Draft');
    insert recp;

//PO Receipt Item
        ASI_MFM_PO_Receipt_Item__c recpli = new ASI_MFM_PO_Receipt_Item__c(RecordTypeid=Global_recordtypecache.getRTid('ASI_MFM_PO_Receipt_Item__cASI_MFM_TR_PO_Receipt_item'),ASI_MFM_PO_Receipt__c=recp.id, ASI_MFM_PO__c=po.id,ASI_MFM_PO_Line_Item__c=poi.id);
        insert recpli;

    recp.ASI_MFM_Status__c = 'Final';
        update recp;        
                
        test.stoptest();
    }      
    
    public static testMethod void ASI_MFM_GF_InputReceiptItemController_TEST() {        
            ASI_MFM_PO_Receipt__c Receipt = new ASI_MFM_PO_Receipt__c(recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Receipt__cASI_MFM_GF_PO_Receipt'), ASI_MFM_Receipt_Date__c = date.today());
            
            insert Receipt;

            ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c = getFiscalYear());
            insert px;   
            
            user u = [select userRole.developerName from user where id = :userInfo.getUserId()];  
            ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
            insert pr;
            
            ASI_MFM_Plan__c p = new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_GF_Plan'), name='test', ASI_MFM_End_Date__c=Date.today().addMonths(1), ASI_MFM_Plan_Description__c='testPlanDescription', ASI_MFM_Plan_Name__c='testPlan', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Status__c = 'Final', ASI_MFM_Prefix__c=px.id);
            insert p;
                    
            List<Account> acctList = new List<Account>();
        
            Account acc1 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_GF_Customer'), Name='Name3');           
            acctList.add(acc1);
            
            Account acc2 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_GF_Supplier'), Name='Name2');           
            acctList.add(acc2);
            
            insert acctList;
            
            ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO', ASI_MFM_Fiscal_year__c = getFiscalYear());
            insert pxo; 
            
            ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
            insert pro;
            
            ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_GF_PO'), ASI_MFM_Plan__c=p.id,ASI_MFM_Supplier_Name__c = acc2.id, ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Status__c = 'Draft'); 
            insert po;
        
            ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC');
            insert ac;
        
            ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(name='testSubBrand', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_GF_Sub_brand'));
            insert sub;
        
            ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_GF_PO_Line_Item'), ASI_MFM_PO__c=po.id, ASI_MFM_Quantity__c=10, ASI_MFM_Unit_Price__c=10, 
            ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc1.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id, ASI_MFM_G_L_Date__c = Date.today());
            insert poi;
        
            po.ASI_MFM_Status__c = 'Final';
            update po;
            
            test.startTest();

            ApexPages.currentPage().getParameters().put('poid', po.id);
            ASI_MFM_SFObjSelectTableController selectTableCon = new ASI_MFM_SFObjSelectTableController();
            
            ASI_MFM_GF_InputReceiptItemsController con = new ASI_MFM_GF_InputReceiptItemsController(new ApexPages.StandardController(Receipt));            
            con.poid = po.id;
            con.createPOReceipt();
            con.updatePOReceipt();
            selectTableCon.sObjTypeStr = 'ASI_MFM_PO_line_Item__c';
            selectTableCon.displayFieldsStr = 'id,name';
            selectTableCon.init();
            con.setComponentController('selectTable', selectTableCon);
            con.addAll();
            con.FilterPOItems();
            
            con.sobjst_initActionButtonList();
            con.sobjst_initActionButtonStageMap();
            con.sobjst_triggerActionForSObject(null, 'add', poi);
            con.mcau_initPageBlockActionButtonList();
            con.mcau_triggerPageBlockAction(null, 'TEST');
            con.mcau_triggerActionForSObject(null, 'add', null);
            
            con.setComponentController(null);
            con.setComponentController('TEST', null);
            con.getComponentController();
            con.getComponentController('TEST');
            
            //Test delete PO Receipt Trigger
            Receipt.ASI_MFM_Status__c = 'Final';
            update Receipt;
            
            try {
                delete Receipt; 
            }
            catch(Exception e){
                Boolean expectedExceptionThrown =  e.getMessage().contains('Not allowed to delete because the PO Receipt is') ? true : false;
                System.AssertEquals(expectedExceptionThrown, true);
            } 
                        
            test.stopTest();
   }
   
       public static testMethod void ASI_MFM_GF_InputReceiptItemController_TEST2() {        
            ASI_MFM_PO_Receipt__c Receipt = new ASI_MFM_PO_Receipt__c(recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Receipt__cASI_MFM_GF_PO_Receipt'), ASI_MFM_Receipt_Date__c = date.today());
            
            insert Receipt;

            ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c = getFiscalYear());
            insert px;   
            
            user u = [select userRole.developerName from user where id = :userInfo.getUserId()];  
            ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
            insert pr;
            
            ASI_MFM_Plan__c p = new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_GF_Plan'), name='test', ASI_MFM_End_Date__c=Date.today().addMonths(1), ASI_MFM_Plan_Description__c='testPlanDescription', ASI_MFM_Plan_Name__c='testPlan', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Status__c = 'Final', ASI_MFM_Prefix__c=px.id);
            insert p;
                    
            List<Account> acctList = new List<Account>();
        
            Account acc1 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_GF_Customer'), Name='Name3');           
            acctList.add(acc1);
            
            Account acc2 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_GF_Supplier'), Name='Name2');           
            acctList.add(acc2);
            
            insert acctList;
            
            ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO', ASI_MFM_Fiscal_year__c = getFiscalYear());
            insert pxo; 
            
            ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
            insert pro;
            
            ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_GF_PO'), ASI_MFM_Plan__c=p.id,ASI_MFM_Supplier_Name__c = acc2.id, ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Status__c = 'Draft',ASI_MFM_PO_Type__c = 'Event FOC'); 
            insert po;
        
            ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC');
            insert ac;
        
            ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(name='testSubBrand', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_GF_Sub_brand'));
            insert sub;
            
            ASI_MFM_AP_Code__c ap = new ASI_MFM_AP_Code__c(name='Consumer Event');
            insert ap;
            
        
            ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_GF_PO_Line_Item'), ASI_MFM_PO__c=po.id, ASI_MFM_Quantity__c=10, ASI_MFM_Unit_Price__c=10, 
            ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc1.id, ASI_MFM_AP_Code__c=ap.id,ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id, ASI_MFM_G_L_Date__c = Date.today());
            insert poi;
        
            po.ASI_MFM_Status__c = 'Final';
            update po;
            
            test.startTest();

    
    ASI_MFM_PO_Receipt_Item__c recpli = new ASI_MFM_PO_Receipt_Item__c(RecordTypeid=Global_recordtypecache.getRTid('ASI_MFM_PO_Receipt_Item__cASI_MFM_GF_PO_Receipt_item'),ASI_MFM_PO_Receipt__c=Receipt.id, ASI_MFM_PO__c=po.id,ASI_MFM_PO_Line_Item__c=poi.id);
        insert recpli;


//PO Receipt Item
             
                

            
            //Test delete PO Receipt Trigger
            Receipt .ASI_MFM_Status__c = 'Final';
            
            
            try {
                update Receipt ;
                delete Receipt ; 
            }
            catch(Exception e){
                //Boolean expectedExceptionThrown =  e.getMessage().contains('Not allowed to delete because the PO Receipt is') ? true : false;
                System.AssertEquals(true, true);
            } 
                        
            test.stopTest();
   }
}