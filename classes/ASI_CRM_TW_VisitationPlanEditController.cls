public with sharing class ASI_CRM_TW_VisitationPlanEditController {
    public static final String VISIT_DAY_DELIM = ', ';
    public static final String POINT_KEY_TOTAL = 'total';
    public static final String POINT_KEY_JDE = 'jde';
    public static final String POINT_KEY_CASH = 'cash';
    public static final String POINT_KEY_POTENTIAL = 'potential';
    public static final String POINT_KEY_POTENTIAL_PRESTIGE = 'potential_prestige';
    
    public static final String ASI_CRM_TW_VISITATIONPLAN_RECORDTYPE = 'ASI_CRM_TW_Visitation_Plan';
    public static final String ASI_CRM_TW_OUTLET_RECORDTYPE = 'ASI_CRM_TW_Outlet';    
    public static final String ASI_CRM_TW_HOLIDAY_RECORDTYPE = 'ASI_CRM_TW_Holiday';
    
    private static final List<String> POINT_KEY_LIST = new List<String> {
        /*POINT_KEY_JDE
        , POINT_KEY_CASH
        , POINT_KEY_POTENTIAL
        , POINT_KEY_POTENTIAL_PRESTIGE*/
        ASI_CRM_TW_OUTLET_RECORDTYPE 
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
    public Map<Date, String> dateToVisitCustomerMap { get; set; }
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
    public String searchGrade { get; set; }
    public String searchCity { get; set; }
    public String searchTown { get; set; }
    public String searchOutletType { get; set; }

    Map<id, Integer> mapPromoStatusNo { get; set; } //Added by Alvin @201711228
    Map<id, List<Map<id, Integer>>> mapPromoStatusDetailsMaster { get; set; } //Added by Alvin @201711228
    Map<id, String> mapPromoName { get; set; } //Added by Alvin @201711228
    Map<id, List<String>> mapPromoStatusDetailsByAcc { get; set; } //Added by Alvin @201711228
    List<ASI_CRM_Promotion_Status__c> listPromoStatus { get; set; } //Added by Alvin @201711228
    public Map<Id, Account> mapAccount { get; set; } //Added by Alvin @201711228
    public Set<id> setAccountId { get; set; } //Added by Alvin @201711228
    
    public List<ASI_CRM_Holiday__c> LHoliday { get; set; } //Added by Twinkle 20141104   
    public String userLanguage {set; get;}
    public String visitPlanHeaderName { get; set; }
    
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
    
    public ASI_CRM_TW_VisitationPlanEditController(ApexPages.StandardSetController stdSetController) {
        this.hasError = false;
        this.stdSetController = stdSetcontroller;
        userLanguage = UserInfo.getLanguage();
        // Get the visitation information
        
        String parentId = null;                

        parentId = ApexPages.currentPage().getParameters().get('id');
        if (parentId == null) {
            this.hasError = true;
            showPageError(String.format('URL paramether is missing: {0}', new String[] {'id'}));
            return;
        }                
        
        this.visitDetailList = [SELECT Id, Name, ASI_HK_CRM_Visitation_Plan__c, ASI_HK_CRM_Account__c, ASI_HK_CRM_Account__r.Name,  
        ASI_HK_CRM_Visit_Date__c FROM ASI_HK_CRM_Visitation_Plan_Detail__c 
        WHERE ASI_HK_CRM_Visitation_Plan__c = :parentId 
        AND ASI_HK_CRM_Visit_Date__c <> null //Added by Introv@20170616 for issue fixing
        AND ASI_HK_CRM_Visitation_Plan__r.recordtype.DeveloperName  = :ASI_CRM_TW_VISITATIONPLAN_RECORDTYPE ];
       
        this.visitPlanHeader = [SELECT Id, Name, ASI_HK_CRM_Year__c, ASI_HK_CRM_Month__c, 
            OwnerId FROM ASI_HK_CRM_Visitation_Plan__c 
            WHERE Id = :parentId AND recordtype.DeveloperName = :ASI_CRM_TW_VISITATIONPLAN_RECORDTYPE ];
        this.visitPlanId = this.visitPlanHeader.Id;
        visitPlanHeaderName = this.visitPlanHeader.Name; 
        
        // Initialize data for display
        this.visitTableRows = new List<ASI_HK_CRM_VisitationPlanEditRow>();
        this.keyToVisitPointMap = new Map<String, ASI_HK_CRM_VisitationPlanPoint>();
        this.dateToVisitCustomerMap = new Map<Date, String>();

        // Initialize the settings
        Integer vpMonth = getVPMonthFromPicklistValue(visitPlanHeader.ASI_HK_CRM_Month__c);
        if (vpMonth == 0) {
            this.hasError = true;
            showPageError(String.format('Unknown Month of {0}: {1}', new String[] {Schema.SObjectType.ASI_HK_CRM_Visitation_Plan__c.getLabel(), visitPlanHeader.ASI_HK_CRM_Month__c}));
            return;
        }
        try {
            this.theYearInt = Integer.valueOf(visitPlanHeader.ASI_HK_CRM_Year__c);
        } catch (TypeException te) {
            this.hasError = true;
            showPageError(String.format('Unknown Year: {0}', new String[] {Schema.SObjectType.ASI_HK_CRM_Visitation_Plan__c.getLabel(), visitPlanHeader.ASI_HK_CRM_Month__c}));
            return;
        }
        this.visitPlanBeginDate = Date.newInstance(theYearInt, vpMonth, 1);
        this.visitPlanEndDate = Date.newInstance(theYearInt, vpMonth, Date.daysInMonth(theYearInt, vpMonth));
        this.isLocked = 'false';
        this.gradeToRequiredPointMap = initGradeToVisitCountMap();        
        this.visitDetailGen = new ASI_HK_CRM_VisitationPlanDetailGenerator();  
        
        //Added by Twinkle 20141104 - Holiday
        this.LHoliday = [SELECT Id, Name, ASI_CRM_Date_From__c, ASI_CRM_Date_To__c, ASI_CRM_Holiday_Type__c 
                        FROM ASI_CRM_Holiday__c 
                        Where RECORDtype.DeveloperName = :ASI_CRM_TW_HOLIDAY_RECORDTYPE];
        //End - Twinkle 20141104
        //Added by Twinkle 20150112 - Holiday
        for(ASI_CRM_Holiday__c obj : LHoliday){
            if(obj.ASI_CRM_Date_From__c.MONTH()!=visitPlanBeginDate.MONTH() && obj.ASI_CRM_Date_To__c.MONTH()==visitPlanBeginDate.MONTH()){                
                obj.ASI_CRM_Date_From__c = Date.newInstance(obj.ASI_CRM_Date_To__c.YEAR(),obj.ASI_CRM_Date_To__c.MONTH(),1);               
            }
            else if(obj.ASI_CRM_Date_From__c.MONTH()==visitPlanBeginDate.MONTH() && obj.ASI_CRM_Date_To__c.MONTH()!=visitPlanBeginDate.MONTH()){
                Integer numberOfDays = Date.daysInMonth(visitPlanBeginDate.YEAR(), visitPlanBeginDate.MONTH());
                obj.ASI_CRM_Date_To__c = Date.newInstance(obj.ASI_CRM_Date_From__c.YEAR(),obj.ASI_CRM_Date_From__c.MONTH(),numberOfDays);
            }
            else if(obj.ASI_CRM_Date_From__c.MONTH()<visitPlanBeginDate.MONTH() && obj.ASI_CRM_Date_To__c.MONTH()>visitPlanBeginDate.MONTH()){               
                Integer numberOfDays = Date.daysInMonth(visitPlanBeginDate.YEAR(), visitPlanBeginDate.MONTH());
                obj.ASI_CRM_Date_From__c = Date.newInstance(visitPlanBeginDate.YEAR(),visitPlanBeginDate.MONTH(),1);
                obj.ASI_CRM_Date_To__c = Date.newInstance(visitPlanBeginDate.YEAR(),visitPlanBeginDate.MONTH(),numberOfDays);
            }
        }   
        //End - Twinkle 20150112        
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
        searchGrade='';
        searchCity='';
        searchTown='';
        searchOutletType='';
        
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
        [SELECT Id, Name, ASI_HK_CRM_Visitation_Plan__c, ASI_HK_CRM_Account__c, ASI_HK_CRM_Account__r.Name, ASI_HK_CRM_Visit_Date__c 
        FROM ASI_HK_CRM_Visitation_Plan_Detail__c 
        WHERE ASI_HK_CRM_Visitation_Plan__c = :parentId 
        AND ASI_HK_CRM_Visit_Date__c <> null //Added by Introv@20170616 for issue fixing
        AND ASI_HK_CRM_Visitation_Plan__r.recordtype.DeveloperName = :ASI_CRM_TW_VISITATIONPLAN_RECORDTYPE ];

        Map<ID, List<Integer>> acctIdToVisitDaysMap = new Map<ID, List<Integer>>();
        this.dateToVisitCustomerMap = new Map<Date, String>();
        
        for (ASI_HK_CRM_Visitation_Plan_Detail__c vd : visitDetailList2) {
            // List of visitation date of the account
            List<Integer> visitDays = acctIdToVisitDaysMap.get(vd.ASI_HK_CRM_Account__c);
            if (visitDays == null) {
                visitDays = new List<Integer>();
                acctIdToVisitDaysMap.put(vd.ASI_HK_CRM_Account__c, visitDays);
            }
            if (vd.ASI_HK_CRM_Visit_Date__c != null)
                visitDays.add(vd.ASI_HK_CRM_Visit_Date__c.day());

            // Update the customers of visitation of each date
            String customerList = dateToVisitCustomerMap.get(vd.ASI_HK_CRM_Visit_Date__c);
            if (customerList == null || customerList == '') {
                customerList = vd.ASI_HK_CRM_Account__c + ',' + vd.ASI_HK_CRM_Account__r.Name;
            }
            else {
                customerList = customerList + ','+ vd.ASI_HK_CRM_Account__c + ',' + vd.ASI_HK_CRM_Account__r.Name;
            }
            
            dateToVisitCustomerMap.put(vd.ASI_HK_CRM_Visit_Date__c, customerList);
        }

        ID headerOwnerId = this.visitPlanHeader.OwnerId;
        System.Debug('Debug headerOwnerId  :' + headerOwnerId );        
        
        // Remove --> ASI_HK_CRM_Status__c=\'Active\' and ASI_HK_CRM_IsDeliveryAccount__c = true  AND '
        List<Account> targetSObjList=Database.query('SELECT Id, Name, RecordTypeId, RecordType.Name, RecordType.DeveloperName, ' +
        'ASI_HK_CRM_Grade__c,ASI_HK_CRM_Territory__c, ASI_HK_CRM_Address__c, ASI_KOR_Grade__c, ' +
        '(Select  ASI_CRM_Channel__c, ASI_TH_CRM_OutletType__c, ASI_TH_CRM_OutletSubType__c, ASI_TH_CRM_OutletImage__c, ASI_TH_CRM_LeadBrand__c, ASI_CRM_City__c, ASI_CRM_Segmentation_Criteria__c, ASI_CRM_TW_No_Visit__c, ASI_CRM_TW_No_Required_Visit__c, ASI_CRM_CN_Suggested_No_of_Visit__c ' + 
        'FROM ASI_CRM_Accounts_Additional_Fields__r Limit 1) ' +
        'FROM Account WHERE ASI_HK_CRM_Inactive__c = false ' +
        'AND OwnerId = :headerOwnerId ' + 
        (searchAccountName.equals('')?'':' and name like \'%'+searchAccountName+'%\' ') +
        (searchGrade.equals('')?'':' and ASI_KOR_Grade__c like \'%'+searchGrade+'%\' ') +
        'AND RecordType.DeveloperName = \'' + ASI_CRM_TW_OUTLET_RECORDTYPE + '\' ' +
        'AND id In (SELECT ASI_CRM_Account__c FROM ASI_CRM_AccountsAdditionalField__c ' +
        'WHERE ASI_CRM_AccountsAdditionalField__c.ASI_CRM_City__c like \'%' + searchCity + '%\' ' +
        'AND ASI_CRM_AccountsAdditionalField__c.ASI_CRM_TW_No_Visit__c  = false ' + 
        'AND ASI_CRM_AccountsAdditionalField__c.ASI_CRM_Town__c like \'%' + searchTown + '%\' ' +
        'AND ASI_CRM_AccountsAdditionalField__c.ASI_TH_CRM_OutletType__r.Name like \'%' + searchOutletType + '%\' ) ' +
        'ORDER BY '+sortFullExp + ' limit 500');
        
        system.debug(targetSObjList);

        Set<Id> segmentationIds = new Set<Id>();
        for (Account targetSObj: targetSObjList) {
            List<ASI_CRM_AccountsAdditionalField__c> additionalFieldList = targetSObj.ASI_CRM_Accounts_Additional_Fields__r; 
            if (additionalFieldList.size() > 0) segmentationIds.add(additionalFieldList[0].ASI_CRM_Segmentation_Criteria__c );
        }
        
        Map<id, ASI_CRM_SegmentationCriteria__c> segmentationCriteriaMap = new Map<id, ASI_CRM_SegmentationCriteria__c>([SELECT id, ASI_CRM_CallFrequency__c FROM ASI_CRM_SegmentationCriteria__c WHERE id in :segmentationIds]);

        for (Account targetSObj: targetSObjList) {
            System.Debug('targetSObj.id:' + targetSObj.id); 
            System.Debug('targetSObj:' + targetSObj.Name);
            System.Debug('targetSObj.ASI_CRM_Accounts_Additional_Fields__r:' + targetSObj.ASI_CRM_Accounts_Additional_Fields__r.size());
            System.Debug('targetSObj.RecordType.DeveloperName:' + targetSObj.RecordType.DeveloperName);
            System.Debug('DEF_WORTH_POINT:' + DEF_WORTH_POINT);
            System.Debug('acctIdToVisitDaysMap.get(targetSObj.Id):' + acctIdToVisitDaysMap.get(targetSObj.Id));
            
            Integer requiredPoint = 0;
            Integer suggestedPoint = 0;
            
            if (targetSObj.ASI_CRM_Accounts_Additional_Fields__r.size() > 0){
                ASI_CRM_SegmentationCriteria__c segmentationCriteria = (ASI_CRM_SegmentationCriteria__c)segmentationCriteriaMap.get(targetSObj.ASI_CRM_Accounts_Additional_Fields__r[0].ASI_CRM_Segmentation_Criteria__c);
                if (segmentationCriteria  != null && segmentationCriteria.ASI_CRM_CallFrequency__c != null)
                    requiredPoint = segmentationCriteria.ASI_CRM_CallFrequency__c.intValue() ;
                suggestedPoint = targetSObj.ASI_CRM_Accounts_Additional_Fields__r[0].ASI_CRM_CN_Suggested_No_of_Visit__c == null? 0:targetSObj.ASI_CRM_Accounts_Additional_Fields__r[0].ASI_CRM_CN_Suggested_No_of_Visit__c.intValue();
            }
            
            this.visitTableRows.add(new ASI_HK_CRM_VisitationPlanEditRow(targetSObj, targetSObj.ASI_CRM_Accounts_Additional_Fields__r,
            targetSObj.RecordType.DeveloperName, DEF_WORTH_POINT, requiredPoint, acctIdToVisitDaysMap.get(targetSObj.Id),targetSObj.ASI_CRM_Accounts_Additional_Fields__r[0].ASI_CRM_TW_No_Required_Visit__c, suggestedPoint,
                                                                        mapPromoStatusNo.get(targetSObj.Id), mapPromoStatusDetailsByAcc.get(targetSObj.id)));
        }
        
        for (Date tempDate = this.visitPlanBeginDate; tempDate <= this.visitPlanEndDate; tempDate = tempDate.addDays(1)) {
            String customerList = dateToVisitCustomerMap.get(tempDate);
            if (customerList == null || customerList == '')
	            dateToVisitCustomerMap.put(tempDate, '');
        }
        // Calculate the overall points
        initOverallPoints();

        return null;
    }
        
    public PageReference initPage() {
        if (hasError) return null;
        // Summarize the visitation details by Account
        Map<ID, List<Integer>> acctIdToVisitDaysMap = new Map<ID, List<Integer>>();
        this.dateToVisitCustomerMap = new Map<Date, String>();

        for (ASI_HK_CRM_Visitation_Plan_Detail__c vd : visitDetailList) {
            // List of visitation date of the account
            List<Integer> visitDays = acctIdToVisitDaysMap.get(vd.ASI_HK_CRM_Account__c);
            if (visitDays == null) {
                visitDays = new List<Integer>();
                acctIdToVisitDaysMap.put(vd.ASI_HK_CRM_Account__c, visitDays);
            }
            if(vd.ASI_HK_CRM_Visit_Date__c != null)
                visitDays.add(vd.ASI_HK_CRM_Visit_Date__c.day());

            String customerList = dateToVisitCustomerMap.get(vd.ASI_HK_CRM_Visit_Date__c);
            if (customerList == null || customerList == '') {
                customerList = vd.ASI_HK_CRM_Account__c + ',' + vd.ASI_HK_CRM_Account__r.Name;
            }
            else {
                customerList = customerList + ','+ vd.ASI_HK_CRM_Account__c + ',' + vd.ASI_HK_CRM_Account__r.Name;
            }
            
            dateToVisitCustomerMap.put(vd.ASI_HK_CRM_Visit_Date__c, customerList);
        }
        
        // Create table row info for each Account
        ID headerOwnerId = this.visitPlanHeader.OwnerId;
        
        //Added by Introv Alvin 20171228
        listPromoStatus = [SELECT id, ASI_CRM_Promotion__r.ASI_HK_CRM_Promotion_Name__c, ASI_CRM_Account__c, ASI_CRM_Promotion__c
                           FROM ASI_CRM_Promotion_Status__c 
                           WHERE RecordType.DeveloperName = 'ASI_CRM_TW_PromotionStatus' AND ASI_CRM_Done__c = FALSE AND OwnerId = :headerOwnerId];
        setAccountId = new Set<id>();
        mapPromoStatusNo = new Map<id, Integer>();
        mapPromoStatusDetailsMaster = new Map<id, List<Map<id, Integer>>>();
        mapPromoName = new Map<id, String>();
        
        for (ASI_CRM_Promotion_Status__c mPromoStatus:listPromoStatus) {
            setAccountId.add(mPromoStatus.ASI_CRM_Account__c);
            
            //count no. of ps for each Outlet
            if (mPromoStatus.ASI_CRM_Account__c != null && mapPromoStatusNo.get(mPromoStatus.ASI_CRM_Account__c) != null) {
                mapPromoStatusNo.put(mPromoStatus.ASI_CRM_Account__c, mapPromoStatusNo.get(mPromoStatus.ASI_CRM_Account__c) + 1);
            }
            else {
                mapPromoStatusNo.put(mPromoStatus.ASI_CRM_Account__c, 1);
            }

            if (mPromoStatus.ASI_CRM_Promotion__c != NULL) {
                mapPromoName.put(mPromoStatus.ASI_CRM_Promotion__c, mPromoStatus.ASI_CRM_Promotion__r.ASI_HK_CRM_Promotion_Name__c);
            }
            
            Map<id, Integer> taskNoPromotion = new Map<id, Integer>();
            if (mPromoStatus.ASI_CRM_Account__c != NULL && mPromoStatus.ASI_CRM_Promotion__c != NULL) {
                if (mapPromoStatusDetailsMaster.get(mPromoStatus.ASI_CRM_Account__c) != NULL) {
                    Boolean boolPromoInList = false;
                    
                    List<Map<Id, Integer>> existTaskList = mapPromoStatusDetailsMaster.get(mPromoStatus.ASI_CRM_Account__c);
                    
                    for (Map<Id, Integer> task : existTaskList) {
                        for (Id key : task.KeySet()) {
                            if (key == mPromoStatus.ASI_CRM_Promotion__c) {
                                Integer count = task.get(key);
                                
                                if (count == null) {
                                    count = 0;
                                }
                                
                                task.put(key, count + 1);
                                boolPromoInList = true;
                                break;
                            }
                        }
                    }
                    
                    if (!boolPromoInList) {
                        Map<Id, Integer> newMap = new Map<Id, Integer>();
                        newMap.put(mPromoStatus.ASI_CRM_Promotion__c, 1);
                        
                        List<Map<Id, Integer>> newList = new List<Map<Id, Integer>>();
                        newList = mapPromoStatusDetailsMaster.get(mPromoStatus.ASI_CRM_Account__c);
                        newList.add(newMap);
                        
                        mapPromoStatusDetailsMaster.put(mPromoStatus.ASI_CRM_Account__c, newList);
                    }
                }   
                else {
                    Map<Id, Integer> newMap = new Map<Id, Integer>();
                    newMap.put(mPromoStatus.ASI_CRM_Promotion__c, 1);
                    
                    List<Map<Id, Integer>> newList = new List<Map<Id, Integer>>();
                    newList.add(newMap);
                    
                    mapPromoStatusDetailsMaster.put(mPromoStatus.ASI_CRM_Account__c, newList);
                }
            }
            //End by Introv Alvin 20171228
        }
        
        //Added by Introv Alvin 20171228, get promotion status details
        mapPromoStatusDetailsByAcc = new Map<id, List<String>>();
        for (String accId : mapPromoStatusDetailsMaster.keySet()) {
            for (Map<id, Integer> tnp : mapPromoStatusDetailsMaster.get(accId)) {   
                for (Id key : tnp.KeySet()) {
                    List<String> details = mapPromoStatusDetailsByAcc.get(accId);
                    String promoStatusDetail = mapPromoName.get(key) + ',' + tnp.get(key);
                    
                    if (details == null) {
                        details = new List<String>();
                        details.add(promoStatusDetail);
                        mapPromoStatusDetailsByAcc.put(accId, details);
                    }
                    else {
                       details.add(promoStatusDetail);
                    }
                }
            }
        }
        //End by Introv Alvin 20171228
        
        //Remove --> ASI_HK_CRM_Status__c='Active' AND ASI_HK_CRM_IsDeliveryAccount__c = true AND 
        for (List<Account> targetSObjList : [SELECT Id, Name, RecordTypeId, RecordType.Name, RecordType.DeveloperName, 
        ASI_HK_CRM_Grade__c,ASI_HK_CRM_Territory__c, ASI_HK_CRM_Address__c,ASI_KOR_Grade__c, 
        (Select ASI_CRM_Channel__c, ASI_TH_CRM_OutletType__c, ASI_TH_CRM_OutletSubType__c, ASI_TH_CRM_OutletImage__c, ASI_TH_CRM_LeadBrand__c, ASI_CRM_Segmentation_Criteria__c, ASI_CRM_TW_No_Visit__c, ASI_CRM_TW_No_Required_Visit__c, ASI_CRM_CN_Suggested_No_of_Visit__c From ASI_CRM_Accounts_Additional_Fields__r Limit 1) 
        FROM Account WHERE ASI_HK_CRM_Inactive__c = false
        AND id In (SELECT ASI_CRM_Account__c FROM ASI_CRM_AccountsAdditionalField__c WHERE ASI_CRM_TW_No_Visit__c = false)
        AND OwnerId = :headerOwnerId 
        AND (RecordType.DeveloperName = :ASI_CRM_TW_OUTLET_RECORDTYPE)
        ORDER BY ASI_HK_CRM_Grade__c,Name limit 500]) {
            Set<Id> segmentationIds = new Set<Id>();
            for (Account targetSObj: targetSObjList) {
                List<ASI_CRM_AccountsAdditionalField__c> additionalFieldList = targetSObj.ASI_CRM_Accounts_Additional_Fields__r; 
                if (additionalFieldList.size() > 0) segmentationIds.add(additionalFieldList[0].ASI_CRM_Segmentation_Criteria__c );
            }
            
            Map<id, ASI_CRM_SegmentationCriteria__c> segmentationCriteriaMap = new Map<id, ASI_CRM_SegmentationCriteria__c>([SELECT id, ASI_CRM_CallFrequency__c FROM ASI_CRM_SegmentationCriteria__c WHERE id in :segmentationIds]);
            
            for (Account targetSObj: targetSObjList) {                
                List<ASI_CRM_AccountsAdditionalField__c> additionalFieldList = targetSObj.ASI_CRM_Accounts_Additional_Fields__r;      

                Integer requiredPoint = 0;
                Integer suggestedPoint = 0;
                
                if (additionalFieldList != null && additionalFieldList.size() > 0){
                    ASI_CRM_SegmentationCriteria__c segmentationCriteria = (ASI_CRM_SegmentationCriteria__c)segmentationCriteriaMap.get(additionalFieldList[0].ASI_CRM_Segmentation_Criteria__c);
                    if (segmentationCriteria  != null)
                        requiredPoint = (segmentationCriteria.ASI_CRM_CallFrequency__c == null)? 0 : segmentationCriteria.ASI_CRM_CallFrequency__c.intValue() ;
                    
                    suggestedPoint = additionalFieldList[0].ASI_CRM_CN_Suggested_No_of_Visit__c == null? 0:additionalFieldList[0].ASI_CRM_CN_Suggested_No_of_Visit__c.intValue();
                    
                    this.visitTableRows.add(new ASI_HK_CRM_VisitationPlanEditRow(targetSObj, (additionalFieldList.size()==0)? null : additionalFieldList[0],
                                                                                 targetSObj.RecordType.DeveloperName, DEF_WORTH_POINT, requiredPoint, acctIdToVisitDaysMap.get(targetSObj.Id),additionalFieldList[0].ASI_CRM_TW_No_Required_Visit__c, suggestedPoint,
                                                                                 mapPromoStatusNo.get(targetSObj.Id), mapPromoStatusDetailsByAcc.get(targetSObj.id)));
                } 
            }
        }
        // Fill in zero visitation count for missing date
        for (Date tempDate = this.visitPlanBeginDate; tempDate <= this.visitPlanEndDate; tempDate = tempDate.addDays(1)) {
            String customerList = dateToVisitCustomerMap.get(tempDate);
            if (customerList == null || customerList == '')
	            dateToVisitCustomerMap.put(tempDate, '');
        }
        // Calculate the overall points
        initOverallPoints();
        
        return null;
    }
    
    public PageReference quickSaveChanges() {
        Boolean saveSuccess = implSaveChanges();
        PageReference redirectPage = null;
        if (saveSuccess) {
            redirectPage = Page.ASI_CRM_TW_VisitationPlanEditPage;
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
            AND ASI_HK_CRM_Visit_Date__c <> null //Added by Introv@20170616 for issue fixing
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
            
            
            System.debug('account.Name :' + row.targetSObj.Name);
            System.debug('requiredPt :' + row.requiredPt);
            System.debug('plannedPt :' + visitDayStrList.size());
                        System.debug('visitDayStr :' + row.visitDayStr);
            
            if(row.suggestedPt != null && row.suggestedPt != 0)
            {
                if(visitDayStrList.size() >0 && visitDayStrList.size() < row.suggestedPt)
                {
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'No. of Planned visitation must be more than No. of suggested visitation for outlet \'' + row.targetSObj.Name + '\''));
                return false;
                }
            }
            else if (row.additionalField.ASI_CRM_TW_No_Required_Visit__c == false && row.requiredPt != 0.33 && visitDayStrList.size() >0 && visitDayStrList.size() < row.requiredPt) {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'No. of Planned visitation must be more than No. of required visitation for outlet \'' + row.targetSObj.Name + '\''));
                return false;
            }
            
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
        if (allSuccess && insertVisitDetailList.size() > 0) {
            try {
                insert insertVisitDetailList;
            } catch (DmlException dmle) {
                allSuccess = false;
                database.rollback(sp);
            }
        }
        
        Map<id, ASI_HK_CRM_Visitation_Plan_Detail__c> mapNewVpdAcc = NEW Map<id, ASI_HK_CRM_Visitation_Plan_Detail__c>();
        Map<id, ASI_HK_CRM_Visitation_Plan_Detail__c> mapdeletedVpdAcc = NEW Map<id, ASI_HK_CRM_Visitation_Plan_Detail__c>();
        
        if (allSuccess && listPromoStatus.size() > 0){
            for (ASI_HK_CRM_Visitation_Plan_Detail__c vpd : insertVisitDetailList) {
                mapNewVpdAcc.put(vpd.ASI_HK_CRM_Account__c, vpd);              
            }
            
            for(ASI_HK_CRM_Visitation_Plan_Detail__c vpd : deleteVisitDetailList) {
                mapdeletedVpdAcc.put(vpd.ASI_HK_CRM_Account__c, vpd);              
            }      
            
            //Added by William Yang (Introv) on 20150711
            List<ASI_CRM_Promotion_Status__c> promoStatusToUpdate = new List<ASI_CRM_Promotion_Status__c>();
            Map<id, ASI_CRM_Promotion_Status__c> mapPromoStatusToUpdate = new Map<id, ASI_CRM_Promotion_Status__c>();
            
            for (ASI_CRM_Promotion_Status__c mPromoStatus : listPromoStatus) {
                if (mPromoStatus.ASI_CRM_Account__c != NULL) {
                    if (mapdeletedVpdAcc.get(mPromoStatus.ASI_CRM_Account__c) != null)
                    {
                        //merchanTasksToUpdate.add(mPromoStatus);
                        mapPromoStatusToUpdate.put(mPromoStatus.id, mPromoStatus);
                        mPromoStatus.ASI_CRM_VisitationPlanDetail__c = null;                        
                    }
                    
                    if (mapNewVpdAcc.get(mPromoStatus.ASI_CRM_Account__c) != null)
                    {
                        //merchanTasksToUpdate.add(mPromoStatus);      
                        mapPromoStatusToUpdate.put(mPromoStatus.id, mPromoStatus);                  
                        mPromoStatus.ASI_CRM_VisitationPlanDetail__c = mapNewVpdAcc.get(mPromoStatus.ASI_CRM_Account__c).id;                        
                    }
                }    
            }
            
            try {
                //update listPromoStatus;
                promoStatusToUpdate = mapPromoStatusToUpdate.values();
                update promoStatusToUpdate;
            } catch (Exception e) {
                allSuccess = false;
                database.rollback(sp);
                //system.debug('###Dml Exception: '+dmle.getDmlMessage(0));
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Update Error'+e));
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
        WHERE DeveloperName IN (:ASI_CRM_TW_OUTLET_RECORDTYPE )];
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
        
    /*private String getCustomTypeByRTDevName(String rtDevName) {
        if (rtDevName == RT_DEVNAME_JDE) return POINT_KEY_JDE;
        else if (rtDevName == RT_DEVNAME_CASH) return POINT_KEY_CASH;
        else if (rtDevName == RT_DEVNAME_POTENTIAL) return POINT_KEY_POTENTIAL;
        else if (rtDevName == RT_DEVNAME_POTENTIAL_PRESTIGE) return POINT_KEY_POTENTIAL_PRESTIGE;
        return null;
    }*/
    
    public class ASI_HK_CRM_VisitationPlanEditRow {
        public Account targetSObj { get; set; }
        public ASI_CRM_AccountsAdditionalField__c additionalField { get; set; }
        public String customType { get; private set; }
        public Integer worthPt { get; set; }
        public Integer requiredPt { get; set; }
        public Integer plannedPt { get; set; }
        public String visitDayStr { get; set; }
        public Boolean boolNoRequireVisit { get; set; } //Added by Twinkle 20141209
        public Integer suggestedPt {get; set;}
        public Integer intPromoStatusNo { get; set; }
        public List<String> promoStatusDetails { get; set; }
        
        public ASI_HK_CRM_VisitationPlanEditRow(Account targetSObj, ASI_CRM_AccountsAdditionalField__c additionalField, String customType, 
        Integer worthPt, Integer requiredPt, List<Integer> visitDayIntList, Boolean noRequireVisit, Integer suggestedPt, Integer intPromoStatusNo, List<String> promoStatusDetails) {
            this.targetSObj = targetSObj;
            this.additionalField = additionalField;
            this.customType = customType;
            this.worthPt = worthPt;
            this.requiredPt = requiredPt;
            this.visitDayStr = intListToSeparatedStr(visitDayIntList, VISIT_DAY_DELIM);
            this.plannedPt = calculatePlannedPoint(visitDayIntList);
            this.boolNoRequireVisit = noRequireVisit;
            this.suggestedPt = suggestedPt;
            this.intPromoStatusNo = intPromoStatusNo;
            this.promoStatusDetails = promoStatusDetails;
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