public class ASI_MFM_PH_PORelatedPaymentsController {
    public List<ASI_MFM_Payment__c> payments {get; set;}
     public List<ASI_MFM_Payment_Line_Item__c> paymentlineItem {get; set;}
    public Class interimData{
        public ASI_MFM_Payment__c py {get; set;}
        public Decimal amount {get; set;} //Calculate related po
        public integer totalLinenum {set;get;}
        public integer FinVerifynum {set;get;}
        public integer ETLnum {set;get;}
        public Decimal Percent {set;get;}
        public Decimal ETLPercent {set;get;}
        public List<ASI_MFM_Payment_Line_Item__c> pali{set;get;}
        
        public interimData (){
       
        }
            
        public interimData (ASI_MFM_Payment__c  Payment, Decimal Amount){
            this.py  = Payment;
            this.Amount = Amount;
        }
        
        public interimData (ASI_MFM_Payment__c  Payment, Decimal Amount,integer totalLinenum,integer FinVerifynum,integer ETLnum,List<ASI_MFM_Payment_Line_Item__c> pali){
            this.py = Payment;
            this.amount = Amount;
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
    public List<interimData> results {get; set;}
    
    public Boolean display {get; set;} 
    
    public ASI_MFM_PH_PORelatedPaymentsController(ApexPages.StandardController controller){
    
        Set<ID>paymentIDSet = new Set<ID>();
        ASI_MFM_PO__c po = (ASI_MFM_PO__c) controller.getRecord();
        paymentlineItem=[Select Name, ASI_MFM_Payment_List_Item_Description__c,ASI_MFM_AP_Remark__c, ASI_MFM_Payment__c,ASI_MFM_Payment_Amount__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__c, ASI_MFM_Payment__r.id, ASI_MFM_Payment_Line_Item_Finance_Verify__c, ASI_MFM_ETL__c ,ASI_MFM_ETL_Date__c from ASI_MFM_Payment_Line_Item__c where ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__c = :po.Id];
            
        for (ASI_MFM_Payment_Line_Item__c paymentLine : paymentlineItem){
            paymentIDSet.add(paymentLine.ASI_MFM_Payment__c);
        }
        
        payments = [select id,Name, ASI_MFM_Status__c, ASI_MFM_Currency__c, Owner.Name, ASI_MFM_Supplier_Name__r.Name, ASI_MFM_Payment_Amount__c from ASI_MFM_Payment__c where id = :paymentIDSet];
        //this will display in page
        results = new List<interimData>();
        for(ASI_MFM_Payment__c pay:payments){
            interimData temp= new interimData();
                Decimal Amount = 0;
                integer total=0;
                integer ETLcheck=0;
                integer Finverfy=0;
                
                temp.py=pay;
                temp.amount=0;
                List<ASI_MFM_Payment_Line_Item__c> PaylineI = new List<ASI_MFM_Payment_Line_Item__c>();
                
               for(ASI_MFM_Payment_Line_Item__c pyl:paymentlineItem){
                   if(pyl.ASI_MFM_Payment__c==pay.id){
                       temp.amount=temp.amount+pyl.ASI_MFM_Payment_Amount__c;
                       
                       if(pyl.ASI_MFM_Payment_Line_Item_Finance_Verify__c){
                           Finverfy++;
                       }
                       if(pyl.ASI_MFM_ETL__c){
                           ETLcheck++;
                       }                        
                       total++;
                       PaylineI.add(pyl);
                   }
                   
               }
            
            results.add(new  interimData(temp.py, temp.amount,total,Finverfy,ETLcheck,PaylineI));
            
            //results.add(temp);
        }
        if(results.size()>0){
            display=true;
        }else{
            display=false;
        }
    }
}