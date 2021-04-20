public class ASI_MFM_KR_DirectPaymentUploadCtrl {
    public ASI_MFM_Payment__c header {get;set;} {header = new ASI_MFM_Payment__c(recordTypeId=Global_RecordTypeCache.getRTId('ASI_MFM_Payment__cASI_MFM_KR_Payment')); }
    
    ASI_MFM_Plan__c Plan =new ASI_MFM_Plan__c ();
    
    public String Msg {get;set;} {Msg='';}
    public String CurrencyName {get;set;} 
    public double exchangeRate {get;set;} {exchangeRate= 1;} 
    public Boolean isRedirect {set; get;}
    public boolean UpsertPermission {get;set;} 
    
    public ASI_MFM_KR_DirectPaymentUploadCtrl(apexpages.standardController sc){
        Id recordId; 
        Boolean IsProcess= false;
        UpsertPermission=true;
        isRedirect=true;
        if(sc.getId()!=NULL){
            recordId=sc.getId();
            Plan = [select Id,Name  from ASI_MFM_Plan__c where id = :sc.getId()];
            List<ASI_MFM_Plan_Line_Item__c> PlanLine = [select Id,name,ASI_MFM_PRPO_Needed__c from ASI_MFM_Plan_Line_Item__c where ASI_MFM_Plan__c=:Plan.ID ];
            //Check if need to create Direct Payment
            for(ASI_MFM_Plan_Line_Item__c pl: PlanLine){
                if(!pl.ASI_MFM_PRPO_Needed__c){
                    IsProcess=true;
                }
            }
            if(PlanLine.size()==0){
                UpsertPermission=false;
                isRedirect=false;
                Msg+='We found that you have not created Plan Line. Currently,  Direct Payment Upload will be available after Plan Line Details are entered correctly. Please add Plan Line Details by using Manage All button.';
            }
            
            if(!IsProcess){
                UpsertPermission=false;
                isRedirect=false;
                Msg+='No need to create Direct Payment in this Plan.';
            }
            
            header = new ASI_MFM_Payment__c(ASI_MFM_Plan__c=Plan.Id);
        }
        
    }
    
    
    
    @RemoteAction
    public static Map<String, Decimal> retrieveExchangeRate(){
        Map<String, Decimal> exchangeRateTable = new  Map<String, Decimal>();
        string country = 'KR';
        Map<String, String> CurrencyEffectiveMap = new Map<String, String>();
        List<String> availableCurrency = new List<String> { 'KRW', 'AUD', 'EUR', 'GBP', 'HKD' ,'SGD' ,'USD'};
            
            AggregateResult[] CurrencyEffective =[Select ASI_MFM_Counter_Currency__c , Id, MAX(ASI_MFM_Effective_Date__c) from ASI_MFM_Exchange_Rate__c 
                                                  where ASI_MFM_Application__c = 'MFM' and ASI_MFM_Country__c = : country
                                                  and ASI_MFM_Base_Currency__c ='KRW' and ASI_MFM_Effective_Date__c <= :date.today()  
                                                  and (ASI_MFM_Counter_Currency__c in: availableCurrency) group by ASI_MFM_Counter_Currency__c, Id];
        
        //extract currency and id from CurrencyEffective to CurrencyEffectiveMap
        if(CurrencyEffective!=null){
            for(AggregateResult ar : CurrencyEffective){ 
                CurrencyEffectiveMap.put(String.ValueOf(ar.get('ASI_MFM_Counter_Currency__c')), String.ValueOf(ar.get('Id')));
            }
        }
        //store currency, exchange rate to a list called exchangeRates
        List<ASI_MFM_Exchange_Rate__c> exchangeRates = new List<ASI_MFM_Exchange_Rate__c>();
        
        exchangeRates =   [Select ASI_MFM_Counter_Currency__c, ASI_MFM_Exchange_Rate__c from ASI_MFM_Exchange_Rate__c  where id in: CurrencyEffectiveMap.values()];
        
        //if there is record in exchangeRate list, records will be inserted into exchangeRateTable which is a Map
        if(exchangeRates!=null && exchangeRates.size()>0){
            
            for(ASI_MFM_Exchange_Rate__c ae : exchangeRates){
                exchangeRateTable.put(ae.ASI_MFM_Counter_Currency__c, ae.ASI_MFM_Exchange_Rate__c);
            }
            system.debug('exchangeRateTable :' + exchangeRateTable);       
        }
        
        return exchangeRateTable;
    }
    
    //********************************************End : RemoteAction**************************************************************
    
    
    
}