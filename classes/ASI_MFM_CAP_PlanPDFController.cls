public with sharing class ASI_MFM_CAP_PlanPDFController{
        
        public String currentHeaderId;
        public String headerRecordTypeId {get; set;}
        public string init;
        public List<ASI_MFM_Plan_Line_Item__c> details;
        public ASI_MFM_Plan__c Header;
        public Decimal totalAmount {get;set;}
        public String approver1 {get;set;}
        public String approver2 {get;set;}
        public boolean isWithinBudget {get;set;}
        public String strCountry {get; set;}
        public String strCurrency {get; set;}
        private List<User> userList;
        
        public ASI_MFM_CAP_PlanPDFController()
        {
            // init();
        }  
        
        public void setcurrentHeaderId (String s) {
            currentHeaderId = s;
            init();
        }

        public String getcurrentHeaderId() {
            return currentHeaderId;
        }
        
        public void setHeaderRecordTypeId (String s) {
            currentHeaderId = s;
        }

        public String getHeaderRecordTypeId() {
            return currentHeaderId;
        }
        
        public String setinit(string s)
        {
            System.debug('-- setinit called!');
            init();
            return s;
        }
        
        /*public String getinit()
        {
            init();
            return '';
        }*/

        public void init()
        {
            system.debug('-- header : '+header);
            if (/*header == null &&*/ currentHeaderId != null) 
            {
             Map<String, Schema.SObjectField> planFieldMap = Schema.SObjectType.ASI_MFM_Plan__c.fields.getMap();
             String theQuery = 'Select ';
        
             for(String fields  : planFieldMap.keySet()){
                theQuery += fields + ' ,';
             }
         
             thequery = theQuery.subString(0,theQuery.length()-1);
             thequery += ', owner.name, createdby.name From ASI_MFM_Plan__c where  ID = ' + '\'' + currentHeaderId + '\' ';
             
             List<ASI_MFM_Plan__c> planList = (List<ASI_MFM_Plan__c>)Database.query(theQuery); 
             if (planList.size() > 0) {
                 header = planList.get(0);
                 System.debug('------ header.ASI_MFM_Currency__c ------ : ' + header.ASI_MFM_Currency__c);
                 userList = [SELECT ASI_MFM_Country__c
                               FROM User
                              WHERE Id = :header.OwnerId
                              LIMIT 1];
                 System.debug('------ userList[0].ASI_MFM_Country__c ------ : ' + userList[0].ASI_MFM_Country__c);
                 // ASI_MFM_Country_Recordtype_Mapping__c.getInstance(userList[0].ASI_MFM_Country__c).User_Country__c
                 if(!userList.isEmpty() && !String.isBlank(userList[0].ASI_MFM_Country__c)) {
                     strCountry = ASI_MFM_Country_Recordtype_Mapping__c.getInstance(userList[0].ASI_MFM_Country__c).User_Country__c;
                     // strCountry += ' Ltd';
                     // System.debug('------ strCountry ------ : ' + strCountry);
                 }
              }    
             } 
             
             if (Details == null && currentHeaderId != null) 
             {
                 Map<String, Schema.SObjectField> planDetailsFieldMap = Schema.SObjectType.ASI_MFM_Plan_Line_Item__c.fields.getMap();
                 String theQuery = 'Select ';
        
                 for(String fields  : planDetailsFieldMap.keySet()){
                    theQuery += fields + ' ,';
                 }
         
                 thequery = theQuery.subString(0,theQuery.length()-1);
                 thequery += 'From ASI_MFM_Plan_Line_Item__c where ASI_MFM_Plan__c = ' + '\'' + currentHeaderId + '\' ';
         
                 Details = (List<ASI_MFM_Plan_Line_Item__c>)Database.query(theQuery); 
                 totalAmount = 0;
                 for (ASI_MFM_Plan_Line_Item__c planItem : Details) {
                     System.debug(' ------ planItem.ASI_MFM_Total_Cost__c ------' + planItem.ASI_MFM_Total_Cost__c);
                     totalAmount += planItem.ASI_MFM_Total_Cost__c;
                 }
             }
        }
        
        public List<ASI_MFM_Plan_Line_Item__c> getDetails()
        {
           System.debug('------ Details ------ : ' + Details);
           if (/*Details == null &&*/ currentHeaderId != null) 
           {
             Map<String, Schema.SObjectField> planDetailsFieldMap = Schema.SObjectType.ASI_MFM_Plan_Line_Item__c.fields.getMap();
             String theQuery = 'Select ';
        
             for(String fields  : planDetailsFieldMap.keySet()){
                theQuery += fields + ' ,';
             }
         
             thequery = theQuery.subString(0,theQuery.length()-1);
             thequery += ', ASI_MFM_A_C_Code__r.name, ASI_MFM_AP_Code__r.name From ASI_MFM_Plan_Line_Item__c where ASI_MFM_Plan__c = ' + '\'' + currentHeaderId + '\' ORDER BY ID ASC';
         
             System.debug('------ thequery ------ : ' + thequery);
             Details = (List<ASI_MFM_Plan_Line_Item__c>)Database.query(theQuery);       
             System.debug('------ Details ------ : ' + Details[0].ASI_MFM_A_C_Code__r.name);
             totalAmount = 0;
             for (ASI_MFM_Plan_Line_Item__c planItem : Details)
             {
                 if(planItem.ASI_MFM_Total_Cost__c != null)
                     totalAmount += planItem.ASI_MFM_Total_Cost__c;
             }
            System.debug('------ totalAmount ------ : ' + totalAmount); 
            CalculateBudget(getHeader().ASI_MFM_Fiscal_year__c, totalAmount);        
            }
            return Details;
        }  
        
        public ASI_MFM_Plan__c getHeader()
        {
            if (header == null && currentHeaderId != null) 
            {
             Map<String, Schema.SObjectField> planFieldMap = Schema.SObjectType.ASI_MFM_Plan__c.fields.getMap();
             String theQuery = 'Select ';
        
             for(String fields  : planFieldMap.keySet()){
                theQuery += fields + ' ,';
             } 
         
             thequery = theQuery.subString(0,theQuery.length()-1);
             thequery += ', owner.name, createdby.name, ASI_MFM_Approver_1__r.name, ASI_MFM_Approver_2__r.name From ASI_MFM_Plan__c where  ID = ' + '\'' + currentHeaderId + '\' ';
         
             List<ASI_MFM_Plan__c> planList = (List<ASI_MFM_Plan__c>)Database.query(theQuery); 
             if (planList.size() > 0)
             {
                 header = planList.get(0);
                 list<ProcessInstance> existingApprovals = [SELECT Id, TargetObjectId,
                                                (SELECT Id, StepStatus, actorid, Actor.name, Comments FROM StepsAndWorkitems WHERE StepStatus = : 'Approved')
                                                FROM ProcessInstance 
                                                WHERE TargetObjectId = :header.id];
                 if(header.ASI_MFM_Carry_Forward_Budget__c)
                      approver1 = header.ASI_MFM_Approver_1__r.name;
                 if(header.ASI_MFM_Evaluation_Required__c)
                      approver2 = header.ASI_MFM_Approver_2__r.name;
                 /*if (existingApprovals.size()>0)
                 {
                     Integer count = 0;
                     for(ProcessInstanceHistory i : existingApprovals[0].StepsAndWorkitems)
                     {
                         count++;
                         if ((count/2)*2 != count)
                             approver1 = i.Actor.name;
                         if ((count/2)*2 == count)
                             approver2 = i.Actor.name;
                     }
                 }*/
             }
             }   
             return header;
        }
        
        // Calculate and set Within Capital Budget
        private void CalculateBudget(String fiscalyear, Decimal totalAmountVAR)
        {
            /*List<ASI_MFM_Budget__c> budgetList = [SELECT ID, Name, ASI_MFM_Total_Amount__c, ASI_MFM_Fiscal_Year__c, ASI_MFM_Type__c FROM ASI_MFM_Budget__c
                                                    WHERE recordtypeid = : Global_RecordTypeCache.getRtId('ASI_MFM_Budget__cASI_MFM_CAP_Budget')
                                                    AND ASI_MFM_Fiscal_Year__c = : fiscalyear
                                                    AND ASI_MFM_Budget_Type__c = : 'CAPEX'];*/
            
            String budgetRecordTypeDevName = 'ASI_MFM_CAP_TW_Budget';
            System.debug('------ fiscalyear Function ------ : ' + fiscalyear);
            System.debug('------ headerRecordTypeId Function ------ : ' + headerRecordTypeId);
            if(headerRecordTypeId == NULL) {
                System.debug('------ headerRecordTypeId IN IF ------ : ' + headerRecordTypeId);
                headerRecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_CAP_Plan');
                budgetRecordTypeDevName = 'ASI_MFM_CAP_Budget';
            }
            
            List<ASI_MFM_Budget__c> budgetList = [SELECT ID, Name, ASI_MFM_Total_Amount__c, ASI_MFM_Fiscal_Year__c, ASI_MFM_Type__c FROM ASI_MFM_Budget__c
                                                    WHERE recordtype.developerName LIKE :budgetRecordTypeDevName
                                                    AND ASI_MFM_Fiscal_Year__c = : fiscalyear
                                                    AND ASI_MFM_Budget_Type__c = : 'CAPEX'];
            
            System.debug('------ budgetList Function ------ : ' + budgetList);
            
            System.debug('------ headerRecordTypeId After IF ------ : ' + headerRecordTypeId);                                      
            List<ASI_MFM_Plan__c> planList = [SELECT ID, Name, ASI_MFM_Plan_Amount__c FROM ASI_MFM_Plan__c
                                                WHERE recordtypeid = : headerRecordTypeId
                                                AND ASI_MFM_Fiscal_year__c = : fiscalyear
                                                AND ASI_MFM_Plan_Type__c = : 'CAPEX'];
                                                
            Decimal totalAmountVAR1 = 0;
            for (ASI_MFM_Plan__c plan : planList)
            {
                totalAmountVAR1 += plan.ASI_MFM_Plan_Amount__c;
            }
            
            Decimal totalBudgetAmount = 0;
            String filterByType = '';
            Set<String> typeSet = new Set<String>();
            for(ASI_MFM_Budget__c budget : budgetList)
                typeSet.add(budget.ASI_MFM_Type__c);
            
            if(typeSet.contains('Original Budget'))
                filterByType = 'Original Budget';
                
            if(typeSet.contains('LE1'))
                filterByType = 'LE1';
                
            if(typeSet.contains('LE2'))
                filterByType = 'LE2';
                
            if(typeSet.contains('LE3'))
                filterByType = 'LE3';
                
            if (typeSet.contains('LE4'))
                filterByType = 'LE4';
                
                
            for (ASI_MFM_Budget__c budget : budgetList)
            {
                System.debug('IN FOR OF BUDGET LIST!');
                if(budget.ASI_MFM_Type__c == filterByType)
                {
                    System.debug('IN IF OF FILTER TYPE!');
                    totalBudgetAmount += budget.ASI_MFM_Total_Amount__c;
                }
            }
            System.debug('------ totalAmountVAR1 ------ : ' + totalAmountVAR1);
            System.debug('------ totalBudgetAmount ------ : ' + totalBudgetAmount);
            System.debug('------ isWithinBudget ------ : ' + isWithinBudget);
            if (totalAmountVAR1 > totalBudgetAmount)
                isWithinBudget = false;
            else
                isWithinBudget = true;
            System.debug('------ isWithinBudget ------ : ' + isWithinBudget);
        }
        
}