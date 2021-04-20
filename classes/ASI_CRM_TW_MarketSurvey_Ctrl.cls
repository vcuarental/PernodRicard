public with sharing class ASI_CRM_TW_MarketSurvey_Ctrl {
    public MarketSurveyPage marketSurveyPage { get; set; }
    
    public String accountId {get; set;}
    public String channelCode {get; set;}
    public String accountName {get;set;}
    
    private List<ASI_CRM_OutletDepletion__c> outletDepletions;

    public ASI_CRM_TW_MarketSurvey_Ctrl (ApexPages.StandardController controller) {
        marketSurveyPage = new MarketSurveyPage ();
        
        accountId = ApexPages.currentPage().getParameters().get('accountId');
        //accountOutlet = [SELECT Id,Name FROM ACCOUNT WHERE Id = :accountId];
        
        channelCode = ApexPages.currentPage().getParameters().get('channelCode');
        
        search();      
    }
    
    public void search(){
        String querySoql = 'SELECT ASI_CRM_Date__c,  ASI_CRM_Depletion__c, ASI_CRM_Outlet__r.Id,ASI_CRM_Outlet__r.Name, Name, OwnerId, Id, RecordTypeId, ASI_CRM_SubBrand__r.Id, ASI_CRM_SubBrand__r.Name FROM ASI_CRM_OutletDepletion__c WHERE ASI_CRM_Date__c = LAST_MONTH AND ASI_CRM_Outlet__r.Id = :accountId';
        
        accountName = [SELECT Id, Name FROM Account WHERE Id = :accountId limit 1].Name;
    
        String channelChecking = '';
        
        if('TOT'.equals(channelCode)){
            channelChecking = 'ASI_CRM_TW_TOT__c = True';
        }else if ('LS'.equals(channelCode)){
            channelChecking = 'ASI_CRM_TW_LS__c = True';
        }else if ('HBR'.equals(channelCode)){
            channelChecking = 'ASI_CRM_TW_HBR__c = True';
        } else if ('CR'.equals(channelCode)){
            channelChecking = 'ASI_CRM_TW_CR__c = True';
        } else if ('CVS'.equals(channelCode)){
            channelChecking = 'ASI_CRM_TW_CVS__c = True';
        } else if ('HYP'.equals(channelCode)){
            channelChecking = 'ASI_CRM_TW_HYPER__c = True';
        } else if ('SUP'.equals(channelCode)){
            channelChecking = 'ASI_CRM_TW_SUPER__c = True';
        }
        
        
        if(!''.equals(channelChecking)){
            querySoql = querySoql + ' AND ASI_CRM_SubBrand__r.' + channelChecking; 
        }
         
        outletDepletions = Database.query(querySoql);   
    
        List<ASI_MFM_Sub_brand__c> subBrands = Database.query('SELECT Id, Name, ASI_CRM_TW_Company__c,ASI_CRM_TW_Sequence_Company__c,ASI_CRM_TW_Sequence_Sub_brand__c FROM ASI_MFM_Sub_brand__c WHERE ' + channelChecking  + ' ORDER BY ASI_CRM_TW_Sequence_Company__c,ASI_CRM_TW_Sequence_Sub_brand__c');
    
        marketSurveyPage.marketSurveyMap = new Map<String,List<MarketSurvey>>();
        marketSurveyPage.companyMarketSurveySizeMap = new Map<String,Integer>();
        marketSurveyPage.marketCompanies = new List<MarketCompany>();
        
        String company = '';
        Integer index = 0;
        
        for(ASI_MFM_Sub_brand__c subBrand : subBrands){
            MarketSurvey marketSurvey = new MarketSurvey();           
            
            marketSurvey.company = subBrand.ASI_CRM_TW_Company__c;
            marketSurvey.subBrand = subBrand.Name;
            marketSurvey.subBrandId = subBrand.Id;
            for(ASI_CRM_OutletDepletion__c outletDepletion : outletDepletions){
                if(subBrand.Name.equals(outletDepletion.ASI_CRM_SubBrand__r.Name)){
                   marketSurvey.depletion = outletDepletion.ASI_CRM_Depletion__c;
                   break;
                }
            }

            if(company != marketSurvey.company){
                index = 0;
                company = marketSurvey.company;
            }
            
            marketSurvey.index = ++index;            
            marketSurveyPage.companyMarketSurveySizeMap.put(marketSurvey.company,index);           
            
            List<MarketSurvey> marketSurveys = marketSurveyPage.marketSurveyMap.get(marketSurvey.company);
            if(marketSurveys == null){
                marketSurveys = new List<MarketSurvey>();
                marketSurveyPage.marketCompanies.add(new MarketCompany(subBrand.ASI_CRM_TW_Company__c,subBrand.ASI_CRM_TW_Sequence_Company__c));
            }
            marketSurveys.add(marketSurvey);
            
            marketSurveyPage.marketSurveyMap.put(marketSurvey.company,marketSurveys);
            
            
        }

        for(String key : marketSurveyPage.companyMarketSurveySizeMap.keySet()){
            Integer rows = marketSurveyPage.companyMarketSurveySizeMap.get(key);
            
            rows = rows / 4 + (Math.mod(rows,4)>0?1:0);
            
            marketSurveyPage.companyMarketSurveySizeMap.put(key,rows);
        }

        marketSurveyPage.marketCompanies.sort();
    }
    
    public void save(){
        List<ASI_CRM_OutletDepletion__c> newOutletDepletions = new  List<ASI_CRM_OutletDepletion__c>();
        
        ASI_CRM_AccountsAdditionalField__c customer = [SELECT Id, Name FROM ASI_CRM_AccountsAdditionalField__c WHERE ASI_CRM_Account__c = :accountId];
        
        for(String key : marketSurveyPage.marketSurveyMap.keySet()){
            List<MarketSurvey> marketSurveys = marketSurveyPage.marketSurveyMap.get(key);
            
            for(MarketSurvey marketSurvey : marketSurveys ){
                boolean isNew = true;
                for(ASI_CRM_OutletDepletion__c outletDepletion : outletDepletions){
                    if(marketSurvey.subBrand.equals(outletDepletion.ASI_CRM_SubBrand__r.Name)){
                        outletDepletion.ASI_CRM_Depletion__c = marketSurvey.depletion;
                        outletDepletion.ASI_CRM_AccountsAdditionalField__c = customer.Id;
                        isNew = false;
                        break;
                    }
                }
                
                if(isNew){
                    ASI_CRM_OutletDepletion__c  outletDepletion = new ASI_CRM_OutletDepletion__c();
                    outletDepletion.ASI_CRM_Date__c = Date.today().addMonths(-1);
                    outletDepletion.ASI_CRM_Outlet__c = accountId;
                    outletDepletion.ASI_CRM_AccountsAdditionalField__c = customer.Id;
                    outletDepletion.ASI_CRM_SubBrand__c = marketSurvey.subBrandId;
                    outletDepletion.ASI_CRM_Depletion__c = marketSurvey.depletion;
                    
                    newOutletDepletions.add(outletDepletion);
                }
            }
        }
        
        update outletDepletions;
        insert newOutletDepletions;
        
        search();
    }
    
    public class MarketSurveyPage{
        public String yearMonth { get; set; }
        public Map<String,List<MarketSurvey>> marketSurveyMap { get; set; }       
        public Map<String,Integer> companyMarketSurveySizeMap { get; set;}
        public List<MarketCompany> marketCompanies {get; set;}
    }
    
    public class MarketSurvey{
        public String company {get; set;}
        public String subBrand {get; set;}
        public String subBrandId {get; set;}
        public Decimal depletion {get; set;}
        public Integer index {get; set;}
    }
    
    public class MarketCompany implements Comparable{
        public String company {get; set;} 
        public Decimal seq { get; set;}
        
        public MarketCompany(String company, Decimal seq){
            this.company = company;
            this.seq = seq;
        }
        
        public Integer compareTo(Object compareTo) {
            MarketCompany compareToMc = (MarketCompany)compareTo;
            if (seq == compareToMc.seq) return 0;
            if (seq > compareToMc.seq) return 1;
            return -1;        
        }
    }  
}