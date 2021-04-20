public with sharing class ASI_TH_CRM_RSP_MassEdit {
    private static integer MAX_MONTH_NUM = 6;

    public ASI_TH_CRM_RSP__c rsp_fromDate { get; set; }
    public ASI_TH_CRM_RSP__c rsp_toDate { get; set; }
    
    public Date fromDate = Date.newInstance(Date.today().year(),Date.today().month(),1);
    public Date toDate = Date.newInstance(9999,12,31);
    
    public List<String> monthTitles {get; set;}
    
    public Map<String,Map<String,RspPrice>> results {get; set;}
    public Set<String> subBrandDisplay{get;set;}
    
    public List<ASI_TH_CRM_RSP__c> rsps{get; private set;}
    public List<String> subBrands {get; private set;}
    
    private integer counter = 0;  //keeps track of the offset
    private integer pageSubBandSize = 30; //sets the page size or number of SubBand
    public integer totalSize; //used to show user the total size of the list
    public integer numberOfMonth {set;get;}
    
    public boolean disablePrevious {set;get;}
    public boolean disableNext {set;get;}

    public String recordNumberDisplay {get;set;}//show current no out of total no.
    public String totalSizeSOQL;
    public String querySOQL;     
    
    public ASI_TH_CRM_RSP_MassEdit(ApexPages.StandardController controller) {
        rsp_fromDate = new ASI_TH_CRM_RSP__c ();
        rsp_toDate = new ASI_TH_CRM_RSP__c (); 
        
        
        retrieveSubBrands();            
    }
    
    private void retrieveSubBrands(){
        subBrands = new List<String>();
    
        List<AggregateResult> subBrandAggregateResults = [SELECT ASI_TH_CRM_Sub_Brand__r.Id Id,ASI_TH_CRM_Sub_Brand__r.Name Name FROM ASI_TH_CRM_RSP__c WHERE ASI_TH_CRM_Sub_Brand__C <> NULL AND ASI_TH_CRM_Date__c >= :fromDate AND ASI_TH_CRM_Date__c < :toDate GROUP BY ASI_TH_CRM_Sub_Brand__r.Id,ASI_TH_CRM_Sub_Brand__r.Name ORDER BY ASI_TH_CRM_Sub_Brand__r.Name];             
    
        for(AggregateResult subBrand : subBrandAggregateResults){
            subBrands.add(String.valueOf(subBrand.get('Id')));
        }
        
        System.debug('subBrands retrieve:' + subBrands);
    }
    
    public void search(){
        if(rsp_fromDate.ASI_TH_CRM_Date__c == null && rsp_toDate.ASI_TH_CRM_Date__c == null) return;
            
         if(rsp_fromDate.ASI_TH_CRM_Date__c != null){
             fromDate = Date.newInstance(rsp_fromDate.ASI_TH_CRM_Date__c.year(),rsp_fromDate.ASI_TH_CRM_Date__c.month(),1);
         }
            
         if(rsp_toDate.ASI_TH_CRM_Date__c != null){
             toDate = Date.newInstance(rsp_toDate.ASI_TH_CRM_Date__c.year(),rsp_toDate.ASI_TH_CRM_Date__c.month() + 1,1);
         }
         
        numberOfMonth = (toDate.year()*12 + toDate.month()) - (fromDate.year()*12 + fromDate.month());
        
        if(numberOfMonth > MAX_MONTH_NUM){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Maximum no. of month could not exceed 6! Please narrow down your search range.'));
            return;
        }
        
        retrieveSubBrands();   
           
         //totalSize = Database.countquery('SELECT COUNT() FROM ASI_TH_CRM_RSP__c WHERE ASI_TH_CRM_Date__c >= :fromDate AND ASI_TH_CRM_Date__c < :toDate');
         totalSize = subBrands.size();      
                       
         //rsps = [SELECT ASI_TH_CRM_Date__c, ASI_TH_CRM_MT_RSP__c, ASI_TH_CRM_Price_to_WS__c, ASI_TH_CRM_Sub_Brand__r.Name, ASI_TH_CRM_WS_RSP__c, ASI_TH_CRM_WS_to_RT__c FROM ASI_TH_CRM_RSP__c WHERE ASI_TH_CRM_Date__c >= :fromDate AND ASI_TH_CRM_Date__c < :toDate ORDER BY ASI_TH_CRM_Date__c ASC,ASI_TH_CRM_Sub_brand__r.Name];
         
         results = new Map<String,Map<String,RspPrice>>();
         
         monthTitles = new List<String>();
         
         counter = 0;
         
         if (totalSize > 0){                
             querySOQL = 'SELECT ASI_TH_CRM_Date__c, ASI_TH_CRM_MT_RSP__c, ASI_TH_CRM_Price_to_WS__c, ASI_TH_CRM_Sub_Brand__r.Name, ASI_TH_CRM_WS_RSP__c, ASI_TH_CRM_WS_to_RT__c FROM ASI_TH_CRM_RSP__c WHERE ASI_TH_CRM_Date__c >= :fromDate AND ASI_TH_CRM_Date__c < :toDate ';
             
             //pageSize = pageSubBandSize * numberOfMonth;
             
             searchCurrentPage();
         }else{
             results = new Map<String,Map<String,RspPrice>>();
             
             monthTitles = new List<String>();         
         }                  
    }
    
    private String getPagnationSubBrands(){
        String subBrandIdStr = '\'000000000000000\'';
        
        for(Integer i = counter;i < Math.min((counter + pageSubBandSize),totalSize); i++){
            String subBrandId = subBrands.get(i);
            subBrandIdStr = subBrandIdStr + ',\'' + subBrandId + '\'';
        }
        
        System.debug('subBrandIdStr:' + subBrandIdStr);
        
        return subBrandIdStr;
    }
    
    public void searchCurrentPage(){
        try{
            results = new Map<String,Map<String,RspPrice>>();
             
            monthTitles = new List<String>();        
                    
            //System.debug('querySOQL:' + querySOQL + ' LIMIT ' + String.valueOf(pageSize) + ' OFFSET '+ String.valueof(counter));
            
            disablePrevious = getDisablePrevious();
            disableNext = getDisableNext();
            //recordNumberDisplay = '(' + String.valueOf(counter/numberOfMonth + 1)+ ' - ' + String.valueOf(Math.min((counter/numberOfMonth + pageSubBandSize),totalSize/numberOfMonth)) + ' of ' + String.valueOf(totalSize/numberOfMonth) + ')';
            recordNumberDisplay = '(' + String.valueOf(counter + 1)+ ' - ' + String.valueOf(Math.min((counter + pageSubBandSize),totalSize)) + ' of ' + String.valueOf(totalSize) + ')';
            
            //rsps = Database.query(querySOQL + ' LIMIT ' + String.valueOf(pageSize) + ' OFFSET '+ String.valueof(counter));
            
            rsps = Database.query(querySOQL + ' AND ASI_TH_CRM_Sub_brand__C IN ( ' + getPagnationSubBrands() + ') ORDER BY ASI_TH_CRM_Sub_brand__r.Name,ASI_TH_CRM_Date__c ASC');

            for (ASI_TH_CRM_RSP__c rsp: rsps){
                  Datetime dt = datetime.newInstance(rsp.ASI_TH_CRM_Date__c.year(), rsp.ASI_TH_CRM_Date__c.month(),rsp.ASI_TH_CRM_Date__c.day());
                  String monthTitle = dt.format('MMM-yy');                  
                  
                  System.debug('ASI_TH_CRM_Date__c:' + rsp.ASI_TH_CRM_Date__c);
                  
                  Boolean isExist = false;
                  for(String month:monthTitles){
                      if( month == monthTitle){
                         isExist = true;
                         break; 
                      }
                  }
                  if(!isExist){
                      monthTitles.add(monthTitle);
                  }
                  System.debug('SubBrand-Name accessible:' + Schema.sObjectType.ASI_MFM_Sub_brand__c.fields.Name.isAccessible());
                  
                   System.debug('SubBrand-Name:' + rsp.ASI_TH_CRM_Sub_Brand__r.Name);
                  Map<String,RspPrice> rspPriceMap = results.get(rsp.ASI_TH_CRM_Sub_Brand__r.Name);
                  
                  if(rspPriceMap == null){
                      rspPriceMap = new Map<String,RspPrice>();
                  }
                  
                  RspPrice rspPrice = new RspPrice();
                  
                  rspPrice.id = rsp.Id;
                  rspPrice.mtrsp = rsp.ASI_TH_CRM_MT_RSP__c;
                  rspPrice.pricetows = rsp.ASI_TH_CRM_Price_to_WS__c;
                  rspPrice.wsrsp = rsp.ASI_TH_CRM_WS_RSP__c;
                  rspPrice.wstort = rsp.ASI_TH_CRM_WS_to_RT__c ;
                  rspPrice.month = monthTitle;    
                  rspPrice.subbrand = rsp.ASI_TH_CRM_Sub_Brand__r.Name;
                  
                  rspPriceMap.put(monthTitle, rspPrice); 
                  
                  results.put(rsp.ASI_TH_CRM_Sub_Brand__r.Name, rspPriceMap);        
            }
            
            for(String month : monthTitles){
                for(String subBrandkey:results.keySet()){ 
                    Map<String,RspPrice> rspPriceMap = results.get(subBrandkey);
                    
                    if(rspPriceMap.get(month)== null){
                        RspPrice rspPrice = new RspPrice();
                        rspPrice.month = month;
                        
                        rspPriceMap.put(month,rspPrice);
                    }
                }
            }
            
            if(results != null && results.size()>0)
                subBrandDisplay = results.keyset();
                                   
        }catch(Exception ex){
            ApexPages.addMessages(ex);
        }     
    }
    
    public void save(){
          if(results == null || rsps == null) return;
          
          for (ASI_TH_CRM_RSP__c rsp : rsps){
              Map<String,RspPrice> rspPriceMap = results.get(rsp.ASI_TH_CRM_Sub_Brand__r.Name);
              
              if (rspPriceMap != null){
                  Datetime dt = datetime.newInstance(rsp.ASI_TH_CRM_Date__c.year(), rsp.ASI_TH_CRM_Date__c.month(),rsp.ASI_TH_CRM_Date__c.day());
                 
                  RspPrice rspPrice = rspPriceMap.get(dt.format('MMM-yy'));
                  if(rspPrice != null && rsp.Id == rspPrice.id){
                      rsp.ASI_TH_CRM_MT_RSP__c = rspPrice.mtrsp;
                      rsp.ASI_TH_CRM_Price_to_WS__c = rspPrice.pricetows;
                      rsp.ASI_TH_CRM_WS_RSP__c = rspPrice.wsrsp;
                      rsp.ASI_TH_CRM_WS_to_RT__c = rspPrice.wstort ;
                  }
              }
          }
          
          System.Savepoint sp = database.setSavepoint();
          
          try {
              update rsps;
              
              search();
          } catch (DmlException dmle) {
              database.rollback(sp);
          } catch (Exception e) {
              database.rollback(sp);
          }    
    }
    
    public void copy(){
        if (results == null) return;

        Datetime dtThisMonth = Datetime.now();       
        Datetime dtLastMonth = Datetime.now().addMonths(-1);

        for (String key : results.keySet()){
            Map<String,RspPrice> rspPriceMap = results.get(key);
            
            if(rspPriceMap != null){        
                RspPrice thisMonthRspPrice = rspPriceMap.get(dtThisMonth.format('MMM-yy'));
                RspPrice lastMonthRspPrice = rspPriceMap.get(dtLastMonth .format('MMM-yy'));
                   
                if(thisMonthRspPrice != null && lastMonthRspPrice != null){
                    thisMonthRspPrice.mtrsp = lastMonthRspPrice.mtrsp;
                    thisMonthRspPrice.pricetows = lastMonthRspPrice.pricetows;
                    thisMonthRspPrice.wsrsp = lastMonthRspPrice.wsrsp;
                    thisMonthRspPrice.wstort = lastMonthRspPrice.wstort;
                }
            }    
        }        
    }
    
    public Class RspPrice{
        public String id{ 
            get{
                if(String.isBlank(id)) {
                    return null;
                }
                return id;
              } 
            set; }
        public Decimal mtrsp {get; set;}
        public Decimal pricetows {get; set;}
        public Decimal wsrsp {get; set;}
        public Decimal wstort {get; set;}
        public String month {get; set;}
        public String subbrand {get;set;}
    }
    
    public PageReference Beginning() { //user clicked beginning
        counter = 0;
        searchCurrentPage();
        return null;
    }
    
    public PageReference Previous() { //user clicked previous button
        counter -= pageSubBandSize;
        searchCurrentPage();
        return null;
    }
    
    public PageReference Next() { //user clicked next button
        counter += pageSubBandSize;
        if(counter >= 2000)
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Maximum no. of search result (2000 records) reached! Please narrow down your search range.'));
            return null;
        }
        searchCurrentPage();
        return null;
    }
    
    public PageReference End() { //user clicked end  
        counter = totalSize - pageSubBandSize;    
        if(counter >= 2000)
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Maximum no. of search result (2000 records) reached! Please narrow down your search range.'));
            return null;
        }
        searchCurrentPage();
        return null;
    }
    
    public Boolean getDisablePrevious() { 
        //this will disable the previous and beginning buttons
        if (counter>0) 
            disablePrevious = false;
        else 
            disablePrevious = true;
        return disablePrevious;
    }
    
    public Boolean getDisableNext() { //this will disable the next and end buttons
        if (counter + pageSubBandSize < totalSize) 
            disableNext = false; 
        else 
            disableNext = true;
        return disableNext;
    }
}