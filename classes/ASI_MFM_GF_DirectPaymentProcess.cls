public class ASI_MFM_GF_DirectPaymentProcess implements Database.Batchable<sObject>, Database.Stateful{
    // global class ASI_MFM_GF_DirectPaymentProcess implements Database.Batchable<sObject>{
    //global class ASI_MFM_GF_DirectPaymentProcess implements Database.Batchable<sObject>, Database.Stateful{
    // global class ASI_MFM_GF_DirectPaymentProcess implements Database.Batchable<sObject>, Database.Stateful{    public class ASI_MFM_GF_DirectPaymentProcess {
    // From ASI_MFM_EditSmallAmountPayment_Ctrl
    public map<integer, ASI_MFM_EditSmallAmountPayment_Ctrl.SAPLineObj> SAPL_Item_Map {set;get;}{SAPL_Item_Map=new map<integer, ASI_MFM_EditSmallAmountPayment_Ctrl.SAPLineObj>();}
    public ASI_MFM_EditSmallAmountPayment_Ctrl.SAPHeaderObj LSAPHeader {set;get;} {LSAPHeader=new ASI_MFM_EditSmallAmountPayment_Ctrl.SAPHeaderObj();}
    public asi_mfm_prefix__c payment_prefixes;
    public asi_mfm_prefix__c po_prefixes;
    public ASI_MFM_PO__c create_po {set;get;}{create_po=new ASI_MFM_PO__c(); }
    public ASI_MFM_Payment__c create_pa {set;get;} {create_pa=new ASI_MFM_Payment__c();}
    public List <ASI_MFM_PO_Line_Item__c> Save_SAPL_POItem {set;get;}  
    public List <ASI_MFM_Payment_Line_Item__c> Save_SAPL_PAYItem {set;get;}   
    public string country {set;get;} {country= 'GF';}
    public string base_ccy {set;get;}  {base_ccy = 'USD';}
    public string counter_ccy {set;get;} //Payment Currency
    public date last_effective_date = System.Today();
    public double exchangeRate {set;get;} { exchangeRate = 0;}
    public double totalPaymentAmt {set;get;}{totalPaymentAmt= 0;}
    
    public string Msg {GET;SET;}
    PUBLIC string poid;//
    PUBLIC string paid;//{GET;SET;}
    public ASI_MFM_Mass_Upload_Log__c log{GET;SET;} {log=new ASI_MFM_Mass_Upload_Log__c(); }
    /*
    public ASI_MFM_GF_DirectPaymentProcess(asi_mfm_prefix__c po_prefixes,
                                           asi_mfm_prefix__c payment_prefixes,
                                           ASI_MFM_EditSmallAmountPayment_Ctrl.SAPHeaderObj LSAPHeader,
                                           map<integer, ASI_MFM_EditSmallAmountPayment_Ctrl.SAPLineObj> SAPL_Item_Map,
                                           double totalPaymentAmt,string Msg)
    {
        System.Debug('CHECK 0.0: ' + totalPaymentAmt);
        this.po_prefixes=po_prefixes;
        this.payment_prefixes=payment_prefixes;
        this.LSAPHeader=LSAPHeader;
        this.SAPL_Item_Map.putAll(SAPL_Item_Map);
        this.totalPaymentAmt=totalPaymentAmt;
        this.counter_ccy=LSAPHeader.pay.ASI_MFM_Currency__c;
        this.Msg=Msg;
    }   
    */
    public ASI_MFM_GF_DirectPaymentProcess(asi_mfm_prefix__c po_prefixes,
                                           asi_mfm_prefix__c payment_prefixes,
                                           ASI_MFM_EditSmallAmountPayment_Ctrl.SAPHeaderObj LSAPHeader,
                                           map<integer, ASI_MFM_EditSmallAmountPayment_Ctrl.SAPLineObj> SAPL_Item_Map,
                                           double totalPaymentAmt,ASI_MFM_Mass_Upload_Log__c log)
    {
        System.Debug('CHECK 1.0: ' + totalPaymentAmt);
        this.po_prefixes=po_prefixes;
        this.payment_prefixes=payment_prefixes;
        this.LSAPHeader=LSAPHeader;
        this.SAPL_Item_Map.putAll(SAPL_Item_Map);
        this.totalPaymentAmt=totalPaymentAmt;
        this.counter_ccy=LSAPHeader.pay.ASI_MFM_Currency__c;
        this.log=log;
        log.ASI_MFM_Error_Message__c='';
    }   
    
    public database.querylocator start(Database.BatchableContext BC){
        System.Debug('CHECK 2.0: GOT IN');
        // This methods returns a SOQL query locator containing the records
        // select ASI_MFM_Counter_Currency__c, ASI_MFM_Effective_Date__c, ASI_MFM_Exchange_Rate__c from ASI_MFM_Exchange_Rate__c where ASI_MFM_Application__c = 'MFM' and ASI_MFM_Country__c = :country and ASI_MFM_Base_Currency__c = :base_ccy and ASI_MFM_Counter_Currency__c = :counter_ccy and ASI_MFM_Effective_Date__c <= :last_effective_date order by ASI_MFM_Counter_Currency__c asc, ASI_MFM_Effective_Date__c desc
        return Database.getQueryLocator([select ASI_MFM_Counter_Currency__c, ASI_MFM_Effective_Date__c, ASI_MFM_Exchange_Rate__c from ASI_MFM_Exchange_Rate__c where ASI_MFM_Application__c = 'MFM' and ASI_MFM_Country__c = :country and ASI_MFM_Base_Currency__c = :base_ccy and ASI_MFM_Counter_Currency__c = :counter_ccy limit 1]);
    }
    
    public void execute(Database.BatchableContext BC, List<sObject> scope)
    {   /*
        //check if there are 5 active batch jobs 
        if ([SELECT count() FROM AsyncApexJob WHERE JobType='BatchApex' AND (Status = 'Processing' OR Status = 'Preparing')] < 5){ 
            database.executebatch(new ASI_MFM_GF_DirectPaymentProcess(po_prefixes,payment_prefixes,LSAPHeader,SAPL_Item_Map,totalPaymentAmt,counter_ccy,log));
        } 
        if (Test.isRunningTest() || [SELECT count() FROM AsyncApexJob WHERE JobType='BatchApex' AND (Status = 'Processing' OR Status = 'Preparing')] >= 5){
            ASI_MFM_GF_DirectPaymentProcess  scRetry = new ASI_MFM_GF_DirectPaymentProcess(); 
            Datetime dt = Datetime.now() + (0.00138); // 2 mins 
            String timeForScheduler = dt.format('s m H d M \'?\' yyyy'); 
            Id schedId = System.Schedule('ContractShareScheRetry'+timeForScheduler,timeForScheduler,scRetry);
        } 
        */
        
        
        List<ASI_MFM_Exchange_Rate__c> xr_list = (List<ASI_MFM_Exchange_Rate__c>)scope;
        if (LSAPHeader.pay.ASI_MFM_Currency__c == base_ccy){
            exchangeRate = 1;
        }
        else {
            for (ASI_MFM_Exchange_Rate__c xr:xr_list) {
                if (xr.ASI_MFM_Counter_Currency__c == counter_ccy && xr.ASI_MFM_Effective_Date__c <= last_effective_date) {
                    exchangeRate = xr.ASI_MFM_Exchange_Rate__c;
                    break;
                }
                else if (xr.ASI_MFM_Counter_Currency__c > counter_ccy) {
                    break;
                }
            }
        }                   
        //Exchange Rate End
        
        
        
        
        System.Savepoint sp = database.setSavepoint();
        try {
            
            //1st create PO Header
            create_po = new ASI_MFM_PO__c();
            
            //1st create PO Header
            create_po.ASI_MFM_Plan__c = LSAPHeader.po.ASI_MFM_Plan__c;
            create_po.ASI_MFM_Prefix__c = po_prefixes.id;
            create_po.ASI_MFM_Supplier_Name__c = LSAPHeader.pay.ASI_MFM_Supplier_Name__c ;
            create_po.ASI_MFM_Currency__c = LSAPHeader.pay.ASI_MFM_Currency__c ;
            create_po.recordTypeID = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_GF_PO_Read_Only');
            create_po.ASI_MFM_Status__c = 'Final';
            create_po.ASI_MFM_PO_Type__c = 'Normal';
            create_po.ASI_MFM_Is_Direct_Payment__c = true;
            create_po.ASI_MFM_PO_Start_Date__c = System.Today();
            create_po.ASI_MFM_PO_End_Date__c = System.Today();
            // Added by 2017-12-28 Linus@introv
            create_po.ASI_MFM_GF_Service_Goods__c = LSAPHeader.pay.ASI_MFM_GF_Service_Goods__c;
            
            
            
            create_pa = new ASI_MFM_Payment__c();
            create_pa.ASI_MFM_Prefix__c = payment_prefixes.id;
            create_pa.ASI_MFM_Supplier_Name__c = LSAPHeader.pay.ASI_MFM_Supplier_Name__c ;
            create_pa.ASI_MFM_Currency__c = LSAPHeader.pay.ASI_MFM_Currency__c ;
            create_pa.ASI_MFM_Invoice_Number__c = LSAPHeader.pay.ASI_MFM_Invoice_Number__c;
            create_pa.ASI_MFM_Invoice_Date__c =LSAPHeader.pay.ASI_MFM_Invoice_Date__c;
            create_pa.recordTypeID = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_GF_Payment');
            create_pa.ASI_MFM_Status__c = 'Draft';                //Added by 2018-08-21 Linus@introv
            create_pa.ASI_MFM_Is_Direct_Payment__c = true;
            create_pa.ASI_MFM_G_L_Date__c = System.Today();
            create_pa.ASI_MFM_Is_AMEX_Payment__c = LSAPHeader.pay.ASI_MFM_Is_AMEX_Payment__c;
            create_pa.ASI_MFM_Payment_Amount__c = totalPaymentAmt;
            //Added by 2017-12-28 Linus@introv
            create_pa.ASI_MFM_GF_Service_Goods__c = LSAPHeader.pay.ASI_MFM_GF_Service_Goods__c;
            
            
            Save_SAPL_POItem = new List<ASI_MFM_PO_Line_Item__c>();
            insert create_po;
            poid=create_po.id;
        } catch (DmlException dmle) {
            log.ASI_MFM_Error_Message__c+= dmle.getMessage();
            database.rollback(sp);
            
            
        } catch (Exception e) {
            log.ASI_MFM_Error_Message__c+=e.getMessage();
            database.rollback(sp);
            
        } 
        
        ASI_MFM_PO_Receipt__c rec = new ASI_MFM_PO_Receipt__c();
        
        rec.ASI_MFM_Receipt_Date__c =  System.Today();
        rec.ASI_MFM_Status__c = 'Draft';            //Added by 2018-08-21 Linus@introv
        rec.recordTypeID = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Receipt__cASI_MFM_GF_PO_Receipt');
        rec.ASI_MFM_Is_AMEX_Receipt__c = LSAPHeader.pay.ASI_MFM_Is_AMEX_Payment__c;
        
        
        
        //Payment
        try{
            insert rec; 
            insert create_pa;
            paid=create_pa.id;
        } catch (DmlException dmle) {
            log.ASI_MFM_Error_Message__c+= dmle.getMessage();
            database.rollback(sp);
            
            
        } catch (Exception e) {
            log.ASI_MFM_Error_Message__c+=e.getMessage();
            database.rollback(sp);
            
        } 
        
        //PO Line
        
        try{
           
            
            Save_SAPL_POItem = new List <ASI_MFM_PO_Line_Item__c> () ;
            Save_SAPL_PAYItem = new List <ASI_MFM_Payment_Line_Item__c> () ; 
            for (integer i : SAPL_Item_Map.keySet())
            {
                ASI_MFM_EditSmallAmountPayment_Ctrl.SAPLineObj sapl = SAPL_Item_Map.get(i);
                ASI_MFM_PO_Line_Item__c poline = new ASI_MFM_PO_Line_Item__c();
                poline.ASI_MFM_PO__c = create_po.id;
                poline.ASI_MFM_AP_Code__c = sapl.pol.ASI_MFM_AP_Code__c ;
                poline.ASI_MFM_A_C_Code__c = sapl.pol.ASI_MFM_AP_Code__r.ASI_MFM_A_C_Code__c ;
                poline.ASI_MFM_Customer_Name__c = sapl.pol.ASI_MFM_Customer_Name__c;
                poline.ASI_MFM_Reference__c = sapl.pol.ASI_MFM_Reference__c;
                poline.ASI_MFM_Amount__c = sapl.pl.ASI_MFM_Payment_Amount__c ;
                poline.ASI_MFM_Distributor_Amount__c = sapl.pl.ASI_MFM_Payment_Amount_Distributor__c ;   system.debug('SB Code: ' + sapl.pol.ASI_MFM_Sub_brand_Code__c); system.debug('SB Al: ' + sapl.pol.ASI_MFM_Sub_brand_Allocation_Type__c);
                poline.ASI_MFM_Sub_brand_Code__c = sapl.pol.ASI_MFM_Sub_brand_Code__c ;
                poline.ASI_MFM_Sub_brand_Allocation_Type__c = sapl.pol.ASI_MFM_Sub_brand_Allocation_Type__c ;
                poline.ASI_MFM_List_Item_Description__c = sapl.pl.ASI_MFM_Payment_List_Item_Description__c ;
                poline.ASI_MFM_G_L_Date__c = System.Today();
                poline.ASI_MFM_Recharge__c = sapl.pol.ASI_MFM_Recharge__c ;
                poline.ASI_MFM_Receipt_Date__c = System.Today();
                // Added by 2017-12-28 Linus@introv
                poline.ASI_MFM_GF_VAT_Rate__c = sapl.pl.ASI_MFM_GF_VAT_Rate__c;
                
                ASI_MFM_Payment_Line_Item__c paline = new ASI_MFM_Payment_Line_Item__c();
                paline.ASI_MFM_Payment__c = create_pa.id;
                paline.ASI_MFM_Payee__c = create_pa.ASI_MFM_Supplier_Name__c ;
                paline.ASI_MFM_Payment_Amount__c = sapl.pl.ASI_MFM_Payment_Amount__c ;
                paline.ASI_MFM_Payment_Amount_Distributor__c = sapl.pl.ASI_MFM_Payment_Amount_Distributor__c ;
                paline.ASI_MFM_Payment_List_Item_Description__c = sapl.pl.ASI_MFM_Payment_List_Item_Description__c ;
                // Added by 2017-12-28 Linus@introv
                paline.ASI_MFM_GF_VAT_Rate__c = sapl.pl.ASI_MFM_GF_VAT_Rate__c;
                Save_SAPL_POItem.add(poline);
                Save_SAPL_PAYItem.add(paline);
                
              
                
                
            }
            insert Save_SAPL_POItem;
            
            
        } catch (DmlException dmle) {
            log.ASI_MFM_Error_Message__c+= dmle.getMessage();
            database.rollback(sp);
            
            
        } catch (Exception e) {
            log.ASI_MFM_Error_Message__c+=e.getMessage();
            database.rollback(sp);
            
        } 
        
        //Payment line
        
        try{
             List<ASI_MFM_PO_Receipt_Item__c> recLines = new List<ASI_MFM_PO_Receipt_Item__c>();
            for (Integer p = 0;p < Save_SAPL_POItem.size();p++)
            {
                Save_SAPL_PAYItem[p].ASI_MFM_PO_Line_Item__c = Save_SAPL_POItem[p].id;
                
                  ASI_MFM_PO_Receipt_Item__c recLine = new ASI_MFM_PO_Receipt_Item__c();
                
                recLine.ASI_MFM_PO_Receipt__c = rec.id;
                recLine.ASI_MFM_PO_Line_Item__c = Save_SAPL_POItem[p].id;
                recLine.ASI_MFM_PO__c = poid;
                recLine.ASI_MFM_Amount__c = Save_SAPL_POItem[p].ASI_MFM_Amount__c;
                recLine.recordTypeID = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Receipt_Item__cASI_MFM_GF_PO_Receipt_item');
                
                recLines.add(recLine);
            }
            insert recLines;
            
            insert Save_SAPL_PAYItem;
            
            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            req1.setObjectId(paid);
            req1.setSubmitterId(UserInfo.getUserId());
            System.debug('------ req1 ------ : ' + req1);
            Approval.ProcessResult result = Approval.process(req1);
            System.debug('------ result ------ : ' + result);  //Added by 2018-08-21 Linus@introv
            
            if (!result.isSuccess()){
                log.ASI_MFM_Error_Message__c+='Error: Record failed to submit for approval.';
            }
            
        } catch (DmlException dmle) {
            log.ASI_MFM_Error_Message__c+= dmle.getMessage();
            database.rollback(sp);
            
            
        } catch (Exception e) {
            log.ASI_MFM_Error_Message__c+=e.getMessage();
            database.rollback(sp);
            
        } 
        
        
    }
    
    public void finish(Database.BatchableContext BC)
    {
        if(log.ASI_MFM_Error_Message__c==''){
            log.ASI_MFM_Configuration__c=poid+'/'+paid;
            //log.ASI_MFM_Configuration__c='Payment Request has been created.<br/>Please click on the Link to view the Payment. <a href="/'+paid+'">View Payment</a>    ';
            log.ASI_MFM_Status__c='Success';
        }else{
            log.ASI_MFM_Status__c='Failed';
        }
        
        update log;
    }
    
}