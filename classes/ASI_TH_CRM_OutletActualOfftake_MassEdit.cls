public without sharing class ASI_TH_CRM_OutletActualOfftake_MassEdit {
    private static integer MAX_MONTH_NUM = 6;

    public ID outletId { get; private set; }
    public ASI_TH_CRM_Actual_Offtake__c ao_fromDate { get; set; }
    public ASI_TH_CRM_Actual_Offtake__c ao_toDate{ get; set; }
    
    String wholesaler = '';
    String subBrand = '';
    Date fromDate = Date.newInstance(Date.today().year(),Date.today().month(),1);
    Date toDate = Date.newInstance(9999,12,31);    
    
    public List<String> monthTitles {get; set;}
    
    public Map<String,Map<String,Map<String,OffTake>>> results { get; set;}
    
    public List<ASI_TH_CRM_Actual_Offtake__c> actualOffTakes { get; private set;}    
 
    private integer counter = 0;  //keeps track of the offset
    //private integer pageSubBandSize = 10; //sets the page size or number of SubBand
    private integer pageSize = 300;
    public integer totalSize; //used to show user the total size of the list
    public integer numberOfMonth;
    
    public boolean disablePrevious {set;get;}
    public boolean disableNext {set;get;}

    public String recordNumberDisplay {get;set;}//show current no out of total no.
    public String totalSizeSOQL;
    public String querySOQL;  
    
    public ASI_TH_CRM_OutletActualOfftake_MassEdit(ApexPages.StandardController controller) {
        this.outletId = ApexPages.currentPage().getParameters().get('id');
        ao_fromDate = new ASI_TH_CRM_Actual_Offtake__c();
        ao_toDate= new ASI_TH_CRM_Actual_Offtake__c();             
    }
    
    
    public void search(){
            if(ao_fromDate.ASI_TH_CRM_From_Wholesaler__c == null && ao_fromDate.ASI_TH_CRM_Sub_brand__c == null){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please select the Wholesaler or the Sub-Brand.'));
                return;
            }else{
                wholesaler = ao_fromDate.ASI_TH_CRM_From_Wholesaler__c;
                subBrand = ao_fromDate.ASI_TH_CRM_Sub_brand__c;
            }                      
        
            if(ao_fromDate.ASI_TH_CRM_Offtake_G_L_Date__c == null && ao_toDate.ASI_TH_CRM_Offtake_G_L_Date__c == null) return;
            
            if(ao_fromDate.ASI_TH_CRM_Offtake_G_L_Date__c != null){
                fromDate = Date.newInstance(ao_fromDate.ASI_TH_CRM_Offtake_G_L_Date__c.year(),ao_fromDate.ASI_TH_CRM_Offtake_G_L_Date__c.month(),1);
            }
            
            if(ao_toDate.ASI_TH_CRM_Offtake_G_L_Date__c != null){
                Date tempDate = ao_toDate.ASI_TH_CRM_Offtake_G_L_Date__c.addMonths(1);
                toDate = Date.newInstance(tempDate.year(),tempDate.month(),1);
            }
            
            numberOfMonth = (toDate.year() * 12 + toDate.month()) - (fromDate.year() *12 + fromDate.month());
            
            if(numberOfMonth > MAX_MONTH_NUM){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Maximum no. of month could not exceed 6! Please narrow down your search range.'));
                return;
            }           
            
            String queryWhere = 'ASI_TH_CRM_Outlet__r.Id = :outletId AND ASI_TH_CRM_Offtake_G_L_Date__c >= :fromDate AND ASI_TH_CRM_Offtake_G_L_Date__c < :toDate AND ASI_TH_CRM_Delete__c = FALSE '; 
            
            if(wholesaler != null && !''.equals(wholesaler)){
                queryWhere = queryWhere + 'AND ASI_TH_CRM_From_Wholesaler__c = :wholesaler '; 
            }
            
            if(subBrand != null && !''.equals(subBrand)){
                queryWhere = queryWhere + 'AND ASI_TH_CRM_Sub_brand__c = :subBrand '; 
            }            
            
            totalSize = Database.countquery('SELECT COUNT() FROM ASI_TH_CRM_Actual_Offtake__c WHERE ' + queryWhere); 
            
            //actualOffTakes = [SELECT Id,Name, ASI_TH_CRM_From_Wholesaler__r.Id,ASI_TH_CRM_From_Wholesaler__r.Name, ASI_TH_CRM_Quantity__c, ASI_TH_CRM_Sub_brand__r.Id,ASI_TH_CRM_Sub_brand__r.Name,ASI_TH_CRM_Outlet__c,ASI_TH_CRM_Offtake_G_L_Date__c FROM ASI_TH_CRM_Actual_Offtake__c WHERE ASI_TH_CRM_Outlet__r.Id = :this.outletId AND ASI_TH_CRM_From_Wholesaler__c = :ao_fromDate.ASI_TH_CRM_From_Wholesaler__c AND ASI_TH_CRM_Offtake_G_L_Date__c >= :fromDate AND ASI_TH_CRM_Offtake_G_L_Date__c < :toDate ORDER BY ASI_TH_CRM_From_Wholesaler__r.Name,ASI_TH_CRM_Sub_brand__r.Name,ASI_TH_CRM_Offtake_G_L_Date__c DESC];
            
            results = new Map<String,Map<String,Map<String,OffTake>>>();
            
            monthTitles = new List<String>();
            
            counter = 0;
            
            numberOfMonth = (toDate.year() * 12 + toDate.month()) - (fromDate.year() *12 + fromDate.month());
            
             if (totalSize > 0){                
                 querySOQL = 'SELECT Id,Name, ASI_TH_CRM_From_Wholesaler__r.Id,ASI_TH_CRM_From_Wholesaler__r.Name, ASI_TH_CRM_Quantity__c, ASI_TH_CRM_Sub_brand__r.Id,ASI_TH_CRM_Sub_brand__r.Name,ASI_TH_CRM_Outlet__c,ASI_TH_CRM_Offtake_G_L_Date__c FROM ASI_TH_CRM_Actual_Offtake__c WHERE ' + queryWhere + ' ORDER BY ASI_TH_CRM_From_Wholesaler__r.Name,ASI_TH_CRM_Sub_brand__r.Name,ASI_TH_CRM_Offtake_G_L_Date__c DESC';
                 
                 //pageSize = pageSubBandSize * numberOfMonth;
                 
                 searchCurrentPage();
             }                
      }
      
      public void searchCurrentPage(){
          try{
            results = new Map<String,Map<String,Map<String,OffTake>>>();
             
            monthTitles = new List<String>();           
            for(integer i = 0;i < numberOfMonth;i++){
                Date tempDate = fromDate.addMonths(i);
                
                Datetime dt = datetime.newInstance(tempDate.year(), tempDate.month(),tempDate.day());
                String monthTitle = dt.format('MMM-yy');
                
                monthTitles.add(monthTitle);
            }                     
                    
            System.debug('querySOQL:' + querySOQL + ' LIMIT ' + String.valueOf(pageSize) + ' OFFSET '+ String.valueof(counter));
            
            disablePrevious = getDisablePrevious();
            disableNext = getDisableNext();
            //recordNumberDisplay = '(' + String.valueOf(counter + 1)+ ' - ' + String.valueOf(Math.min((counter + pageSize),totalSize)) + ' of ' + String.valueOf(totalSize) + ')';
            
            actualOffTakes = Database.query(querySOQL + ' LIMIT ' + String.valueOf(pageSize) + ' OFFSET '+ String.valueof(counter));          
      
            for (ASI_TH_CRM_Actual_Offtake__c actualOfftake : actualOffTakes){
                  //String monthTitle = actualOfftake.ASI_TH_CRM_Offtake_G_L_Date__c.year() + '-' + actualOfftake.ASI_TH_CRM_Offtake_G_L_Date__c.month();
                  Datetime dt = datetime.newInstance(actualOfftake.ASI_TH_CRM_Offtake_G_L_Date__c.year(), actualOfftake.ASI_TH_CRM_Offtake_G_L_Date__c.month(),actualOfftake.ASI_TH_CRM_Offtake_G_L_Date__c.day());
                  String monthTitle = dt.format('MMM-yy');                  
                  /*
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
                  */
                  Map<String,Map<String,OffTake>> subBrandMap = results.get(actualOfftake.ASI_TH_CRM_From_Wholesaler__r.Name);
                  
                  if(subBrandMap == null){
                      subBrandMap = new Map<String,Map<String,OffTake>>();
                  }
                  
                  Map<String,OffTake> offTakeMap = subBrandMap.get(actualOfftake.ASI_TH_CRM_Sub_brand__r.Name);
                  
                  if(offTakeMap == null){
                      offTakeMap = new Map<String,OffTake>();
                  }
                  offTakeMap.put(monthTitle, new OffTake(actualOfftake.Id,actualOfftake.ASI_TH_CRM_Quantity__c,monthTitle)); 
                  //offTakeLit.add(new OffTake(actualOfftake.Id,String.valueOf(actualOfftake.ASI_TH_CRM_Quantity__c),monthTitle));
                  
                  subBrandMap.put(actualOfftake.ASI_TH_CRM_Sub_brand__r.Name,offTakeMap);
                  results.put(actualOfftake.ASI_TH_CRM_From_Wholesaler__r.Name, subBrandMap);        
            }
            
            for(String month : monthTitles){
                for(String wholeSalerkey:results.keySet()){ 
                    Map<String,Map<String,OffTake>> subBrandMap = results.get(wholeSalerkey);
                    
                    for(String subBrandkey:subBrandMap.keySet()){
                        Map<String,OffTake> offTakeMap = subBrandMap.get(subBrandkey);
                        
                        if(offTakeMap.get(month)== null){
                            offTakeMap.put(month, new OffTake(null,null,month));
                        }
                    }
                }
            }
        }catch(Exception ex){
            ApexPages.addMessages(ex);
        }                     
      }
      
      public void save(){
          //System.debug('Save Results:' + results);
          
          //System.debug('Saving Results:' + actualOffTakes );

          if(results == null || actualOffTakes == null) return;
          
          for (ASI_TH_CRM_Actual_Offtake__c actualOfftake : actualOffTakes){
              Map<String,Map<String,OffTake>> subBrandMap = results.get(actualOfftake.ASI_TH_CRM_From_Wholesaler__r.Name);
              
              if (subBrandMap != null){
                  Map<String,OffTake> offTakeMap = subBrandMap.get(actualOfftake.ASI_TH_CRM_Sub_brand__r.Name);
                  
                  if(offTakeMap != null){                     
                      //OffTake offTake = offTakeMap.get(actualOfftake.ASI_TH_CRM_Offtake_G_L_Date__c.year() + '-' + actualOfftake.ASI_TH_CRM_Offtake_G_L_Date__c.month());
                      Datetime dt = datetime.newInstance(actualOfftake.ASI_TH_CRM_Offtake_G_L_Date__c.year(), actualOfftake.ASI_TH_CRM_Offtake_G_L_Date__c.month(),actualOfftake.ASI_TH_CRM_Offtake_G_L_Date__c.day());
                      
                      OffTake offTake = offTakeMap.get(dt.format('MMM-yy'));
                      if(offTake != null && actualOfftake.Id == offTake.id){                              
                          actualOfftake.ASI_TH_CRM_Quantity__c = offTake.quantity;
                      }
                  }
              }
          }
         
          //System.debug('Saved Results:' + actualOffTakes);
          
          System.Savepoint sp = database.setSavepoint();
          
          try {
              update actualOffTakes;
              
              search();
          } catch (DmlException dmle) {
              database.rollback(sp);
          } catch (Exception e) {
              database.rollback(sp);
          }
           
      }
      
      public class OffTake{
          public String id{ 
              get{
                 if(String.isBlank(id)) {
                    return null;
                 }
                  return id;
              } 
              set; }
          public Decimal quantity{ get; set; }
          public String month{get; set;}
          
          public OffTake(String id, Decimal quantity, String month){
              this.id = id;
              this.quantity = quantity;
              this.month = month;
          }        
      }
      
    public PageReference Beginning() { //user clicked beginning
        counter = 0;
        searchCurrentPage();
        return null;
    }
    
    public PageReference Previous() { //user clicked previous button
        counter -= pageSize;
        searchCurrentPage();
        return null;
    }
    
    public PageReference Next() { //user clicked next button
        counter += pageSize;
        if(counter >= 2000)
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Maximum no. of search result (2000 records) reached! Please narrow down your search range.'));
            return null;
        }
        searchCurrentPage();
        return null;
    }
    
    public PageReference End() { //user clicked end  
        counter = totalSize - pageSize;    
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
        if (counter + pageSize < totalSize) 
            disableNext = false; 
        else 
            disableNext = true;
        return disableNext;
    }   
}