public with sharing class ASI_JP_TnE_ClaimHeaderPDFController {

        private ASI_TnE_ClaimHeader__c header;
        public String currentHeaderId {get; set;}
        public String currentAction {get; set;}
        public User selectedUser {get;set;}        
        public User ownerUser {get;set;}
        private List<ASI_TnE_ClaimDetail__c> claimDetails {get;set;}        
        private List<List<Object>> aggregatedClaimDetails {get;set;}
        public Decimal totalAmount {get;set;}
        // BETA CR
        public string uLocale {get; set;}
                
        public ASI_JP_TnE_ClaimHeaderPDFController()
        {
            this.uLocale = userinfo.getLanguage();
            system.debug('leikey ' + uLocale);
        }       
        
        public List<ASI_TnE_ClaimDetail__c> getClaimDetails()
        {
           if (claimDetails == null) {
                claimDetails = [SELECT ASI_TnE_Receipt_Date__c, 
                    ASI_TnE_Expense_Category__c, 
                    ASI_TnE_Expense_Classification__r.Name,  
                    ASI_TnE_Expense_Classification__r.Name_en_US__c,   
                    ASI_TnE_Receipt_Number__c,                                
                    ASI_TnE_Total_Number_Pax__c,
                    ASI_TnE_Currency__c,
                    ASI_TnE_Receipt_Amount__c,
                    ASI_TnE_Details_of_Expense__c,                
                    ASI_TnE_Payment_Amount__c,
                    ASI_TnE_Attendee_Name__c,
                    ASI_TnE_Expense_Classification__r.ASI_TnE_Auto_Receipt_No__c               
                    FROM ASI_TnE_ClaimDetail__c 
                    WHERE ASI_TnE_ClaimHeader__c = :currentHeaderId order by
                    ASI_TnE_Receipt_Date__c, ASI_TnE_Expense_Category__r.ASI_JP_TnE_Expense_Category_Order__c,ASI_TnE_Receipt_Number__c,name
                ];   
                
                Integer i=1;
                for(ASI_TnE_ClaimDetail__c d : claimDetails ){
                    if(d.ASI_TnE_Expense_Classification__r.ASI_TnE_Auto_Receipt_No__c){
                        d.ASI_TnE_Receipt_Number__c=i;
                        i++;
                    }
                }         
            }
           
            return claimDetails;
        }
        
        public User getCurrentUser()
        {
            getHeader();
            return selectedUser;        
        }
        
        public boolean getIsFinalPrint()
        {
            return (currentAction!=null && 'finalPrint'.equals(currentAction));        
        }
        
        public boolean getIseApprovedPrint()
        {
            return (currentAction!=null && 'eApprovedPrint'.equals(currentAction));        
        }
        
        public List<List<Object>> getAggregatedCategoryExpenses()
        {
          if (aggregatedClaimDetails == null)
          {
            totalAmount  = 0;
            aggregatedClaimDetails  = new List<List<Object>>();
            List<ASI_TnE_ClaimDetail__c> claimDetails = [SELECT 
            ASI_TnE_Expense_Classification__r.ASI_JP_TnE_Account_Mapping__r.ASI_JP_TnE_Account_Name__c, 
            ASI_TnE_Expense_Classification__r.ASI_JP_TnE_Account_Mapping__r.ASI_TnE_Account_Number__c,
            ASI_TnE_Payment_Amount__c,
            ASI_TnE_Taxable_Amount__c, 
            ASI_TnE_Non_Taxable_Amount__c,
            ASI_TnE_Tax_Area__c,
            ASI_TnE_Expense_Classification__r.ASI_JP_TnE_Expense_Category__r.ASI_JP_TnE_Expense_Category_Order__c
            FROM ASI_TnE_ClaimDetail__c WHERE ASI_TnE_ClaimHeader__c = :currentHeaderId
            order by ASI_TnE_Expense_Classification__r.ASI_JP_TnE_Account_Mapping__r.ASI_JP_TnE_Account_Mapping_Order__c,ASI_TnE_Tax_Area__c];  
            
            String previousCategory = '';
            String previousAccountNumber = '';
            Decimal previousTotalAmount = 0;
            Decimal previousTaxableAmount = 0;
            Decimal previousNonTaxableAmount = 0;
            
            List<String> headerList = new List<String>();
            
            List<Decimal> totalAmountList = new List<Decimal>();
            
            List<Decimal> taxableAmountList = new List<Decimal>();
            
            List<Decimal> nonTaxableAmountList = new List<Decimal>();
            
            List<String> accountNumberList = new List<String>();
            
            System.debug('XXXX Claim Details: ' + claimDetails );
            
            Map<String, Decimal> vatamountM = new Map<String, Decimal>();
            
            for (ASI_TnE_ClaimDetail__c claimDetail : claimDetails)
            {
                String currentCategory = claimDetail.ASI_TnE_Expense_Classification__r.ASI_JP_TnE_Account_Mapping__r.ASI_JP_TnE_Account_Name__c;
                String currentAccountNumber = claimDetail.ASI_TnE_Expense_Classification__r.ASI_JP_TnE_Account_Mapping__r.ASI_TnE_Account_Number__c == null ? '' :
                                              claimDetail.ASI_TnE_Expense_Classification__r.ASI_JP_TnE_Account_Mapping__r.ASI_TnE_Account_Number__c;
                
                System.debug('clk1: currentCategory =  ' + currentCategory + ' currentACnumber = ' + currentAccountNumber + ' currentTotalAmount = ' + claimDetail.ASI_TnE_Payment_Amount__c + ' currentTaxableAmount = ' + claimDetail.ASI_TnE_Taxable_Amount__c + ' currentNonTaxAmount = ' + claimDetail.ASI_TnE_Non_Taxable_Amount__c);
                System.debug('clk2: previousCategory =  ' + previousCategory + ' previousAccountNumber = ' + currentAccountNumber + ' previousTotalAmount = ' + previousTotalAmount + ' previousTaxableAmount = ' + previousTaxableAmount + ' previousNonTaxableAmount = ' + previousNonTaxableAmount);
                System.debug('clk3: categoryOrderNumber = ' + claimDetail.ASI_TnE_Expense_Classification__r.ASI_JP_TnE_Expense_Category__r.ASI_JP_TnE_Expense_Category_Order__c);
                
                if (previousCategory+previousAccountNumber != '' && (previousCategory+previousAccountNumber != currentCategory+currentAccountNumber))
                {
                    headerList.add(previousCategory);
                    totalAmountList.add(previousTotalAmount);
                    taxableAmountList.add(previousTaxableAmount);
                    nonTaxableAmountList.add(previousNonTaxableAmount);
                    accountNumberList.add(previousAccountNumber);      
                    totalAmount +=  previousTotalAmount;
                    previousCategory = currentCategory;
                    previousAccountNumber = currentAccountNumber;
                    previousTotalAmount = claimDetail.ASI_TnE_Payment_Amount__c;
                    previousTaxableAmount = claimDetail.ASI_TnE_Taxable_Amount__c;
                    previousNonTaxableAmount = claimDetail.ASI_TnE_Non_Taxable_Amount__c;
                        
                } else
                {
                    previousCategory = currentCategory;
                    previousAccountNumber = currentAccountNumber;
                    previousTotalAmount += claimDetail.ASI_TnE_Payment_Amount__c;    
                    previousTaxableAmount += claimDetail.ASI_TnE_Taxable_Amount__c;
                    previousNonTaxableAmount += claimDetail.ASI_TnE_Non_Taxable_Amount__c;
                    
                                            
                }             

                if(vatamountM.containsKey(claimDetail.ASI_TnE_Tax_Area__c)){
                    Decimal temp=vatamountM.get(claimDetail.ASI_TnE_Tax_Area__c);
                    temp+= (claimDetail.ASI_TnE_Payment_Amount__c - claimDetail.ASI_TnE_Taxable_Amount__c - claimDetail.ASI_TnE_Non_Taxable_Amount__c);
                    vatamountM.put(claimDetail.ASI_TnE_Tax_Area__c,temp) ;
                }else
                    vatamountM.put(claimDetail.ASI_TnE_Tax_Area__c, (claimDetail.ASI_TnE_Payment_Amount__c - claimDetail.ASI_TnE_Taxable_Amount__c - claimDetail.ASI_TnE_Non_Taxable_Amount__c)) ;
            }
            
            if (previousCategory+previousAccountNumber != '')
            {
                    headerList.add(previousCategory);
                    totalAmountList.add(previousTotalAmount);
                    taxableAmountList.add(previousTaxableAmount);
                    nonTaxableAmountList.add(previousNonTaxableAmount);
                    accountNumberList.add(previousAccountNumber);              
                    totalAmount +=  previousTotalAmount;
            }
            
            if (headerList.size() > 0)
            {
                
                headerList.add('Total');
                
                Decimal totalAmounts = 0;
                for (Decimal totalAmount : totalAmountList)
                {
                    totalAmounts += totalAmount;                
                }
                totalAmountList.add(totalAmounts);
                
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
                
                List<Decimal> vatamountL =vatamountM.values();
                
                String vatS='';
                
                for(Decimal d:vatamountL)
                    vatS+=d.format()+'<br/>';
                    
                accountNumberList.add(vatS);
                
                
                
                aggregatedClaimDetails.add(headerList);                
                aggregatedClaimDetails.add(totalAmountList);                
                aggregatedClaimDetails.add(taxableAmountList);                
                aggregatedClaimDetails.add(nonTaxableAmountList);                
                aggregatedClaimDetails.add(accountNumberList);
            
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
                 ASI_TnE_Remarks__c,
                 ASI_TnE_First_Approval_By__c, ASI_TnE_First_Approval_Date__c,
                 ASI_TnE_Second_Approval_By__c,ASI_TnE_Second_Approval_Date__c,
                 ASI_TnE_Payee__r.Name,ASI_TnE_Payee__r.ASI_MFM_Customer_Supplier_Number__c,
                 ASI_TnE_Payment_Option__c,
                 Owner.Name, OwnerId, ASI_TnE_Payment_Date__c,ASI_TnE_Submission_Date__c,ASI_TnE_Document_No__c,
                 CreatedById, ASI_TnE_Charger__c
                 //20161027, Leo@Elufa
                 ,ASI_TnE_JP_Marketing_User__c ,ASI_TnE_Third_Approval_By__c
                 ,ASI_TnE_Third_Approval_Date__c ,ASI_TnE_Fourth_Approval_By__c
                 ,ASI_TnE_Fourth_Approval_Date__c
                 //20161027, Leo@Elufa
                 from ASI_TnE_ClaimHeader__c where Id = :currentHeaderId];  
                
                Set<Id> userIds = new Set<Id>();
                userIds.add(header.OwnerId);
                userIds.add(header.CreatedById);
                
                if (header.ASI_TnE_Charger__c != null)
                    userIds.add(header.ASI_TnE_Charger__c);
                
                Map<Id,User> users = new Map<Id,User>([SELECT Name, CompanyName, ASI_JP_TnE_Department_Category_Code__c, 
                ASI_TnE_Sub_Ledger__c, ASI_TnE_Department_Code__c from User where
                Id in :userIds]);
                
                if (header.ASI_TnE_Charger__c == null)
                    selectedUser = users.get(header.OwnerId);  
                else
                    selectedUser = users.get(header.ASI_TnE_Charger__c);
                          
                ownerUser = users.get(header.OwnerId);
             }   
             return header;
        }     
        
                
        public ASI_JP_TnE_ClaimHeaderPDFController (ApexPages.StandardController stdController){
            this();
            //this.header = (ASI_TnE_ClaimHeader__c)stdController.getRecord();           
        }
}