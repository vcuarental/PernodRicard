public without sharing class ASI_TnE_KR_ClaimHeaderPDFController {

        private ASI_TnE_ClaimHeader__c header;
    	//private List<ASI_eForm_HR_MDM__c> mdm; //added by Leo ,2015-06-02
        public String currentHeaderId {get; set;}
        public String currentAction {get; set;}
        public User selectedUser {get;set;}        
        public User ownerUser {get;set;}
        private List<ASI_TnE_ClaimDetail__c> claimDetails {get;set;}
    public List<double> amountOfAnP {get; set;}
        private List<List<Object>> aggregatedClaimDetails {get;set;}
        public Decimal totalAmount {get;set;}
        // BETA CR
        public string uLocale {get; set;}
        public integer days {get; set;}
    	
    	public List<approvalDetail> approvalDetails;
    	public Integer numOfApprovals{get;set;}
    
    public String employeeId;
    
    public integer getNumberOfDays(){
       List<ASI_TnE_ClaimDetail__c> obj = getClaimDetails();
        days = date.daysInMonth(obj[0].ASI_TnE_Receipt_Date__c.Year(),obj[0].ASI_TnE_Receipt_Date__c.Month());
        return days;
    }
    
        public ASI_TnE_KR_ClaimHeaderPDFController()
        {
            this.uLocale = userinfo.getLanguage();
            system.debug('leikey ' + uLocale);
        }       
        
    public List<double> getAmount(){
        getClaimDetails();
        return amountOfAnP;
    }
    
    public ASI_eForm_HR_MDM__c getBankInfo()
    {
        ASI_eForm_HR_MDM__c tempBankInfo;
        
        if (employeeId != null)
        {
            tempBankInfo = [SELECT id, ASI_eForm_Employee_Korean_Name__c
                       		FROM ASI_eForm_HR_MDM__c WHERE Name =: employeeId limit 1];
        }
        return tempBankInfo;
    }
    
    public List<approvalDetail> getapprovalDetails() {
        List<approvalDetail> details = new List<approvalDetail>();
        if (details.size() == 0 && currentHeaderId != null){
            List<ProcessInstance> pList = [SELECT Id, (SELECT CreatedDate, Id, StepStatus, Comments, ActorId, Actor.Name FROM StepsAndWorkitems Order By CreatedDate DESC, StepStatus DESC) FROM ProcessInstance Where TargetObjectId = :currentHeaderId Order By CreatedDate DESC Limit 1];
            Set<Id> actoerIdSet = new Set<Id>();
            for (ProcessInstance p:pList) {
                for (ProcessInstanceHistory his:p.StepsAndWorkitems) {
                    actoerIdSet.add(his.ActorId);
                }
            }
            Map<Id, User> userMap = new Map<Id, User>([Select Id, title From User Where Id In :actoerIdSet]);
            for (ProcessInstance p:pList) {
                Boolean byPassPending = false;
                if(p.StepsAndWorkitems.size() != 0 && (p.StepsAndWorkitems[0].StepStatus == 'Approved' || p.StepsAndWorkitems[0].StepStatus == 'Rejected') ){
                    byPassPending = true;
                }
                for (ProcessInstanceHistory his:p.StepsAndWorkitems) {
                    if(his.StepStatus != 'Reassigned' && his.StepStatus != 'NoResponse' && !(byPassPending && his.StepStatus == 'Pending')){
                        approvalDetail detail = new approvalDetail();
                        detail.title = userMap.get(his.ActorId).title;
                        detail.history = his;
                        details.add(detail);
                    }
                }
            }
            numOfApprovals = details.size();
        }
        return details;
    }
    
        public List<ASI_TnE_ClaimDetail__c> getClaimDetails()
        {
           if (claimDetails == null) {
                claimDetails = [SELECT 
                    Name,
                    ASI_TnE_Receipt_Date__c, 
                    ASI_TnE_KR_Receipt_Time__c,
                    ASI_TnE_Expense_Category__c,
                    ASI_TnE_Expense_Classification__r.ASI_JP_TnE_Account_Mapping__r.ASI_TnE_Account_Number__c,
                    ASI_TnE_Expense_Category__r.Name_en_US__c,
                    ASI_TnE_Expense_Classification__r.Name,  
                    ASI_TnE_Expense_Classification__r.Name_en_US__c,   
                    ASI_TnE_Receipt_Number__c,
                    ASI_TnE_KR_Business_Name__c,                                
                    ASI_TnE_Total_Number_Pax__c,
                    ASI_TnE_KR_InterCompany__c,
                    ASI_TnE_KR_Customer__r.Name,
                    ASI_TnE_Dept_in_Charge__c,
					ASI_TnE_KR_AccountCode__c,
                    ASI_TnE_KR_Sub_Brand__r.ASI_KOR_Brand_Code__c,
                    ASI_TnE_KR_Owner__r.Name,
                    ASI_TnE_KR_Co_Approver__r.Name,
                    ASI_TnE_Currency__c,
                    ASI_TnE_Branch_code_Channel__r.Name,
                    ASI_TnE_KR_Owner__r.CompanyName,
                    ASI_TnE_Promotion_Code__c,
                    ASI_TnE_Receipt_Amount__c,
                    ASI_TnE_Details_of_Expense__c,                
                    ASI_TnE_KR_AmountKRW__c,
                    ASI_TnE_Attendee_Name__c,
                    ASI_TnE_FX_Rate__c,
                    ASI_TnE_KR_Where__r.Name,
                    ASI_TnE_Expense_Classification__r.ASI_TnE_Auto_Receipt_No__c,
                    ASI_TnE_KR_Promotion_Code__r.Name
                    FROM ASI_TnE_ClaimDetail__c 
                    WHERE ASI_TnE_ClaimHeader__c = :currentHeaderId order by
                    ASI_TnE_Dept_in_Charge__c,ASI_TnE_Receipt_Date__c,ASI_TnE_Expense_Category__r.ASI_JP_TnE_Expense_Category_Order__c,ASI_TnE_Receipt_Number__c,name
                ];   
                
                Integer i=1;
               
               amountOfAnP = new list<Double>();
               amountOfAnP.add(0);
               amountOfAnP.add(0);
               amountOfAnP.add(0);
                for(ASI_TnE_ClaimDetail__c d : claimDetails ){
                    
                    if(d.ASI_TnE_Dept_in_Charge__c=='Trade MKT'){
                        
                        amountOfAnP[0] += d.ASI_TnE_Receipt_Amount__c;
                    }
                    
                    if(d.ASI_TnE_Dept_in_Charge__c=='Brand MKT'){
                        
                        amountOfAnP[1] += d.ASI_TnE_Receipt_Amount__c;
                    }
                    
                    if(d.ASI_TnE_Dept_in_Charge__c=='Wrong Use'){
                        
                        amountOfAnP[2] += d.ASI_TnE_Receipt_Amount__c;
                    }
                    
                    /*if(d.ASI_TnE_Expense_Classification__r.ASI_TnE_Auto_Receipt_No__c){
                        d.ASI_TnE_Receipt_Number__c=i;
                        i++;
                    }*/
                }
               amountOfAnP.add(amountOfAnP[0]+amountOfAnP[1]+amountOfAnP[2]);
            }
           
            return claimDetails;
        }
    
        public User getCurrentUser()
        {
            getHeader();
            return selectedUser;        
        }
        
        /*public boolean getIsFinalPrint()
        {
            return (currentAction!=null && 'finalPrint'.equals(currentAction));        
        }
        
        public boolean getIseApprovedPrint()
        {
            return (currentAction!=null && 'Approved'.equals(currentAction));        
        }*/
        
        public List<List<Object>> getAggregatedCategoryExpenses()
        {
          if (aggregatedClaimDetails == null)
          {
            totalAmount  = 0;
            aggregatedClaimDetails  = new List<List<Object>>();
            List<ASI_TnE_ClaimDetail__c> claimDetails = [SELECT 
            ASI_TnE_Expense_Classification__r.ASI_JP_TnE_Account_Mapping__r.ASI_JP_TnE_Account_Name__c, 
            ASI_TnE_Expense_Classification__r.ASI_JP_TnE_Account_Mapping__r.ASI_TnE_Account_Number__c,
            ASI_TnE_Expense_Classification__r.ASI_TnE_KR_Expense_Category__r.Name_en_US__c,
            ASI_TnE_Expense_Classification__r.Name_en_US__c,
            ASI_TnE_KR_AmountKRW__c,
            ASI_TnE_Taxable_Amount__c,
            ASI_TnE_Expense_Category__r.Name_en_US__c,
            //ASI_TnE_Branch_code_Channel__c,                                             
            ASI_TnE_Non_Taxable_Amount__c,
            ASI_TnE_Expense_Classification__r.ASI_JP_TnE_Expense_Category__r.ASI_JP_TnE_Expense_Category_Order__c
            FROM ASI_TnE_ClaimDetail__c WHERE ASI_TnE_ClaimHeader__c = :currentHeaderId
            order by ASI_TnE_Expense_Classification__r.ASI_JP_TnE_Account_Mapping__r.ASI_JP_TnE_Account_Mapping_Order__c];  
            
            String previousClassification = '';
            String previousCategory = '';
            String previousAccountNumber = '';
            Decimal previousTotalAmount = 0;
            Decimal previousTaxableAmount = 0;
            Decimal previousNonTaxableAmount = 0;
            
            List<String> classList = new List<String>();
            
            List<Decimal> totalAmountList = new List<Decimal>();
            
            List<Decimal> taxableAmountList = new List<Decimal>();
            
            List<Decimal> nonTaxableAmountList = new List<Decimal>();
            
            List<String> accountNumberList = new List<String>();
              
            List<String> catList = new List<String>();
              Map<String,String> classMapAC = new Map<String,String>();
              Map<String,String> classMapCat = new Map<String,String>();
              Map<String,Decimal> classMapTot = new Map<String,Decimal>();
            
            System.debug('XXXX Claim Details: ' + claimDetails );
            
            for (ASI_TnE_ClaimDetail__c claimDetail : claimDetails)
            {
                String currentClassification = claimDetail.ASI_TnE_Expense_Classification__r.Name_en_US__c;
                String currentCategory = claimDetail.ASI_TnE_Expense_Classification__r.ASI_TnE_KR_Expense_Category__r.Name_en_US__c;
                //String currentCategory = claimDetail.ASI_TnE_Expense_Category__r.Name_en_US__c;/*ASI_TnE_Expense_Classification__r.ASI_JP_TnE_Account_Mapping__r.ASI_JP_TnE_Account_Name__c;*/
                String currentAccountNumber = claimDetail.ASI_TnE_Expense_Classification__r.ASI_JP_TnE_Account_Mapping__r.ASI_TnE_Account_Number__c == null ? '' :
                                              claimDetail.ASI_TnE_Expense_Classification__r.ASI_JP_TnE_Account_Mapping__r.ASI_TnE_Account_Number__c;
                
                System.debug('clk1: currentCategory =  ' + currentCategory + ' currentACnumber = ' + currentAccountNumber + ' currentTotalAmount = ' + claimDetail.ASI_TnE_KR_AmountKRW__c + ' currentTaxableAmount = ' + claimDetail.ASI_TnE_Taxable_Amount__c + ' currentNonTaxAmount = ' + claimDetail.ASI_TnE_Non_Taxable_Amount__c);
                System.debug('clk2: previousCategory =  ' + previousCategory + ' previousAccountNumber = ' + currentAccountNumber + ' previousTotalAmount = ' + previousTotalAmount + ' previousTaxableAmount = ' + previousTaxableAmount + ' previousNonTaxableAmount = ' + previousNonTaxableAmount);
                System.debug('clk3: categoryOrderNumber = ' + claimDetail.ASI_TnE_Expense_Classification__r.ASI_JP_TnE_Expense_Category__r.ASI_JP_TnE_Expense_Category_Order__c);
                
                if (previousClassification/*+previousAccountNumber*/ != '' && (previousClassification/*+previousAccountNumber*/ != currentClassification/*+currentAccountNumber*/))
                {
                    //classList.add(previousClassification);
                    totalAmountList.add(previousTotalAmount);
                    taxableAmountList.add(previousTaxableAmount);
                    nonTaxableAmountList.add(previousNonTaxableAmount);
                    accountNumberList.add(previousAccountNumber);
                    if(previousClassification != currentClassification && previousAccountNumber == currentAccountNumber)
                        classMapAC.put(previousClassification,previousAccountNumber);
                    else
                        classMapAC.put(previousClassification,previousAccountNumber);
                    classMapCat.put(previousClassification,previousCategory);
                    if(!classMapTot.containsKey(previousClassification))
                        classMapTot.put(previousClassification,previousTotalAmount);
                    else
                        classMapTot.put(previousClassification,classMapTot.get(previousClassification)+previousTotalAmount);
                    //catList.add(previousCategory);
                    totalAmount +=  previousTotalAmount;
                    previousCategory = currentCategory;
                    previousClassification = currentClassification;
                    previousAccountNumber = currentAccountNumber;
                    previousTotalAmount = claimDetail.ASI_TnE_KR_AmountKRW__c;
                    previousTaxableAmount = claimDetail.ASI_TnE_Taxable_Amount__c;
                    previousNonTaxableAmount = claimDetail.ASI_TnE_Non_Taxable_Amount__c;
                } else
                {
                    previousClassification = currentClassification;
                    previousCategory = currentCategory;
                    previousAccountNumber = currentAccountNumber;
                    previousTotalAmount += claimDetail.ASI_TnE_KR_AmountKRW__c;    
                    if( claimDetail.ASI_TnE_Taxable_Amount__c!=null){
                    previousTaxableAmount += claimDetail.ASI_TnE_Taxable_Amount__c;
                    }
                    else{claimDetail.ASI_TnE_Taxable_Amount__c=0;}
                    if( claimDetail.ASI_TnE_Non_Taxable_Amount__c!=null){
                    previousNonTaxableAmount += claimDetail.ASI_TnE_Non_Taxable_Amount__c;
                    }else{claimDetail.ASI_TnE_Non_Taxable_Amount__c=0;}
                }                
            }
            
            if (previousClassification+previousAccountNumber != '')
            {
                classMapAC.put(previousClassification,previousAccountNumber);
                classMapCat.put(previousClassification,previousCategory);
                if(!classMapTot.containsKey(previousClassification))
                    classMapTot.put(previousClassification,previousTotalAmount);
                else
                    classMapTot.put(previousClassification,classMapTot.get(previousClassification)+previousTotalAmount);
                    //classList.add(previousClassification);
                    //totalAmountList.add(previousTotalAmount);
                    taxableAmountList.add(previousTaxableAmount);
                    nonTaxableAmountList.add(previousNonTaxableAmount);
                    accountNumberList.add(previousAccountNumber);
                	//catList.add(previousCategory);
                    totalAmount +=  previousTotalAmount;
            }
              for(integer i = 0 ; i < taxableAmountList.size(); i++){
                  if(taxableAmountList[i]==null){
                  taxableAmountList[i]=0;
                  }
              }
              for(integer i = 0 ; i < nontaxableAmountList.size(); i++){
                  if(nontaxableAmountList[i]==null){
                  nontaxableAmountList[i]=0;
                  }
              }
              
            if (/*classList.size() > 0*/classMapAC.keySet().size() > 0)
            {
                for(String a : classMapAC.keySet())
                    classList.add(a);
                //classList.add('Total');
                Decimal totalAmounts = 0;
                for (Decimal totalAmount : totalAmountList)
                {
                    totalAmounts += totalAmount;                
                }
                //totalAmountList.add(totalAmounts);
                Decimal taxableAmounts = 0;
                for (Decimal taxableAmount: taxableAmountList)
                {
                    taxableAmounts += taxableAmount;                
                }
                taxableAmountList.add(taxableAmounts);

                Decimal nonTaxableAmounts = 0;
                for (Decimal nonTaxableAmount : nonTaxableAmountList)
                {
                    nonTaxableAmounts += nonTaxableAmount ;                
                }
                nonTaxableAmountList.add(nonTaxableAmounts );
                //accountNumberList.add((totalAmounts - taxableAmounts - nonTaxableAmounts).format());
                    
                aggregatedClaimDetails.add(classList);
                
                aggregatedClaimDetails.add(classMapTot.values());
                
                aggregatedClaimDetails.add(taxableAmountList);
                
                aggregatedClaimDetails.add(nonTaxableAmountList);
                
                aggregatedClaimDetails.add(classMapAC.values());
                
                aggregatedClaimDetails.add(classMapCat.values());
            
            }
              
          }
            
          System.debug('XXX Aggregated Details: ' +aggregatedClaimDetails );
           return aggregatedClaimDetails ;
        }
        
        public ASI_TnE_ClaimHeader__c getHeader()
        {
              if (header == null && currentHeaderId != null) {
                 header = [SELECT ASI_TnE_Date__c, Name, ASI_TnE_Department_Division__c, ASI_TnE_Status__c,
                 ASI_TnE_Cover_Period_From__c, ASI_TnE_Cover_Period_To__c,
                 ASI_TnE_KR_Employee_ID__c,
                 ASI_TnE_Remarks__c,
                 ASI_TnE_End_Date__c,
                 ASI_TnE_KR_TotalAmount__c,
                 ASI_TnE_KR_Credit_Card_No__c,
                 ASI_TnE_Currency__c,
                 ASI_TnE_KR_CoApprover_1__r.Name,ASI_TnE_KR_CoApprover_2__r.Name,ASI_TnE_KR_CoApprover_3__r.Name,ASI_TnE_KR_CoApprover_4__r.Name,ASI_TnE_KR_CoApprover_5__r.Name,
                 ASI_TnE_KR_Budget_Owner_1__r.Name,ASI_TnE_KR_Budget_Owner_2__r.Name,ASI_TnE_KR_Budget_Owner_3__r.Name,ASI_TnE_KR_Budget_Owner_4__r.Name,ASI_TnE_KR_Budget_Owner_5__r.Name,
                 ASI_TnE_First_Approval_By__c, ASI_TnE_First_Approval_Date__c,
                 ASI_TnE_Second_Approval_By__c,ASI_TnE_Second_Approval_Date__c,
                 ASI_TnE_KR_Additional_Approver_1__r.Name,ASI_TnE_KR_Additional_Approver_2__r.Name,ASI_TnE_KR_Additional_Approver_3__r.Name,ASI_TnE_KR_Additional_Approver_4__r.Name,ASI_TnE_KR_Additional_Approver_5__r.Name,          
                 ASI_TnE_KR_Payee__r.Name,ASI_TnE_KR_Payee__r.CompanyName,ASI_TnE_KR_Payee__r.ASI_KOR_Commission_Code__c,ASI_TnE_KR_Payee__r.ASI_KOR_User_Branch_Code__c,
                 ASI_TnE_KR_Line_Manager__r.Name,
                 ASI_TnE_Payment_Option__c,
                 Owner.Name, OwnerId, ASI_TnE_Payment_Date__c,ASI_TnE_Submission_Date__c,ASI_TnE_Document_No__c,
                 CreatedById, ASI_TnE_Charger__c,
                 ASI_TnE_KR_Department__c,ASI_TnE_KR_Company__c,ASI_TnE_KR_UpdateCount__c
                 from ASI_TnE_ClaimHeader__c where Id = :currentHeaderId];
                
                Set<Id> userIds = new Set<Id>();
                userIds.add(header.OwnerId);
                userIds.add(header.CreatedById);
                  
                employeeId = header.ASI_TnE_KR_Employee_ID__c;
                
                if (header.ASI_TnE_Charger__c != null)
                    userIds.add(header.ASI_TnE_Charger__c);
                
                Map<Id,User> users = new Map<Id,User>([SELECT Name, CompanyName, ASI_JP_TnE_Department_Category_Code__c, 
                ASI_TnE_Sub_Ledger__c,ASI_KOR_Commission_Code__c,ASI_KOR_User_Branch_Name__c,ASI_KOR_User_Branch_Code__c, ASI_TnE_Department_Code__c from User where
                Id in :userIds]);
                
                if (header.ASI_TnE_Charger__c == null)
                    selectedUser = users.get(header.OwnerId);  
                else
                    selectedUser = users.get(header.ASI_TnE_Charger__c);
                          
                ownerUser = users.get(header.OwnerId);
             }   
             return header;
        }     
        
                
        public ASI_TnE_KR_ClaimHeaderPDFController (ApexPages.StandardController stdController){
            this();
            //this.header = (ASI_TnE_ClaimHeader__c)stdController.getRecord();           
        }
    
    //Approval History
    public Class approvalDetail{
        public ProcessInstanceHistory history{get;set;}
        public String title{get;set;}
    }
}