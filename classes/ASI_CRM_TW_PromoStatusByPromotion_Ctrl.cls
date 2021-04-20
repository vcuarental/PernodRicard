/*Filename:    ASI_CRM_TW_PromoStatusByPromotion_Ctrl.cls
* Author:      Alvin Wu (Introv Limited)
* Purpose:     Controller Class for listing Promotion Status by Promotion
*
* -----------------------------------------------------------------------------
*/
public with sharing class ASI_CRM_TW_PromoStatusByPromotion_Ctrl {

    public id promoId {set;get;}
    public String userLanguage {set;get;}
    public List<ASI_CRM_Promotion_Status__c> listPromoStatus {set;get;}
    public Set<Id> setPromoStatusId {set;get;}
    public Map<Integer, Id> mapTotalPromoStatus {set;get;}
    public Map<Integer, classPromoStatus> mapPromoStatus {set;get;}
    public List<Attachment> listAttachments {set;get;}
    public Map<Id, List<Attachment>> mapAttachmentByPromoStatus {set;get;}
    public id reportForPrintId {set;get;}
    List <Report> reportList=new List<Report>();
    public String promoCodeAndName {set;get;}
    
    //Pagination
    public String querySOQL;
    public boolean disablePrevious {set;get;}
    public boolean disableNext {set;get;}
    public String recordNumberDisplay {set;get;}//show current no out of total no.
    private Double counter = 0;  //keeps track of the offset
    private Double pageSize = 10; //sets the page size or number of SubBand
    public Integer totalSize {set;get;} //used to show user the total size of the list       
    public Decimal totalNumOfUnit {set;get;} //sum of total number of unit for all promotion status
    
    public Integer pageNum {set;get;}
    public Double totalpageNum {set;get;}
    public Integer intTotalpageNum {set;get;}
    public Set<Integer> setPageNum {set;get;}
    
    //Added by Kevani Chow@27/04/2016 (For Search Criteria)
    public List<String> searchDone { get; set; }
    public List<String> searchTaskType { get; set; }
    public List<String> searchRegion { get; set; }
    public List<String> searchChannel { get; set; }
    public List<String> searchSales { get; set ;}                  // Added by 2018-08-07 Linus@introv
    Public List<SelectOption> ChannelList{get;set;}
    public ASI_HK_CRM_Promotion__c promo {get;set;}
    //Modified by Kevani Chow@27/04/2016 (For Search Criteria)
    public void Initial(){
            
        searchDone = new List<String>();
        searchTaskType = new List<String>(); 
        searchRegion = new List<String>(); 
        searchChannel = new List<String>(); 
        searchSales = new LisT<String>();                       // Added by 2018-08-07 Linus@introv
        
        ChannelList=getChannelList();
        
        ViewSearch(); 
        
        reportList =[Select ID from Report where DeveloperName = 'ASI_CRM_TW_PromoStatusReport_bPromotion'];
        if (reportList!=null && reportList.size()>0){
            reportForPrintid= (String)reportList.get(0).get('Id');
        }
        else
            reportForPrintid = null;
    }

   //Added by Kevani Chow@29/04/2016 (For Search Criteria)
   public class Channel{
    public string ChannelName {get;set;}
    public string ChannelId {get; set;}
  }
  
   public class Region{
    public string RegionName {get;set;}
    public string RegionlId {get; set;}
  }
    
    /*public String getPromoName(){
        return promo.Name;
    }
    
    public Date getPromoStartDate(){
        return promo.ASI_HK_CRM_Promotion_Start_Date__c;
    }
    
    public Date getPromoEndDate(){
        return promo.ASI_HK_CRM_Promotion_End_Date__c;
    }
    */
   Public List<SelectOption> getChannelList(){       
       List<SelectOption> options = new List<SelectOption>();
       Id cRecordTypeId = Global_RecordTypeCache.getRTId('ASI_CRM_CN_Channel__cASI_CRM_TW_Channel');
       List <ASI_CRM_CN_Channel__c> ChannelOption = [SELECT Id, Name, ASI_CRM_CN_Channel_Code__c FROM ASI_CRM_CN_Channel__c 
                                                                   WHERE RecordTypeId =: cRecordTypeId ORDER BY Name];

       if(ChannelOption.size()>0){
           for(ASI_CRM_CN_Channel__c channel :ChannelOption){
               Channel c = new Channel();
               c.ChannelName = channel.Name;
               c.ChannelId = channel.ASI_CRM_CN_Channel_Code__c;
               options.add(new SelectOption(c.ChannelId,c.ChannelName)); 
            }
        }
       
        return options;
    }	
    
    public List<SelectOption> getRegionList() {
        List<SelectOption> options = new List<SelectOption>();
        
        options.add(new SelectOption('Central','Central'));
        options.add(new SelectOption('North','North'));
        //options.add(new SelectOption('North 2','North 2'));
        options.add(new SelectOption('South','South'));
        options.add(new SelectOption('CVS','CVS'));
        options.add(new SelectOption('SUPER','SUPER'));
        options.add(new SelectOption('HYPER','HYPER'));
    
        return options;
    
    }
    
    
    public List<SelectOption> getDoneList(){
        
        List<SelectOption> options = new List<SelectOption>();
        
        options.add(new SelectOption('True',userLanguage=='zh_TW'?'是':'Yes'));
        options.add(new SelectOption('False',userLanguage=='zh_TW'?'否':'No'));
    
        return options;
    
    }


    public List<SelectOption> getTaskList() {
        List<SelectOption> options = new List<SelectOption>();
        
        Schema.DescribeFieldResult fieldResult = ASI_CRM_Promotion_Status__c.ASI_CRM_Task__c.getDescribe();
        List<Schema.PicklistEntry> Tasklist = fieldResult.getPicklistValues();
            
        for(Schema.PicklistEntry f : Tasklist){
            options.add(new SelectOption(f.getValue(), f.getLabel()));
        }       
        return options;
    }
    
    // Added by 2018-08-07 Linus@introv
    Public List<SelectOption> getSalesList() {
        List<SelectOption> options = new List<SelectOption>();        
        Id RecordTypeId = Global_RecordTypeCache.getRTId('ASI_CRM_Promotion_Status__cASI_CRM_TW_PromotionStatus');
        List<ASI_CRM_Promotion_Status__c> SalesOption = [Select Ownerid, Owner.Name from ASI_CRM_Promotion_Status__c where ASI_CRM_Promotion__c = :promoId and recordtypeid = :RecordTypeId];
        Set<Id> userId_Set = new Set<Id>();
        
        if(Salesoption.size() > 0){
            for(ASI_CRM_Promotion_Status__c sales: SalesOption){
                if(!userId_Set.contains(sales.OwnerId)){
                    userId_Set.add(sales.OwnerId);
                    options.add(new SelectOption(sales.OwnerId, sales.Owner.Name));
                }
            }
        }
        
        return options;
    }
    
    public String getSearchSalesSOQL(List<String> values){
        system.debug('values: ' + values);
        String strSalesSOQL = ' AND Ownerid IN( ';
        if(values.size() > 0){
            for(String s: values){
                strSalesSOQL += '\'' +s+'\',';
            }
          strSalesSOQL = strSalesSOQL.substring(0,strSalesSOQL.length()-1) +') ';
        }
        
        system.debug('strSalesSOQL: '+strSalesSOQL);
        return strSalesSOQL;
    }
    // END - Linus
    
   //Get searchDone SOQL expression
    public String getSearchDoneSOQL(List<String> values){
        system.debug('values: '+values);
        String strDoneSOQL = '';
        if(values.size() > 1||values.size()==0){
            strDoneSOQL = '';
        }else{
        for(String s: values){
                strDoneSOQL +=' AND ASI_CRM_Done__c = ' +s+' ';
           }
        }
        system.debug('strDoneSOQL: '+strDoneSOQL);
        return strDoneSOQL;
    }
    
    
   //Get searchTaskType SOQL expression
    public String getSeacrhTaskTypeSOQL(List<String> values){
        system.debug('values: '+values);
        String strTaskSOQL = 'AND ASI_CRM_Task__c IN(';
        if(values.size() > 0){
            for(String s: values){
                strTaskSOQL += '\'' +s+'\',';
            }
          strTaskSOQL = strTaskSOQL.substring(0,strTaskSOQL.length()-1) +') ';
        }
        system.debug('strTaskSOQL: '+strTaskSOQL);
        return strTaskSOQL;
    }
    
    
   //Get searchChannel SOQL expression
   public String getSeacrhChannelTypeSOQL(List<String> values){
       system.debug('values: '+values);
        String strChannelSOQL = 'AND ASI_CRM_Promotion__r.ASI_CRM_Channel__c INCLUDES(';
        if(values.size() > 0){
            for(String s: values){
                strChannelSOQL += '\'' +s+'\',';
            }
          strChannelSOQL = strChannelSOQL.substring(0,strChannelSOQL.length()-1) +') ';
        }
        system.debug('strChannelSOQL: '+strChannelSOQL);
        return strChannelSOQL;
    }
    
   //Get searchRegion SOQL expression
    public String getSearchRegionSOQL(List<String> values){
        system.debug('values: '+values);
        String strRegionSOQL = 'AND ASI_CRM_Region__c IN(';
        if(values.size() > 0){
            for(String s: values){
                strRegionSOQL += '\'' +s+'\',';
            }
          strRegionSOQL = strRegionSOQL.substring(0,strRegionSOQL.length()-1) +') ';  
        }
        system.debug('strRegionSOQL: '+strRegionSOQL);
        return strRegionSOQL;
    }
    
//Modified by Kevani Chow@27/04/2016 (For Search Criteria)
     public void ViewSearch(){

        
        
        system.debug('searchDone: '+searchDone);
        system.debug('searchTaskType: '+searchTaskType);
        system.debug('searchRegion: ' +searchRegion);
        system.debug('searchChannel: '+searchChannel);
        system.debug('searchSales: ' +searchSales);
             
        userLanguage = UserInfo.getLanguage();
        listPromoStatus = new List<ASI_CRM_Promotion_Status__c >();
        mapTotalPromoStatus = new Map<Integer, Id>();
        pageNum = 1;
        totalpageNum = 0;
        totalSize = 0;
        totalNumOfUnit = 0;
        intTotalpageNum = 0;
        Integer intIndexTotalPromoStatus = 0;
        
        if(promoId != NULL){
            Id RecordTypeId = Global_RecordTypeCache.getRTId('ASI_CRM_Promotion_Status__cASI_CRM_TW_PromotionStatus');
            querySOQL = 'SELECT id, Name, ASI_CRM_Promotion__r.ASI_HK_CRM_Promotion_Name__c, ASI_CRM_Promotion__r.ASI_HK_CRM_Promotion_Start_Date__c, ' +
                        'ASI_CRM_Promotion__r.ASI_HK_CRM_Promotion_End_Date__c, ASI_CRM_Account__c, ASI_CRM_JDE_Account_Number__c, '+ 
                        'ASI_CRM_Customer_Outlet_Image__c, ASI_CRM_Customer_Outlet_Type__c, ASI_CRM_Grade__c, ' +
                        'ASI_CRM_Unit__c, ASI_CRM_Supplier__c, ASI_CRM_Task__c, ASI_CRM_Done__c, Owner.Name ' +
                        'FROM ASI_CRM_Promotion_Status__c '+ 
                        'WHERE ASI_CRM_Promotion__c = \'' + promoId + '\' '+
                        'AND RecordTypeId = \'' + RecordTypeId + '\' ' + 
                         (searchDone != null && searchDone.size() > 0?getSearchDoneSOQL(searchDone):'') +
                         (searchTaskType != null && searchTaskType.size()>0? getSeacrhTaskTypeSOQL(searchTaskType):'')+
                         (searchChannel != null && searchChannel.size()>0? getSeacrhChannelTypeSOQL(searchChannel):'') +
                         (searchRegion != null && searchRegion.size()>0? getSearchRegionSOQL(searchRegion):'') + 
                		 (searchSales != null && searchSales.size()>0? getSearchSalesSOQL(searchSales):'');                             // Added by 2018-08-07 Linus@introv
                         
            System.debug('Query Promotions:' + querySOQL);
            listPromoStatus = Database.query(querySOQL +' ORDER BY ASI_CRM_JDE_Account_Number__c LIMIT 2000');   
            system.debug('listPromoStatus: '+listPromoStatus);
            
            totalSize = listPromoStatus.size();
            totalpageNum = math.ceil(totalSize/pageSize);
            intTotalpageNum = Integer.valueof(totalpageNum);
        }
        System.debug('listPromoStatus.size(): '+listPromoStatus.size());
        
         if (listPromoStatus != null && listPromoStatus.size() > 0)
            for (ASI_CRM_Promotion_Status__c mp : listPromoStatus){
                mapTotalPromoStatus.put(intIndexTotalPromoStatus++, mp.id);
                totalNumOfUnit += mp.ASI_CRM_Unit__c;
            }
        

        if(mapTotalPromoStatus!=null && mapTotalPromoStatus.size() > 0){
            System.debug('mapTotalPromoStatus.size(): '+mapTotalPromoStatus.size());
            System.debug('searchCurrentPage run ');
            searchCurrentPage();
        }else{
            pageNum = 0;
            searchCurrentPage();
        }   
        
    }
    
    public Class classPromoStatus{
        public ASI_CRM_Promotion_Status__c mPromoStatus {get; set;}
        public String imageURL1 {get; set;}
        public String imageURL2 {get; set;}
        //Added by Kevani Chow@Introv 27/4/2016 (for display 4 images)
        public String imageURL3 {get; set;}
        public String imageURL4 {get; set;}
    }
    
    public ASI_CRM_TW_PromoStatusByPromotion_Ctrl(ApexPages.StandardController controller) {
        promoId = ApexPages.currentPage().getParameters().get('id');
        
        promo = [Select Name, ASI_HK_CRM_Promotion_Name__c, ASI_HK_CRM_Promotion_Start_Date__c, ASI_HK_CRM_Promotion_End_Date__c From ASI_HK_CRM_Promotion__c WHERE Id =: promoId];
        promoCodeAndName = promo.Name + ' / ' + promo.ASI_HK_CRM_Promotion_Name__c;
        //promo = (ASI_HK_CRM_Promotion__c)controller.getrecord();
        
        Initial();

    }
       
    
    private String getPagnationRecords(){
        String strMPromoStatusIds = '\'000000000000000\'';
        
        for(Double i = counter;i < Math.min((counter + pageSize), totalSize); i++){
            Integer j = integer.valueof(i);
            if(mapTotalPromoStatus.get(j) != null){
                String strMTaskId = mapTotalPromoStatus.get(j);
                strMPromoStatusIds = strMPromoStatusIds + ',\'' + strMTaskId + '\'';
            }
        }
        return strMPromoStatusIds;
    }
    
     public void searchCurrentPage(){
        setPageNum = new Set<Integer>();
        disablePrevious = getDisablePrevious();
        disableNext = getDisableNext();
        
        setPromoStatusId = new Set<Id>();
        mapPromoStatus = new Map<Integer, classPromoStatus>();
        listAttachments = new List<Attachment>();
        mapAttachmentByPromoStatus = new Map<Id, List<Attachment>>();
        
        Integer intIndexMerchanTask = 0;
        
        recordNumberDisplay = '(' + String.valueOf(Integer.valueof(counter) + 1)+ ' - ' + String.valueOf(Integer.valueof(Math.min((counter + pageSize), totalSize))) + (userlanguage == 'zh_TW'?' 之 ':' of ') + String.valueOf(Integer.valueof(totalSize)) + ')';   
        
        listPromoStatus = Database.query(querySOQL + ' AND id IN ( ' + getPagnationRecords() + ')  ORDER BY ASI_CRM_JDE_Account_Number__c ');
        system.debug('listPromoStatus in searchCurrentPage: '+listPromoStatus);
        
        if(listPromoStatus != null && listPromoStatus.size() > 0)
            for (ASI_CRM_Promotion_Status__c mp : listPromoStatus){
                setPromoStatusId.add(mp.id);
            }
        
        if (setPromoStatusId != null && setPromoStatusId.size() > 0){
        
            for (Attachment attch : [SELECT id, ParentId, Name FROM Attachment WHERE ParentId IN:setPromoStatusId AND Name LIKE 'PromoStatus%' ORDER BY NAME DESC]){
                List<Attachment> listAttch = new List<Attachment>();
                if(attch.ParentId != NULL && mapAttachmentByPromoStatus.get(attch.ParentId) != NULL){
                    listAttch = mapAttachmentByPromoStatus.get(attch.ParentId);
                    listAttch.add(attch);
                }
                else{
                    listAttch.add(attch);
                }
                mapAttachmentByPromoStatus.put(attch.ParentId, listAttch);
            }
            system.debug('listPromoStatus: ' + listPromoStatus);
            for (ASI_CRM_Promotion_Status__c mp : listPromoStatus){
                classPromoStatus objPromotStatus = new classPromoStatus();
                String URL1 = NULL;
                String URL2 = NULL;
                String URL3 = NULL;
                String URL4 = NULL;
                
                
                if(mapAttachmentByPromoStatus != NULL && mapAttachmentByPromoStatus.get(mp.id) != NULL){
                    if(mapAttachmentByPromoStatus.get(mp.id).size() > 0)
                        URL1 = '/servlet/servlet.FileDownload?file='+mapAttachmentByPromoStatus.get(mp.id)[0].id;
                    if(mapAttachmentByPromoStatus.get(mp.id).size() > 1)
                        URL2 = '/servlet/servlet.FileDownload?file='+mapAttachmentByPromoStatus.get(mp.id)[1].id;
                    if(mapAttachmentByPromoStatus.get(mp.id).size() > 2)
                        URL3 = '/servlet/servlet.FileDownload?file='+mapAttachmentByPromoStatus.get(mp.id)[2].id;
                    if(mapAttachmentByPromoStatus.get(mp.id).size() > 3)
                        URL4 = '/servlet/servlet.FileDownload?file='+mapAttachmentByPromoStatus.get(mp.id)[3].id;
                }
                
                objPromotStatus.mPromoStatus = mp;
                objPromotStatus.imageURL1 = URL1;
                objPromotStatus.imageURL2 = URL2;
                objPromotStatus.imageURL3 = URL3;
                objPromotStatus.imageURL4 = URL4;
                mapPromoStatus.put(intIndexMerchanTask++, objPromotStatus);
            }
            system.debug('mapPromoStatus: '+mapPromoStatus);
            //Redirect page setting
            for(Integer i=1; i<=Integer.valueof(totalpageNum); i++){
                setPageNum.add(i);
            }
        }
    }
    
    public void pageRedirect(){
        if(setPageNum.contains(pageNum)){
            if(Double.valueof(pageNum) != 1)
                counter = (Double.valueof(pageNum)-1)*pageSize;
            else
                counter = 0;
            searchCurrentPage();
        }
        else{
            if(userlanguage == 'zh_TW')
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, '??'+setPageNum.size()+'?, ???????.'));              
            else
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'There are only '+setPageNum.size()+' pages, please enter correct page number.'));
        }
    }
    
    //user clicked beginning
    public PageReference Beginning(){
        pageNum = 1;
        counter = 0;
        searchCurrentPage();
        return null;
    }
    
    //user clicked previous button
    public PageReference Previous(){
        pageNum -= 1;
        counter -= pageSize;
        searchCurrentPage();
        return null;
    }
    
    //user clicked next button
    public PageReference Next(){
        pageNum += 1;
        counter += pageSize;
        searchCurrentPage();
        return null;
    }
    
    //user clicked end  
    public PageReference End(){
        pageNum = intTotalpageNum;
        counter = totalSize - pageSize;    
        System.debug('intTotalpageNum: ' + intTotalpageNum + ' totalSize: ' + totalSize + ' pageSize: ' + pageSize);
        searchCurrentPage();
        return null;
    }
    
    //this will disable the previous and beginning buttons
    public Boolean getDisablePrevious(){ 
        if (counter > 0) 
            disablePrevious = false;
        else 
            disablePrevious = true;
        return disablePrevious;
    }
    
    //this will disable the next and end buttons
    public Boolean getDisableNext(){
        if (counter + pageSize < totalSize) 
            disableNext = false; 
        else 
            disableNext = true;
        return disableNext;
    }
}