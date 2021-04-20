/*Filename:    ASI_CRM_TW_CapCollection_Ctrl.cls
* Author:      Clone from ASI_CRM_TW_MarketSurvey_Ctrl
* Modified By: Twinkle LI (Introv Limited)
* Purpose:     Controller Class for Cap Collection input for current month - TW CRM
*
* History
* -----------------------------------------------------------------------------
*/
public with sharing class ASI_CRM_TW_CapCollection_Ctrl {
    public MarketSurveyPage marketSurveyPage { get; set; }
    
    public String accountId {get; set;}
    public String channelCode {get; set;}
    public String vpid {get; set;}
    public String accountName {get;set;}
    public String userLanguage {set; get;}
    
    private List<ASI_CRM_OutletDepletion__c> outletDepletions;

    public ASI_CRM_TW_CapCollection_Ctrl (ApexPages.StandardController controller) {
        marketSurveyPage = new MarketSurveyPage ();
        
        accountId = ApexPages.currentPage().getParameters().get('accountId');
        channelCode = ApexPages.currentPage().getParameters().get('channelCode');
        vpid = ApexPages.currentPage().getParameters().get('vpid');
        
        if (string.isBlank(accountId) || string.isBlank(vpid)) {
            showPageError('Invalid Parameters!');
            return;
        }
        
        search();      
    }
    
    public void search(){
        userLanguage = UserInfo.getLanguage();
        
        Id RecordTypeId = Global_RecordTypeCache.getRTId('ASI_CRM_OutletDepletion__cASI_CRM_TW_OutletDepletion_RcrdTyp');
        String querySoql = 'SELECT ASI_CRM_Date__c,  ASI_CRM_Bottle_Head__c, ASI_CRM_Outlet__r.Id,ASI_CRM_Outlet__r.Name, Name, OwnerId, Id, RecordTypeId, ASI_CRM_SubBrand__r.Id, ASI_CRM_SubBrand__r.Name FROM ASI_CRM_OutletDepletion__c WHERE RecordTypeId ='+ '\'' +RecordTypeId+ '\'' + 'AND ASI_CRM_Outlet__r.Id = :accountId AND ASI_CRM_VisitationPlanDetail__c = :vpid';
        Account acc = [SELECT Id, Name FROM Account WHERE Id = :accountId limit 1];
        if(acc != null)
            accountName = acc.Name;
        else
            accountName = 'Account Name Unavailable';
    
        String channelChecking = '';
        
        if('TOT'.equals(channelCode)){
            channelChecking = 'ASI_CRM_TW_TOT__c = True';
        }else if ('LS'.equals(channelCode)){
            channelChecking = 'ASI_CRM_TW_LS__c = True';
        }else if ('HBR'.equals(channelCode)){
            channelChecking = 'ASI_CRM_TW_HBR__c = True';
        } else if ('CR'.equals(channelCode)){
            channelChecking = 'ASI_CRM_TW_CR__c = True';
        }
        
        if(!''.equals(channelChecking)){
            querySoql = querySoql + ' AND ASI_CRM_SubBrand__r.' + channelChecking; 
        }        
        querySoql = querySoql + ' FOR UPDATE';
         
        outletDepletions = Database.query(querySoql);   
    
        //get total
        Map<string, decimal> mapTotal = new Map<string, decimal>();
        String sQueryTotalSoql = 'SELECT ASI_CRM_SubBrand__r.Name SubBrandName, SUM(ASI_CRM_Bottle_Head__c) TotalBottle FROM ASI_CRM_OutletDepletion__c WHERE RecordTypeId ='+ '\'' +RecordTypeId+ '\'' + 'AND ASI_CRM_Date__c = THIS_MONTH AND ASI_CRM_Outlet__r.Id = :accountId AND ASI_CRM_VisitationPlanDetail__c != NULL';
        if(!''.equals(channelChecking)){
            sQueryTotalSoql = sQueryTotalSoql + ' AND ASI_CRM_SubBrand__r.' + channelChecking; 
        }        
        sQueryTotalSoql = sQueryTotalSoql + ' GROUP BY ASI_CRM_SubBrand__r.Name';
        List<AggregateResult> oAggreResult = Database.query(sQueryTotalSoql);
        for (AggregateResult ar : oAggreResult)  {
            string sTmpSubBrandName = (string)ar.get('SubBrandName');
            decimal dTmpTotalBottle = (decimal)ar.get('TotalBottle');
            if (dTmpTotalBottle == null)
                dTmpTotalBottle = 0;
            else
                dTmpTotalBottle = dTmpTotalBottle.setScale(0, System.RoundingMode.HALF_UP);
            mapTotal.put(sTmpSubBrandName, dTmpTotalBottle);
        }
        
        List<ASI_MFM_Sub_brand__c> subBrands = Database.query('SELECT Id, Name, ASI_CRM_TW_Company__c,ASI_CRM_TW_Sequence_Company__c,ASI_CRM_TW_Sequence_Sub_brand__c FROM ASI_MFM_Sub_brand__c WHERE ' + channelChecking  + ' AND ASI_CRM_TW_Company__c = \'PRT\' ORDER BY ASI_CRM_TW_Sequence_Company__c,ASI_CRM_TW_Sequence_Sub_brand__c');
    
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
            marketSurvey.balance = 0;
            
            //get total/balance
            /*
            for(ASI_CRM_OutletDepletion__c outletDepletion : outletDepletions){
                if(subBrand.Name != NULL && outletDepletion.ASI_CRM_SubBrand__c != NULL && subBrand.Name.equals(outletDepletion.ASI_CRM_SubBrand__r.Name)){
                   if(outletDepletion.ASI_CRM_Bottle_Head__c == null)
                       marketSurvey.balance = 0;
                   else
                       marketSurvey.balance = outletDepletion.ASI_CRM_Bottle_Head__c;
                   break;
                }
            }
            */
            if (subBrand.Name != NULL && mapTotal.containsKey(subBrand.Name)) {
                marketSurvey.balance = mapTotal.get(subBrand.Name);
            } else {
                marketSurvey.balance = 0;
            }
            
            //get vpid
            for(ASI_CRM_OutletDepletion__c outletDepletion : outletDepletions){
                if(subBrand.Name != NULL && outletDepletion.ASI_CRM_SubBrand__c != NULL && subBrand.Name.equals(outletDepletion.ASI_CRM_SubBrand__r.Name)){
                   if(outletDepletion.ASI_CRM_Bottle_Head__c == null)
                       marketSurvey.bottleHead = 0;
                   else
                       marketSurvey.bottleHead = outletDepletion.ASI_CRM_Bottle_Head__c;
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
            
            rows = rows / 2 + (Math.mod(rows,2)>0?1:0);
            
            marketSurveyPage.companyMarketSurveySizeMap.put(key,rows);
        }

        marketSurveyPage.marketCompanies.sort();
    }
    
    public void saveAction(){
        List<ASI_CRM_OutletDepletion__c> newOutletDepletions = new  List<ASI_CRM_OutletDepletion__c>();
        
        ASI_CRM_AccountsAdditionalField__c customer = [SELECT Id, Name FROM ASI_CRM_AccountsAdditionalField__c WHERE ASI_CRM_Account__c = :accountId];
        
        for(String key : marketSurveyPage.marketSurveyMap.keySet()){
            List<MarketSurvey> marketSurveys = marketSurveyPage.marketSurveyMap.get(key);
            
            for(MarketSurvey marketSurvey : marketSurveys){
                boolean isNew = true;
                for(ASI_CRM_OutletDepletion__c outletDepletion : outletDepletions){
                    if(marketSurvey.subBrand != NULL && outletDepletion.ASI_CRM_SubBrand__c != NULL && marketSurvey.subBrand.equals(outletDepletion.ASI_CRM_SubBrand__r.Name)){
                        if(marketSurvey.bottleHead == null){
                            marketSurvey.bottleHead = 0;
                        }
                        if(marketSurvey.balance == null){
                            marketSurvey.balance = 0;
                        }
                        //outletDepletion.ASI_CRM_Bottle_Head__c = marketSurvey.bottleHead + marketSurvey.balance;
                        outletDepletion.ASI_CRM_Bottle_Head__c = marketSurvey.bottleHead;
                        outletDepletion.ASI_CRM_AccountsAdditionalField__c = customer.Id;
                        isNew = false;
                        break;
                    }
                }
                
                if(isNew){
                    ASI_CRM_OutletDepletion__c  outletDepletion = new ASI_CRM_OutletDepletion__c();
                    outletDepletion.RecordTypeId = Global_RecordTypeCache.getRTId('ASI_CRM_OutletDepletion__cASI_CRM_TW_OutletDepletion_RcrdTyp');
                    outletDepletion.ASI_CRM_Date__c = Date.today();
                    outletDepletion.ASI_CRM_Outlet__c = accountId;
                    outletDepletion.ASI_CRM_AccountsAdditionalField__c = customer.Id;
                    outletDepletion.ASI_CRM_SubBrand__c = marketSurvey.subBrandId;
                    outletDepletion.ASI_CRM_Bottle_Head__c = marketSurvey.bottleHead;
                    outletDepletion.ASI_CRM_VisitationPlanDetail__c = vpid;
                    
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
        public Decimal balance {get; set;}
        public Decimal bottleHead {get; set;}
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

    /** Show error message */
    private void showPageMessage(ApexPages.Severity severity, String msg) {
        if (!Test.isRunningTest()) {
        	ApexPages.addMessage(new ApexPages.Message(severity, msg));
        }
    }
    /** Show error message */
    private void showPageError(String msg) {
        showPageMessage(ApexPages.Severity.ERROR, msg);
    }

}