public with sharing class ASI_TH_CRM_VisitationPlanEditController {
        public static final String VISIT_DAY_DELIM = ', ';
        public static final String POINT_KEY_TOTAL = 'total';
        public static final String POINT_KEY_JDE = 'jde';
        public static final String POINT_KEY_CASH = 'cash';
        public static final String POINT_KEY_POTENTIAL = 'potential';
        public static final String POINT_KEY_POTENTIAL_PRESTIGE = 'potential_prestige';
        
        public static final String ASI_TH_CRM_VISITATIONPLAN_RECORDTYPE = 'ASI_TH_CRM_Visitation_Plan';
        public static final String ASI_TH_CRM_OUTLET_RECORDTYPE = 'ASI_TH_CRM_Outlet';
        public static final String ASI_TH_CRM_POTENTIALOUTLET_RECORDTYPE = 'ASI_TH_CRM_Potential_Outlet';
        public static final String ASI_TH_CRM_WHOLESALER_RECORDTYPE = 'ASI_TH_CRM_Wholesaler';
        
        private static final List<String> POINT_KEY_LIST = new List<String> {
            /*POINT_KEY_JDE
            , POINT_KEY_CASH
            , POINT_KEY_POTENTIAL
            , POINT_KEY_POTENTIAL_PRESTIGE*/
            ASI_TH_CRM_OUTLET_RECORDTYPE , ASI_TH_CRM_POTENTIALOUTLET_RECORDTYPE, ASI_TH_CRM_WHOLESALER_RECORDTYPE
        };
        private static final String RT_DEVNAME_JDE = ASI_HK_CRM_AccountGenerator.RT_JDE_CREDIT;
        private static final String RT_DEVNAME_CASH = ASI_HK_CRM_AccountGenerator.RT_CASH;
        private static final String RT_DEVNAME_POTENTIAL = ASI_HK_CRM_AccountGenerator.RT_POTENTIAL;
        private static final String RT_DEVNAME_POTENTIAL_PRESTIGE = ASI_HK_CRM_AccountGenerator.RT_POTENTIAL_PRESTIGE;
        private static final Set<String> RT_DEVNAME_SET = ASI_HK_CRM_AccountGenerator.RTDEVNAME_ALL;
        private static final Integer DEF_WORTH_POINT = 1;

        // Variables used in VF page
        public List<ASI_HK_CRM_VisitationPlanEditRow> visitTableRows { get; set; }
        public Map<String, ASI_HK_CRM_VisitationPlanPoint> keyToVisitPointMap { get; set; }
        public Map<Date, Integer> dateToVisitCountMap { get; set; }
        public final Date visitPlanBeginDate { get; private set; }
        public final Date visitPlanEndDate { get; private set; }
        public final ID visitPlanId { get; private set; }
        public String ptKeyTotal { get { return POINT_KEY_TOTAL; } private set; }
        public String ptKeyJDE { get { return POINT_KEY_JDE; } private set; }
        public String ptKeyCash { get { return POINT_KEY_CASH; } private set; }
        public String ptKeyPotential { get { return POINT_KEY_POTENTIAL; } private set; }
        public String ptKeyPotentialPrestige { get { return POINT_KEY_POTENTIAL_PRESTIGE; } private set; }
        public List<String> ptKeyList { get { return POINT_KEY_LIST; } private set; }
        public String visitDayDelim { get {return VISIT_DAY_DELIM;} private set; }
        public String isLocked { get; set; }
        public Boolean hasError { get; set; }

        private final ApexPages.StandardSetController stdSetController;
        private final ASI_HK_CRM_Visitation_Plan__c visitPlanHeader;
        private final List<ASI_HK_CRM_Visitation_Plan_Detail__c> visitDetailList;
        private final ASI_HK_CRM_VisitationPlanDetailGenerator visitDetailGen;
        private final Map<String, Integer> gradeToRequiredPointMap;
        private Integer theYearInt;
        
        private List<Account> accounts;
        private String sortDirection = 'ASC';
        private String sortExp = 'ASI_HK_CRM_Grade__c';
        
        public String searchAccountName { get; set; }            
        
        public String sortExpression {
            get{ return sortExp;}
            set{
                if (value == sortExp)
                    sortDirection = (sortDirection == 'ASC')? 'DESC' : 'ASC';
                else
                    sortDirection = 'ASC';
                sortExp = value;
            }
        }
        
        public ASI_TH_CRM_VisitationPlanEditController(ApexPages.StandardSetController stdSetController) {
            this.hasError = false;
            this.stdSetController = stdSetcontroller;
            // Get the visitation information
            
            String parentId = null;                

            parentId = ApexPages.currentPage().getParameters().get('id');
            if (parentId == null) {
                this.hasError = true;
                showPageError(String.format('URL paramether is missing: {0}', new String[] {'id'}));
                return;
            }                
            
            this.visitDetailList = [SELECT Id, Name, ASI_HK_CRM_Visitation_Plan__c, ASI_HK_CRM_Account__c, 
            ASI_HK_CRM_Visit_Date__c FROM ASI_HK_CRM_Visitation_Plan_Detail__c 
            WHERE ASI_HK_CRM_Visitation_Plan__c = :parentId 
            AND ASI_HK_CRM_Visitation_Plan__r.recordtype.DeveloperName  = :ASI_TH_CRM_VISITATIONPLAN_RECORDTYPE ];
           
            this.visitPlanHeader = [SELECT Id, Name, ASI_HK_CRM_Year__c, ASI_HK_CRM_Month__c, ASI_HK_CRM_Confirmed__c, 
                OwnerId FROM ASI_HK_CRM_Visitation_Plan__c 
                WHERE Id = :parentId AND recordtype.DeveloperName = :ASI_TH_CRM_VISITATIONPLAN_RECORDTYPE ];
            this.visitPlanId = this.visitPlanHeader.Id;
            
            // Initialize data for display
            this.visitTableRows = new List<ASI_HK_CRM_VisitationPlanEditRow>();
            this.keyToVisitPointMap = new Map<String, ASI_HK_CRM_VisitationPlanPoint>();
            this.dateToVisitCountMap = new Map<Date, Integer>();
            
            // Initialize the settings
            Integer vpMonth = getVPMonthFromPicklistValue(visitPlanHeader.ASI_HK_CRM_Month__c);
            if (vpMonth == 0) {
                this.hasError = true;
                showPageError(String.format('Unknown Month of {0}: {1}', new String[] {Schema.SObjectType.ASI_HK_CRM_Visitation_Plan__c.getLabel(), visitPlanHeader.ASI_HK_CRM_Month__c}));
                return;
            }
            try {
                system.debug(UserInfo.getLocale());
                ///* [SH] 2019-01-11
                if(UserInfo.getLocale() == 'th_TH')
                    this.theYearInt = Integer.valueOf(visitPlanHeader.ASI_HK_CRM_Year__c) +543;
                else
        		//*/
                    this.theYearInt = Integer.valueOf(visitPlanHeader.ASI_HK_CRM_Year__c);
            } catch (TypeException te) {
                this.hasError = true;
                showPageError(String.format('Unknown Year: {0}', new String[] {Schema.SObjectType.ASI_HK_CRM_Visitation_Plan__c.getLabel(), visitPlanHeader.ASI_HK_CRM_Month__c}));
                return;
            }
            this.visitPlanBeginDate = Date.newInstance(theYearInt, vpMonth, 1);
            system.debug(this.visitPlanBeginDate);
            this.visitPlanEndDate = Date.newInstance(theYearInt, vpMonth, Date.daysInMonth(theYearInt, vpMonth));
            this.isLocked = this.visitPlanHeader.ASI_HK_CRM_Confirmed__c == true ? 'true' : 'false';
            this.gradeToRequiredPointMap = initGradeToVisitCountMap();
            
            this.visitDetailGen = new ASI_HK_CRM_VisitationPlanDetailGenerator();        
        }
        
        public String getSortDirection()
        {
            if (sortExpression == null || sortExpression == '')
                return 'ASC';
            else
                return sortDirection;
        }
        
        public void setSortDirection(String value)
        {  
            sortDirection = value;
        }
        
        public void ResetNameSearch(){
            searchAccountName='';
            NameSearch(); 
        }
        
        public void NameSearch(){
            sortDirection = 'ASC';
            sortExp = 'ASI_HK_CRM_Grade__c,name';  
            ViewData();     
            sortExp = 'ASI_HK_CRM_Grade__c'; 
        }
        
        public PageReference ViewData() {
            string sortFullExp = sortExpression  + ' ' + sortDirection;
            if(!sortFullExp.contains('name'))
                sortFullExp +=',name'; 
                
            this.visitTableRows.clear();
            String parentId = ApexPages.currentPage().getParameters().get('id');
            
            List<ASI_HK_CRM_Visitation_Plan_Detail__c> visitDetailList2 = 
            [SELECT Id, Name, ASI_HK_CRM_Visitation_Plan__c, ASI_HK_CRM_Account__c, ASI_HK_CRM_Visit_Date__c 
            FROM ASI_HK_CRM_Visitation_Plan_Detail__c 
            WHERE ASI_HK_CRM_Visitation_Plan__c = :parentId 
            AND ASI_HK_CRM_Visitation_Plan__r.recordtype.DeveloperName = :ASI_TH_CRM_VISITATIONPLAN_RECORDTYPE ];
            
            Map<ID, List<Integer>> acctIdToVisitDaysMap = new Map<ID, List<Integer>>();
            this.dateToVisitCountMap = new Map<Date, Integer>();
            for (ASI_HK_CRM_Visitation_Plan_Detail__c vd : visitDetailList2) {
                // List of visitation date of the account
                List<Integer> visitDays = acctIdToVisitDaysMap.get(vd.ASI_HK_CRM_Account__c);
                if (visitDays == null) {
                    visitDays = new List<Integer>();
                    acctIdToVisitDaysMap.put(vd.ASI_HK_CRM_Account__c, visitDays);
                }
                if(vd.ASI_HK_CRM_Visit_Date__c != null)
                    visitDays.add(vd.ASI_HK_CRM_Visit_Date__c.day());
                // Update the numbers of visitation of each date
                Integer visitCount = dateToVisitCountMap.get(vd.ASI_HK_CRM_Visit_Date__c);
                if (visitCount == null) {
                    visitCount = 0;
                }
                dateToVisitCountMap.put(vd.ASI_HK_CRM_Visit_Date__c, visitCount + 1);
            }
            
            ID headerOwnerId = this.visitPlanHeader.OwnerId;
            System.Debug('Debug headerOwnerId  :' + headerOwnerId );        
            
            List<Account> targetSObjList=Database.query('SELECT Id, Name, RecordTypeId, RecordType.Name, RecordType.DeveloperName, ' +
            'ASI_HK_CRM_Grade__c,ASI_HK_CRM_Territory__c, ASI_HK_CRM_Address__c,  ' +
            '(Select ASI_TH_CRM_OutletType__c, ASI_TH_CRM_OutletSubType__c, ASI_TH_CRM_OutletImage__c, ASI_TH_CRM_LeadBrand__c  From ASI_CRM_Accounts_Additional_Fields__r Limit 1)' +
            'FROM Account WHERE ASI_HK_CRM_Inactive__c = false ' +
            'AND OwnerId = :headerOwnerId '+(searchAccountName.equals('')?'':' and name like \'%'+searchAccountName+'%\' ') +
            'AND (RecordType.DeveloperName = \'' + ASI_TH_CRM_OUTLET_RECORDTYPE + '\' ' +
            'OR RecordType.DeveloperName = \'' + ASI_TH_CRM_POTENTIALOUTLET_RECORDTYPE + '\' ' +
            'OR RecordType.DeveloperName = \'' + ASI_TH_CRM_WHOLESALER_RECORDTYPE + '\') ' +
            'ORDER BY '+sortFullExp);

            for (Account targetSObj: targetSObjList) {
                Integer requiredPoint = targetSObj.ASI_HK_CRM_Grade__c == null ? 0 : this.gradeToRequiredPointMap.get(targetSObj.ASI_HK_CRM_Grade__c);
                if (requiredPoint == null) {
                    this.hasError = true;
                    showPageError(String.format('Invalid Grade: {1}. Please update Custom Setting {0}', new String[] {'ASI_HK_CRM_AcctGradeVisitCountMapping__c', targetSObj.ASI_HK_CRM_Grade__c}));
                    return null;
                }
                //this.visitTableRows.add(new ASI_HK_CRM_VisitationPlanEditRow(targetSObj, getCustomTypeByRTDevName(targetSObj.RecordType.DeveloperName), DEF_WORTH_POINT, requiredPoint, acctIdToVisitDaysMap.get(targetSObj.Id)));
                
                System.Debug('targetSObj.id:' + targetSObj.id); 
                System.Debug('targetSObj:' + targetSObj.Name);
                System.Debug('targetSObj.ASI_CRM_Accounts_Additional_Fields__r:' + targetSObj.ASI_CRM_Accounts_Additional_Fields__r.size());
                System.Debug('targetSObj.RecordType.DeveloperName:' + targetSObj.RecordType.DeveloperName);
                System.Debug('DEF_WORTH_POINT:' + DEF_WORTH_POINT);
                System.Debug('requiredPoint:' + requiredPoint);
                System.Debug('acctIdToVisitDaysMap.get(targetSObj.Id):' + acctIdToVisitDaysMap.get(targetSObj.Id));
                
                List<ASI_CRM_AccountsAdditionalField__c> additionalFieldList = targetSObj.ASI_CRM_Accounts_Additional_Fields__r;
                //if(acctIdToVisitDaysMap.get(targetSObj.Id) != null)
                    this.visitTableRows.add(new ASI_HK_CRM_VisitationPlanEditRow(targetSObj, (additionalFieldList.size()==0)? null : additionalFieldList[0],
                targetSObj.RecordType.DeveloperName, DEF_WORTH_POINT, requiredPoint, acctIdToVisitDaysMap.get(targetSObj.Id)));
            }
            
            for (Date tempDate = this.visitPlanBeginDate; tempDate <= this.visitPlanEndDate; tempDate = tempDate.addDays(1)) {
                Integer visitCount = dateToVisitCountMap.get(tempDate);
                if (visitCount == null)
                    dateToVisitCountMap.put(tempDate, 0);
            }
            // Calculate the overall points
            initOverallPoints();

            return null;
        }
            
        public PageReference initPage() {
            if (hasError) return null;
            // Summarize the visitation details by Account
            Map<ID, List<Integer>> acctIdToVisitDaysMap = new Map<ID, List<Integer>>();
            this.dateToVisitCountMap = new Map<Date, Integer>();
            for (ASI_HK_CRM_Visitation_Plan_Detail__c vd : visitDetailList) {
                // List of visitation date of the account
                List<Integer> visitDays = acctIdToVisitDaysMap.get(vd.ASI_HK_CRM_Account__c);
                if (visitDays == null) {
                    visitDays = new List<Integer>();
                    acctIdToVisitDaysMap.put(vd.ASI_HK_CRM_Account__c, visitDays);
                }
                if(vd.ASI_HK_CRM_Visit_Date__c != null)
                    visitDays.add(vd.ASI_HK_CRM_Visit_Date__c.day());
                // Update the numbers of visitation of each date
                Integer visitCount = dateToVisitCountMap.get(vd.ASI_HK_CRM_Visit_Date__c);
                if (visitCount == null) {
                    visitCount = 0;
                }
                dateToVisitCountMap.put(vd.ASI_HK_CRM_Visit_Date__c, visitCount + 1);
            }
            // Create table row info for each Account
            ID headerOwnerId = this.visitPlanHeader.OwnerId;
            for (List<Account> targetSObjList : [SELECT Id, Name, RecordTypeId, RecordType.Name, RecordType.DeveloperName, 
            ASI_HK_CRM_Grade__c,ASI_HK_CRM_Territory__c, ASI_HK_CRM_Address__c,
            (Select ASI_TH_CRM_OutletType__c, ASI_TH_CRM_OutletSubType__c, ASI_TH_CRM_OutletImage__c, ASI_TH_CRM_LeadBrand__c, ASI_CRM_Action_Grade__c, ASI_CRM_Prioritization_Type__c, ASI_CRM_Sales_Call_Target__c From ASI_CRM_Accounts_Additional_Fields__r Limit 1) 
            FROM Account WHERE ASI_HK_CRM_Inactive__c = false  
            AND OwnerId = :headerOwnerId 
            AND (RecordType.DeveloperName = :ASI_TH_CRM_OUTLET_RECORDTYPE OR RecordType.DeveloperName = :ASI_TH_CRM_POTENTIALOUTLET_RECORDTYPE OR RecordType.DeveloperName = :ASI_TH_CRM_WHOLESALER_RECORDTYPE)
            ORDER BY ASI_HK_CRM_Grade__c,Name]) {
                for (Account targetSObj: targetSObjList) {
                    Integer requiredPoint = targetSObj.ASI_HK_CRM_Grade__c == null ? 0 : this.gradeToRequiredPointMap.get(targetSObj.ASI_HK_CRM_Grade__c);
                    if (requiredPoint == null) {
                        this.hasError = true;
                        showPageError(String.format('Invalid Grade: {1}. Please update Custom Setting {0}', new String[] {'ASI_HK_CRM_AcctGradeVisitCountMapping__c', targetSObj.ASI_HK_CRM_Grade__c}));
                        return null;
                    }        
                    List<ASI_CRM_AccountsAdditionalField__c> additionalFieldList = targetSObj.ASI_CRM_Accounts_Additional_Fields__r;      
                    System.Debug('additionalField.size():' + additionalFieldList.size());                  
                    
                    this.visitTableRows.add(new ASI_HK_CRM_VisitationPlanEditRow(targetSObj, (additionalFieldList.size()==0)? null : additionalFieldList[0],
                    targetSObj.RecordType.DeveloperName, DEF_WORTH_POINT, requiredPoint, acctIdToVisitDaysMap.get(targetSObj.Id)));
                }
            }
            // Fill in zero visitation count for missing date
            for (Date tempDate = this.visitPlanBeginDate; tempDate <= this.visitPlanEndDate; tempDate = tempDate.addDays(1)) {
                Integer visitCount = dateToVisitCountMap.get(tempDate);
                if (visitCount == null)
                    dateToVisitCountMap.put(tempDate, 0);
            }
            // Calculate the overall points
            initOverallPoints();        
            
            return null;
        }
        
        public PageReference quickSaveChanges() {
            Boolean saveSuccess = implSaveChanges();
            PageReference redirectPage = null;
            if (saveSuccess) {
                redirectPage = Page.ASI_TH_CRM_VisitationPlanEditPage;
                redirectPage.setRedirect(true);
                redirectPage.getParameters().put('id', visitPlanHeader.Id);
            }
            return redirectPage;
        }
        public PageReference saveChanges() {
            Boolean saveSuccess = implSaveChanges();
            PageReference redirectPage = null;
            if (saveSuccess) {
                redirectPage = new PageReference('/' + visitPlanId);
                redirectPage.setRedirect(true);
            }
            return redirectPage;
        }        
        
        public Boolean implSaveChanges() {
            List<ASI_HK_CRM_Visitation_Plan_Detail__c> visitDetailList = 
            [SELECT Id, ASI_HK_CRM_Visit_Date__c, ASI_HK_CRM_Account__c 
            FROM ASI_HK_CRM_Visitation_Plan_Detail__c WHERE ASI_HK_CRM_Visitation_Plan__c = :visitPlanHeader.Id 
            ORDER BY ASI_HK_CRM_Visit_Date__c];
            Map<ID, List<ASI_HK_CRM_Visitation_Plan_Detail__c>> acctIdToVisitDetailMap = new Map<ID, List<ASI_HK_CRM_Visitation_Plan_Detail__c>>();
            for (ASI_HK_CRM_Visitation_Plan_Detail__c vDetail : visitDetailList) {
                List<ASI_HK_CRM_Visitation_Plan_Detail__c> tempVisitDetailList = acctIdToVisitDetailMap.get(vDetail.ASI_HK_CRM_Account__c);
                if (tempVisitDetailList == null) {
                    tempVisitDetailList = new List<ASI_HK_CRM_Visitation_Plan_Detail__c>();
                    acctIdToVisitDetailMap.put(vDetail.ASI_HK_CRM_Account__c, tempVisitDetailList);
                }
                tempVisitDetailList.add(vDetail);
            }
            List<ASI_HK_CRM_Visitation_Plan_Detail__c> deleteVisitDetailList = new List<ASI_HK_CRM_Visitation_Plan_Detail__c>();
            List<ASI_HK_CRM_Visitation_Plan_Detail__c> insertVisitDetailList = new List<ASI_HK_CRM_Visitation_Plan_Detail__c>();
            for (ASI_HK_CRM_VisitationPlanEditRow row : visitTableRows) {
                Account acct = row.targetSObj;
                ID acctId = row.targetSObj.Id;
                List<ASI_HK_CRM_Visitation_Plan_Detail__c> vDetailList = acctIdToVisitDetailMap.get(acctId);
                if (vDetailList == null) vDetailList = new List<ASI_HK_CRM_Visitation_Plan_Detail__c>();
                List<String> visitDayStrList = (row.visitDayStr != null && row.visitDayStr.length() > 0) ? row.visitDayStr.split(VISIT_DAY_DELIM, 0) : new List<String>();
                List<Integer> visitDayIntList = new List<Integer>();
                for (String visitDayStr : visitDayStrList) visitDayIntList.add(Integer.valueOf(visitDayStr.trim()));
                visitDayIntList.sort();
                Integer i = 0, j = 0;
                Boolean reachEndOfUserInput = false;
                Boolean reachEndOfOriginal = false;
                while (i < visitDayIntList.size() || j < vDetailList.size()) {
                    if (!reachEndOfUserInput && i >=visitDayIntList.size()) reachEndOfUserInput = true;
                    if (!reachEndOfOriginal && j >=vDetailList.size()) reachEndOfOriginal = true;
                    Integer userInputDay = 0;
                    Integer originalDay = 0;
                    if (!reachEndOfUserInput) userInputDay = visitDayIntList.get(i);
                    if (!reachEndOfOriginal && vDetailList.get(j).ASI_HK_CRM_Visit_Date__c !=NULL) originalDay = vDetailList.get(j).ASI_HK_CRM_Visit_Date__c.day();
                    if (!reachEndOfUserInput && (reachEndOfOriginal || userInputDay < originalDay)) {
                        insertVisitDetailList.add(
                            this.visitDetailGen.generateVisitationPlanDetail(
                                this.visitPlanHeader
                                , acct
                                , Date.newInstance(this.theYearInt, getVPMonthFromPicklistValue(visitPlanHeader.ASI_HK_CRM_Month__c), userInputDay)
                            )
                        );
                        i++;
                    } else if (!reachEndOfOriginal && (reachEndOfUserInput || userInputDay > originalDay)) {
                        deleteVisitDetailList.add(vDetailList.get(j));
                        j++;
                    } else {
                        i++;
                        j++;
                    }
                }
            }
            
            Boolean allSuccess = true;
            System.Savepoint sp = database.setSavepoint();
            if (allSuccess && deleteVisitDetailList.size() > 0) {
                try {
                    delete deleteVisitDetailList;
                } catch (DmlException dmle) {
                    allSuccess = false;
                    database.rollback(sp);
                }
            }
            if (allSuccess && insertVisitDetailList != null && insertVisitDetailList.size() > 0) {
                try {
                    insert insertVisitDetailList;
                } catch (DmlException dmle) {
                    allSuccess = false;
                    database.rollback(sp);
                }
            }
            
            
            return allSuccess;
        }
        
        private Integer getVPMonthFromPicklistValue(String plValue) {
            Integer result = ASI_HK_CRM_VisitationPlanGenerator.convertMonthPLValueToInteger(plValue);
            if (result == null) return 0;
            return result;
        }
        
        private void initOverallPoints() {
            List<RecordType> rtList = [SELECT Id, Name, DeveloperName FROM RecordType 
            WHERE DeveloperName IN (:ASI_TH_CRM_OUTLET_RECORDTYPE , :ASI_TH_CRM_POTENTIALOUTLET_RECORDTYPE, :ASI_TH_CRM_WHOLESALER_RECORDTYPE )];
            this.keyToVisitPointMap = new Map<String, ASI_HK_CRM_VisitationPlanPoint>();
            for (RecordType rt : rtList) {
                System.Debug('Debug rt.DeveloperName:' + rt.DeveloperName);
                this.keyToVisitPointMap.put(
                    //getCustomTypeByRTDevName(rt.DeveloperName)
                    rt.DeveloperName
                    , new ASI_HK_CRM_VisitationPlanPoint(rt.Name, 0, 0)
                );
            }
            
            Integer totalRequiredPt = 0;
            Integer totalPlannedPt = 0;
            for (ASI_HK_CRM_VisitationPlanEditRow visitRow : this.visitTableRows) {
                if (visitRow.customType == null) continue;
                ASI_HK_CRM_VisitationPlanPoint pt = keyToVisitPointMap.get(visitRow.customType);
                if (pt == null) continue;
                pt.requiredPt = pt.requiredPt + visitRow.requiredPt;
                pt.plannedPt = pt.plannedPt + visitRow.plannedPt;
                totalRequiredPt += visitRow.requiredPt;
                totalPlannedPt += visitRow.plannedPt;
            }
            keyToVisitPointMap.put(POINT_KEY_TOTAL, new ASI_HK_CRM_VisitationPlanPoint(Label.ASI_HK_CRM_VF_VISIT_TotalPoint, totalRequiredPt, totalPlannedPt));
        }
        
        private Map<String, Integer> initGradeToVisitCountMap() {
            Map<String, Integer> result = new Map<String, Integer>();
            Map<String, ASI_HK_CRM_AcctGradeVisitCountMapping__c> settingMap = ASI_HK_CRM_AcctGradeVisitCountMapping__c.getAll();
            Set<String> gradeSet = settingMap.keySet();
            for (String gradeStr : gradeSet) {
                result.put(gradeStr, settingMap.get(gradeStr).ASI_HK_CRM_No_of_Required_Visitation__c.intValue());
            }
            return result;
        }
        
        private void showPageMessage(ApexPages.Severity severity, String msg) {
            ApexPages.addMessage(new ApexPages.Message(severity, msg));
        }
        private void showPageError(String msg) {
            showPageMessage(ApexPages.Severity.ERROR, msg);
        }
            
        private String getCustomTypeByRTDevName(String rtDevName) {
            if (rtDevName == RT_DEVNAME_JDE) return POINT_KEY_JDE;
            else if (rtDevName == RT_DEVNAME_CASH) return POINT_KEY_CASH;
            else if (rtDevName == RT_DEVNAME_POTENTIAL) return POINT_KEY_POTENTIAL;
            else if (rtDevName == RT_DEVNAME_POTENTIAL_PRESTIGE) return POINT_KEY_POTENTIAL_PRESTIGE;
            return null;
        }
        
        public class ASI_HK_CRM_VisitationPlanEditRow {
            public Account targetSObj { get; set; }
            public ASI_CRM_AccountsAdditionalField__c additionalField { get; set; }
            public String customType { get; private set; }
            public Integer worthPt { get; set; }
            public Integer requiredPt { get; set; }
            public Integer plannedPt { get; private set; }
            public String visitDayStr { get; set; }
            
            public ASI_HK_CRM_VisitationPlanEditRow(Account targetSObj, ASI_CRM_AccountsAdditionalField__c additionalField, String customType, 
            Integer worthPt, Integer requiredPt, List<Integer> visitDayIntList) {
                this.targetSObj = targetSObj;
                this.additionalField = additionalField;
                this.customType = customType;
                this.worthPt = worthPt;
                this.requiredPt = requiredPt;
                this.visitDayStr = intListToSeparatedStr(visitDayIntList, VISIT_DAY_DELIM);
                this.plannedPt = calculatePlannedPoint(visitDayIntList);
            }
            
            private String intListToSeparatedStr(List<Integer> intList, String delim) {
                if (intList == null || delim == null) return '';
                intList.sort();
                return String.join(intList, delim);
            }
            
            private Integer calculatePlannedPoint(List<Integer> visitDayIntList) {
                return visitDayIntList == null ? 0 : this.worthPt * visitDayIntList.size();
            }
        }
        
        public class ASI_HK_CRM_VisitationPlanPoint {
            public String label { get; private set; }
            public Integer requiredPt { get; private set; }
            public Integer plannedPt { get; private set; }
            public Integer balancePt { get {return this.requiredPt - this.plannedPt;} private set; }
            
            public ASI_HK_CRM_VisitationPlanPoint(String label, Integer requiredPt, Integer plannedPt) {
                this.label = label;
                this.requiredPt = requiredPt;
                this.plannedPt = plannedPt;
            }
        }

    }