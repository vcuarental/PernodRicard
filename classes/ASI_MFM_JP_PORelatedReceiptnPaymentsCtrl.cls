public with sharing class ASI_MFM_JP_PORelatedReceiptnPaymentsCtrl{
    
    public ApexPages.StandardController standardController {get;set;}
    public ASI_MFM_PO__c Header {get;set;}
    public static final string ASIMFMPOReceiptItemRdDevelopName = '';
    public static final string ASIMFMPaymentLineItemRTDevelopName = '';
    
    public Map<Id, List<ASI_MFM_PO_Receipt_Item__c>> POReceiptsLinesMap {set;get;}{ POReceiptsLinesMap = new Map<Id, List<ASI_MFM_PO_Receipt_Item__c>>(); }
    public Map<Id, ASI_MFM_PO_Receipt__c> POReciptMap {set;get;} { POReciptMap  = new Map<Id, ASI_MFM_PO_Receipt__c> ();} 
    
    public ASI_MFM_JP_PORelatedReceiptnPaymentsCtrl(){}
    public Class POReceipt{
        public ASI_MFM_PO_Receipt__c POReceipt {set;get;}
        public Decimal Amount                  {set;get;}
        public integer totalnum {set;get;}
        public integer BAVerifynum {set;get;}
        public integer Verifynum {set;get;}
        public Decimal Percent {set;get;}
        public Decimal BAPercent {set;get;}
        public List<ASI_MFM_PO_Receipt_Item__c> pori{set;get;}
        public POReceipt (ASI_MFM_PO_Receipt__c POReceipt , Decimal Amount){
            this.POReceipt = POReceipt;
            this.Amount = Amount;
        }
        public POReceipt (ASI_MFM_PO_Receipt__c POReceipt , Decimal Amount,integer totalnum,integer Verifynum,integer BAVerifynum,List<ASI_MFM_PO_Receipt_Item__c> pori){
            this.POReceipt = POReceipt;
            this.Amount = Amount;
            this.totalnum=totalnum;
            this.Verifynum=Verifynum;
            this.BAVerifynum=BAVerifynum;
            if(this.totalnum!=0 && this.totalnum !=null){
                this.Percent=((Decimal)Verifynum)/((Decimal)totalnum);
                this.BAPercent=((Decimal)BAVerifynum)/((Decimal)totalnum);
            }
            this.pori=pori;
        }
    } 
    
    public Class Payment{
        public ASI_MFM_Payment__c    Payment   {set;get;}
        public Decimal Amount                  {set;get;}
        public integer totalLinenum {set;get;}
        public integer FinVerifynum {set;get;}
        public integer ETLnum {set;get;}
        public Decimal Percent {set;get;}
        public Decimal ETLPercent {set;get;}
        public List<ASI_MFM_Payment_Line_Item__c> pali{set;get;}
        
        public Payment (ASI_MFM_Payment__c  Payment, Decimal Amount){
            this.Payment = Payment;
            this.Amount = Amount;
        }
        public Payment (ASI_MFM_Payment__c  Payment, Decimal Amount,integer totalLinenum,integer FinVerifynum,integer ETLnum,List<ASI_MFM_Payment_Line_Item__c> pali){
            this.Payment = Payment;
            this.Amount = Amount;
            this.totalLinenum = totalLinenum;
            this.FinVerifynum = FinVerifynum;
            this.ETLnum = ETLnum;
            this.pali=pali;
            if(this.totalLinenum!=null && this.totalLinenum!=0){
                this.Percent=((Decimal)FinVerifynum)/((Decimal)totalLinenum);
                this.ETLPercent=((Decimal)ETLnum)/((Decimal)totalLinenum);
            }
        }
    }    
    
    
    
    
    public Map<Id, List<ASI_MFM_Payment_Line_Item__c>> paymentlinesMap  {get; set;} { paymentlinesMap  = new Map<Id, List<ASI_MFM_Payment_Line_Item__c>> ();}
    public Map<Id, ASI_MFM_Payment__c> PaymentMap {set;get;} { PaymentMap  = new Map<Id, ASI_MFM_Payment__c> ();} 
    
    public List<POReceipt> POReceipts           {set;get;}      {POReceipts = new List<POReceipt>();}
    public List<Payment> Payments               {set;get;}      {Payments = new List<Payment>();}
    
    
    public ASI_MFM_JP_PORelatedReceiptnPaymentsCtrl(ApexPages.StandardController controller){
        this.standardController = controller;
        this.Header = (ASI_MFM_PO__c) this.standardController.getRecord();
        
        if(this.Header !=null && this.Header.Id !=null){
            
            for(ASI_MFM_PO__c po : [Select id FROM ASI_MFM_PO__c where Id =: this.Header.Id limit 1]){
                this.Header = po;
            }  
            
            initalize(); 
        }
        
    }
    
    
    
    public void initalize(){
        
        initalizePOReceiptsLines();
        initalizePOReceipts(); 
        initalizePaymentLines();
        initalizePayments();
    }
    
    public void initalizePOReceiptsLines(){
        
        List<ASI_MFM_PO_Receipt_Item__c> POReceiptItems = new List<ASI_MFM_PO_Receipt_Item__c>();
        
        
        if(this.Header !=null && this.Header.Id !=null){
            
            for(ASI_MFM_PO_Receipt_Item__c PORL : [Select id ,name,ASI_MFM_PO_Line_Item__c , ASI_MFM_PO__c ,ASI_MFM_Marketing_Verify__c,ASI_MFM_Receipt_Date__c,ASI_MFM_Remark__c,
                                                   ASI_MFM_Amount__c , ASI_MFM_PO_Receipt__r.ASI_MFM_Receipt_Date__c , ASI_MFM_PO_Receipt__c, ASI_MFM_ACC_Verify__c,ASI_MFM_PO_Receipt_Balance_Amount__c
                                                   from ASI_MFM_PO_Receipt_Item__c where ASI_MFM_PO__c =: this.Header.Id
                                                   Order by ASI_MFM_PO_Receipt__c])
            {
                POReceiptItems = POReceiptsLinesMap.get( PORL.ASI_MFM_PO_Receipt__c);
                if(POReceiptItems == null) POReceiptItems = new List<ASI_MFM_PO_Receipt_Item__c>();
                POReceiptItems.add(PORL);
                POReceiptsLinesMap.put(PORL.ASI_MFM_PO_Receipt__c, POReceiptItems);
            }
            
            for( ASI_MFM_PO_Receipt__c POR : [Select id , Name ,ASI_MFM_Receipt_Date__c,ASI_MFM_Status__c from ASI_MFM_PO_Receipt__c where Id IN: POReceiptsLinesMap.Keyset()]){
                POReciptMap.put(POR.Id, POR);
            }
            
            //system.debug('POReceiptItems'+POReceiptItems); System.assertEquals('Testing Data Now:'+POReceiptsLinesMap, null);
        }
    }
    
    
    public void initalizePOReceipts(){
        
        if(!POReceiptsLinesMap.isEmpty() && POReceiptsLinesMap.size()>0){
            for(Id  key : POReceiptsLinesMap.keyset()){
                Decimal Amount = 0;
                integer total=0;
                integer verfy=0;
                integer BAverfy=0;
                List<ASI_MFM_PO_Receipt_Item__c> POReceiptI = new List<ASI_MFM_PO_Receipt_Item__c>();
                for (ASI_MFM_PO_Receipt_Item__c por : POReceiptsLinesMap.get(key)){
                    if(por.ASI_MFM_Amount__c!=null){
                        Amount+= por.ASI_MFM_Amount__c;
                    }
                    
                    total++;
                    if(por.ASI_MFM_Marketing_Verify__c){
                        verfy++;
                    }
                    if(por.ASI_MFM_ACC_Verify__c){
                        BAverfy++;
                    }
                    POReceiptI.add(por);
                }
                
                POReceipts.add(new POReceipt(POReciptMap.get(Key), Amount,total,verfy,BAverfy,POReceiptI));
            }
            
        }
    }
    
    
    
    
    
    
    public void initalizePaymentLines(){
        
        List<ASI_MFM_Payment_Line_Item__c> PaymentItems = new List<ASI_MFM_Payment_Line_Item__c>();
        
        
        if(this.Header !=null && this.Header.Id !=null){
            
            for(ASI_MFM_Payment_Line_Item__c PI :[Select id ,name,ASI_MFM_Complete_POL__c, ASI_MFM_Payment_Amount__c,ASI_MFM_Payment__c,ASI_MFM_Payment_Line_Item_Finance_Verify__c,ASI_MFM_ETL_Date__c,ASI_MFM_ETL__c,ASI_MFM_Voucher_Created__c, ASI_MFM_Payment_List_Item_Description__c 
                                                  from 
                                                  ASI_MFM_Payment_Line_Item__c where ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__c =: this.Header.Id
                                                 ])
            {
                PaymentItems = paymentlinesMap.get( PI.ASI_MFM_Payment__c);
                if(PaymentItems == null)PaymentItems = new List<ASI_MFM_Payment_Line_Item__c>();
                PaymentItems.add(PI);
                paymentlinesMap.put(PI.ASI_MFM_Payment__c, PaymentItems);                        
            }
            
            for( ASI_MFM_Payment__c Pay : [Select id , Name,ASI_MFM_Invoice_Number__c , ASI_MFM_Currency__c,ASI_MFM_Invoice_Date__c, ASI_MFM_Invoice_Due_Date__c, ASI_MFM_G_L_Date__c, ASI_MFM_Status__c   from ASI_MFM_Payment__c where Id IN: paymentlinesMap.Keyset()]){
                PaymentMap.put(Pay.Id, Pay);
            }
            
            system.debug( PaymentItems);
        }
    }
    
    public void initalizePayments(){
        
        if(!paymentlinesMap.isEmpty() && paymentlinesMap.size()>0){
            for(Id  key : paymentlinesMap.keyset()){
                Decimal Amount = 0;
                integer total=0;
                integer ETLcheck=0;
                integer Finverfy=0;
                List<ASI_MFM_Payment_Line_Item__c> PaylineI = new List<ASI_MFM_Payment_Line_Item__c>();
                for (ASI_MFM_Payment_Line_Item__c pi : paymentlinesMap.get(key)){
                    if(pi.ASI_MFM_Payment_Amount__c!=null){
                        Amount+= pi.ASI_MFM_Payment_Amount__c;
                    }
                    
                    total++;
                    if(pi.ASI_MFM_Payment_Line_Item_Finance_Verify__c){
                        Finverfy++;
                            }
                    if(pi.ASI_MFM_ETL__c){
                        ETLcheck++;
                    }   
                    PaylineI.add(pi);
                }
                
                Payments.add(new Payment(PaymentMap.get(Key), Amount,total,Finverfy,ETLcheck,PaylineI));
            }
            
        }
    }
    
    
    
    
    
    
    
    
    /*
public List<ASI_MFM_Payment__c> payments {get; set;}
public List<ASI_MFM_Payment_Line_Item__c> paymentlineItem {get; set;}
public Class interimData{
public ASI_MFM_Payment__c py {get; set;}
public Decimal amount {get; set;} //Calculate related po
}
public List<interimData> results {get; set;}

public Boolean display {get; set;} 

public ASI_MFM_JP_PORelatedReceiptnPaymentsCtrl(ApexPages.StandardController controller){

Set<ID>paymentIDSet = new Set<ID>();
ASI_MFM_PO__c po = (ASI_MFM_PO__c) controller.getRecord();
paymentlineItem=[Select ASI_MFM_Payment__c,ASI_MFM_Payment_Amount__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__c, ASI_MFM_Payment__r.id from ASI_MFM_Payment_Line_Item__c where ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__c = :po.Id];

for (ASI_MFM_Payment_Line_Item__c paymentLine : paymentlineItem){
paymentIDSet.add(paymentLine.ASI_MFM_Payment__c);
}

payments = [select id,Name, ASI_MFM_Status__c, ASI_MFM_Currency__c, Owner.Name, ASI_MFM_Supplier_Name__r.Name, ASI_MFM_Payment_Amount__c from ASI_MFM_Payment__c where id = :paymentIDSet];
//this will display in page
results = new List<interimData>();
for(ASI_MFM_Payment__c pay:payments){
interimData temp= new interimData();
temp.py=pay;
temp.amount=0;
for(ASI_MFM_Payment_Line_Item__c pyl:paymentlineItem){
if(pyl.ASI_MFM_Payment__c==pay.id){
temp.amount=temp.amount+pyl.ASI_MFM_Payment_Amount__c;
}
}
results.add(temp);
}
if(results.size()>0){
display=true;
}else{
display=false;
}
}

*/
}