public with sharing class ASI_CRM_CN_AccountAdlRltListCtrl {
    private String accountId;

    public boolean isOutlet {set;get;}  
    public boolean isWholesaler {set;get;}

/*    
    public List<SubBrandVolume> subBrandVolumes {get;set;}
    public List<SubBrandTop5> top5Intakes {get;set;}
    public List<SubBrandTop5> top5Offtakes {get;set;}
    public List<SubBrandTop5> top5CapCollections {get;set;}
*/
    public Map<String,VolumeSummary> intakesMap {get;set;}
    public Map<String,VolumeSummary> depletionsMap {get;set;}
    public Map<String,VolumeSummary> inventoriesMap {get;set;}
    
    public Map<String,VolumeSummary> top10IntakesMap {get;set;}
    public Map<String,VolumeSummary> top10DepletionsMap {get;set;}
    public Map<String,VolumeSummary> top10CapCollectionsMap {get;set;}
    
    public ASI_CRM_CN_AccountAdlRltListCtrl (ApexPages.StandardController controller){
        ASI_CRM_AccountsAdditionalField__c accountAdditional = (ASI_CRM_AccountsAdditionalField__c)controller.getRecord();

        accountAdditional  = [SELECT id, ASI_CRM_Account__r.Id,RecordType.DeveloperName FROM ASI_CRM_AccountsAdditionalField__c WHERE Id = :accountAdditional.Id];
        
        this.accountId = accountAdditional.Id;
        //this.accountId = accountAdditional.ASI_CRM_Account__r.Id;
        //this.accountId = 'a8bM00000008P5i';
        //'a8bM00000008P5i';a8bM00000008OLEIA2        
        
        if(accountAdditional.RecordType.DeveloperName != null){
            isOutlet = accountAdditional.RecordType.DeveloperName == 'ASI_CRM_Outlet_CN';
            isWholesaler = accountAdditional.RecordType.DeveloperName == 'ASI_CRM_CN_WS';         
            System.debug('isOutlet:' + isOutlet + '. isWholesaler:' + isWholesaler);
            generateVolumeData();
        }              
    }
    
    public void generateVolumeData(){
        /*
        subBrandVolumes = new List<SubBrandVolume>();
        top5Intakes = new List<SubBrandTop5>();
        top5Offtakes = new List<SubBrandTop5>();
        top5CapCollections = new List<SubBrandTop5>();
        */
  
        
        Date tempDate = Date.today().addMonths(-2);
        Date fromDate = Date.newInstance(tempDate.year(), tempDate.month(),1);
        Date toDate = Date.newInstance(Date.today().year(), Date.today().month(),1);
        
        if(isWholesaler){
            intakesMap = new Map<String,VolumeSummary>();
            depletionsMap = new Map<String,VolumeSummary>();
            inventoriesMap = new Map<String,VolumeSummary>();           
        
            List<ASI_CRM_Subbrand_Volume__c> subBrandVolumeList = [SELECT ASI_CRM_Subbrand__r.Name,ASI_CRM_Year__c,ASI_CRM_Month__c,ASI_CRM_PR_Direct__c,ASI_CRM_T1_Depletion__c,ASI_CRM_T2_Depletion__c,ASI_CRM_Offtake__c,ASI_CRM_WS_INV__c,ASI_CRM_T1_DepletiontoT2__c,ASI_CRM_T2_DepletiontoT3__c,ASI_CRM_End_Date__c FROM ASI_CRM_Subbrand_Volume__c WHERE ASI_CRM_Account__c = :accountId AND ASI_CRM_End_Date__c >= :fromDate AND ASI_CRM_End_Date__c < :toDate ORDER BY ASI_CRM_Subbrand__c];
            
            for(ASI_CRM_Subbrand_Volume__c subBrandVolumeC : subBrandVolumeList){
                String subBrand = subBrandVolumeC.ASI_CRM_Subbrand__r.Name;
            
                VolumeSummary intake = null;
                VolumeSummary depletion = null;
                VolumeSummary inventory = null;
            
                if (intakesMap.get(subBrand) != null){
                    intake = (VolumeSummary)intakesMap.get(subBrand);
                }else{
                    intake = new VolumeSummary();
                    intake.subBrand = subBrand;
                }
                
                if (depletionsMap.get(subBrand) != null){
                    depletion = (VolumeSummary)depletionsMap.get(subBrand);
                }else{
                    depletion = new VolumeSummary();
                    depletion.subBrand = subBrand;
                }
                
                if (inventoriesMap.get(subBrand) != null){
                    inventory = (VolumeSummary)inventoriesMap.get(subBrand);
                }else{
                    inventory = new VolumeSummary();
                    inventory.subBrand = subBrand;
                }                
                
                if (subBrandVolumeC.ASI_CRM_End_Date__c.month() == tempDate.month()){
                    intake.last2ndMonthAmount = (subBrandVolumeC.ASI_CRM_PR_Direct__c != null?subBrandVolumeC.ASI_CRM_PR_Direct__c:0) + (subBrandVolumeC.ASI_CRM_T1_Depletion__c != null?subBrandVolumeC.ASI_CRM_T1_Depletion__c:0) + (subBrandVolumeC.ASI_CRM_T2_Depletion__c != null?subBrandVolumeC.ASI_CRM_T2_Depletion__c:0);
                    depletion.last2ndMonthAmount = (subBrandVolumeC.ASI_CRM_T1_DepletiontoT2__c != null?subBrandVolumeC.ASI_CRM_T1_DepletiontoT2__c:0) + (subBrandVolumeC.ASI_CRM_T2_DepletiontoT3__c != null?subBrandVolumeC.ASI_CRM_T2_DepletiontoT3__c:0);
                    inventory.last2ndMonthAmount = subBrandVolumeC.ASI_CRM_WS_INV__c != null?subBrandVolumeC.ASI_CRM_WS_INV__c:0;
                }else{
                    intake.lastMonthAmount = (subBrandVolumeC.ASI_CRM_PR_Direct__c != null?subBrandVolumeC.ASI_CRM_PR_Direct__c:0) + (subBrandVolumeC.ASI_CRM_T1_Depletion__c != null?subBrandVolumeC.ASI_CRM_T1_Depletion__c:0) + (subBrandVolumeC.ASI_CRM_T2_Depletion__c != null?subBrandVolumeC.ASI_CRM_T2_Depletion__c:0);
                    depletion.lastMonthAmount = (subBrandVolumeC.ASI_CRM_T1_DepletiontoT2__c != null?subBrandVolumeC.ASI_CRM_T1_DepletiontoT2__c:0) + (subBrandVolumeC.ASI_CRM_T2_DepletiontoT3__c != null?subBrandVolumeC.ASI_CRM_T2_DepletiontoT3__c:0);
                    inventory.lastMonthAmount = subBrandVolumeC.ASI_CRM_WS_INV__c != null?subBrandVolumeC.ASI_CRM_WS_INV__c:0;                    
                }
                
                intakesMap.put(subBrand,intake);
                depletionsMap.put(subBrand,depletion);
                inventoriesMap.put(subBrand,inventory);
                
                //subBrandVolumes.add(new SubBrandVolume(subBrandVolumeC));
            }
        }
        
        if(isOutlet){
            top10IntakesMap = new Map<String,VolumeSummary>();
            top10DepletionsMap = new Map<String,VolumeSummary>();
            top10CapCollectionsMap = new Map<String,VolumeSummary>();                   
        
            tempDate = Date.today().addMonths(-1);
            fromDate = Date.newInstance(tempDate.year(), tempDate.month(),1);
        
            List<ASI_CRM_Subbrand_Volume__c> subBrandIntakes = [SELECT ASI_CRM_Subbrand__r.Name,ASI_CRM_PR_Direct_Std__c,ASI_CRM_T1_Depletion_Std__c,ASI_CRM_T2_Depletion_Std__c FROM ASI_CRM_Subbrand_Volume__c WHERE ASI_CRM_Account__c = :accountId AND ASI_CRM_End_Date__c >= :fromDate AND ASI_CRM_End_Date__c < :toDate ORDER BY ASI_CRM_Subbrand__r.Name];
            ASI_CRM_Subbrand_Volume__c tempIntake;

            if (subBrandIntakes != null){                
                for(Integer i = 0; i < subBrandIntakes.size(); i++) {
                    for(Integer j = subBrandIntakes.size() - 1; j > i; j--) {
                        ASI_CRM_Subbrand_Volume__c subBrandIntake1 = (ASI_CRM_Subbrand_Volume__c) subBrandIntakes.get(j);
                        ASI_CRM_Subbrand_Volume__c subBrandIntake2 = (ASI_CRM_Subbrand_Volume__c) subBrandIntakes.get(j-1);
                        
                        Decimal direct1 = subBrandIntake1.ASI_CRM_PR_Direct_Std__c != null?subBrandIntake1.ASI_CRM_PR_Direct_Std__c:0;
                        Decimal depletion1 = subBrandIntake1.ASI_CRM_T1_Depletion_Std__c != null?subBrandIntake1.ASI_CRM_T1_Depletion_Std__c:0; 
                        Decimal shipment1 = subBrandIntake1.ASI_CRM_T2_Depletion_Std__c != null?subBrandIntake1.ASI_CRM_T2_Depletion_Std__c:0;
                        Decimal intake1 = direct1 + depletion1 + shipment1;
                        
                        Decimal direct2 = subBrandIntake2.ASI_CRM_PR_Direct_Std__c != null?subBrandIntake2.ASI_CRM_PR_Direct_Std__c:0;  
                        Decimal depletion2 = subBrandIntake2.ASI_CRM_T1_Depletion_Std__c != null?subBrandIntake2.ASI_CRM_T1_Depletion_Std__c:0;
                        Decimal shipment2 =  subBrandIntake2.ASI_CRM_T2_Depletion_Std__c != null?subBrandIntake2.ASI_CRM_T2_Depletion_Std__c:0;    
                        Decimal intake2 = direct2  + depletion2  + shipment2;
                        
                        if(intake1 > intake2){
                            tempIntake = subBrandIntakes.get(j);
                            subBrandIntakes.set(j,subBrandIntakes.get(j-1));  
                            subBrandIntakes.set(j-1,tempIntake);  
                        }
                    }
                }
                
                Integer len = subBrandIntakes.size() > 10 ? 10 : subBrandIntakes.size();
                for(Integer i = 0; i < len; i++) {
                    ASI_CRM_Subbrand_Volume__c subBrandIntake = (ASI_CRM_Subbrand_Volume__c) subBrandIntakes.get(i);
                
                    VolumeSummary intake = new VolumeSummary();
                    intake.subBrand = subBrandIntake.ASI_CRM_Subbrand__r.Name;            
                    //intake.lastMonthAmount = subBrandIntake.ASI_CRM_PR_Direct_Std__c != null?subBrandIntake.ASI_CRM_PR_Direct_Std__c:0 + subBrandIntake.ASI_CRM_T1_Depletion_Std__c != null?subBrandIntake.ASI_CRM_T1_Depletion_Std__c:0 + subBrandIntake.ASI_CRM_T2_Depletion_Std__c != null?subBrandIntake.ASI_CRM_T2_Depletion_Std__c:0;
                    Decimal direct = subBrandIntake.ASI_CRM_PR_Direct_Std__c != null?subBrandIntake.ASI_CRM_PR_Direct_Std__c:0;
                    Decimal depletion = subBrandIntake.ASI_CRM_T1_Depletion_Std__c != null?subBrandIntake.ASI_CRM_T1_Depletion_Std__c:0; 
                    Decimal shipment = subBrandIntake.ASI_CRM_T2_Depletion_Std__c != null?subBrandIntake.ASI_CRM_T2_Depletion_Std__c:0;                                   
                    intake.lastMonthAmount = direct + depletion + shipment;
                    
                    top10IntakesMap.put(intake.subBrand,intake);
                }               
            }        
            
            List<ASI_CRM_Subbrand_Volume__c> subBrandOfftakes = [SELECT ASI_CRM_Subbrand__r.Name,ASI_CRM_Offtake_Std__c FROM ASI_CRM_Subbrand_Volume__c WHERE ASI_CRM_Account__c = :accountId AND ASI_CRM_End_Date__c >= :fromDate AND ASI_CRM_End_Date__c < :toDate ORDER BY ASI_CRM_Offtake__c DESC,ASI_CRM_Subbrand__r.Name LIMIT 10];               
        
            for(ASI_CRM_Subbrand_Volume__c subBrandOfftake : subBrandOfftakes){
                VolumeSummary offTake = new VolumeSummary();
                offTake.subBrand = subBrandOfftake.ASI_CRM_Subbrand__r.Name;
                offTake.lastMonthAmount = subBrandOfftake.ASI_CRM_Offtake_Std__c != null?subBrandOfftake.ASI_CRM_Offtake_Std__c:0;        
                
                top10DepletionsMap.put(offTake.subBrand, offTake);
            }
            
            List<ASI_CRM_Subbrand_Volume__c> subBrandCapCollections = [SELECT ASI_CRM_Subbrand__r.Name,ASI_CRM_Green_Cap_Std__c FROM ASI_CRM_Subbrand_Volume__c WHERE ASI_CRM_Account__c = :accountId AND ASI_CRM_End_Date__c >= :fromDate AND ASI_CRM_End_Date__c < :toDate ORDER BY ASI_CRM_Green_Cap__c,ASI_CRM_Subbrand__r.Name DESC LIMIT 10];               
        
            for(ASI_CRM_Subbrand_Volume__c subBrandCapCollection : subBrandCapCollections){
                VolumeSummary capCollection = new VolumeSummary();
                capCollection.subBrand = subBrandCapCollection.ASI_CRM_Subbrand__r.Name;
                capCollection.lastMonthAmount = subBrandCapCollection.ASI_CRM_Green_Cap_Std__c != null?subBrandCapCollection.ASI_CRM_Green_Cap_Std__c:0;
                
                top10CapCollectionsMap.put(capCollection.subBrand,capCollection);
            }
            
            //Retrieve last 2nd month & last 3th month
            toDate = fromDate;
            tempDate = Date.today().addMonths(-3);
            fromDate = Date.newInstance(tempDate.year(), tempDate.month(),1);           
            
            subBrandIntakes = [SELECT ASI_CRM_Subbrand__r.Name,ASI_CRM_PR_Direct_Std__c,ASI_CRM_T1_Depletion_Std__c,ASI_CRM_T2_Depletion_Std__c,ASI_CRM_End_Date__c  FROM ASI_CRM_Subbrand_Volume__c WHERE ASI_CRM_Account__c = :accountId AND ASI_CRM_End_Date__c >= :fromDate AND ASI_CRM_End_Date__c < :toDate AND ASI_CRM_Subbrand__r.Name IN :top10IntakesMap.keySet() ORDER BY ASI_CRM_Subbrand__r.Name];            
        
            for(ASI_CRM_Subbrand_Volume__c subBrandIntake : subBrandIntakes ){
                VolumeSummary intake = (VolumeSummary) top10IntakesMap.get(subBrandIntake.ASI_CRM_Subbrand__r.Name);
                
                Decimal direct = subBrandIntake.ASI_CRM_PR_Direct_Std__c != null?subBrandIntake.ASI_CRM_PR_Direct_Std__c:0;
                Decimal depletion = subBrandIntake.ASI_CRM_T1_Depletion_Std__c != null?subBrandIntake.ASI_CRM_T1_Depletion_Std__c:0; 
                Decimal shipment = subBrandIntake.ASI_CRM_T2_Depletion_Std__c != null?subBrandIntake.ASI_CRM_T2_Depletion_Std__c:0;  
                
                if (subBrandIntake.ASI_CRM_End_Date__c.month() == tempDate.month()){
                    intake.last3thMonthAmount = direct + depletion + shipment;
                }else{
                    intake.last2ndMonthAmount = direct + depletion + shipment;
                }
                
                top10IntakesMap.put(intake.subBrand,intake); 
            }
            
            subBrandOfftakes = [SELECT ASI_CRM_Subbrand__r.Name,ASI_CRM_Offtake_Std__c,ASI_CRM_End_Date__c FROM ASI_CRM_Subbrand_Volume__c WHERE ASI_CRM_Account__c = :accountId AND ASI_CRM_End_Date__c >= :fromDate AND ASI_CRM_End_Date__c < :toDate AND ASI_CRM_Subbrand__r.Name IN :top10DepletionsMap.keySet() ORDER BY ASI_CRM_Offtake__c DESC,ASI_CRM_Subbrand__r.Name LIMIT 10];               
        
            for(ASI_CRM_Subbrand_Volume__c subBrandOfftake : subBrandOfftakes){
                VolumeSummary offTake = (VolumeSummary) top10DepletionsMap.get(subBrandOfftake.ASI_CRM_Subbrand__r.Name);
            
                if (subBrandOfftake.ASI_CRM_End_Date__c.month() == tempDate.month()){
                    offTake.last3thMonthAmount = subBrandOfftake.ASI_CRM_Offtake_Std__c != null?subBrandOfftake.ASI_CRM_Offtake_Std__c:0;        
                }else{
                    offTake.last2ndMonthAmount = subBrandOfftake.ASI_CRM_Offtake_Std__c != null?subBrandOfftake.ASI_CRM_Offtake_Std__c:0;        
                }
                
                top10DepletionsMap.put(offTake.subBrand, offTake);
            }
            
            subBrandCapCollections = [SELECT ASI_CRM_Subbrand__r.Name,ASI_CRM_Green_Cap_Std__c,ASI_CRM_End_Date__c  FROM ASI_CRM_Subbrand_Volume__c WHERE ASI_CRM_Account__c = :accountId AND ASI_CRM_End_Date__c >= :fromDate AND ASI_CRM_End_Date__c < :toDate AND ASI_CRM_Subbrand__r.Name IN :top10CapCollectionsMap.keySet() ORDER BY ASI_CRM_Green_Cap__c,ASI_CRM_Subbrand__r.Name DESC LIMIT 10];               
        
            for(ASI_CRM_Subbrand_Volume__c subBrandCapCollection : subBrandCapCollections){
                VolumeSummary capCollection = (VolumeSummary) top10CapCollectionsMap.get(subBrandCapCollection.ASI_CRM_Subbrand__r.Name);
                
                if (subBrandCapCollection.ASI_CRM_End_Date__c.month() == tempDate.month()){
                    capCollection.last3thMonthAmount = subBrandCapCollection.ASI_CRM_Green_Cap_Std__c != null?subBrandCapCollection.ASI_CRM_Green_Cap_Std__c:0;        
                }else{
                    capCollection.last2ndMonthAmount = subBrandCapCollection.ASI_CRM_Green_Cap_Std__c != null?subBrandCapCollection.ASI_CRM_Green_Cap_Std__c:0;        
                }
                
                top10CapCollectionsMap.put(capCollection.subBrand,capCollection);
            }            
        }
    }
/*        
        if(isOutlet){
            AggregateResult[] subBrandIntakes = [SELECT ASI_CRM_Subbrand__r.Name subBrand,SUM(ASI_CRM_PR_Direct__c) direct, SUM(ASI_CRM_T1_Depletion__c) depletion,SUM(ASI_CRM_T2_Depletion__c) shipment FROM ASI_CRM_Subbrand_Volume__c WHERE ASI_CRM_Account__c = :accountId AND ASI_CRM_End_Date__c >= :fromDate AND ASI_CRM_End_Date__c < :toDate GROUP BY ASI_CRM_Subbrand__r.Name];
            AggregateResult tempIntake;

            for(Integer i = 0; i < subBrandIntakes.size(); i++) {
                for(Integer j = subBrandIntakes.size() - 1; j > i; j--) {
                    Decimal intake1 = Decimal.valueOf(String.valueOf(subBrandIntakes[j].get('direct') != null?subBrandIntakes[j].get('direct'):'0')) + Decimal.valueOf(String.valueOf(subBrandIntakes[j].get('depletion') != null?subBrandIntakes[j].get('depletion'):'0')) + Decimal.valueOf(String.valueOf(subBrandIntakes[j].get('shipment') != null?subBrandIntakes[j].get('shipment'):'0'));
                    Decimal intake2 = Decimal.valueOf(String.valueOf(subBrandIntakes[j-1].get('direct') != null?subBrandIntakes[j-1].get('direct'):'0')) + Decimal.valueOf(String.valueOf(subBrandIntakes[j-1].get('depletion') != null?subBrandIntakes[j-1].get('depletion'):'0')) + Decimal.valueOf(String.valueOf(subBrandIntakes[j-1].get('shipment') != null?subBrandIntakes[j-1].get('shipment'):'0'));
                    
                    if(intake1 > intake2){
                        tempIntake = subBrandIntakes[j];
                        subBrandIntakes[j] = subBrandIntakes[j-1];  
                        subBrandIntakes[j-1] = tempIntake;  
                    }
                }
            }
            
            Integer len = subBrandIntakes.size() > 5 ? 5: subBrandIntakes.size();
            for(Integer i = 0; i < len; i++) {
                Decimal intake = Decimal.valueOf(String.valueOf(subBrandIntakes[i].get('direct') != null?subBrandIntakes[i].get('direct'):'0')) + Decimal.valueOf(String.valueOf(subBrandIntakes[i].get('depletion') != null?subBrandIntakes[i].get('depletion'):'0')) + Decimal.valueOf(String.valueOf(subBrandIntakes[i].get('shipment') != null?subBrandIntakes[i].get('shipment'):'0'));
                top5Intakes.add(new SubBrandTop5(String.valueOf(subBrandIntakes[i].get('subBrand')),intake));
            }
            
            AggregateResult[] subBrandOfftakes = [SELECT ASI_CRM_Subbrand__r.Name subBrand,SUM(ASI_CRM_Offtake__c) offtake FROM ASI_CRM_Subbrand_Volume__c WHERE ASI_CRM_Account__c = :accountId AND ASI_CRM_End_Date__c >= :fromDate AND ASI_CRM_End_Date__c < :toDate GROUP BY ASI_CRM_Subbrand__r.Name ORDER BY SUM(ASI_CRM_Offtake__c) DESC LIMIT 5];               
        
            for(AggregateResult subBrandOfftake : subBrandOfftakes){
                top5Offtakes.add(new SubBrandTop5(String.valueOf(subBrandOfftake.get('subBrand')),Decimal.valueOf(String.valueOf(subBrandOfftake.get('offtake') != null?subBrandOfftake.get('offtake'):'0'))));
            }
            
            AggregateResult[] subBrandCapCollections = [SELECT ASI_CRM_Subbrand__r.Name subBrand,SUM(ASI_CRM_Green_Cap__c) greenCap FROM ASI_CRM_Subbrand_Volume__c WHERE ASI_CRM_Account__c = :accountId AND ASI_CRM_End_Date__c >= :fromDate AND ASI_CRM_End_Date__c < :toDate GROUP BY ASI_CRM_Subbrand__r.Name ORDER BY SUM(ASI_CRM_Green_Cap__c) DESC LIMIT 5];               
        
            for(AggregateResult subBrandCapCollection : subBrandCapCollections){
                top5CapCollections.add(new SubBrandTop5(String.valueOf(subBrandCapCollection.get('subBrand')),Decimal.valueOf(String.valueOf(subBrandCapCollection.get('greenCap') != null?subBrandCapCollection.get('greenCap'):'0'))));
            }
        }                
    }
  
    public class SubBrandVolume{
        public ASI_CRM_Subbrand_Volume__c orgVolume {get; set;}
        
        public Decimal Intake{
            get{
               return (orgVolume.ASI_CRM_PR_Direct__c != null?orgVolume.ASI_CRM_PR_Direct__c:0) + (orgVolume.ASI_CRM_T1_Depletion__c != null?orgVolume.ASI_CRM_T1_Depletion__c:0) + (orgVolume .ASI_CRM_T2_Depletion__c != null?orgVolume .ASI_CRM_T2_Depletion__c:0);
            }
        }
        
        public Decimal Depletion{
            get{
               return (orgVolume.ASI_CRM_T1_DepletiontoT2__c != null?orgVolume.ASI_CRM_T1_DepletiontoT2__c:0) + (orgVolume .ASI_CRM_T2_DepletiontoT3__c != null?orgVolume .ASI_CRM_T2_DepletiontoT3__c:0);
            }
        }        
        
        public SubBrandVolume(ASI_CRM_Subbrand_Volume__c orgVolume){
            this.orgVolume = orgVolume;
        }
    }
*/    
    public class VolumeSummary{
        public String subBrand {get; set;}
        public Decimal lastMonthAmount {get; set;}
        public Decimal last2ndMonthAmount {get; set;}
        public Decimal last3thMonthAmount {get; set;}    
    }
}