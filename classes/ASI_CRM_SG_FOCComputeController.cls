/*********************************************************************************
 * Name:ASI_CRM_SG_FOCComputeController
 * Description: 
 * Test Class: ASI_CRM_SG_FOCComputeControllerTest
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 15/01/2018         Wilken        		[WL 1.0] Add ReGenerate Contract Margin function
 * 06/02/2018         Wilken        		[WL 2.0] Allow regenerate FOC to generate for previous month
 * 16/03/2018         Wilken        		[WL 3.0] Add Wholesaler Back Rebate generation section
 * 04/05/2018         Wilken        		[WL 4.0] Add Promotion Incentive generation section
 * 2020-12-03         PRA COE               // COE 1 REMOVE ASI_CRM_SG_GenPromotionIncentive_Batch ASI_CRM_SG_GenContractMarginBatch ASI_CRM_SG_GenWSBackRebates_Batch
*********************************************************************************/
	
/*
    -Get each SKU and outlet from the offtake upload
        -Loop all offtake based on the month and year inputted on the picklist
            -To get for the current FOC filter the query by current month and current year
        -Loop all offtake based on the month and year inputted on the picklist minus 1 month(In short, compute the previous month offtake to get the remainder)
            -To get for the previous month FOC filter the query by previous month
    -Check the SKU and outlet if it exist on contracts
        -To get all the SKU’s for a certain contacts, Query ASI_CRM_ContractTarget__c filter by ASI_CRM_Contract__c
        -If SKU and outlet exists on contracts
        -Compute the FOC by dividing all Offtake by number of package size
    */

    /* Loop all offtake based on the month and year inputted on the picklist */
         //-To get for the current FOC filter the query by current month and current year

    global without sharing class ASI_CRM_SG_FOCComputeController{

    public ASI_CRM_SG_FOCComputeController(){
		customer = new ASI_HK_CRM_Promotion_Detail__c();
    }
    
    /*
    //Wilken 20161010 Admin UI for regenerate FOC for a specific contract
        
    @RemoteAction
    global static Boolean computeFOCAdmin(String month, String year, String contractNumber){
        system.debug('input value: ' + month + year + contractNumber);
        
        List<ASI_TH_CRM_Contract__c> contractList = [select id, ownerId from ASI_TH_CRM_Contract__c where Name = :contractNumber and recordtype.developerName = 'ASI_CRM_SG_Contract_Read_Only'];
        
        if (contractList.size() == 1){
            list<string> list_c = new list<string>();
            list_c.add(contractList.get(0).Id);
            
            Id BatchId = Database.executeBatch(new ASI_CRM_SG_FOCBatchProcess(month,year, contractList.get(0).ownerId, list_c));
            String msg = 'Batch Started';   
            
            system.debug('Return True to page');
            return true;
        }
        else {
            system.debug('Return False to page');
            return false;
        }       
    }
    
    public Boolean canReGenFOC{
        get{
            Boolean flag = false;
            
            List<GroupMember> viewReGenGroupList = [SELECT groupID, userOrGroupID FROM groupMember 
                WHERE GroupID in (SELECT ID FROM Group WHERE DeveloperName = 'ASI_CRM_SG_FOC_Generation_Admin')];
                
            for (GroupMember viewReGenGroup:viewReGenGroupList){
                if (UserInfo.getUserId() == viewReGenGroup.userOrGroupID)
                    flag = true;
            }
            
            return flag;
        }
        set;
    }
    */
        
    @RemoteAction
    global  static Boolean computeFOC(String month, String year){
        Id BatchId = Database.executeBatch(new ASI_CRM_SG_FOCBatchProcess(month,year));
        String msg = 'Batch Started';   
        return true;
    }
    
    @RemoteAction
	/* 20170713 Vincent Lam, return alert message
    global static Boolean checkCurrentFOCComputation(String monthStr, String yearStr){
	*/
    global static string checkCurrentFOCComputation(String monthStr, String yearStr){
        List<ASI_CRM_SG_FOC_Carry_Over__c> CarryOvers = new List<ASI_CRM_SG_FOC_Carry_Over__c>();
		/*
        for(ASI_CRM_SG_FOC_Carry_Over__c foc:[Select ASI_CRM_SG_Outlet__c,ASI_CRM_SG_SKU__c,ASI_CRM_SG_Carry_Over__c,ASI_CRM_SG_Contract__r.ownerId,ASI_CRM_SG_Wholesaler__c,ASI_CRM_SG_Previous_Carry_Over_Value__c 
                                                    from ASI_CRM_SG_FOC_Carry_Over__c where ASI_CRM_SG_Month__c=:Decimal.valueOf(monthStr) and ASI_CRM_SG_Year__c=:yearStr and ASI_CRM_SG_Contract__r.ownerId =:UserInfo.getUserId()]){
            CarryOvers.add(foc);
        } 
        if(CarryOvers.size()>0){
            return true;
        }
        else{
            return false;
        }
		*/
		
        Decimal month=0;
        String year='0';
        for(ASI_CRM_SG_FOC_Carry_Over__c foc:[select ASI_CRM_SG_Month__c,ASI_CRM_SG_Year__c from ASI_CRM_SG_FOC_Carry_Over__c
                                                    where ASI_CRM_SG_Contract__r.ownerId =:UserInfo.getUserId() order by ASI_CRM_SG_Year__c desc,ASI_CRM_SG_Month__c desc limit 1]){
            month = foc.ASI_CRM_SG_Month__c;
            year = String.valueof(foc.ASI_CRM_SG_Year__c);
        } 

        if((month>Decimal.valueOf(monthStr) && Decimal.valueOf(year)== Decimal.valueOf(yearStr)) || (Decimal.valueOf(year)> Decimal.valueOf(yearStr)) || (month==Decimal.valueOf(monthStr) && Decimal.valueOf(year)== Decimal.valueOf(yearStr))){
            return 'There is already an existing FOC Computed for: '+month+'/'+year+' To create a new FOC delete the FOC for '+month+'/'+year+' first.';
        } else {
			return 'OK';
		}

        
    }
    @RemoteAction 
    global static String computeBottleIncentive(String fromMonth, String fromYear, String toMonth, String toYear) {

        Integer fromYearInt = Integer.valueOf(fromYear);
        Integer fromMonthInt = Integer.valueOf(fromMonth);
        Integer toYearInt = Integer.valueOf(toYear);
        Integer toMonthInt = Integer.valueOf(toMonth);

        Integer toDayInt = Date.daysInMonth(toYearInt, toMonthInt);

        Date fromDate = Date.newInstance(fromYearInt, fromMonthInt, 1);
        Date toDate = Date.newInstance(toYearInt, toMonthInt, toDayInt);

        List<ASI_TH_CRM_PaymentRequest__c> paymentRequestList = [SELECT Id, name, ASI_CRM_Generation_From_Date__c, ASI_CRM_Generation_To_Date__c
                                                                 FROM ASI_TH_CRM_PaymentRequest__c
                                                                 WHERE RecordType.DeveloperName in ('ASI_CRM_SG_Payment_Request', 'ASI_CRM_SG_Payment_Request_Read_Only')
                                                                 AND ownerId =:UserInfo.getUserId()
                                                                 AND (
                                                                     (ASI_CRM_Generation_From_Date__c <= :fromDate AND ASI_CRM_Generation_To_Date__c >= :fromDate) 
                                                                 	OR (ASI_CRM_Generation_From_Date__c <= :toDate AND ASI_CRM_Generation_To_Date__c >= :toDate)
                                                                 	OR (ASI_CRM_Generation_From_Date__c >= :fromDate AND ASI_CRM_Generation_To_Date__c <= :toDate)
                                                                 	OR (ASI_CRM_Generation_From_Date__c <= :fromDate AND ASI_CRM_Generation_To_Date__c >= :toDate)
                                                                 )];

        if(paymentRequestList.size() > 0) {
            ASI_TH_CRM_PaymentRequest__c paymentRequest = paymentRequestList.get(0);
            datetime fromDateTime = datetime.newInstance(paymentRequest.ASI_CRM_Generation_From_Date__c.year(), paymentRequest.ASI_CRM_Generation_From_Date__c.month(),paymentRequest.ASI_CRM_Generation_From_Date__c.day());
            datetime toDateTime = datetime.newInstance(paymentRequest.ASI_CRM_Generation_To_Date__c.year(), paymentRequest.ASI_CRM_Generation_To_Date__c.month(),paymentRequest.ASI_CRM_Generation_To_Date__c.day());
            string formattedFromDate = fromDateTime.format('yyyy-MM');
            string formattedToDate = toDateTime.format('yyyy-MM');
            return 'There is already an existing Bottle Incentive Payment Request (' + paymentRequest.name + ') for : ' + formattedFromDate + 
                   ' to ' + formattedToDate + ' To create a new Bottle Incentive Payment Request, delete the Bottle Incentive Payment Request for ' + 
                   formattedFromDate + ' to ' + formattedToDate + ' first.';
        } else {
            Database.executeBatch(new ASI_CRM_SG_GenBottleIncentiveBatch(fromMonth, fromYear, toMonth, toYear));
        }

        return 'OK';
    }

    @RemoteAction 
    global static String deleteBottleIncentive(String fromMonth, String fromYear, String toMonth, String toYear) {

        Integer fromYearInt = Integer.valueOf(fromYear);
        Integer fromMonthInt = Integer.valueOf(fromMonth);
        Integer toYearInt = Integer.valueOf(toYear);
        Integer toMonthInt = Integer.valueOf(toMonth);

        Integer toDayInt = Date.daysInMonth(toYearInt, toMonthInt);

        Date fromDate = Date.newInstance(fromYearInt, fromMonthInt, 1);
        Date toDate = Date.newInstance(toYearInt, toMonthInt, toDayInt);

        List<ASI_TH_CRM_PaymentRequest__c> paymentRequestList = [SELECT Id, name, ASI_CRM_Generation_From_Date__c, ASI_CRM_Generation_To_Date__c, ASI_TH_CRM_Status__c
                                                                 FROM ASI_TH_CRM_PaymentRequest__c
                                                                 WHERE ASI_CRM_Generation_From_Date__c = :fromDate 
                                                                 AND ASI_CRM_Generation_To_Date__c = :toDate
                                                                 AND ownerId =:UserInfo.getUserId()
                                                                 AND RecordType.DeveloperName  in ('ASI_CRM_SG_Payment_Request', 'ASI_CRM_SG_Payment_Request_Read_Only')];

        if(paymentRequestList.size() > 0) {
            integer countNotDraft = 0;
            string paymentNotDraft = '';
            for (ASI_TH_CRM_PaymentRequest__c p : paymentRequestList){
                if(p.ASI_TH_CRM_Status__c != 'Draft' && p.ASI_TH_CRM_Status__c != 'Draft') {
                    countNotDraft++;
                    paymentNotDraft = p.name;
                }
            }
            if (countNotDraft>0){
                return 'Cant Delete. There is existing Approved/Submitted/Final Bottle Incentive Payment Request ('+paymentNotDraft+').';
            } else {
                delete paymentRequestList;
            }
            
        } else {
            return 'No Bottle Incentive Payment Request was found! Please make sure the start and end months are correct.';
        }


        return 'Deleted';
    } 

    @RemoteAction
    global static String checkBeforeDeleteFOC(String monthStr, String yearStr, String contractNo) {
        List<ASI_TH_CRM_Contract__c> contractList = [SELECT Id, OwnerId
                                                     FROM ASI_TH_CRM_Contract__c
                                                     WHERE Name =: contractNo 
                                                     AND ownerId = :UserInfo.getUserId()
                                                     AND recordtype.developerName = 'ASI_CRM_SG_Contract_Read_Only'];

        List<String> contractIdList = new List<String>();                                               
        for(ASI_TH_CRM_Contract__c contract : contractList) {
            contractIdList.add(contract.Id);
        }

        if(contractIdList.size() == 0) {
            return 'Contract '+contractNo+' is not a valid approved contract';
        }

        Map<String,ASI_CRM_SG_FOC_Carry_Over__c> FOCCompToDelete = new Map<String,ASI_CRM_SG_FOC_Carry_Over__c>();
        // store all carry over that month to check if user has run FOC generation
        List<ASI_CRM_SG_FOC_Carry_Over__c> list_allCarryOver = new List<ASI_CRM_SG_FOC_Carry_Over__c>();

        Decimal month=0;
        String year='0';
        for(ASI_CRM_SG_FOC_Carry_Over__c foc:[select ASI_CRM_SG_Month__c,ASI_CRM_SG_Year__c from ASI_CRM_SG_FOC_Carry_Over__c
                                                    where ASI_CRM_SG_Contract__r.Name =: contractNo order by ASI_CRM_SG_Year__c desc,ASI_CRM_SG_Month__c desc limit 1]){
            month = foc.ASI_CRM_SG_Month__c;
            year = String.valueof(foc.ASI_CRM_SG_Year__c);
        } 

        /*
        // wrong checking
        if(month>Decimal.valueOf(monthStr) && (Decimal.valueOf(year)> Decimal.valueOf(yearStr) || Decimal.valueOf(year)== Decimal.valueOf(yearStr))){
            return 'Free Goods Request and FOC Carry Over of '+month +'-'+year + ' has to be deleted before regenerating '+monthStr +'-'+yearStr+' request';
        }
        */
		
		/*[WL 2.0] BEGIN*/
        if((month>Decimal.valueOf(monthStr) && Decimal.valueOf(year)== Decimal.valueOf(yearStr)) || Decimal.valueOf(year)> Decimal.valueOf(yearStr)){
            //return 'Free Goods Request and FOC Carry Over of '+month +'-'+year + ' has to be deleted before regenerating '+monthStr +'-'+yearStr+' request';
			return 'HasLaterMonthFOC';
        }
		/*[WL 2.0] END*/

        month = Decimal.valueOf(monthStr);
        year = yearStr;

        for(ASI_CRM_SG_FOC_Carry_Over__c foc:[
            Select ASI_CRM_SG_Outlet__c,
            ASI_CRM_SG_SKU__c,
            ASI_CRM_SG_Carry_Over__c,
            ASI_CRM_SG_Contract__r.ownerId,
            ASI_CRM_SG_Wholesaler__c,
            ASI_CRM_SG_Previous_Carry_Over_Value__c,
            ASI_CRM_SG_Contract__r.Name
            from ASI_CRM_SG_FOC_Carry_Over__c 
            where ASI_CRM_SG_Month__c=:Decimal.valueOf(monthStr) 
            and ASI_CRM_SG_Year__c=:yearStr
        	and ownerId = :UserInfo.getUserId()]){
            	list_allCarryOver.add(foc);
                if (foc.ASI_CRM_SG_Contract__r.Name==contractNo){
                    FOCCompToDelete.put(String.valueOf(foc.ASI_CRM_SG_SKU__c)+String.valueOf(foc.ASI_CRM_SG_Wholesaler__c)+String.valueOf(foc.ASI_CRM_SG_Outlet__c),foc);
                }
                
        }

        List<ASI_FOC_Free_Goods_Request__c> FOCFreeGoodsExistingToDelete = new List<ASI_FOC_Free_Goods_Request__c>();
        // store all FOC that month to check if user has run FOC generation
        List<ASI_FOC_Free_Goods_Request__c> list_allFOC = new List<ASI_FOC_Free_Goods_Request__c>();
        
        for(ASI_FOC_Free_Goods_Request__c c:[
            Select Id, Name, 
            ASI_CRM_SG_System_Generated__c,
            ASI_FOC_Request_Status__c,
            ASI_CRM_Contract__r.Name
            from ASI_FOC_Free_Goods_Request__c 
            where ASI_CRM_SG_Month__c=:monthStr 
            and ASI_CRM_SG_Year__c=:yearStr 
        	and ownerId = :UserInfo.getUserId()]){
                list_allFOC.add(c);
                if (c.ASI_CRM_Contract__r.Name==contractNo){
                    if((c.ASI_FOC_Request_Status__c=='Approved' || c.ASI_FOC_Request_Status__c=='Submitted' || c.ASI_FOC_Request_Status__c=='Final') && c.ASI_CRM_SG_System_Generated__c){
                        system.debug('Cannot delete due to submitted FOC: ' + c.Name + ' Delete Month: ' + monthStr + ' DeleteYear: ' + yearStr);
                        return 'Free Goods Request for '+monthStr +'-'+yearStr+' cannot be generated because there are existing request which has been submitted or approved already';
                    } else if((c.ASI_FOC_Request_Status__c=='Draft' || c.ASI_FOC_Request_Status__c=='Rejected') && c.ASI_CRM_SG_System_Generated__c){
                        FOCFreeGoodsExistingToDelete.add(c);
                    }
                }
        }

        if(list_allFOC.size()==0) {
            return 'There are no system generated Free Goods Request for '+monthStr +'-'+yearStr+', please use the monthly generation by batch function instead';
        } else
        if (FOCFreeGoodsExistingToDelete.size() == 0){
            return 'noFOC';
        } else {
            return 'OK';
        }
    }

    @RemoteAction
    global static String recomputeFOC(String monthStr, String yearStr, String contractNo) {
        List<ASI_TH_CRM_Contract__c> contractList = [SELECT Id, OwnerId
                                                     FROM ASI_TH_CRM_Contract__c
                                                     WHERE Name =: contractNo
                                                     AND recordtype.developerName = 'ASI_CRM_SG_Contract_Read_Only'];
    
        List<String> contractIdList = new List<String>();                                               
        for(ASI_TH_CRM_Contract__c contract : contractList) {
            contractIdList.add(contract.Id);
        }

        if(contractIdList.size() == 0) {
            return 'Contract '+contractNo+' is not a valid approved contract';
        }

        Map<String,ASI_CRM_SG_FOC_Carry_Over__c> FOCCompToDelete = new Map<String,ASI_CRM_SG_FOC_Carry_Over__c>();

        Decimal month=0;
        String year='0';
        for(ASI_CRM_SG_FOC_Carry_Over__c foc:[select ASI_CRM_SG_Month__c,ASI_CRM_SG_Year__c from ASI_CRM_SG_FOC_Carry_Over__c
                                                    where ASI_CRM_SG_Contract__r.Name =: contractNo order by ASI_CRM_SG_Year__c desc,ASI_CRM_SG_Month__c desc limit 1]){
            month = foc.ASI_CRM_SG_Month__c;
            year = String.valueof(foc.ASI_CRM_SG_Year__c);
        } 

        /*
        // wrong checking
        if(month>Decimal.valueOf(monthStr) && (Decimal.valueOf(year)> Decimal.valueOf(yearStr) || Decimal.valueOf(year)== Decimal.valueOf(yearStr))){
            return 'Free Goods Request and FOC Carry Over of '+month +'-'+year + ' has to be deleted before regenerating '+monthStr +'-'+yearStr+' request';
        }
        */
		
		/*[WL 2.0] BEGIN*/
        /*if((month>Decimal.valueOf(monthStr) && Decimal.valueOf(year)== Decimal.valueOf(yearStr)) || Decimal.valueOf(year)> Decimal.valueOf(yearStr)){
            return 'Free Goods Request and FOC Carry Over of '+month +'-'+year + ' has to be deleted before regenerating '+monthStr +'-'+yearStr+' request';
        }*/
		/*[WL 2.0] END*/

        month = Decimal.valueOf(monthStr);
        year = yearStr;

        for(ASI_CRM_SG_FOC_Carry_Over__c foc:[Select ASI_CRM_SG_Outlet__c,ASI_CRM_SG_SKU__c,ASI_CRM_SG_Carry_Over__c,ASI_CRM_SG_Contract__r.ownerId,ASI_CRM_SG_Wholesaler__c,ASI_CRM_SG_Previous_Carry_Over_Value__c 
                                                    from ASI_CRM_SG_FOC_Carry_Over__c where ASI_CRM_SG_Month__c=:Decimal.valueOf(monthStr) and ASI_CRM_SG_Year__c=:yearStr and ASI_CRM_SG_Contract__r.Name =: contractNo]){
            FOCCompToDelete.put(String.valueOf(foc.ASI_CRM_SG_SKU__c)+String.valueOf(foc.ASI_CRM_SG_Wholesaler__c)+String.valueOf(foc.ASI_CRM_SG_Outlet__c),foc);
        }

        List<ASI_FOC_Free_Goods_Request__c> FOCFreeGoodsExistingToDelete = new List<ASI_FOC_Free_Goods_Request__c>();
        List<ASI_FOC_Free_Goods_Request__c> FOCFreeGoodsExistingApproved = new List<ASI_FOC_Free_Goods_Request__c>();
        for(ASI_FOC_Free_Goods_Request__c c:[Select Id, Name, ASI_CRM_SG_System_Generated__c,ASI_FOC_Request_Status__c from ASI_FOC_Free_Goods_Request__c where ASI_CRM_SG_Month__c=:monthStr and ASI_CRM_SG_Year__c=:yearStr and ASI_CRM_Contract__r.Name =: contractNo]){
            if((c.ASI_FOC_Request_Status__c=='Approved' || c.ASI_FOC_Request_Status__c=='Submitted' || c.ASI_FOC_Request_Status__c=='Final') && c.ASI_CRM_SG_System_Generated__c){
                system.debug('Cannot delete due to submitted FOC: ' + c.Name + ' Delete Month: ' + monthStr + ' DeleteYear: ' + yearStr);
                FOCFreeGoodsExistingApproved.add(c);
            }
            else if((c.ASI_FOC_Request_Status__c=='Draft' || c.ASI_FOC_Request_Status__c=='Rejected') && c.ASI_CRM_SG_System_Generated__c){
                FOCFreeGoodsExistingToDelete.add(c);
            }
        }

        if(FOCFreeGoodsExistingApproved.size()>0){
            return 'Free Goods Request for '+monthStr +'-'+yearStr+' cannot be generated because there are existing request which has been submitted or approved already';
        }
        else{
            Boolean isCarrOverDeleted =false;
            Boolean isFOCDeleted =false;
       
            /*
            if(month<Decimal.valueOf(monthStr) && (Decimal.valueOf(year)< Decimal.valueOf(yearStr) || Decimal.valueOf(year)== Decimal.valueOf(yearStr))){
                return 'There are no FOC to delete ';
            }
			*/
            
            if(FOCCompToDelete.size()>0){
                delete FOCCompToDelete.values();
                isFOCDeleted =true;
            }   
            if(FOCFreeGoodsExistingToDelete.size()>0){
                delete FOCFreeGoodsExistingToDelete;
                isCarrOverDeleted =true;
            } 

            if(isFOCDeleted){
                List<ASI_CRM_SG_FOC_Carry_Over_Key_Values__c> keyValuesToUpdate = new List<ASI_CRM_SG_FOC_Carry_Over_Key_Values__c>();
                // Dele FOC Key Values
                for(ASI_CRM_SG_FOC_Carry_Over_Key_Values__c kv:[Select Name, ASI_CRM_SG_Carry_Over_Value__c from ASI_CRM_SG_FOC_Carry_Over_Key_Values__c where name in:FOCCompToDelete.keySet()]){

                    kv.ASI_CRM_SG_Carry_Over_Value__c = FOCCompToDelete.get(kv.name).ASI_CRM_SG_Previous_Carry_Over_Value__c;
                    keyValuesToUpdate.add(kv);
                }
                if(keyValuesToUpdate.size()>0){
                   update keyValuesToUpdate; 
                }
            }

            if(contractIdList.size() > 0) {
                system.debug('Hi: '+month+' '+month.format()+' '+year);
                
                Database.executeBatch(new ASI_CRM_SG_FOCBatchProcess(month.format(), year, contractList.get(0).ownerId, contractIdList));
            } 

            /*
            if(isFOCDeleted || isCarrOverDeleted) {
                return 'OK';
            } else {
                return 'There are no FOC to delete ';
            }
            */
            return 'OK';

        }
    }

    @RemoteAction
    global static String deleteFOCComputationAndFOCRequest(String monthStr, String yearStr){
        system.debug('Delete Month: ' + monthStr + ' Delete Year: ' + yearStr);
        Map<String,ASI_CRM_SG_FOC_Carry_Over__c> FOCCompToDelete = new Map<String,ASI_CRM_SG_FOC_Carry_Over__c>();
        Decimal month=0;
        String year='0';
        for(ASI_CRM_SG_FOC_Carry_Over__c foc:[select ASI_CRM_SG_Month__c,ASI_CRM_SG_Year__c from ASI_CRM_SG_FOC_Carry_Over__c
                                                    where ASI_CRM_SG_Contract__r.ownerId =:UserInfo.getUserId() order by ASI_CRM_SG_Year__c desc,ASI_CRM_SG_Month__c desc limit 1]){
            month = foc.ASI_CRM_SG_Month__c;
            year = String.valueof(foc.ASI_CRM_SG_Year__c);
        } 
         
        /*
        // wrong checking
        if(month>Decimal.valueOf(monthStr) && (Decimal.valueOf(year)> Decimal.valueOf(yearStr) || Decimal.valueOf(year)== Decimal.valueOf(yearStr))){
            return 'Free Goods Request and FOC Carry Over of '+month +'-'+year + ' has to be deleted before regenerating '+monthStr +'-'+yearStr+' request';
        }
        */
        if((month>Decimal.valueOf(monthStr) && Decimal.valueOf(year)== Decimal.valueOf(yearStr)) || Decimal.valueOf(year)> Decimal.valueOf(yearStr)){
            return 'Free Goods Request and FOC Carry Over of '+month +'-'+year + ' has to be deleted before regenerating '+monthStr +'-'+yearStr+' request';
        }

        month = Decimal.valueOf(monthStr);
        year = yearStr;

        for(ASI_CRM_SG_FOC_Carry_Over__c foc:[Select ASI_CRM_SG_Outlet__c,ASI_CRM_SG_SKU__c,ASI_CRM_SG_Carry_Over__c,ASI_CRM_SG_Contract__r.ownerId,ASI_CRM_SG_Wholesaler__c,ASI_CRM_SG_Previous_Carry_Over_Value__c 
                                                    from ASI_CRM_SG_FOC_Carry_Over__c where ASI_CRM_SG_Month__c=:Decimal.valueOf(monthStr) and ASI_CRM_SG_Year__c=:yearStr and ASI_CRM_SG_Contract__r.ownerId =:UserInfo.getUserId()]){
            FOCCompToDelete.put(String.valueOf(foc.ASI_CRM_SG_SKU__c)+String.valueOf(foc.ASI_CRM_SG_Wholesaler__c)+String.valueOf(foc.ASI_CRM_SG_Outlet__c),foc);
        }  
        
        List<ASI_FOC_Free_Goods_Request__c> FOCFreeGoodsExistingToDelete = new List<ASI_FOC_Free_Goods_Request__c>();
        List<ASI_FOC_Free_Goods_Request__c> FOCFreeGoodsExistingApproved = new List<ASI_FOC_Free_Goods_Request__c>();
        for(ASI_FOC_Free_Goods_Request__c c:[Select Id, Name, ASI_CRM_SG_System_Generated__c,ASI_FOC_Request_Status__c from ASI_FOC_Free_Goods_Request__c where ASI_CRM_SG_Month__c=:monthStr and ASI_CRM_SG_Year__c=:yearStr and ASI_CRM_Contract__r.ownerId =:UserInfo.getUserId()]){
            if((c.ASI_FOC_Request_Status__c=='Approved' || c.ASI_FOC_Request_Status__c=='Submitted' || c.ASI_FOC_Request_Status__c=='Final') && c.ASI_CRM_SG_System_Generated__c){
                system.debug('Cannot delete due to submitted FOC: ' + c.Name + ' Delete Month: ' + monthStr + ' DeleteYear: ' + yearStr);
                FOCFreeGoodsExistingApproved.add(c);
            }
            else if((c.ASI_FOC_Request_Status__c=='Draft' || c.ASI_FOC_Request_Status__c=='Rejected') && c.ASI_CRM_SG_System_Generated__c){
                FOCFreeGoodsExistingToDelete.add(c);
            }
            
        }
        if(FOCFreeGoodsExistingApproved.size()>0){
            return 'Cant Delete. There are existing Approved/Submitted/Final FOC ';
        }
        else{
            Boolean isCarrOverDeleted =false;
            Boolean isFOCDeleted =false;
       
            
            if(month<Decimal.valueOf(monthStr) && (Decimal.valueOf(year)< Decimal.valueOf(yearStr) || Decimal.valueOf(year)== Decimal.valueOf(yearStr))){
                return 'There are no FOC to delete ';
            }
            
            if(FOCCompToDelete.size()>0){
                delete FOCCompToDelete.values();
                isFOCDeleted =true;
            }   
            if(FOCFreeGoodsExistingToDelete.size()>0){
                delete FOCFreeGoodsExistingToDelete;
                isCarrOverDeleted =true;
            }  
            if(isFOCDeleted){
                List<ASI_CRM_SG_FOC_Carry_Over_Key_Values__c> keyValuesToUpdate = new List<ASI_CRM_SG_FOC_Carry_Over_Key_Values__c>();
                // Dele FOC Key Values
                for(ASI_CRM_SG_FOC_Carry_Over_Key_Values__c kv:[Select Name, ASI_CRM_SG_Carry_Over_Value__c from ASI_CRM_SG_FOC_Carry_Over_Key_Values__c where name in:FOCCompToDelete.keySet()]){

                    kv.ASI_CRM_SG_Carry_Over_Value__c = FOCCompToDelete.get(kv.name).ASI_CRM_SG_Previous_Carry_Over_Value__c;
                    keyValuesToUpdate.add(kv);
                }
                if(keyValuesToUpdate.size()>0){
                   update keyValuesToUpdate; 
                }
                
                return 'Deleted';
            }
            else if(isCarrOverDeleted){
                return 'Deleted';
            }
            else{
                return 'There are no FOC to delete ';
            }
            
        }
    }

    @RemoteAction 
    global static String computeContractMargin(String fromMonth, String fromYear) {

        List<ASI_CRM_Credit_Debit_Note__c> creditNoteList = [SELECT Id, name
                                                             FROM ASI_CRM_Credit_Debit_Note__c
                                                             WHERE RecordType.DeveloperName in (
                                                                 'ASI_CRM_SG_Contract_Margin_Credit_Note', 'ASI_CRM_SG_Contract_Margin_Credit_Note_Read_Only',
                                                                 'ASI_CRM_SG_Contract_Margin_Debit_Note', 'ASI_CRM_SG_Contract_Margin_Debit_Note_Read_Only'
                                                             )
                                                             AND ownerId =:UserInfo.getUserId()
                                                             AND ASI_CRM_Year__c = :fromYear
                                                             AND ASI_CRM_Month__c = :fromMonth
                                                             AND ASI_CRM_SYS_System_Generated__c = true
                                                            ];

        if(creditNoteList.size() > 0) {
            return 'There is already an existing Contract Margin Credit/Debit Note for : ' + fromMonth + '/' + fromYear + '. ' +
                   'To create a new Contract Margin Credit/Debit Note, delete the Contract Margin Credit/Debit Note for ' + 
                   fromMonth + '/' + fromYear + ' first.';
        } 

        return 'OK';
    }

    @RemoteAction 
    global static String deleteContractMargin(String fromMonth, String fromYear) {

        List<ASI_CRM_Credit_Debit_Note__c> creditNoteList = [SELECT Id, name, ASI_CRM_Status__c
                                                                 FROM ASI_CRM_Credit_Debit_Note__c
                                                                 WHERE ASI_CRM_Year__c = :fromYear 
                                                                 AND ASI_CRM_Month__c = :fromMonth
                                                                 AND ownerId =:UserInfo.getUserId()
                                                                 AND RecordType.DeveloperName  in (
                                                                 'ASI_CRM_SG_Contract_Margin_Credit_Note', 'ASI_CRM_SG_Contract_Margin_Credit_Note_Read_Only',
                                                                 'ASI_CRM_SG_Contract_Margin_Debit_Note', 'ASI_CRM_SG_Contract_Margin_Debit_Note_Read_Only'
                                                             )];

        if(creditNoteList.size() > 0) {
            integer countNotDraft = 0;
            string paymentNotDraft = '';
            for (ASI_CRM_Credit_Debit_Note__c p : creditNoteList){
                if(p.ASI_CRM_Status__c != 'Draft' && p.ASI_CRM_Status__c != 'Rejected') {
                    countNotDraft++;
                    paymentNotDraft = p.name;
                }
            }
            if (countNotDraft>0){
                return 'Cant Delete. There is existing Approved/Submitted/Final Contract Margin Credit/Debit Note ('+paymentNotDraft+').';
            } else {
                delete creditNoteList;
            }
            
        } else {
            return 'No Contract Margin Credit/Debit Note was found! Please make sure the month/year is correct.';
        }


        return 'Deleted';
    } 

    
    public Boolean canGenPromptPayment{
        get{
            Boolean flag = false;
            
            List<GroupMember> viewReGenGroupList = [SELECT groupID, userOrGroupID FROM groupMember 
                WHERE GroupID in (SELECT ID FROM Group WHERE DeveloperName = 'ASI_CRM_SG_Prompt_Payment_Admin')];
                
            for (GroupMember viewReGenGroup:viewReGenGroupList){
                if (UserInfo.getUserId() == viewReGenGroup.userOrGroupID)
                    flag = true;
            }
            
            return flag;
        }
        set;
    }
	
	/*[WL 4.0] BEGIN*/
	public ASI_HK_CRM_Promotion_Detail__c customer {get;set;}
	
	@RemoteAction
    global static String computePromotion(String yearStr, String monthStr){
		Integer monthInt = Integer.valueOf(monthStr);
		Integer yearInt = Integer.valueOf(yearStr);
		
		List<ASI_TH_CRM_PaymentRequest__c> paymentList = [SELECT id, Name, ASI_TH_CRM_Status__c 
															FROM ASI_TH_CRM_PaymentRequest__c 
															WHERE recordtype.developerName in ('ASI_CRM_SG_Payment_Request', 'ASI_CRM_SG_Payment_Request_Read_Only')
															AND ASI_CRM_System_Remark__c = 'SG Promotion'
															AND CALENDAR_MONTH(ASI_CRM_Generation_From_Date__c) = :monthInt
															AND CALENDAR_YEAR(ASI_CRM_Generation_From_Date__c) = :yearInt 
															AND OwnerId = :UserInfo.getUserId()];
															
		List<ASI_CRM_Voucher__c> voucherList = [SELECT Id, Name from ASI_CRM_Voucher__c WHERE ASI_CRM_Month__c = :monthStr AND ASI_CRM_Year__c = :yearStr 
												AND OwnerId = :UserInfo.getUserId() AND recordType.DeveloperName = 'ASI_CRM_SG_Voucher'];
															
		List<ASI_FOC_Free_Goods_Request__c> focList = [SELECT Id, Name, ASI_FOC_Request_Status__c from ASI_FOC_Free_Goods_Request__c 
												WHERE recordType.DeveloperName in ('ASI_CRM_SG_FOC', 'ASI_CRM_SG_FOC_Read_Only')
												AND ASI_CRM_System_Remark__c = 'SG Promotion'
												AND ASI_CRM_SG_Month__c = :monthStr
												AND ASI_CRM_SG_Year__c = :yearStr
												AND OwnerId = :UserInfo.getUserId()];
		
		if(paymentList.size() > 0 || voucherList.size() > 0 || focList.size() > 0) {
            return 'There is already an existing Promotion incentive for : ' + monthStr + '/' + yearStr + '. ' +
                   'To generate new Promotion incentive, delete the incentive for ' + 
                   monthStr + '/' + yearStr + ' first.';
        } 
        
        String result ='OK';
        return result;     
    }
	
	@RemoteAction 
    global static String deletePromotion(String fromMonth, String fromYear) {
															 
		Integer monthInt = Integer.valueOf(fromMonth);
		Integer yearInt = Integer.valueOf(fromYear);

		string SG_PROMOTION_REMARK = 'SG Promotion';
		string SG_PROMOTION_REMARK_TOBEDELETED = 'SG Promotion (To Be Deleted)';

		List<ASI_TH_CRM_PaymentRequest__c> paymentList = [SELECT id, Name, ASI_TH_CRM_Status__c 
															FROM ASI_TH_CRM_PaymentRequest__c 
															WHERE recordtype.developerName in ('ASI_CRM_SG_Payment_Request', 'ASI_CRM_SG_Payment_Request_Read_Only')
															AND ASI_CRM_System_Remark__c = :SG_PROMOTION_REMARK
															AND CALENDAR_MONTH(ASI_CRM_Generation_From_Date__c) = :monthInt
															AND CALENDAR_YEAR(ASI_CRM_Generation_From_Date__c) = :yearInt 
															AND OwnerId = :UserInfo.getUserId()];
															
		List<ASI_CRM_Voucher__c> voucherList = [SELECT Id, Name from ASI_CRM_Voucher__c WHERE ASI_CRM_Month__c = :fromMonth AND ASI_CRM_Year__c = :fromYear 
												AND OwnerId = :UserInfo.getUserId() AND recordType.DeveloperName = 'ASI_CRM_SG_Voucher'
												AND ASI_CRM_System_Generated_Msg__c = :SG_PROMOTION_REMARK];
															
		List<ASI_FOC_Free_Goods_Request__c> focList = [SELECT Id, Name, ASI_FOC_Request_Status__c from ASI_FOC_Free_Goods_Request__c 
												WHERE recordType.DeveloperName in ('ASI_CRM_SG_FOC', 'ASI_CRM_SG_FOC_Read_Only')
												AND ASI_CRM_System_Remark__c = :SG_PROMOTION_REMARK
												AND ASI_CRM_SG_Month__c = :fromMonth
												AND ASI_CRM_SG_Year__c = :fromYear
												AND OwnerId = :UserInfo.getUserId()];
												
        if(paymentList.size() > 0) {
            integer countNotDraft = 0;
            string paymentNotDraft = '';
            for (ASI_TH_CRM_PaymentRequest__c p : paymentList){
                if(p.ASI_TH_CRM_Status__c != 'Draft' && p.ASI_TH_CRM_Status__c != 'Rejected') {
                    countNotDraft++;
                    paymentNotDraft = p.Name;
                }else{
					p.ASI_CRM_System_Remark__c = SG_PROMOTION_REMARK_TOBEDELETED;
				}
            }
            if (countNotDraft>0){
                return 'Cannot delete the incentive for selected month. There is existing Submitted/Final Payment ('+paymentNotDraft+').';
            } else {
                update paymentList;
				delete paymentList;
            }
        }
		
		if(voucherList.size() > 0) {
			for(ASI_CRM_Voucher__c v : voucherList){
				v.ASI_CRM_System_Generated_Msg__c = SG_PROMOTION_REMARK_TOBEDELETED;
			}
			update voucherList;
			delete voucherList;
        }
		
		if (focList.size() > 0){
			integer countNotDraft = 0;
            string focNotDraft = '';
            for (ASI_FOC_Free_Goods_Request__c foc : focList){
                if(foc.ASI_FOC_Request_Status__c != 'Draft' && foc.ASI_FOC_Request_Status__c != 'Rejected') {
                    countNotDraft++;
                    focNotDraft = foc.Name;
                }else{
					foc.ASI_CRM_System_Remark__c = SG_PROMOTION_REMARK_TOBEDELETED;
				}
            }
            if (countNotDraft>0){
                return 'Cant Delete. There is existing Submitted/Final Free Goods Request ('+focNotDraft+').';
            } else {
                update focList;
				delete focList;
            }
		}
		
		if (paymentList.size() == 0 && voucherList.size() == 0 && focList.size() == 0 ){
            return 'No Promotion Incentive was found! Please make sure the month/year is correct.';
        }

        return 'Deleted';
    } 
	
	@RemoteAction
    global static String checkBeforePromotionReGen(String monthStr, String yearStr, String custName) {
		string result;
		
		string SG_PROMOTION_REMARK = 'SG Promotion';
		string SG_PROMOTION_REMARK_TOBEDELETED = 'SG Promotion (To Be Deleted)';

		Id custId = [SELECT Id FROM ASI_CRM_AccountsAdditionalField__c WHERE RecordType.DeveloperName IN ('ASI_CRM_SG_Outlet', 'ASI_CRM_SG_Wholesaler') AND Name = :custName LIMIT 1].Id;
		Integer monthInt = Integer.valueOf(monthStr);
		Integer yearInt = Integer.valueOf(yearStr);															 

		List<ASI_TH_CRM_PaymentRequest__c> paymentList = [SELECT id, Name, ASI_TH_CRM_Status__c, ASI_CRM_CN_OutletWS__c
															FROM ASI_TH_CRM_PaymentRequest__c 
															WHERE recordtype.developerName in ('ASI_CRM_SG_Payment_Request', 'ASI_CRM_SG_Payment_Request_Read_Only')
															AND ASI_CRM_System_Remark__c = :SG_PROMOTION_REMARK
															AND CALENDAR_MONTH(ASI_CRM_Generation_From_Date__c) = :monthInt
															AND CALENDAR_YEAR(ASI_CRM_Generation_From_Date__c) = :yearInt 
															AND OwnerId = :UserInfo.getUserId()];
															
		List<ASI_CRM_Voucher__c> voucherList = [SELECT Id, Name, ASI_CRM_Customer__c from ASI_CRM_Voucher__c 
								WHERE ASI_CRM_Month__c = :monthStr 
								AND ASI_CRM_Year__c = :yearStr 
								AND OwnerId = :UserInfo.getUserId() AND recordType.DeveloperName = 'ASI_CRM_SG_Voucher'
								AND ASI_CRM_System_Generated_Msg__c = :SG_PROMOTION_REMARK];
								
		List<ASI_FOC_Free_Goods_Request__c> focList = [SELECT Id, Name, ASI_FOC_Request_Status__c, ASI_CRM_Outlet__c from ASI_FOC_Free_Goods_Request__c 
												WHERE recordType.DeveloperName in ('ASI_CRM_SG_FOC', 'ASI_CRM_SG_FOC_Read_Only')
												AND ASI_CRM_System_Remark__c = :SG_PROMOTION_REMARK
												AND ASI_CRM_SG_Month__c = :monthStr
												AND ASI_CRM_SG_Year__c = :yearStr
												AND OwnerId = :UserInfo.getUserId()];

		Boolean notDraft = false;
		
		List<ASI_TH_CRM_PaymentRequest__c> paymentListDelete = new List<ASI_TH_CRM_PaymentRequest__c>();
		List<ASI_CRM_Voucher__c> voucherListDelete = new List<ASI_CRM_Voucher__c>();
		List<ASI_FOC_Free_Goods_Request__c> focListDelete = new List<ASI_FOC_Free_Goods_Request__c>();
		
		if (paymentList.size() == 0 && voucherList.size() == 0 && focList.size() == 0){
			result = 'There are no Promotion incetive for '+monthStr +'-'+yearStr+', please use the monthly generation by batch function instead';			
			system.debug('checkBeforePromotionReGen: ' + result);
			return result;
		}
		else {
			for (ASI_TH_CRM_PaymentRequest__c payment:paymentList){
				if (payment.ASI_CRM_CN_OutletWS__c == custId && payment.ASI_TH_CRM_Status__c != 'Draft' && payment.ASI_TH_CRM_Status__c != 'Rejected')
					notDraft = true;
			}
			
			for (ASI_FOC_Free_Goods_Request__c foc:focList){
				if (foc.ASI_CRM_Outlet__c == custId && foc.ASI_FOC_Request_Status__c != 'Draft' && foc.ASI_FOC_Request_Status__c != 'Rejected')
					notDraft = true;
			}
			
			if (notDraft){
				result = 'There are existing submitted or approved Promotion incetive of this Outlet/Wholesaler for '+monthStr +'-'+yearStr+', please delete them before regeneration';			
				system.debug('checkBeforePromotionReGen: ' + result);
				return result;
			}
			else {
				for (ASI_TH_CRM_PaymentRequest__c payment:paymentList){
					if (payment.ASI_CRM_CN_OutletWS__c == custId){
						payment.ASI_CRM_System_Remark__c = SG_PROMOTION_REMARK_TOBEDELETED;
						paymentListDelete.add(payment);
					}
				}
				
				for (ASI_CRM_Voucher__c voucher:voucherList){
					if (voucher.ASI_CRM_Customer__c == custId){
						voucher.ASI_CRM_System_Generated_Msg__c = SG_PROMOTION_REMARK_TOBEDELETED;
						voucherListDelete.add(voucher);
					}
				}
				
				for (ASI_FOC_Free_Goods_Request__c foc:focList){
					if (foc.ASI_CRM_Outlet__c == custId){
						foc.ASI_CRM_System_Remark__c = SG_PROMOTION_REMARK_TOBEDELETED;
						focListDelete.add(foc);
					}
				}
				
				 
				update paymentListDelete;
				update voucherListDelete;
				update focListDelete;
				delete paymentListDelete;
				delete voucherListDelete;
				delete focListDelete;
				
				result = 'OK';
				system.debug('checkBeforeDeleteCM: ' + result);
				return result;
			}
		}	
    }
	
	@RemoteAction
    global static String computePromotionReGen(String yearStr, String monthStr, String custName){
        return 'OK';     
    }
	/*[WL 4.0] END*/
	
	/*[WL 3.0] BEGIN*/
	public ASI_HK_CRM_Promotion_Detail__c wholesaler {get;set;}
	
	public Boolean canGenWSBackRebate{
        get{
            Boolean flag = false;
            
            List<GroupMember> viewReGenGroupList = [SELECT groupID, userOrGroupID FROM groupMember 
                WHERE GroupID in (SELECT ID FROM Group WHERE DeveloperName = 'ASI_CRM_SG_WS_Back_Rebate_User')];
                
            for (GroupMember viewReGenGroup:viewReGenGroupList){
                if (UserInfo.getUserId() == viewReGenGroup.userOrGroupID)
                    flag = true;
            }
            
            return flag;
        }
        set;
    }
	
	@RemoteAction
    global static String computeWSBackRebate(String yearStr, String monthStr, String type){
		List<ASI_CRM_Credit_Debit_Note__c> creditNoteList = [SELECT Id, name
                                                             FROM ASI_CRM_Credit_Debit_Note__c
                                                             WHERE RecordType.DeveloperName in (
                                                                 'ASI_CRM_SG_Back_Rebate_Credit_Note', 'ASI_CRM_SG_Back_Rebate_Credit_Note_Read_Only',
                                                                 'ASI_CRM_SG_Back_Rebate_Debit_Note', 'ASI_CRM_SG_Back_Rebate_Debit_Note_Read_Only'
                                                             )
                                                             AND ownerId =:UserInfo.getUserId()
                                                             AND ASI_CRM_Year__c = :yearStr
                                                             AND ASI_CRM_Month__c = :monthStr
                                                             AND ASI_CRM_SYS_System_Generated__c = true
                                                            ];
		Integer monthInt = Integer.valueOf(monthStr);
		Integer yearInt = Integer.valueOf(yearStr);
		
		List<ASI_TH_CRM_PaymentRequest__c> paymentList = [SELECT id 
																		FROM ASI_TH_CRM_PaymentRequest__c 
																		WHERE recordtype.developerName in ('ASI_CRM_SG_Payment_Request', 'ASI_CRM_SG_Payment_Request_Read_Only')
																		AND ASI_CRM_System_Remark__c = 'Wholesaler Back Rebate Payment'
																		AND CALENDAR_MONTH(ASI_CRM_Generation_From_Date__c) = :monthInt
																		AND CALENDAR_YEAR(ASI_CRM_Generation_From_Date__c) = :yearInt 
																		AND OwnerId = :UserInfo.getUserId()];
																		
		system.debug('monthInt: ' + monthInt + ' yearInt: ' + yearInt + ' paymentList size:' + paymentList.size());
		
		List<ASI_TH_CRM_Actual_Offtake__c> list_o = [Select id
                     From 
                         ASI_TH_CRM_Actual_Offtake__c 
                     where 
                       recordtype.developerName = 'ASI_CRM_SG_Actual_Offtake'
					   AND ASI_CRM_FromWS__c != null
					   AND ASI_CRM_SG_Customer__c != null
					   AND ASI_CRM_SKU__c != null
					   AND ASI_CRM_FromWS__r.ownerid = :UserInfo.getUserId()
					   AND ASI_CRM_SG_Customer__r.ASI_CRM_Outlet_Type__c = 'Open Outlet'
                       AND calendar_year(ASI_TH_CRM_Offtake_G_L_Date__c) = :yearInt
                       AND calendar_month(ASI_TH_CRM_Offtake_G_L_Date__c)  = :monthInt
					   AND ASI_CRM_SKU__r.ASI_CRM_Missing_PricesForWSBackRebate__c = true
					   AND ASI_CRM_SKU__r.ASI_CRM_Bypass_for_WS_Back_Rebate__c = false
					 limit 1
		];
		
        if(creditNoteList.size() > 0) {
            return 'There is already an existing Wholesaler Back Rebate Credit/Debit Note for : ' + monthStr + '/' + yearStr + '. ' +
                   'To create a new Wholesaler Back Rebate Credit/Debit Note, delete the Wholesaler Back Rebate Credit/Debit Note for ' + 
                   monthStr + '/' + yearStr + ' first.';
        } 
		else if (paymentList.size() > 0){
			return 'There is already an existing Wholesaler Back Rebate Payment Request for : ' + monthStr + '/' + yearStr + '. ' +
                   'To create a new Wholesaler Back Rebate Payment Request, delete the Wholesaler Back Rebate Payment Request for ' + 
                   monthStr + '/' + yearStr + ' first.';
		}
		else if (list_o.size() > 0){
			return 'There is missing Open Outlet / Incentive Price in the offtakes for ' + monthStr + '/' + yearStr + '. ' +
                   'Please ask SKU Price/Cost admin to manage the prices or setup bypass for this checking.';
		}
		
		
        String result ='OK';
        return result;     
    }
	
	@RemoteAction 
    global static String deleteWSBackRebate(String fromMonth, String fromYear) {

        List<ASI_CRM_Credit_Debit_Note__c> creditNoteList = [SELECT Id, Name, ASI_CRM_Status__c
                                                                 FROM ASI_CRM_Credit_Debit_Note__c
                                                                 WHERE ASI_CRM_Year__c = :fromYear 
                                                                 AND ASI_CRM_Month__c = :fromMonth
                                                                 AND ownerId =:UserInfo.getUserId()
                                                                 AND RecordType.DeveloperName  in (
                                                                 'ASI_CRM_SG_Back_Rebate_Credit_Note', 'ASI_CRM_SG_Back_Rebate_Credit_Note_Read_Only',
                                                                 'ASI_CRM_SG_Back_Rebate_Debit_Note', 'ASI_CRM_SG_Back_Rebate_Debit_Note_Read_Only'
                                                             )];
															 
		Integer monthInt = Integer.valueOf(fromMonth);
		Integer yearInt = Integer.valueOf(fromYear);															 

		List<ASI_TH_CRM_PaymentRequest__c> paymentList = [SELECT id, Name, ASI_TH_CRM_Status__c 
															FROM ASI_TH_CRM_PaymentRequest__c 
															WHERE recordtype.developerName in ('ASI_CRM_SG_Payment_Request', 'ASI_CRM_SG_Payment_Request_Read_Only')
															AND ASI_CRM_System_Remark__c = 'Wholesaler Back Rebate Payment'
															AND CALENDAR_MONTH(ASI_CRM_Generation_From_Date__c) = :monthInt
															AND CALENDAR_YEAR(ASI_CRM_Generation_From_Date__c) = :yearInt 
															AND OwnerId = :UserInfo.getUserId()];
																		
        if(creditNoteList.size() > 0 || paymentList.size() > 0) {
            integer countNotDraft = 0;
            string cNoteNotDraft = '';
			string paymentNotDraft = '';
			
            for (ASI_CRM_Credit_Debit_Note__c p : creditNoteList){
                if(p.ASI_CRM_Status__c != 'Draft' && p.ASI_CRM_Status__c != 'Rejected') {
                    countNotDraft++;
                    cNoteNotDraft = p.Name;
                }
            }
            if (countNotDraft>0){
                return 'Cant Delete. There is existing Submitted/Final Wholesaler Back Rebate Credit/Debit Note ('+cNoteNotDraft+').';
            } else {
                delete creditNoteList;
            }
            
			for (ASI_TH_CRM_PaymentRequest__c p : paymentList){
                if(p.ASI_TH_CRM_Status__c != 'Draft' && p.ASI_TH_CRM_Status__c != 'Rejected') {
                    countNotDraft++;
                    paymentNotDraft = p.Name;
                }
            }
            if (countNotDraft>0){
                return 'Cant Delete. There is existing Submitted/Approved Wholesaler Back Rebate Payment Request  ('+paymentNotDraft+').';
            } else {
                delete paymentList;
            }       

			return 'Deleted';			
        }            
		else {
            return 'No Wholesaler Back Rebate Credit/Debit Note and Payment Request was found! Please make sure the month/year is correct.';
        }
    } 
	
	@RemoteAction
    global static String computeWSBackRebateReGen(String yearStr, String monthStr, String type, String custName){
		List<ASI_CRM_Credit_Debit_Note__c> creditNoteList = [SELECT Id, name, ASI_CRM_Status__c, ASI_CRM_Wholesaler__c
                                                             FROM ASI_CRM_Credit_Debit_Note__c
                                                             WHERE RecordType.DeveloperName in (
                                                                 'ASI_CRM_SG_Back_Rebate_Credit_Note', 'ASI_CRM_SG_Back_Rebate_Credit_Note_Read_Only',
                                                                 'ASI_CRM_SG_Back_Rebate_Debit_Note', 'ASI_CRM_SG_Back_Rebate_Debit_Note_Read_Only'
                                                             )
                                                             AND ownerId =:UserInfo.getUserId()
                                                             AND ASI_CRM_Year__c = :yearStr
                                                             AND ASI_CRM_Month__c = :monthStr
                                                             AND ASI_CRM_SYS_System_Generated__c = true
                                                            ];
		Integer monthInt = Integer.valueOf(monthStr);
		Integer yearInt = Integer.valueOf(yearStr);
		
		List<ASI_TH_CRM_PaymentRequest__c> paymentList = [SELECT id, ASI_TH_CRM_Status__c, ASI_CRM_CN_OutletWS__c  
																		FROM ASI_TH_CRM_PaymentRequest__c 
																		WHERE recordtype.developerName in ('ASI_CRM_SG_Payment_Request', 'ASI_CRM_SG_Payment_Request_Read_Only')
																		AND ASI_CRM_System_Remark__c = 'Wholesaler Back Rebate Payment'
																		AND CALENDAR_MONTH(ASI_CRM_Generation_From_Date__c) = :monthInt
																		AND CALENDAR_YEAR(ASI_CRM_Generation_From_Date__c) = :yearInt 
																		AND OwnerId = :UserInfo.getUserId()];
																		
		system.debug('monthInt: ' + monthInt + ' yearInt: ' + yearInt + ' paymentList size:' + paymentList.size());
		
		Boolean notDraft = false;
		Id wsId = [SELECT Id FROM ASI_CRM_AccountsAdditionalField__c WHERE RecordType.DeveloperName = 'ASI_CRM_SG_Wholesaler' AND Name = :custName LIMIT 1].Id;
		List<ASI_TH_CRM_PaymentRequest__c> paymentDelete = new List<ASI_TH_CRM_PaymentRequest__c>();
		List<ASI_CRM_Credit_Debit_Note__c> cNoteDelete = new List<ASI_CRM_Credit_Debit_Note__c>();
		
        if(creditNoteList.size() == 0 && paymentList.size() == 0) {
            return 'Please use monthly by batch generation for Wholesaler Back Rebate : ' + monthStr + '/' + yearStr + '. ';
        } 
		else {
			for (ASI_CRM_Credit_Debit_Note__c c:creditNoteList){
				if (c.ASI_CRM_Wholesaler__c == wsId && c.ASI_CRM_Status__c != 'Draft' && c.ASI_CRM_Status__c != 'Rejected')
					notDraft = true;
			}
			
			for (ASI_TH_CRM_PaymentRequest__c p:paymentList){
				if (p.ASI_CRM_CN_OutletWS__c == wsId && p.ASI_TH_CRM_Status__c != 'Draft' && p.ASI_TH_CRM_Status__c != 'Rejected')
					notDraft = true;
			}
			
			if (notDraft)
				return 'There are submitted or approved Payment and Credit Note for this period : ' + monthStr + '/' + yearStr + '. ';
			else {		
				for (ASI_CRM_Credit_Debit_Note__c c:creditNoteList){
					if (c.ASI_CRM_Wholesaler__c == wsId)
						cNoteDelete.add(c);
				}
				
				for (ASI_TH_CRM_PaymentRequest__c p:paymentList){
					if (p.ASI_CRM_CN_OutletWS__c == wsId)
						paymentDelete.add(p);
				}
				
				delete cNoteDelete;
				delete paymentDelete;
				 
				return 'OK';
			}
        }
		
    }
	/*[WL 3.0] END*/
	
    public string lastPromptPaymentReceiptDate{
        get{
            string lastReceiptDate = '2016-07-01';
            
            List<ASI_CRM_Credit_Debit_Note__c> cList = [SELECT ASI_CRM_Receipt_End_Date__c FROM ASI_CRM_Credit_Debit_Note__c   
                WHERE recordtype.DeveloperName in ('ASI_CRM_SG_Prompt_Payment_Credit_Note','ASI_CRM_SG_Prompt_Payment_Credit_Note_Read_Only')
				order by ASI_CRM_Receipt_End_Date__c desc limit 1];
                
            if (cList.size()>0){
				ASI_CRM_Credit_Debit_Note__c c = cList[0];
				date oneMoreDay = c.ASI_CRM_Receipt_End_Date__c + 1;
				Datetime dt = datetime.newInstance(oneMoreDay.year(), oneMoreDay.month(),oneMoreDay.day());
				lastReceiptDate = dt.format('YYYY-MM-dd'); 
			}
            
            return lastReceiptDate;
        }
        set;
    }
	
    @RemoteAction 
    global static String computePromptPayment(String invoiceStartDate, String invoiceEndDate) {

        return 'OK';
    }

	/*[WL 1.0] BEGIN*/
	@RemoteAction
    global static String checkBeforeDeleteCM(String monthStr, String yearStr, String contractNo) {
		string result;
		
		//Check if the Contract entered is owned by Current User and is an Approved Contract
        List<ASI_TH_CRM_Contract__c> contractList = [SELECT Id, OwnerId
                                                     FROM ASI_TH_CRM_Contract__c
                                                     WHERE Name =: contractNo 
                                                     AND ownerId = :UserInfo.getUserId()
                                                     AND recordtype.developerName = 'ASI_CRM_SG_Contract_Read_Only'];

        List<String> contractIdList = new List<String>();                                               
        for(ASI_TH_CRM_Contract__c contract : contractList) {
            contractIdList.add(contract.Id);
        }

        if(contractIdList.size() == 0) {
            result = 'Contract '+contractNo+' is not a valid approved contract';
			system.debug('checkBeforeDeleteCM: ' + result);
			return result;
        }

        
		//Check if Current User has used the Monthly By Batch generation already
        List<ASI_CRM_Credit_Debit_Note__c> draftCM = new List<ASI_CRM_Credit_Debit_Note__c>();
		
		List<ASI_CRM_Credit_Debit_Note__c> existingCNoteList = [SELECT Id, ASI_CRM_Contract__r.Name, Name, ASI_CRM_Status__c 
															FROM ASI_CRM_Credit_Debit_Note__c 
															WHERE ASI_CRM_Month__c = :monthStr AND ASI_CRM_Year__c = :yearStr 
																AND OwnerID = :UserInfo.getUserId() AND RecordType.DeveloperName like '%ASI_CRM_SG_Contract_Margin%'];
		
		if (existingCNoteList.size() == 0){
			result = 'There are no Contract Margin Credit/Debit Note for '+monthStr +'-'+yearStr+', please use the monthly generation by batch function instead';			
			system.debug('checkBeforeDeleteCM: ' + result);
			return result;
		}
		else {
			for (ASI_CRM_Credit_Debit_Note__c cNote:existingCNoteList){
				if (cNote.ASI_CRM_Contract__r.Name == contractNo){
					if (cNote.ASI_CRM_Status__c == 'Draft' || cNote.ASI_CRM_Status__c == 'Rejected'){
						result = 'DraftOrRejectedCM';
						system.debug('checkBeforeDeleteCM: ' + result);
						return result;
					}
					else if (cNote.ASI_CRM_Status__c == 'Submitted'){
						result = 'There is a submitted Contract Margin Credit/Debit Note (' + cNote.Name + ') for '+monthStr +'-'+yearStr+', please reject it before regenerating for this Contract';
						system.debug('checkBeforeDeleteCM: ' + result);
						return result;
					}
					else if (cNote.ASI_CRM_Status__c == 'Approved'){
						result = 'There is an approved Contract Margin Credit/Debit Note (' + cNote.Name + ') for '+monthStr +'-'+yearStr+', please contact Finance and IT for support.';
						system.debug('checkBeforeDeleteCM: ' + result);
						return result;
					}
				}
			}
		}
		
		result = 'OKNoExistingCMForThisContract';
		system.debug('checkBeforeDeleteCM: ' + result);
		return result;
    }
	
	@RemoteAction
    global static String recomputeCM(String monthStr, String yearStr, String contractNo) {
		//Delete existing Draft or Rejected Credit Note
		List<ASI_CRM_Credit_Debit_Note__c> existingCNoteList = [SELECT Id 
															FROM ASI_CRM_Credit_Debit_Note__c 
															WHERE ASI_CRM_Month__c = :monthStr AND ASI_CRM_Year__c = :yearStr 
																AND ASI_CRM_Contract__r.Name = :contractNo 
																AND OwnerID = :UserInfo.getUserId() AND RecordType.DeveloperName like '%ASI_CRM_SG_Contract_Margin%'
																AND ASI_CRM_Status__c in ('Draft','Rejected')];
		
		if (existingCNoteList.size() > 0)
			delete existingCNoteList;
		
		//Prepare Batch Job input parameter
		List<ASI_TH_CRM_Contract__c> contractList = [SELECT Id
                                                     FROM ASI_TH_CRM_Contract__c
                                                     WHERE Name =: contractNo 
                                                     AND ownerId = :UserInfo.getUserId()
                                                     AND recordtype.developerName = 'ASI_CRM_SG_Contract_Read_Only'];

        Set<Id> contractIdSet = new Set<Id>();                                               
        for(ASI_TH_CRM_Contract__c contract : contractList) {
            contractIdSet.add(contract.Id);
        }
	
		
		return 'OK';
        
    }
	/*[WL 1.0] END*/
}