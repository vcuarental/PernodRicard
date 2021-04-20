public with sharing class ASI_CRM_CN_AccountChartCtrl {
    public boolean isOutlet {set;get;}  
    public boolean isWholesaler {set;get;}
    
    public List<Data> dashboardData1 {set;get;}
    public List<Data> dashboardData2 {set;get;}
    
    public ASI_CRM_CN_AccountChartCtrl(ApexPages.StandardController controller){
        Account account = (Account)controller.getRecord();
        
        if(account.RecordTypeId != null){
            RecordType recordType = [SELECT DeveloperName, id FROM RecordType WHERE id = :account.RecordTypeId];
            
            isOutlet = recordType.DeveloperName == 'ASI_MFM_CN_Outlet';
            isWholesaler = recordType.DeveloperName == 'ASI_CRM_CN_Wholesales_CN';         
            
            generateDashboardData();
        }              
    }
    
    public void generateDashboardData() {
        dashboardData1 = new List<Data>();
        dashboardData2 = new List<Data>();
        
        Date tempDate = Date.today().addMonths(-6);
        Date fromDate = Date.newInstance(tempDate.year(), tempDate.month(),1);
        Date toDate = Date.newInstance(Date.today().year(), Date.today().month(),1);
        
        List<AggregateResult> subBrandVolumes = [SELECT ASI_CRM_Year__c year,ASI_CRM_Month__c month,SUM(ASI_CRM_PR_Direct__c) direct, SUM(ASI_CRM_T1_Depletion_GS__c) depletion,SUM(ASI_CRM_PR_SHIPMENT__c) shipment FROM ASI_CRM_Subbrand_Volume__c WHERE ASI_CRM_End_Date__c >= :fromDate AND ASI_CRM_End_Date__c < :toDate GROUP BY ASI_CRM_Year__c,ASI_CRM_Month__c];
        
        for(AggregateResult subBrandVolume : subBrandVolumes){             
            String month = String.valueOf(subBrandVolume.get('year')) + '-' + String.valueOf(subBrandVolume.get('month'));
            Decimal data = Decimal.valueOf(String.valueOf(subBrandVolume.get('direct'))) + Decimal.valueOf(String.valueOf(subBrandVolume.get('depletion'))) + Decimal.valueOf(String.valueOf(subBrandVolume.get('shipment')));    
            
            dashboardData1.add(new Data(month,data));
        }
        
        if(isOutlet){
            List<AggregateResult> subBrandOfftakes = [SELECT ASI_CRM_Year__c year,ASI_CRM_Month__c month,SUM(ASI_CRM_Offtake__c) offtake FROM ASI_CRM_Subbrand_Volume__c WHERE ASI_CRM_End_Date__c >= :fromDate AND ASI_CRM_End_Date__c < :toDate GROUP BY ASI_CRM_Year__c,ASI_CRM_Month__c ];
        
            for(AggregateResult subBrandOfftake : subBrandOfftakes){             
                String month = String.valueOf(subBrandOfftake.get('year')) + '-' + String.valueOf(subBrandOfftake.get('month'));
                Decimal data = Decimal.valueOf(String.valueOf(subBrandOfftake.get('offtake')));    
                
                dashboardData2.add(new Data(month,data));
            }       
        }
        
        if(isWholesaler){
            List<AggregateResult> invHistoryVolumes = [SELECT ASI_CRM_Year__c year,ASI_CRM_Month__c month, SUM(ASI_CRM_Volume__c) volume FROM ASI_CRM_WS_Inv_History__c WHERE ASI_CRM_End_Date__c >= :fromDate AND ASI_CRM_End_Date__c < :toDate GROUP BY ASI_CRM_Year__c,ASI_CRM_Month__c];
        
            for(AggregateResult invHistoryVolume : invHistoryVolumes){             
                String month = String.valueOf(invHistoryVolume.get('year')) + '-' + String.valueOf(invHistoryVolume.get('month'));
                Decimal data = Decimal.valueOf(String.valueOf(invHistoryVolume.get('volume')));    
                
                dashboardData2.add(new Data(month,data));
            }       
        }       
    }

    public class Data {
        public String month { get; set; }
        public Decimal data { get; set; }

        public Data(String month, Decimal data) {
            this.month = month;
            this.data = data;
        }
    }
}