/**********************************************************************************
 * Name : ASI_CRM_KR_ListViewInput 
 * Created : Vincent Lam
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * ??										Created
 * 2018-07-12       Laputa: Vincent         [VL 1.0] only display SIT for T1, T2 and T3 wholesalers
 * 2018-07-26       Laputa: Vincent         [VL 2.0] disable the input if the selected month is locked
 **********************************************************************************/
public with sharing class ASI_CRM_KR_ListViewInput {
   	
   	
   	/*Method for Remote action to save records*/
   	@RemoteAction
    public static String saveSITRecords (List<String>itemGrps, List<String> Customers, List<ASI_KOR_Stock_In_Trade__c> SITheaders , List<ASI_KOR_WS_Stock_In_Trade_Detail__c>SITDetails, String year, String month){
        String msg = '';
        String additionalMsg = '';
        Boolean saveSuccess = true;
        Set<String> keys = new Set<String>();
        Integer isCreated = 0;
        Integer isUpdated = 0;   
        
        //additionalMsg+= year +month;
        
        Map<Id, Account> customerMap = new Map<Id, Account>([Select id, ASI_KOR_Customer_Code__c from Account where Id in: Customers]);
        
        for(ASI_KOR_Stock_In_Trade__c sitHeader : sitHeaders){
            // need to add RecordType
            sitHeader.ASI_KOR_Sys_Stock_in_trade_header_ID__c  = year +'_'+ month + '_' + customerMap.get(sitHeader.ASI_KOR_Wholesaler__c).ASI_KOR_Customer_Code__c;
            keys.add(sitHeader.ASI_KOR_Sys_Stock_in_trade_header_ID__c);
        }
        
        System.Savepoint pSavepoint = Database.setSavepoint();

        if(sitHeaders!=null && sitHeaders.size()>0){
            try{

                Database.upsertResult[] results = Database.upsert(sitHeaders, ASI_KOR_Stock_In_Trade__c.ASI_KOR_Sys_Stock_in_trade_header_ID__c, true);
                if (results != null){
                    for (Database.upsertResult result : results) {
                        if (!result.isSuccess()) {
                            Database.Error[] errs = result.getErrors();
                            for(Database.Error err : errs){
                                 System.debug(err.getStatusCode() + ' - ' + err.getMessage());
                                 Database.rollback(pSavepoint); 
                                 saveSuccess = false;
                                 additionalMsg +='Cannot save SIT Header: ' +err.getStatusCode() + ' - ' + err.getMessage();
                            }
                               
            
                        }
                        if(result.isSuccess()){
                                isCreated += result.isCreated()?1:0;
                                isUpdated += result.isCreated()?0:1;
                        }
                    }
                    //if(isCreated>0) additionalMsg +='Total '+ isCreated +' SIT header(s) is(are) created.';
                    //if(isUpdated>0) additionalMsg +='Total '+ isUpdated +' SIT header(s) is(are) updated.';
                }                
            }catch (exception e){
                saveSuccess = false;
                Database.rollback(pSavepoint); 
                additionalMsg +='Cannot save SIT Header: ' + e.getTypeName() + ' - ' + e.getCause() + ': ' + e.getMessage();

            }

        } 
        
        Map<String,ASI_KOR_Stock_In_Trade__c> sitHeaderMap = new Map<String, ASI_KOR_Stock_In_Trade__c>();
        
        for(ASI_KOR_Stock_In_Trade__c sitHeader :[Select Id, ASI_KOR_Sys_Stock_in_trade_header_ID__c, ASI_KOR_Status__c  from  ASI_KOR_Stock_In_Trade__c 
                                                  where ASI_KOR_Month__c =: month and 	ASI_KOR_Year__c =: year
                                                  
                                                  //ASI_KOR_Sys_Stock_in_trade_header_ID__c in:keys
                                                  ] ){
              
              sitHeaderMap.put(sitHeader.ASI_KOR_Sys_Stock_in_trade_header_ID__c,sitHeader);                                       
        } 
        
        Map<String, ASI_KOR_WS_Stock_In_Trade_Detail__c> sitDetailMap = new Map<String, ASI_KOR_WS_Stock_In_Trade_Detail__c>();
        
        for(ASI_KOR_WS_Stock_In_Trade_Detail__c sitDetail : [Select id, ASI_KOR_Item_Group_Code__c , ASI_CRM_KR_HeaderID_Upload__c,	Stock_In_Trade__r.ASI_KOR_Status__c  from ASI_KOR_WS_Stock_In_Trade_Detail__c 
                                                             where Stock_In_Trade__r.ASI_KOR_Month__c =: month and 	Stock_In_Trade__r.ASI_KOR_Year__c =: year]){
                                                                 
                                                                 //	Stock_In_Trade__r.ASI_KOR_Sys_Stock_in_trade_header_ID__c in: sitHeaderMap.keySet()
                                                                 
            sitDetailMap.put(sitDetail.ASI_CRM_KR_HeaderID_Upload__c +'_' + sitDetail.ASI_KOR_Item_Group_Code__c, sitDetail);
        }
        
        Integer listPos = 0;
        set<Integer> removePos = new set<Integer>();
        Map<Id, ASI_KOR_WS_Stock_In_Trade_Detail__c> deleteLinesMap = new Map<Id, ASI_KOR_WS_Stock_In_Trade_Detail__c>();
        
        for(ASI_KOR_WS_Stock_In_Trade_Detail__c sitDetail : SITDetails){
            // need to add RecordType
            if(customerMap.containsKey(sitDetail.ASI_CRM_KR_HeaderID_Upload__c)){
               sitDetail.ASI_CRM_KR_HeaderID_Upload__c  = year +'_'+ month + '_' + customerMap.get(sitDetail.ASI_CRM_KR_HeaderID_Upload__c).ASI_KOR_Customer_Code__c; 
            }
            
            //additionalMsg+= sitDetail.ASI_CRM_KR_HeaderID_Upload__c ;
            if(!sitHeaderMap.isEmpty() && sitHeaderMap.containsKey(sitDetail.ASI_CRM_KR_HeaderID_Upload__c) ){
                if(!Test.isRunningTest()){
                    sitDetail.Stock_In_Trade__c = sitHeaderMap.get(sitDetail.ASI_CRM_KR_HeaderID_Upload__c).Id;
                }
                //sitDetail.Stock_In_Trade__r = new ASI_KOR_Stock_In_Trade__c( ASI_KOR_Sys_Stock_in_trade_header_ID__c  = sitDetail.ASI_CRM_KR_HeaderID_Upload__c );                
            }else{
                removePos.add(listPos); 
            }

            
            if(sitDetailMap!=null&& sitDetailMap.size()>0 && sitDetailMap.containsKey(sitDetail.ASI_CRM_KR_HeaderID_Upload__c +'_' + sitDetail.ASI_KOR_Item_Group_Code__c)){
                sitDetail.Id = sitDetailMap.get(sitDetail.ASI_CRM_KR_HeaderID_Upload__c +'_' + sitDetail.ASI_KOR_Item_Group_Code__c).Id;
            }
            
            if(sitDetail.Id!=null){
                //record is locked
                if(sitHeaderMap.containsKey(sitDetail.ASI_CRM_KR_HeaderID_Upload__c) && sitHeaderMap.get(sitDetail.ASI_CRM_KR_HeaderID_Upload__c ).ASI_KOR_Status__c != 'Editable'){
                     removePos.add(listPos); 
                }//delete if the endstock = 0
                else if(sitDetail.ASI_KOR_WS_SIT_End_Stock__c == 0 && sitHeaderMap.get(sitDetail.ASI_CRM_KR_HeaderID_Upload__c ).ASI_KOR_Status__c == 'Editable'){
                    removePos.add(listPos); 
                    deleteLinesMap.put(sitDetail.Id, sitDetail);
                }
            }
            
            sitDetail.ASI_KOR_WS_SIT_LastMonthEndingStock__c  = sitDetail.ASI_KOR_WS_SIT_LastMonthEndingStock__c ==null? 0: sitDetail.ASI_KOR_WS_SIT_LastMonthEndingStock__c;
             
            if(sitDetail.ASI_KOR_WS_SIT_End_Stock__c == 0  && sitDetail.Id== null){//&& sitDetail.ASI_KOR_WS_SIT_LastMonthEndingStock__c ==0
                //Not insert 0 QTY -  
                removePos.add(listPos);
            }
            
           
            
            
            listPos++;
        }
        
        List<ASI_KOR_WS_Stock_In_Trade_Detail__c> finalsitDetailListCopy = new List<ASI_KOR_WS_Stock_In_Trade_Detail__c>(); 
        
        if(removePos!=null && removePos.size()>0){
             listPos = 0;
             system.debug( 'removePos.size() = ' + removePos.size());
                     
                for(ASI_KOR_WS_Stock_In_Trade_Detail__c sitDetail : SITDetails){
                    
                    
                    if(!removePos.contains(listPos)) {
                        additionalMsg += '';
                        finalsitDetailListCopy.add(sitDetail);
                    }
                    
                    listPos++;
                }
                
                //additionalMsg +='Total '+ SITDetails.size() + '|' + finalsitDetailListCopy.size() +' SIT detail(s) is(are) updated.';
        }else{ 
            
            finalsitDetailListCopy = SITDetails;
           // additionalMsg +='Total '+ finalsitDetailListCopy.size() +' SIT detail(s) is(are) updated.';
        }
        

        
        if(finalsitDetailListCopy!=null && finalsitDetailListCopy.size()>0){
            try{
                isCreated = 0;
                isUpdated = 0; 
                Database.upsertResult[] results = Database.upsert(finalsitDetailListCopy,ASI_KOR_WS_Stock_In_Trade_Detail__c.Id, true); 
                if (results != null){
                    for (Database.upsertResult result : results) {
                        if (!result.isSuccess()) {
                            Database.Error[] errs = result.getErrors();
                            for(Database.Error err : errs){
                                 System.debug(err.getStatusCode() + ' - ' + err.getMessage());
                                 saveSuccess = false;
                                 Database.rollback(pSavepoint); 
                                 additionalMsg +='Cannot save SIT Detail: ' +err.getStatusCode() + ' - ' + err.getMessage();
                            }
                               
            
                        }
                        if(result.isSuccess()){
                                isCreated += result.isCreated()?1:0;
                                isUpdated += result.isCreated()?0:1;
                        }
                    }
                }
                               if(isCreated>0)  additionalMsg +='Total '+ isCreated +' SIT detail(s) is(are) created.';
                               if(isUpdated>0) additionalMsg +='Total '+ isUpdated +' SIT detail(s) is(are) updated.';
                                
            }catch (exception e){
                saveSuccess = false;
                Database.rollback(pSavepoint); 
                additionalMsg+='Cannot save SIT Detail: ' + e.getTypeName() + ' - ' + e.getCause() + ': ' + e.getMessage();
            }

        }      
        
        if(! deleteLinesMap.isEmpty() &&  deleteLinesMap.size()>0){
            try{
                Integer isDeleted = 0; 
                Database.DeleteResult[] results = Database.delete(deleteLinesMap.values(), true); 
                // Operation failed, so get all errors          
                for(Database.DeleteResult result : results) {
                    if (result.isSuccess()) {
                        // Operation was successful, so get the ID of the record that was processed
                        System.debug('Successfully deleted account with ID: ' + result.getId());
                        //additionalMsg +=result.getId() + ' is deleted.';
                        isDeleted+=1;
                    }  else{
                        for(Database.Error err : result.getErrors()) {
                            System.debug('The following error has occurred.');                    
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            saveSuccess = false;
                            Database.rollback(pSavepoint); 
                            additionalMsg +='Cannot delete SIT Detail: ' +err.getStatusCode() + ' - ' + err.getMessage();
                            System.debug('SIT detail fields that affected this error: ' + err.getFields());
                        }
                    }
                }
                
                if(isDeleted>0) additionalMsg +='Total '+ isDeleted +' SIT detail(s) is(are) deleted.';
            }catch (exception e){
                saveSuccess = false;
                Database.rollback(pSavepoint); 
                additionalMsg+='Cannot delete SIT Detail: ' + e.getTypeName() + ' - ' + e.getCause() + ': ' + e.getMessage();
            }
        }
                
        if(saveSuccess){
            msg ='Save Success.' + additionalMsg; 
            if(finalsitDetailListCopy ==null || finalsitDetailListCopy.size()==0){
                msg ='No record(s) is(are) updated.';
            }
        }else{
            Database.rollback(pSavepoint); 
            msg = additionalMsg;
        }
        
        return msg;
    }
   	
   	
    /*Method to convert integer to Month*/
    public static Map<Integer,String> monthMap {set;get;}
    {
       monthMap = new Map<Integer,String>{1=>'January',2=>'February', 3=>'March', 4=>'April', 5=> 'May', 6=>'June' , 7=>'July', 8=>'August', 9=>'September', 10=>'October', 11=>'November', 12=>'December'};
    }
    
    /*General Variable*/
    public static final String SIT_Editable_RecordType_Developer_Name ='ASI_KOR_SIT_Editable';
    public static final String SIT_Locked_RecordType_Developer_Name ='ASI_KOR_SIT_Locked';
    public static final String KOR_WholeSaler_RecordType_Developer_Name ='ASI_KOR_Wholesaler';
    
    /*Search Variable*/ /***transient if needed*/ 
    public String WhereStatm {get;set;}{WhereStatm='';}
    private String init_soql {get;set;} 
    public String Selectedyear {set;get;}  {Selectedyear = string.valueof(Date.today().year());}
    public String Selectedmonth {set;get;}
          {if (Date.today().month() < 10) {
                selectedmonth = '0'+string.valueof(Date.today().month());
            }
            else{
                selectedmonth = string.valueof(Date.today().month());
            }  
          }
    public String Realyear {set;get;}  {Realyear = string.valueof(Date.today().year());}
    public String Realmonth {set;get;} 
          {if (Date.today().month() < 10) {
                Realmonth = '0'+string.valueof(Date.today().month());
            }
            else{
                Realmonth = string.valueof(Date.today().month());
            }  
          }   
    
    /*Constructor*/
    public ASI_CRM_KR_ListViewInput(){
        //For Search Function:
         AcctNamefilter = new ASI_CRM_AccountsAdditionalField__c();
         ItemCodefilter = new ASI_KOR_WS_Stock_In_Trade_Detail__c();   
         initialLoad();
         RunQuery();
    }
    
    /*Initial Function*/
    public void initialLoad(){
         AcctNamefilter = new ASI_CRM_AccountsAdditionalField__c();
         ItemCodefilter = new ASI_KOR_WS_Stock_In_Trade_Detail__c(); 
         
         CustomerMapping = new Map<Id, Account>();
        //Get current year 
        Selectedyear = String.valueOf(Date.today().year());
        // Get last month
        SelectedMonth = String.valueOf(Date.today().addMonths(-1).month()).leftPad(2).replace(' ', '0');
        
        init_soql = 'SELECT ID, ASI_KOR_Item_Group_Code__c,ASI_KOR_Item_Group_Code__r.name, ASI_KOR_WS_SIT_LastMonthEndingStock__c, ASI_KOR_WS_SIT_End_Stock__c,ASI_CRM_KR_HeaderID_Upload__c, '+ 
            		'Stock_In_Trade__r.ASI_KOR_Wholesaler__r.name, Stock_In_Trade__r.ASI_KOR_Wholesaler__c, Stock_In_Trade__r.ASI_KOR_Wholesaler__r.ASI_KOR_Customer_Code__c,'+ 
                    'Stock_In_Trade__r.ASI_KOR_SYS_Month__c,Stock_In_Trade__r.ASI_KOR_Year__c, 	Stock_In_Trade__r.ASI_KOR_Status__c, '+
                    'Stock_In_Trade__r.ASI_KOR_SYS_Period_Code__c,Stock_In_Trade__c, Stock_In_Trade__r.ASI_KOR_Sys_Stock_in_trade_header_ID__c '+
                    'FROM ASI_KOR_WS_Stock_In_Trade_Detail__c WHERE Stock_In_Trade__r.ASI_KOR_Wholesaler__c!=null ';
                
       if(itemGroupMap!=null&& itemGroupMap.size()>0)
       {
                            for( ASI_KOR_Item_Group__c Eachitem: itemGroupMap.values()){
                                    itemGroupMapping.put(EachItem.id, EachItem.name);
                            }
                                
       }
       
       if(accountMap!=null && accountMap.size()>0)
        {
            
                CustomerMapping.putAll(accountMap);
        }
    }
    
 
    /*Method for RunQuery*/
    public PageReference runQuery() {
		msg ='';
        displayPanel = false;
        withLastMonthData = false;
    	/*Get last Month*/
    	All_Cust_Brand_QuantityMap = new Map<Id,Map<string,ASI_KOR_WS_Stock_In_Trade_Detail__c>>();

        Integer lastmonthInt = Integer.valueOf(SelectedMonth.replace('0',''))-1>0? Integer.valueOf(SelectedMonth.replace('0',''))-1:12;
        
        String lastMonthPeriodCode = lastmonthInt==12? String.valueOf(Integer.valueOf(Selectedyear)-1 )  + String.valueOf(lastmonthInt).leftPad(2).replace(' ', '0'):  Selectedyear  + String.valueOf(lastmonthInt).leftPad(2).replace(' ', '0'); 
        String CurrentPeriodCode = Selectedyear + selectedmonth;
        MonthEng(integer.valueOf(Selectedmonth));
        
        system.debug('Current PeriodCode : '+ CurrentPeriodCode);
        system.debug('Last PeriodCode: '+ lastMonthPeriodCode);
		
		/* [VL 2.0] BEGIN */
		list<ASI_KOR_Stock_In_Trade__c> list_sitLocked = [select id from ASI_KOR_Stock_In_Trade__c where recordtype.developername = :SIT_Locked_RecordType_Developer_Name and ASI_KOR_SYS_Period_Code__c = :CurrentPeriodCode limit 1];
		boolean thisMonthIsLocked = list_sitLocked.size() > 0 ? true : false;
		/* [VL 2.0] END */
        
        WhereStatm ='';
         
        WhereStatm='AND ASI_KOR_Item_Group_Code__R.ASI_CRM_KR_StockInTradeSIT__c = TRUE AND ASI_KOR_Item_Group_Code__c !=null '; 
        whereStatm+='AND (Stock_In_Trade__r.RecordType.DeveloperName=\''+ SIT_Editable_RecordType_Developer_Name +'\' OR Stock_In_Trade__r.RecordType.DeveloperName=\''+ SIT_Locked_RecordType_Developer_Name +'\') ';
       
        if(!Test.isRunningTest()){
            WhereStatm +='And (Stock_In_Trade__r.ASI_KOR_SYS_Period_Code__c =\''+String.escapeSingleQuotes(CurrentPeriodCode)+'\' OR Stock_In_Trade__r.ASI_KOR_SYS_Period_Code__c =\''+String.escapeSingleQuotes(lastMonthPeriodCode)+'\') ';
        }
        
        if(AcctNamefilter.ASI_CRM_Account__c!=null){
                
                WhereStatm +=  'And Stock_In_Trade__r.ASI_KOR_Wholesaler__r.ASI_KOR_Venue_Status__c = \'Active\' AND Stock_In_Trade__r.ASI_KOR_Wholesaler__c = \''+String.escapeSingleQuotes(AcctNamefilter.ASI_CRM_Account__c)+'\' ';
           }
           
         if(ItemCodefilter.ASI_KOR_Item_Group_Code__c!=null ){
               
                WhereStatm +=  'And ASI_KOR_Item_Group_Code__c = \''+String.escapeSingleQuotes(ItemCodefilter.ASI_KOR_Item_Group_Code__c)+'\' ';
         } 
           
        try {

                
                // restructure the map
                //Set of Customer 
               
                String acctSOQL = 'select Id, Name,  ASI_KOR_Customer_Code__c , NameLocal, ASI_KOR_Grade__c from Account where ASI_KOR_Venue_Status__c = \'Active\' AND RecordType.DeveloperName =\'' + KOR_WholeSaler_RecordType_Developer_Name+'\' ' + ' And OwnerId =\'' + UserInfo.getUserId() +'\' ' ;
                /* [VL 1.0] BEGIN */
				acctSOQL += ' AND ASI_KOR_Grade__c in (\'T1\', \'T2\', \'T3\') ';
				/* [VL 1.0] END */
				String acctWhereSOQL = '';
                
                if(ItemCodefilter.ASI_KOR_Item_Group_Code__c!=null ){
                    
                     itemGroupMapping.clear();
                     
                     for(ASI_KOR_Item_Group__c item : [select id, name, ASI_KOR_Item_Group_Name__c 
                                                    from ASI_KOR_Item_Group__c
                                                    where ASI_CRM_KR_StockInTradeSIT__c = TRUE
                                                    AND ID =: ItemCodefilter.ASI_KOR_Item_Group_Code__c] ){
                                                        
                           itemGroupMapping.put(item.Id, item.Name);                 
                      }
                      
                     
                     
                }else{
                        
                    itemGroupMapping.clear();
                    if(itemGroupMap!=null&& itemGroupMap.size()>0)
                        {
                            for( ASI_KOR_Item_Group__c Eachitem: itemGroupMap.values()){
                                itemGroupMapping.put(EachItem.id, EachItem.name);
                            }
                        }
                }  


            
                if(AcctNamefilter.ASI_CRM_Account__c!=null){
                    
                        acctWhereSOQL =  'And Id = \''+String.escapeSingleQuotes(AcctNamefilter.ASI_CRM_Account__c)+'\' ';
                        CustomerMapping.clear();
                 
                     for(Account acc: Database.query(acctSOQL + acctWhereSOQL)){

                                     CustomerMapping.put(acc.Id, acc);
               	    } 
                    
                }else{
                    
                    CustomerMapping.clear();
                       if(accountMap!=null && accountMap.size()>0)
                        {
                            
                                CustomerMapping.putAll(accountMap);
                        }                    
                }
                
               
               	
               	if(CustomerMapping!=null && CustomerMapping.size()>0){
               	     Set<Id> accountIds =CustomerMapping.keyset();// (Set<Id>)JSON.deserialize(JSON.serialize(CustomerMapping.keySet()), Set<Id>.class);
               	      WhereStatm +=  'And Stock_In_Trade__r.ASI_KOR_Wholesaler__c in : accountIds ';
               	}
             
                List<ASI_KOR_WS_Stock_In_Trade_Detail__c> SIT_Line_List  = new List<ASI_KOR_WS_Stock_In_Trade_Detail__c>();
                SIT_Line_List = Database.query(init_soql + WhereStatm ); //+ 'limit 1000' 
            
            	system.debug(SIT_Line_List+'Test SIT_Line_List: '+init_soql + WhereStatm ); 
                
                /*    
                if(SIT_Line_List.size()>1000){ 
                    //searchPermission=false;
                    Msg='Select Size > 1000. Please minimize you filter.'+ '</br>';
                    
                }
            	*/
            	
            	if(SIT_Line_List == null || SIT_Line_List.size() ==0 ){   
                    Msg+='No record found. ' + '</br>';
                    displayPanel = false;
                } 
                
                Map<String,Map<Id, Map<String,  ASI_KOR_WS_Stock_In_Trade_Detail__c>>> CustomeritemPeriodSITMap = new Map<String,Map<Id, Map<String,  ASI_KOR_WS_Stock_In_Trade_Detail__c>>>();
                Map<Id, Map<String,  ASI_KOR_WS_Stock_In_Trade_Detail__c>> tempCustomerItemMap = new Map<Id, Map<String,  ASI_KOR_WS_Stock_In_Trade_Detail__c>>();
                Map<String,  ASI_KOR_WS_Stock_In_Trade_Detail__c> tempPeriodMap = new Map<String,  ASI_KOR_WS_Stock_In_Trade_Detail__c>();
                                                    
                for(ASI_KOR_WS_Stock_In_Trade_Detail__c sit : SIT_Line_List){
                    if(CustomeritemPeriodSITMap.containsKey(sit.Stock_In_Trade__r.ASI_KOR_Wholesaler__c)){
                        tempCustomerItemMap = CustomeritemPeriodSITMap.get(sit.Stock_In_Trade__r.ASI_KOR_Wholesaler__c);
                    }else tempCustomerItemMap = new Map<Id, Map<String,  ASI_KOR_WS_Stock_In_Trade_Detail__c>>();
                        
                        if(tempCustomerItemMap.containsKey(sit.ASI_KOR_Item_Group_Code__c)) {
                                tempPeriodMap = tempCustomerItemMap.get(sit.ASI_KOR_Item_Group_Code__c);
                        }else tempPeriodMap = new Map<String,  ASI_KOR_WS_Stock_In_Trade_Detail__c>();
                                if(!tempPeriodMap.containskey(sit.Stock_In_Trade__r.ASI_KOR_SYS_Period_Code__c)){
                                    tempPeriodMap.put(sit.Stock_In_Trade__r.ASI_KOR_SYS_Period_Code__c, sit);
                                    tempCustomerItemMap.put(sit.ASI_KOR_Item_Group_Code__c, tempPeriodMap); 
                                }
                        
                        
                     CustomeritemPeriodSITMap.put(sit.Stock_In_Trade__r.ASI_KOR_Wholesaler__c, tempCustomerItemMap);
					 
				
                }
                

                
  
                /*
                if(Selectedyear=='2018') {
                    system.assertEquals(JSON.serialize(CustomeritemPeriodSITMap.values()), null);
                }
                */
                
                if(CustomerMapping!=null && CustomerMapping.size()>0){
                    
                    
                    Map<String, ASI_KOR_WS_Stock_In_Trade_Detail__c> itemSIT = new Map<String, ASI_KOR_WS_Stock_In_Trade_Detail__c>(); 
                    Set<String> cannotEditSet = new Set<String>();
                        for(String customerId :  CustomerMapping.keySet()){
                            
                            if(CustomeritemPeriodSITMap!=null && CustomeritemPeriodSITMap.containsKey(customerId))
                                  tempCustomerItemMap = CustomeritemPeriodSITMap.get(customerId);
                                else tempCustomerItemMap =  new Map<Id, Map<String,  ASI_KOR_WS_Stock_In_Trade_Detail__c>>();
                            
                            itemSIT = new Map<String, ASI_KOR_WS_Stock_In_Trade_Detail__c>(); 
                            
                            ASI_KOR_WS_Stock_In_Trade_Detail__c tempSIT = new ASI_KOR_WS_Stock_In_Trade_Detail__c();
                            
                            for(String item: itemGroupMapping.keySet()){
                                tempSIT = new ASI_KOR_WS_Stock_In_Trade_Detail__c();
                                
                                if(tempCustomerItemMap!=null && tempCustomerItemMap.containskey(item)){
                                    //find the item 
                                    tempPeriodMap = tempCustomerItemMap.get(item);
                                    //find the last month record 
                                    tempSIT.ASI_KOR_Item_Group_Code__c = Id.valueOf(item); 
                                    if(tempPeriodMap==null || tempPeriodMap.size()==0){
                                       tempSIT.ASI_KOR_Item_Group_Code__c= Id.valueOf(item);
                                       tempSIT.ASI_KOR_WS_SIT_LastMonthEndingStock__c = 0;
                                       tempSIT.ASI_KOR_WS_SIT_End_Stock__c = 0; 
                                    }else{
                                        if(tempPeriodMap.containskey(CurrentPeriodCode)){
                                            tempSIT.Id = tempPeriodMap.containskey(CurrentPeriodCode)?tempPeriodMap.get(CurrentPeriodCode).Id : null;
                                            if(tempPeriodMap.get(CurrentPeriodCode).Stock_In_Trade__r.ASI_KOR_Status__c <>'Editable'){ 
                                                cannotEditSet.add(CustomerId);
                                            }   
                                        }
                                        tempSIT.ASI_KOR_WS_SIT_LastMonthEndingStock__c  = (tempPeriodMap.containskey(lastMonthPeriodCode))?Integer.valueOf(tempPeriodMap.get(lastMonthPeriodCode).ASI_KOR_WS_SIT_End_Stock__c):0;
                                        tempSIT.ASI_KOR_WS_SIT_End_Stock__c = (tempPeriodMap.containskey(CurrentPeriodCode))?Integer.valueOf(tempPeriodMap.get(CurrentPeriodCode).ASI_KOR_WS_SIT_End_Stock__c):0;
                                        }
                                }else{
                                   tempSIT.Id = null;
                                   tempSIT.ASI_KOR_Item_Group_Code__c= Id.valueOf(item);
                                   tempSIT.ASI_KOR_WS_SIT_LastMonthEndingStock__c = 0;
                                   tempSIT.ASI_KOR_WS_SIT_End_Stock__c = 0;
                                }
                                
                                itemSIT.put(item, tempSIT);
                            }
                            All_Cust_Brand_QuantityMap.put(CustomerId, itemSIT);
                            

                        }
                        
                        
                        if(!All_Cust_Brand_QuantityMap.isEmpty()){
                                for(String customerId: All_Cust_Brand_QuantityMap.keyset()){
                                    Map<string,ASI_KOR_WS_Stock_In_Trade_Detail__c> tempCustomerItemList = All_Cust_Brand_QuantityMap.get(customerId);
                                        for(ASI_KOR_WS_Stock_In_Trade_Detail__c sitValues : tempCustomerItemList.values()){
                                            if(!withLastMonthData && sitValues.ASI_KOR_WS_SIT_LastMonthEndingStock__c>0){
                                                withLastMonthData = true;
                                            }
											/* [VL 2.0] BEGIN */
											if(thisMonthIsLocked) sitValues.ASI_CRM_KR_HeaderID_Upload__c  ='Locked';
											else
											/* [VL 2.0] END */
                                            if(cannotEditSet.contains(customerId))  sitValues.ASI_CRM_KR_HeaderID_Upload__c  ='Locked';
                                            else sitValues.ASI_CRM_KR_HeaderID_Upload__c  ='Editable';
                                        }
                                }
                         }
                    
                    if(!withLastMonthData){
                        msg+='There is no last month\''+'s ending stock (SIT) for all wholesaler(s).'+ '</br>';
                    }
                            
                }else{
                    msg+= 'Cannot find related Wholesaler.'+ '</br>';
                    if(!withLastMonthData){
                        msg+='There is no last month\''+'s ending stock (SIT) for all wholesaler(s).'+ '</br>';
                    }
                    //msg+= 'CustomerMapping.size(): '+ CustomerMapping.size() + '</br>';
                    displayPanel = false;
                    //CustomerMapping = null;
                    //All_Cust_Brand_QuantityMap  =  new Map<String,Map<string,ASI_KOR_WS_Stock_In_Trade_Detail__c>>();
                    return null;
                }
                
                if(All_Cust_Brand_QuantityMap!=null && All_Cust_Brand_QuantityMap.size()>0){
                    displayPanel = true;
                }
           //system.assertEquals(All_Cust_Brand_QuantityMap,null);
             
        }catch(exception ex){
            		msg += ex.getMessage();
            		displayPanel = false;
                    //itemGroupMapping= null;
                    //CustomerMapping = null;
                    //All_Cust_Brand_QuantityMap  =  new Map<String,Map<string,ASI_KOR_WS_Stock_In_Trade_Detail__c>>();
   					system.debug(ex.getMessage());
			//system.assertEquals(ex.getMessage(),null);
        }
        
        return null;
    }
    
    public boolean displayPanel {set;get;} { displayPanel = false;}
    public boolean withLastMonthData {set;get;} { withLastMonthData= false;}

    public Map<String, String> itemGroupMapping {get;set;} { itemGroupMapping = new  Map<String, String>();}
    public Map<Id, Account> CustomerMapping {get;set;} {  CustomerMapping = new Map<Id, Account>();}
    public integer itemGroupMappingSize { get { return itemGroupMapping.size( ); } }

    public String Msg {get;set;}
          
    public ASI_CRM_AccountsAdditionalField__c AcctNamefilter{get;set;} 
    public ASI_KOR_WS_Stock_In_Trade_Detail__c ItemCodefilter{get;set;} 
    
    public string CurrentMonth_Dynamic {set;get;} 
    public string Lastmonth_Dynamic {set;get;} 
    
    public string CurrentPeriodCode{get;set;} 
    public string LastMonthPeriodCode{get;set;}
    
    public transient Map<Id, Map<String,ASI_KOR_WS_Stock_In_Trade_Detail__c>> All_Cust_Brand_QuantityMap {get;set;}
    { All_Cust_Brand_QuantityMap = new Map<Id,Map<string,ASI_KOR_WS_Stock_In_Trade_Detail__c>>();}
    
    public static Map<Id, ASI_KOR_Item_Group__c> itemGroupMap {get;set;}
    /*initial all SIT item*/
    static { 
                   itemGroupMap = new Map<Id, ASI_KOR_Item_Group__c>([select id, name, ASI_KOR_Item_Group_Name__c 
                                                                from ASI_KOR_Item_Group__c
                                                                where ASI_CRM_KR_StockInTradeSIT__c = TRUE
                                                                Order by Name , ASI_KOR_Sequence__c
                                                                ]);
                                                                

    }  
    
    
    public static  Map<Id, Account> accountMap {get;set;}
    /*initial all wholesalers*/
    static {
                String acctSOQL = 'Select Id, Name,  ASI_KOR_Customer_Code__c, NameLocal, ASI_KOR_Grade__c from Account where ASI_KOR_Venue_Status__c = \'Active\' AND RecordType.DeveloperName =\'' + KOR_WholeSaler_RecordType_Developer_Name+'\' ' + ' And OwnerId =\'' + UserInfo.getUserId() +'\' ' ;
                /* [VL 1.0] BEGIN */
				acctSOQL += ' AND ASI_KOR_Grade__c in (\'T1\', \'T2\', \'T3\') ';
				/* [VL 1.0] END */
				accountMap =  new Map<id,account>((List<account>)Database.query(acctSOQL));
        
    }

    public void MonthEng (Integer CurrentMonth){
    /*Revised by Alexis on April 5*/
        Date lastMonth =System.Date.newInstance(date.today().year(), CurrentMonth, 1).addMonths(-1);
        currentMonth_Dynamic = DateTime.newInstanceGMT(System.Date.newInstance(date.today().year(), CurrentMonth, 1), System.Time.newInstance(0, 0, 0, 0)).formatGMT('MMMM YYYY');   
        Lastmonth_Dynamic = DateTime.newInstanceGMT(lastMonth, System.Time.newInstance(0, 0, 0, 0)).formatGMT('MMMM YYYY');  
    }


}