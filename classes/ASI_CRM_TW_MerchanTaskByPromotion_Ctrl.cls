/*Filename:    ASI_CRM_TW_MerchanTaskByPromotion_Ctrl.cls
* Author:      Twinkle LI (Introv Limited)
* Purpose:     Controller Class for listing Merchandiser Tasks by Promotion
*
* -----------------------------------------------------------------------------
*/
public with sharing class ASI_CRM_TW_MerchanTaskByPromotion_Ctrl{

    public id promoId {set;get;}
    public String userLanguage {set;get;}
    public List<ASI_CRM_Merchandiser_Task__c> listMerchanTasks {set;get;}
    public Set<Id> setMerchanTasksId {set;get;}
    public Map<Integer, Id> mapTotalMerchanTasks {set;get;}
    public Map<Integer, classMerchanTask> mapMerchanTasks {set;get;}
    public List<Attachment> listAttachments {set;get;}
    public Map<Id, List<Attachment>> mapAttachmentByMerchanTask {set;get;}
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
    public Decimal totalNumOfUnit {set;get;} //sum of total number of unit for all Merchandizing tasks
    
    public Integer pageNum {set;get;}
    public Double totalpageNum {set;get;}
    public Integer intTotalpageNum {set;get;}
    public Set<Integer> setPageNum {set;get;}
    
    //Added by Kevani Chow@27/04/2016 (For Search Criteria)
    public List<String> searchDone { get; set; }
    public List<String> searchTaskType { get; set; }
    public List<String> searchRegion { get; set; }
    public List<String> searchChannel { get; set; }
    Public List<SelectOption> ChannelList{get;set;}
    public ASI_HK_CRM_Promotion__c promo {get;set;}
    //Modified by Kevani Chow@27/04/2016 (For Search Criteria)
    public void Initial(){
            
        searchDone = new List<String>();
        searchTaskType = new List<String>(); 
        searchRegion = new List<String>(); 
        searchChannel = new List<String>(); 
        ChannelList=getChannelList();
        
        ViewSearch(); 
        
        reportList =[Select ID from Report where DeveloperName = 'ASI_CRM_TW_MerchanTaskReport_byPromotion'];
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

    public List<SelectOption> getRegionList(){
        
        List<SelectOption> options = new List<SelectOption>();
        
        options.add(new SelectOption('Central','Central'));
        options.add(new SelectOption('North','North'));
        options.add(new SelectOption('North 2','North 2'));
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
        
        Schema.DescribeFieldResult fieldResult = ASI_CRM_Merchandiser_Task__c.ASI_CRM_Task__c.getDescribe();
        List<Schema.PicklistEntry> Tasklist = fieldResult.getPicklistValues();
            
        for(Schema.PicklistEntry f : Tasklist){
            options.add(new SelectOption(f.getValue(), f.getLabel()));
        }       
        return options;
    }

   //Get searchDone SOQL expression
    public String getSearchDoneSOQL(List<String> values){
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
        String strChannelSOQL = 'AND ASI_CRM_Promotion_Status__r.ASI_CRM_Promotion__r.ASI_CRM_Channel__c INCLUDES(';
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
        String strRegionSOQL = 'AND ASI_CRM_Promotion_Status__r.ASI_CRM_Region__c IN(';
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
             
        userLanguage = UserInfo.getLanguage();
        listMerchanTasks = new List<ASI_CRM_Merchandiser_Task__c>();
        mapTotalMerchanTasks = new Map<Integer, Id>();
        pageNum = 1;
        totalpageNum = 0;
        totalSize = 0;
        totalNumOfUnit = 0;
        intTotalpageNum = 0;
        Integer intIndexTotalMerchanTask = 0;
        
        if(promoId != NULL){
            Id RecordTypeId = Global_RecordTypeCache.getRTId('ASI_CRM_Merchandiser_Task__cASI_CRM_TW_Merchandiser_Task');
            querySOQL = 'SELECT id, Name, ASI_CRM_Promotion_Name__c, ASI_CRM_Start_Date__c, ASI_CRM_End_Date__c, ASI_CRM_Promotion_Status__r.ASI_CRM_Account__c, ASI_CRM_Promotion_Status__r.ASI_CRM_JDE_Account_Number__c,'+ 
                        ' ASI_CRM_Outlet_Image__c, ASI_CRM_Outlet_Type__c, ASI_CRM_Grade__c, ASI_CRM_Unit__c, ASI_CRM_Supplier__c, ASI_CRM_Task__c, ASI_CRM_Done__c, ASI_CRM_PDF__c'+
                        ' FROM ASI_CRM_Merchandiser_Task__c'+ 
                        ' WHERE ASI_CRM_Promotion_Status__r.ASI_CRM_Promotion__c = \'' +promoId+ '\''+
                        ' AND RecordTypeId = \'' +RecordTypeId+ '\'' + 
                        ' AND ASI_CRM_Promotion_Status__c != \'\''+ 
                         (searchDone != null && searchDone.size() > 0?getSearchDoneSOQL(searchDone):'') +
                         (searchTaskType != null && searchTaskType.size()>0? getSeacrhTaskTypeSOQL(searchTaskType):'')+
                         (searchChannel != null && searchChannel.size()>0? getSeacrhChannelTypeSOQL(searchChannel):'') +
                         (searchRegion != null && searchRegion.size()>0? getSearchRegionSOQL(searchRegion):'');
                         
            System.debug('Query Promotions:' + querySOQL);
            listMerchanTasks = Database.query(querySOQL +' ORDER BY ASI_CRM_JDE_Account_Number__c LIMIT 2000');   
            system.debug('listMerchanTasks: '+listMerchanTasks);
            
            totalSize = listMerchanTasks.size();
            totalpageNum = math.ceil(totalSize/pageSize);
            intTotalpageNum = Integer.valueof(totalpageNum);
        }
        System.debug('listMerchanTasks.size(): '+listMerchanTasks.size());
        
         if(listMerchanTasks != null && listMerchanTasks.size() > 0)
            for(ASI_CRM_Merchandiser_Task__c  mt : listMerchanTasks){
                mapTotalMerchanTasks.put(intIndexTotalMerchanTask++, mt.id);
                totalNumOfUnit += mt.ASI_CRM_Unit__c;
            }
        

        if(mapTotalMerchanTasks!=null && mapTotalMerchanTasks.size() > 0){
            System.debug('mapTotalMerchanTasks.size(): '+mapTotalMerchanTasks.size());
            System.debug('searchCurrentPage run ');
            searchCurrentPage();
        }else{
            pageNum = 0;
            searchCurrentPage();
        }   
        
    }
    
    public Class classMerchanTask{
        public ASI_CRM_Merchandiser_Task__c mTask {get; set;}
        public String imageURL1 {get; set;}
        public String imageURL2 {get; set;}
        //Added by Kevani Chow@Introv 27/4/2016 (for display 4 images)
        public String imageURL3 {get; set;}
        public String imageURL4 {get; set;}
    }
    
    public ASI_CRM_TW_MerchanTaskByPromotion_Ctrl(ApexPages.StandardController controller) {
        promoId = ApexPages.currentPage().getParameters().get('id');
        
        promo = [Select Name, ASI_HK_CRM_Promotion_Name__c, ASI_HK_CRM_Promotion_Start_Date__c, ASI_HK_CRM_Promotion_End_Date__c From ASI_HK_CRM_Promotion__c WHERE Id =: promoId];
        promoCodeAndName = promo.Name + ' / ' + promo.ASI_HK_CRM_Promotion_Name__c;
        //promo = (ASI_HK_CRM_Promotion__c)controller.getrecord();
        
        Initial();

    }
       
    
    private String getPagnationRecords(){
        String strMTaskIds = '\'000000000000000\'';
        
        for(Double i = counter;i < Math.min((counter + pageSize), totalSize); i++){
            Integer j = integer.valueof(i);
            if(mapTotalMerchanTasks.get(j) != null){
                String strMTaskId = mapTotalMerchanTasks.get(j);
                strMTaskIds = strMTaskIds + ',\'' + strMTaskId + '\'';
            }
        }
        return strMTaskIds;
    }
    
     public void searchCurrentPage(){
        setPageNum = new Set<Integer>();
        disablePrevious = getDisablePrevious();
        disableNext = getDisableNext();
        
        setMerchanTasksId = new Set<Id>();
        mapMerchanTasks = new Map<Integer, classMerchanTask>();
        listAttachments = new List<Attachment>();
        mapAttachmentByMerchanTask = new Map<Id, List<Attachment>>();
        
        Integer intIndexMerchanTask = 0;
        
        recordNumberDisplay = '(' + String.valueOf(Integer.valueof(counter) + 1)+ ' - ' + String.valueOf(Integer.valueof(Math.min((counter + pageSize), totalSize))) + (userlanguage == 'zh_TW'?' 之 ':' of ') + String.valueOf(Integer.valueof(totalSize)) + ')';   
        
        listMerchanTasks = Database.query(querySOQL + ' AND id IN ( ' + getPagnationRecords() + ')  ORDER BY ASI_CRM_JDE_Account_Number__c ');
        system.debug('listMerchanTasks in searchCurrentPage: '+listMerchanTasks);
        
        if(listMerchanTasks != null && listMerchanTasks.size() > 0)
            for(ASI_CRM_Merchandiser_Task__c  mt : listMerchanTasks){
                setMerchanTasksId.add(mt.id);
            }
        
        if(setMerchanTasksId != null && setMerchanTasksId.size() > 0){
        
            for(Attachment attch : [SELECT id, ParentId FROM Attachment WHERE ParentId IN:setMerchanTasksId ORDER BY CreatedDate DESC]){
                List<Attachment> listAttch = new List<Attachment>();
                if(attch.ParentId != NULL && mapAttachmentByMerchanTask.get(attch.ParentId) != NULL){
                    listAttch = mapAttachmentByMerchanTask.get(attch.ParentId);
                    listAttch.add(attch);
                }
                else{
                    listAttch.add(attch);
                }
                mapAttachmentByMerchanTask.put(attch.ParentId, listAttch);
            }
            system.debug('listMerchanTasks: '+listMerchanTasks);
            for(ASI_CRM_Merchandiser_Task__c  mt : listMerchanTasks){
                classMerchanTask objMerchanTask = new classMerchanTask();
                String URL1 = NULL;
                String URL2 = NULL;
                //Added by Kevani Chow@Introv 27/4/2016 (for display 4 images)
                String URL3 = NULL;
                String URL4 = NULL;
                
                
                if(mapAttachmentByMerchanTask != NULL && mapAttachmentByMerchanTask.get(mt.id) != NULL){
                    if(mapAttachmentByMerchanTask.get(mt.id).size() > 0)
                        URL1 = '/servlet/servlet.FileDownload?file='+mapAttachmentByMerchanTask.get(mt.id)[0].id;
                    if(mapAttachmentByMerchanTask.get(mt.id).size() > 1)
                        URL2 = '/servlet/servlet.FileDownload?file='+mapAttachmentByMerchanTask.get(mt.id)[1].id;
                    //Added by Kevani Chow@Introv 27/4/2016 (for display 4 images)
                    if(mapAttachmentByMerchanTask.get(mt.id).size() > 2)
                        URL3 = '/servlet/servlet.FileDownload?file='+mapAttachmentByMerchanTask.get(mt.id)[2].id;
                    if(mapAttachmentByMerchanTask.get(mt.id).size() > 3)
                        URL4 = '/servlet/servlet.FileDownload?file='+mapAttachmentByMerchanTask.get(mt.id)[3].id;
                }
                
                objMerchanTask.mTask = mt;
                objMerchanTask.imageURL1 = URL1;
                objMerchanTask.imageURL2 = URL2;
                //Added by Kevani Chow@Introv 27/4/2016 (for display 4 images)
                objMerchanTask.imageURL3 = URL3;
                objMerchanTask.imageURL4 = URL4;
                mapMerchanTasks.put(intIndexMerchanTask++, objMerchanTask);
            }
            system.debug('mapMerchanTasks: '+mapMerchanTasks);
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
        //Modified by Wilken on 2015-11-04, show only the remaining pagination records on last page instead of last 20 records
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