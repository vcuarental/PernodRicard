/*Filename:    ASI_CRM_TW_MerchanVisitationPlan_Ctrl.cls
* Author:      Clone from ASI_CRM_TW_VisitationPlanEditController 
* Modified By: Twinkle LI (Introv Limited)
* Purpose:     Controller Class for manage Merchandiser Visitation for TW CRM
*
* -----------------------------------------------------------------------------
*/
public with sharing class ASI_CRM_TW_MerchanVisitationPlan_Ctrl{

    public ASI_CRM_TW_MerchanVisitationPlan_Ctrl(ApexPages.StandardController controller) {
    }

    public static final String VISIT_DAY_DELIM = ', ';
    public static final String POINT_KEY_TOTAL = 'total';
    public static final String POINT_KEY_JDE = 'jde';
    public static final String POINT_KEY_CASH = 'cash';
    public static final String POINT_KEY_POTENTIAL = 'potential';
    public static final String POINT_KEY_POTENTIAL_PRESTIGE = 'potential_prestige';
    
    public static final String ASI_CRM_TW_VISITATIONPLAN_RECORDTYPE = 'ASI_CRM_TW_Merchandiser_Visitation_Plan';
    public static final String ASI_CRM_TW_OUTLET_RECORDTYPE = 'ASI_CRM_TW_Outlet';
    public static final String ASI_CRM_TW_HOLIDAY_RECORDTYPE = 'ASI_CRM_TW_Holiday'; 
    
    private static final List<String> POINT_KEY_LIST = new List<String> {
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
    private Integer theYearInt;
    
    private List<Account> accounts;
    private String sortDirection = 'ASC';
    private String sortExp = 'ASI_HK_CRM_Grade__c';
    
    public String searchAccountName { get; set; }
    public String searchCity { get; set; }
    public String searchTown { get; set; }
    public String searchOutletType { get; set; }
    
    public String visitPlanHeaderName { get; set; }
    
    Map<id, Integer> mapTaskNo { get; set; }
    Map<id, List<Map<id, Integer>>> mapTaskDetailsMaster { get; set; } //Added by Twinkle @20161018
    Map<id, String> mapTaskDetailsByAcc { get; set; } //Added by Twinkle @20161018
    Map<id, String> mapPromoName { get; set; } //Added by Twinkle @20161018
    
    List<ASI_CRM_Merchandiser_Task__c> listMerchanTask { get; set; }
    public List<ASI_CRM_Holiday__c> LHoliday { get; set; }
    
    public String userLanguage { get; set; }
    public Map<Id, Account> mapAccount { get; set; }
    public Set<id> setAccountId { get; set; }
    
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
    
    public ASI_CRM_TW_MerchanVisitationPlan_Ctrl(ApexPages.StandardSetController stdSetController) {
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
        
        this.visitDetailList = [SELECT Id, Name, ASI_HK_CRM_Visitation_Plan__c, ASI_HK_CRM_Account__c, ASI_HK_CRM_Visit_Date__c 
                                FROM ASI_HK_CRM_Visitation_Plan_Detail__c 
                                WHERE ASI_HK_CRM_Visitation_Plan__c = :parentId 
                                AND ASI_HK_CRM_Visit_Date__c <> null //Added by Introv@20170731 for issue fixing
                                AND ASI_HK_CRM_Visitation_Plan__r.recordtype.DeveloperName  = :ASI_CRM_TW_VISITATIONPLAN_RECORDTYPE];
        
        this.visitPlanHeader = [SELECT Id, Name, ASI_HK_CRM_Year__c, ASI_HK_CRM_Month__c, ASI_HK_CRM_Confirmed__c, 
                                OwnerId FROM ASI_HK_CRM_Visitation_Plan__c 
                                WHERE Id = :parentId AND recordtype.DeveloperName = :ASI_CRM_TW_VISITATIONPLAN_RECORDTYPE];
        visitPlanHeaderName = this.visitPlanHeader.Name;                    
                                
        this.visitPlanId = this.visitPlanHeader.Id;
        
        // Initialize data for display
        this.visitTableRows = new List<ASI_HK_CRM_VisitationPlanEditRow>();
        this.dateToVisitCountMap = new Map<Date, Integer>();

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
        this.isLocked = this.visitPlanHeader.ASI_HK_CRM_Confirmed__c == true ? 'true' : 'false';      
        this.visitDetailGen = new ASI_HK_CRM_VisitationPlanDetailGenerator();  
        
        //Added by Twinkle 20141104 - Holiday
        this.LHoliday = [SELECT Id, Name, ASI_CRM_Date_From__c, ASI_CRM_Date_To__c, ASI_CRM_Holiday_Type__c 
                        FROM ASI_CRM_Holiday__c 
                        Where RECORDtype.DeveloperName = :ASI_CRM_TW_HOLIDAY_RECORDTYPE];
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
        [SELECT Id, Name, ASI_HK_CRM_Visitation_Plan__c, ASI_HK_CRM_Account__c, ASI_HK_CRM_Visit_Date__c 
        FROM ASI_HK_CRM_Visitation_Plan_Detail__c 
        WHERE ASI_HK_CRM_Visitation_Plan__c = :parentId 
        AND ASI_HK_CRM_Visit_Date__c <> null //Added by Introv@20170731 for issue fixing
        AND ASI_HK_CRM_Visitation_Plan__r.recordtype.DeveloperName = :ASI_CRM_TW_VISITATIONPLAN_RECORDTYPE ];

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
        
        // Remove --> ASI_HK_CRM_Status__c=\'Active\' and ASI_HK_CRM_IsDeliveryAccount__c = true  AND '
        List<Account> targetSObjList=Database.query('SELECT Id, Name, RecordTypeId, RecordType.Name, RecordType.DeveloperName, ' +
        'ASI_HK_CRM_Grade__c,ASI_HK_CRM_Territory__c, ASI_HK_CRM_Address__c, ASI_KOR_Grade__c, IsPersonAccount, ' +
        '(Select  ASI_CRM_Channel__c, ASI_TH_CRM_OutletType__c, ASI_TH_CRM_OutletSubType__c, ASI_TH_CRM_OutletImage__c, ASI_TH_CRM_LeadBrand__c, ASI_CRM_City__c, ASI_CRM_Segmentation_Criteria__c, ASI_CRM_TW_No_Visit__c, ASI_CRM_TW_No_Required_Visit__c ' + 
        'FROM ASI_CRM_Accounts_Additional_Fields__r Limit 1) ' +
        'FROM Account WHERE id IN:setAccountId AND ASI_HK_CRM_Inactive__c = false '+
        //'AND OwnerId = :headerOwnerId ' + 
        (searchAccountName.equals('')?'':' and name like \'%'+searchAccountName+'%\' ') +
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
            
            if (targetSObj.ASI_CRM_Accounts_Additional_Fields__r.size() > 0){
                ASI_CRM_SegmentationCriteria__c segmentationCriteria = (ASI_CRM_SegmentationCriteria__c)segmentationCriteriaMap.get(targetSObj.ASI_CRM_Accounts_Additional_Fields__r[0].ASI_CRM_Segmentation_Criteria__c);
                if (segmentationCriteria  != null && segmentationCriteria.ASI_CRM_CallFrequency__c != null)
                requiredPoint = segmentationCriteria.ASI_CRM_CallFrequency__c.intValue() ;
            }
            
            this.visitTableRows.add(new ASI_HK_CRM_VisitationPlanEditRow(targetSObj, targetSObj.ASI_CRM_Accounts_Additional_Fields__r,
            targetSObj.RecordType.DeveloperName, DEF_WORTH_POINT, requiredPoint, acctIdToVisitDaysMap.get(targetSObj.Id),targetSObj.ASI_CRM_Accounts_Additional_Fields__r[0].ASI_CRM_TW_No_Required_Visit__c, mapTaskNo.get(targetSObj.Id), mapTaskDetailsByAcc.get(targetSObj.id)));
        }
        
        for (Date tempDate = this.visitPlanBeginDate; tempDate <= this.visitPlanEndDate; tempDate = tempDate.addDays(1)) {
            Integer visitCount = dateToVisitCountMap.get(tempDate);
            if (visitCount == null)
                dateToVisitCountMap.put(tempDate, 0);
        }
        return null;
    }
        
    public PageReference initPage() {
        if (hasError) return null;
        // Summarize the visitation details by Account
        Map<ID, List<Integer>> acctIdToVisitDaysMap = new Map<ID, List<Integer>>();
        this.dateToVisitCountMap = new Map<Date, Integer>();
        mapAccount = new Map<Id, Account>();   

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

        //Added by Twinkle 04/29/2015
        listMerchanTask = [SELECT id, ASI_CRM_Promotion_Status__c, ASI_CRM_Promotion_Name__c, ASI_CRM_Promotion_Status__r.ASI_CRM_Account__c, ASI_CRM_Promotion_Status__r.ASI_CRM_Promotion__c FROM ASI_CRM_Merchandiser_Task__c WHERE RecordType.DeveloperName = 'ASI_CRM_TW_Merchandiser_Task' AND ASI_CRM_Done__c = FALSE AND ASI_CRM_Confirmed__c = FALSE];
        setAccountId = new Set<id>();
        mapTaskNo = new Map<id, Integer>();
        mapTaskDetailsMaster = new Map<id, List<Map<id, Integer>>>();
        mapPromoName = new Map<id, String>();
        
        for(ASI_CRM_Merchandiser_Task__c mtask:listMerchanTask){
            setAccountId.add(mtask.ASI_CRM_Promotion_Status__r.ASI_CRM_Account__c);
            
            //count no. of task for each Outlet
            if(mtask.ASI_CRM_Promotion_Status__c != null && mtask.ASI_CRM_Promotion_Status__r.ASI_CRM_Account__c != null && mapTaskNo.get(mtask.ASI_CRM_Promotion_Status__r.ASI_CRM_Account__c) != null){
                //Integer taskNo = mapTaskNo.get(mtask.ASI_CRM_Promotion_Status__r.ASI_CRM_Account__c);
                //taskNo++;
                mapTaskNo.put(mtask.ASI_CRM_Promotion_Status__r.ASI_CRM_Account__c, mapTaskNo.get(mtask.ASI_CRM_Promotion_Status__r.ASI_CRM_Account__c)+1);
            }
            else
                mapTaskNo.put(mtask.ASI_CRM_Promotion_Status__r.ASI_CRM_Account__c, 1);
                
            //Added by Introv Twinkle @20161018, get task details
            if(mtask.ASI_CRM_Promotion_Status__r.ASI_CRM_Promotion__c != NULL){
                mapPromoName.put(mtask.ASI_CRM_Promotion_Status__r.ASI_CRM_Promotion__c, mtask.ASI_CRM_Promotion_Name__c);
            }
            
            Map<id, Integer> taskNoPromotion = new Map<id, Integer>();
            if(mtask.ASI_CRM_Promotion_Status__c != NULL && 
                mtask.ASI_CRM_Promotion_Status__r.ASI_CRM_Account__c != NULL &&
                mtask.ASI_CRM_Promotion_Status__r.ASI_CRM_Promotion__c != NULL){
            
                if(mapTaskDetailsMaster.get(mtask.ASI_CRM_Promotion_Status__r.ASI_CRM_Account__c) != NULL){
                    Boolean boolPromoInList = FALSE;
                    
                    List<Map<Id, Integer>> listTempTaskDetails = mapTaskDetailsMaster.get(mtask.ASI_CRM_Promotion_Status__r.ASI_CRM_Account__c);
                    system.debug('#Task Detail for Account: '+mtask.ASI_CRM_Promotion_Status__r.ASI_CRM_Account__c+'-'+listTempTaskDetails);
                    
                    Integer index = 0;
                    for(Map<id, Integer> tnp : mapTaskDetailsMaster.get(mtask.ASI_CRM_Promotion_Status__r.ASI_CRM_Account__c)){
                        for(Id key : tnp.KeySet()){
                            if(key == mtask.ASI_CRM_Promotion_Status__r.ASI_CRM_Promotion__c){
                                Map<Id, Integer> newMap = new Map<Id, Integer>();
                                newMap.put(key, tnp.get(key)+1);
                                
                                listTempTaskDetails.remove(index);
                                listTempTaskDetails.add(newMap);
                                
                                mapTaskDetailsMaster.put(mtask.ASI_CRM_Promotion_Status__r.ASI_CRM_Account__c, listTempTaskDetails);
                                
                                boolPromoInList = TRUE;
                                break;
                            }
                        }
                        index++;
                    }
                    
                    if(!boolPromoInList){
                        Map<Id, Integer> newMap = new Map<Id, Integer>();
                        newMap.put(mtask.ASI_CRM_Promotion_Status__r.ASI_CRM_Promotion__c, 1);
                        
                        List<Map<Id, Integer>> newList = new List<Map<Id, Integer>>();
                        newList = mapTaskDetailsMaster.get(mtask.ASI_CRM_Promotion_Status__r.ASI_CRM_Account__c);
                        newList.add(newMap);
                        
                        mapTaskDetailsMaster.put(mtask.ASI_CRM_Promotion_Status__r.ASI_CRM_Account__c, newList);
                    }
                }   
                else{
                    Map<Id, Integer> newMap = new Map<Id, Integer>();
                    newMap.put(mtask.ASI_CRM_Promotion_Status__r.ASI_CRM_Promotion__c, 1);
                    
                    List<Map<Id, Integer>> newList = new List<Map<Id, Integer>>();
                    newList.add(newMap);
                    
                    mapTaskDetailsMaster.put(mtask.ASI_CRM_Promotion_Status__r.ASI_CRM_Account__c, newList);
                }
            }
            system.debug('Task Details: '+mapTaskDetailsMaster);
            //End by Introv Twinkle @20161018
            
        }
        
        //End by Twinkle 04/29/2015
        
        //Added by Introv Twinkle @20161018, get task details
        mapTaskDetailsByAcc = new Map<id, String>();
        for(String accId : mapTaskDetailsMaster.keySet()){
            for(Map<id, Integer> tnp : mapTaskDetailsMaster.get(accId)){   
                for(Id key : tnp.KeySet()){            
                    String taskDetails = mapPromoName.get(key)+','+tnp.get(key);
                    if(mapTaskDetailsByAcc != NULL && mapTaskDetailsByAcc.get(accId) != NULL){
                        mapTaskDetailsByAcc.put(accId, mapTaskDetailsByAcc.get(accId)+'<br/>'+taskDetails);
                    }
                    else
                        mapTaskDetailsByAcc.put(accId, taskDetails);
                }
            }
        }
        //End by Introv Twinkle @20161018
        
        //Remove --> ASI_HK_CRM_Status__c='Active' AND ASI_HK_CRM_IsDeliveryAccount__c = true AND 
        for (List<Account> targetSObjList : [SELECT Id, Name, RecordTypeId, RecordType.Name, RecordType.DeveloperName, 
        ASI_HK_CRM_Grade__c,ASI_HK_CRM_Territory__c, ASI_HK_CRM_Address__c,ASI_KOR_Grade__c, IsPersonAccount, 
        (Select ASI_CRM_Channel__c, ASI_TH_CRM_OutletType__c, ASI_TH_CRM_OutletSubType__c, ASI_TH_CRM_OutletImage__c, ASI_TH_CRM_LeadBrand__c, ASI_CRM_Segmentation_Criteria__c, ASI_CRM_TW_No_Visit__c, ASI_CRM_TW_No_Required_Visit__c From ASI_CRM_Accounts_Additional_Fields__r Limit 1) 
        FROM Account WHERE ASI_HK_CRM_Inactive__c = false
        AND id In: setAccountId
        AND (RecordType.DeveloperName = :ASI_CRM_TW_OUTLET_RECORDTYPE)
        ORDER BY ASI_HK_CRM_Grade__c,Name limit 500]) {
            Set<Id> segmentationIds = new Set<Id>();
            for (Account targetSObj: targetSObjList) {
                List<ASI_CRM_AccountsAdditionalField__c> additionalFieldList = targetSObj.ASI_CRM_Accounts_Additional_Fields__r; 
                if (additionalFieldList.size() > 0) 
                    segmentationIds.add(additionalFieldList[0].ASI_CRM_Segmentation_Criteria__c);
                mapAccount.put(targetSObj.id, targetSObj);             
            }
            
            Map<id, ASI_CRM_SegmentationCriteria__c> segmentationCriteriaMap = new Map<id, ASI_CRM_SegmentationCriteria__c>([SELECT id, ASI_CRM_CallFrequency__c FROM ASI_CRM_SegmentationCriteria__c WHERE id in :segmentationIds]);
            
            for (Account targetSObj: targetSObjList) {                
                List<ASI_CRM_AccountsAdditionalField__c> additionalFieldList = targetSObj.ASI_CRM_Accounts_Additional_Fields__r;      

                Integer requiredPoint = 0;
                
                if (additionalFieldList != null && additionalFieldList.size() > 0){
                    ASI_CRM_SegmentationCriteria__c segmentationCriteria = (ASI_CRM_SegmentationCriteria__c)segmentationCriteriaMap.get(additionalFieldList[0].ASI_CRM_Segmentation_Criteria__c);
                    if (segmentationCriteria  != null)
                    requiredPoint = (segmentationCriteria.ASI_CRM_CallFrequency__c == null)? 0 : segmentationCriteria.ASI_CRM_CallFrequency__c.intValue() ;
                }
                
                this.visitTableRows.add(new ASI_HK_CRM_VisitationPlanEditRow(targetSObj, (additionalFieldList.size()==0)? null : additionalFieldList[0],
                targetSObj.RecordType.DeveloperName, DEF_WORTH_POINT, requiredPoint, acctIdToVisitDaysMap.get(targetSObj.Id), (additionalFieldList.size()==0)? null : additionalFieldList[0].ASI_CRM_TW_No_Required_Visit__c, mapTaskNo.get(targetSObj.id), mapTaskDetailsByAcc.get(targetSObj.id)));
            }
        }
        // Fill in zero visitation count for missing date
        for (Date tempDate = this.visitPlanBeginDate; tempDate <= this.visitPlanEndDate; tempDate = tempDate.addDays(1)) {
            Integer visitCount = dateToVisitCountMap.get(tempDate);
            if (visitCount == null)
                dateToVisitCountMap.put(tempDate, 0);
        }       
        return null;
    }
    
    public PageReference quickSaveChanges() {
        Boolean saveSuccess = implSaveChanges();
        PageReference redirectPage = null;
        if (saveSuccess) {
            redirectPage = Page.ASI_CRM_TW_MerchanVisitationPlan_Page;
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
        ApexPages.getMessages().clear();
        List<ASI_HK_CRM_Visitation_Plan_Detail__c> visitDetailList = 
            [SELECT Id, ASI_HK_CRM_Visit_Date__c, ASI_HK_CRM_Account__c 
            FROM ASI_HK_CRM_Visitation_Plan_Detail__c WHERE ASI_HK_CRM_Visitation_Plan__c = :visitPlanHeader.Id
            AND ASI_HK_CRM_Visit_Date__c <> null //Added by Introv@20170731 for issue fixing
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
        Map<Id, Integer> mapVPDAfterTodaybyAcc = new Map<Id, Integer>();
        Set<Integer> setvDetailListIndex = new Set<Integer>();
        
        for (ASI_HK_CRM_VisitationPlanEditRow row : visitTableRows) {                                                           
            Account acct = row.targetSObj;
            ID acctId = row.targetSObj.Id;
            List<ASI_HK_CRM_Visitation_Plan_Detail__c> vDetailList = acctIdToVisitDetailMap.get(acctId);
            if (vDetailList == null) 
                vDetailList = new List<ASI_HK_CRM_Visitation_Plan_Detail__c>();
            List<String> visitDayStrList = (row.visitDayStr != null && row.visitDayStr.length() > 0) ? row.visitDayStr.split(VISIT_DAY_DELIM, 0) : new List<String>();
            List<Integer> visitDayIntList = new List<Integer>();
            for (String visitDayStr : visitDayStrList) 
                visitDayIntList.add(Integer.valueOf(visitDayStr.trim()));
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
                if (!reachEndOfOriginal && vDetailList.get(j).ASI_HK_CRM_Visit_Date__c != NULL) originalDay = vDetailList.get(j).ASI_HK_CRM_Visit_Date__c.day();
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
                    if(vDetailList.get(j).ASI_HK_CRM_Visit_Date__c >= date.today()){
                        setvDetailListIndex.add(j); //Added by Twinkle 04/29/2015
                    }
                    j++;
                } else {
                    i++;
                    j++;
                }     
            }
            
            //Added by Twinkle 04/29/2015, count existing VPD by Account
            j = 0;
            while (j < vDetailList.size()) {                                
                if(!setvDetailListIndex.contains(j) && vDetailList.get(j).ASI_HK_CRM_Visit_Date__c != NULL && vDetailList.get(j).ASI_HK_CRM_Visit_Date__c >= date.today()){
                    if(mapVPDAfterTodaybyAcc.get(acct.id) == NULL)
                        mapVPDAfterTodaybyAcc.put(acct.id,1);
                    else{
                        Integer count = mapVPDAfterTodaybyAcc.get(acct.id);
                        count++;
                        mapVPDAfterTodaybyAcc.put(acct.id,count);
                    }
                }
                j++;
            }     
            //End by Twinkle 04/29/2015         
        }                 
        
        //Added by Twinkle 04/29/2015
        for(ASI_HK_CRM_Visitation_Plan_Detail__c vpd : insertVisitDetailList){
            if(vpd.ASI_HK_CRM_Visit_Date__c < date.today()){
                if(userLanguage == 'zh_TW')
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, '排班日期必須為今日之後 (含今日)'));
                else
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Cannot select dates before today.'));
                return false;
            }
            //counting the no. of VPD for each Outlet and put into the map
            else{
                if(mapVPDAfterTodaybyAcc.get(vpd.ASI_HK_CRM_Account__c) == NULL)
                    mapVPDAfterTodaybyAcc.put(vpd.ASI_HK_CRM_Account__c,1);
                else{
                    Integer count = mapVPDAfterTodaybyAcc.get(vpd.ASI_HK_CRM_Account__c);
                    count++;
                    mapVPDAfterTodaybyAcc.put(vpd.ASI_HK_CRM_Account__c,count);
                }
            }
        }
        
        //Display which outlet(s) select more than one date after today
        Boolean boolMoreThanOne = FALSE;
        String strAccNames = '';
        for(Id accKey : mapVPDAfterTodaybyAcc.keySet()){
            if(mapVPDAfterTodaybyAcc.get(accKey) >= 2){
                boolMoreThanOne = TRUE;
                if(mapAccount.get(accKey) != NULL){
                    if(strAccNames == '')
                        strAccNames = '\''+mapAccount.get(accKey).Name+'\'';
                    else
                        strAccNames += ', \''+mapAccount.get(accKey).Name+'\'';
                }
            }
        }
        if(boolMoreThanOne == TRUE){
            if(userLanguage == 'zh_TW'){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, '請注意, 每個店家只能選擇一個今天或今天之後的探訪日期.'));
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, '店家 '+strAccNames+' 選擇多於一個探訪日期.'));
            }
            else{
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select only one visit date for one Outlet on/after today.'));
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Outlet(s) '+strAccNames+' select(s) more than one visit date.'));
            }
            return false;
        }
        //End by Twinkle 29/04/2015
        
        Boolean allSuccess = true;
        System.Savepoint sp = database.setSavepoint();
        
        System.debug('###deleteVisitDetailList: '+deleteVisitDetailList);
        if (allSuccess && deleteVisitDetailList.size() > 0) {
            try {
                delete deleteVisitDetailList;
            } catch (Exception e) {
                allSuccess = false;
                database.rollback(sp);
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Delete Error'+e));
            }
        }
        system.debug('###allSuccess: '+allSuccess);
        
        if (allSuccess && insertVisitDetailList.size() > 0) {
            try {
                insert insertVisitDetailList;
            } catch (Exception e) {
                allSuccess = false;
                database.rollback(sp);
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Insert Error'+e));
            }
        }
        system.debug('###allSuccess: '+allSuccess);        
        
        //Added by Twinkle #20150430 - Update Merchan Task when VPD is changed or removed
        Map<id, ASI_HK_CRM_Visitation_Plan_Detail__c> mapNewVpdAcc = NEW Map<id, ASI_HK_CRM_Visitation_Plan_Detail__c>();
        Map<id, ASI_HK_CRM_Visitation_Plan_Detail__c> mapdeletedVpdAcc = NEW Map<id, ASI_HK_CRM_Visitation_Plan_Detail__c>();
        
        if (allSuccess && listMerchanTask.size() > 0){
            for(ASI_HK_CRM_Visitation_Plan_Detail__c vpd : insertVisitDetailList){
                mapNewVpdAcc.put(vpd.ASI_HK_CRM_Account__c, vpd);              
            }
            for(ASI_HK_CRM_Visitation_Plan_Detail__c vpd : deleteVisitDetailList){
                mapdeletedVpdAcc.put(vpd.ASI_HK_CRM_Account__c, vpd);              
            }      
            
            //Added by William Yang (Introv) on 20150711
            List<ASI_CRM_Merchandiser_Task__c> merchanTasksToUpdate = new List<ASI_CRM_Merchandiser_Task__c>();
            Map<id, ASI_CRM_Merchandiser_Task__c> mapMerchanTasksToUpdate = new Map<id, ASI_CRM_Merchandiser_Task__c>();
            
            for(ASI_CRM_Merchandiser_Task__c mtask : listMerchanTask){
                if(mtask.ASI_CRM_Promotion_Status__c != NULL && mtask.ASI_CRM_Promotion_Status__r.ASI_CRM_Account__c != NULL){
                    if(mapdeletedVpdAcc.get(mtask.ASI_CRM_Promotion_Status__r.ASI_CRM_Account__c) != null)
                    {
                        //merchanTasksToUpdate.add(mtask);
                        mapMerchanTasksToUpdate.put(mtask.id, mtask);
                        mtask.ASI_CRM_Visitation_Plan_Detail__c = null;                        
                    }
                    if(mapNewVpdAcc.get(mtask.ASI_CRM_Promotion_Status__r.ASI_CRM_Account__c) != null)
                    {
                        //merchanTasksToUpdate.add(mtask);      
                        mapMerchanTasksToUpdate.put(mtask.id, mtask);                  
                        mtask.ASI_CRM_Visitation_Plan_Detail__c = mapNewVpdAcc.get(mtask.ASI_CRM_Promotion_Status__r.ASI_CRM_Account__c).id;                        
                    }
                }    
            }
            
            try {
                //update listMerchanTask;
                merchanTasksToUpdate = mapMerchanTasksToUpdate.values();
                update merchanTasksToUpdate;
            } catch (Exception e) {
                allSuccess = false;
                database.rollback(sp);
                //system.debug('###Dml Exception: '+dmle.getDmlMessage(0));
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Update Error'+e));
            }
        }      
        system.debug('###allSuccess: '+allSuccess);
        //End by Twinkle #20150430 
        
        return allSuccess;
    }
    
    private Integer getVPMonthFromPicklistValue(String plValue) {
        Integer result = ASI_HK_CRM_VisitationPlanGenerator.convertMonthPLValueToInteger(plValue);
        if (result == null) return 0;
        return result;
    }    
    private void showPageMessage(ApexPages.Severity severity, String msg) {
        ApexPages.addMessage(new ApexPages.Message(severity, msg));
    }
    private void showPageError(String msg) {
        showPageMessage(ApexPages.Severity.ERROR, msg);
    }
    
    public class ASI_HK_CRM_VisitationPlanEditRow {
        public Account targetSObj { get; set; }
        public ASI_CRM_AccountsAdditionalField__c additionalField { get; set; }
        public String customType { get; private set; }
        public Integer worthPt { get; set; }
        public Integer requiredPt { get; set; }
        public Integer plannedPt { get; set; }
        public String visitDayStr { get; set; }
        public Boolean boolNoRequireVisit { get; set; }
        public Integer intTaskNo { get; set; }
        public String taskDetails {get; set; } //Added by Twinkle 20161018
        
        public ASI_HK_CRM_VisitationPlanEditRow(Account targetSObj, ASI_CRM_AccountsAdditionalField__c additionalField, String customType, 
        Integer worthPt, Integer requiredPt, List<Integer> visitDayIntList, Boolean noRequireVisit, Integer intTaskNo, String taskDetails) {
            this.targetSObj = targetSObj;
            this.additionalField = additionalField;
            this.customType = customType;
            this.worthPt = worthPt;
            this.requiredPt = requiredPt;
            this.visitDayStr = intListToSeparatedStr(visitDayIntList, VISIT_DAY_DELIM);
            this.plannedPt = calculatePlannedPoint(visitDayIntList);
            this.boolNoRequireVisit = noRequireVisit;
            this.intTaskNo = intTaskNo;
            this.taskDetails = taskDetails;
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
}