/*********************************************************************************
 * Name:ASI_CRM_VN_VisitationPlanEditController
 * Description: copied and modified from SG CRM
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------
 * 05/10/2015       Laputa: Hank            Created
 * 19/01/2017       Laputa: Jeffrey Cheung  Added filter for outlet, default show confirmed outlet, show call frequency
 * 07/12/2018		Laputa: Calvin			Added Value Segment RT
*********************************************************************************/
public with sharing class ASI_CRM_VN_VisitationPlanEditController {
    public static final String VISIT_DAY_DELIM = ', ';
    public static final String POINT_KEY_TOTAL = 'total';
    public static final String ASI_VN_CRM_VISITATIONPLAN_RECORDTYPE = 'ASI_CRM_VN_Visitation_Plan';
    public static final String ASI_VN_CRM_SUBMITTED_VISITATIONPLAN_RECORDTYPE = 'ASI_CRM_VN_Visitation_Plan_Submitted';
    public static final String ASI_VN_CRM_VISITATIONPLAN_DETAIL_RECORDTYPE = 'ASI_CRM_VN_Visitation_Plan_Detail';
    public static final String ASI_VN_CRM_OFFTRADE_VISITATIONPLAN_DETAIL_RECORDTYPE = 'ASI_CRM_VN_OffTrade_Visitation_Plan_Detail';
    public static final String RT_VN_OUTLET = 'ASI_CRM_VN_Outlet';
    public static final String RT_VN_OFF_TRADE_OUTLET = 'ASI_CRM_VN_Off_Trade_Outlet';
    
    // added by Laputa: Calvin
    public static final String RT_VN_VALUE_OUTLET = 'ASI_CRM_VN_Value_Off_Trade_Outlet';
    public static final String RT_VN_VALUE_OFF_TRADE_OUTLET = 'ASI_CRM_VN_Value_On_Trade_Outlet';
    

    //public static final String RT_VN_POTENTIAL_OUTLET = 'ASI_CRM_VN_Potential_Outlet';
    //public static final String RT_VN_WHOLE_SALER = 'ASI_CRM_VN_Wholesaler';

    private static final List<String> POINT_KEY_LIST = new List<String>{
            RT_VN_OUTLET, RT_VN_OFF_TRADE_OUTLET/*, RT_VN_POTENTIAL_OUTLET, RT_VN_WHOLE_SALER*/, RT_VN_VALUE_OUTLET, RT_VN_VALUE_OFF_TRADE_OUTLET
    };

    private static final Integer DEF_WORTH_POINT = 1;

    // Variables used in VF page
    public List<ASI_HK_CRM_VisitationPlanEditRow> visitTableRows { get; set; }
    public Map<String, ASI_HK_CRM_VisitationPlanPoint> keyToVisitPointMap { get; set; }
    public Map<Date, Integer> dateToVisitCountMap { get; set; }
    public Map<Date, String> dateToOutletsMap { get; set; }
    public final Date visitPlanBeginDate { get; private set; }
    public final Date visitPlanEndDate { get; private set; }
    public final ID visitPlanId { get; private set; }
    public String ptKeyTotal { get {return POINT_KEY_TOTAL;} private set; }
    public List<String> ptKeyList { get {return POINT_KEY_LIST;} private set; }
    public String visitDayDelim { get {return VISIT_DAY_DELIM;} private set; }
    public String isLocked { get; set; }
    public Boolean hasError { get; set; }

    private final ApexPages.StandardSetController stdSetController;
    public ASI_HK_CRM_Visitation_Plan__c visitPlanHeader { get; set; }
    private final List<ASI_HK_CRM_Visitation_Plan_Detail__c> visitDetailList;
    private final ASI_CRM_VN_VisitationPlanDetailGenerator visitDetailGen;
    private final Map<String, Integer> gradeToRequiredPointMap;
    private Integer theYearInt;

    //    variables for outlet filter
    public String selectedArea { get; set; }
    public String selectedProvince { get; set; }
    public String selectedDistrict { get; set; }

    public List<SelectOption> getAreas() {
        return getSelectOptions('ASI_CRM_AccountsAdditionalField__c', 'ASI_CRM_Area__c');
    }
    public List<SelectOption> getProvinces() {
        return getSelectOptions('ASI_CRM_AccountsAdditionalField__c', 'ASI_CRM_VN_Province__c');
    }
    public List<SelectOption> getDistricts() {
        return getSelectOptions('ASI_CRM_AccountsAdditionalField__c', 'ASI_CRM_VN_Quan__c');
    }

    public List<SelectOption> getSelectOptions(String objectName, String fieldName) {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', '-- Select --'));
        //        Copy from https://th3silverlining.com/2012/02/01/salesforce-dynamically-determining-the-field-type-of-a-dynamically-determined-sobject/
        Schema.SObjectType t = Schema.getGlobalDescribe().get(objectName);
        Schema.DescribeSObjectResult r = t.getDescribe();
        Schema.DescribeFieldResult f = r.fields.getMap().get(fieldName).getDescribe();
        List<Schema.PicklistEntry> ple = f.getPicklistValues();

        for (Schema.PicklistEntry picklistEntry : ple) {
            options.add(new SelectOption(picklistEntry.getValue(), picklistEntry.getLabel()));
        }
        options.sort();
        return options;
    }
    //    End of variables for outlet filter

    // holidays!
    public String getHolidays() {
        return JSON.serialize([
                SELECT Id, Name, ASI_CRM_Date_From__c, ASI_CRM_Date_To__c
                FROM ASI_CRM_Holiday__c
                WHERE RecordType.DeveloperName = 'ASI_CRM_VN_Holiday'
                AND ASI_CRM_Date_From__c >= :visitPlanBeginDate.toStartOfMonth()
                AND ASI_CRM_Date_To__c <= :visitPlanEndDate.addMonths(1).toStartOfMonth().addDays(-1)
        ]);
    }

    private List<Account> accounts;
    private String sortDirection = 'ASC';
    private String sortExp = 'ASI_HK_CRM_Grade__c';

    public String searchAccountName { get; set; }
    public String searchAddress {get; set;}

    public String sortExpression {
        get {
            return sortExp;
        }
        set {
            if (value == sortExp)
                sortDirection = (sortDirection == 'ASC')? 'DESC NULLS LAST' : 'ASC'; else
                    sortDirection = 'ASC';
            sortExp = value;
        }
    }

    public ASI_CRM_VN_VisitationPlanEditController(ApexPages.StandardSetController stdSetController) {
        this.hasError = false;
        this.stdSetController = stdSetcontroller;
        // Get the visitation information

        String parentId = null;

        parentId = ApexPages.currentPage().getParameters().get('id');
        if (parentId == null) {
            this.hasError = true;
            showPageError(String.format('URL parameter is missing: {0}', new String[]{
                    'id'
            }));
            return;
        }
        system.debug('@parentId' + parentId);
        system.debug('@ASI_VN_CRM_VISITATIONPLAN_RECORDTYPE' + ASI_VN_CRM_VISITATIONPLAN_RECORDTYPE);
        this.visitDetailList = [
                SELECT Id, Name, ASI_HK_CRM_Visitation_Plan__c, ASI_HK_CRM_Account__c, ASI_CRM_MY_Customer__c,ASI_CRM_MY_Customer__r.Name,
                        ASI_HK_CRM_Visit_Date__c
                FROM ASI_HK_CRM_Visitation_Plan_Detail__c
                WHERE ASI_HK_CRM_Visitation_Plan__c = :parentId
                AND (ASI_HK_CRM_Visitation_Plan__r.RecordType.DeveloperName = :ASI_VN_CRM_VISITATIONPLAN_RECORDTYPE
                OR ASI_HK_CRM_Visitation_Plan__r.RecordType.DeveloperName = :ASI_VN_CRM_SUBMITTED_VISITATIONPLAN_RECORDTYPE)
        ];

        this.visitPlanHeader = [
                SELECT Id, Name, ASI_HK_CRM_Year__c, ASI_HK_CRM_Month__c, ASI_HK_CRM_Confirmed__c, recordtype.name, recordtype.DeveloperName,
                        OwnerId, ASI_CRM_VN_Period__c
                FROM ASI_HK_CRM_Visitation_Plan__c
                WHERE Id = :parentId AND (recordtype.DeveloperName = :ASI_VN_CRM_VISITATIONPLAN_RECORDTYPE
                OR recordtype.DeveloperName = :ASI_VN_CRM_SUBMITTED_VISITATIONPLAN_RECORDTYPE )
        ];
        this.visitPlanId = this.visitPlanHeader.Id;

        // Initialize data for display
        this.visitTableRows = new List<ASI_HK_CRM_VisitationPlanEditRow>();
        this.keyToVisitPointMap = new Map<String, ASI_HK_CRM_VisitationPlanPoint>();
        this.dateToVisitCountMap = new Map<Date, Integer>();
        this.dateToOutletsMap = new Map<Date, String>();

        // Initialize the settings
        Integer vpMonth = getVPMonthFromPicklistValue(visitPlanHeader.ASI_HK_CRM_Month__c);
        if (vpMonth == 0) {
            this.hasError = true;
            showPageError(String.format('Unknown Month of {0}: {1}', new String[]{
                    Schema.SObjectType.ASI_HK_CRM_Visitation_Plan__c.getLabel(), visitPlanHeader.ASI_HK_CRM_Month__c
            }));
            return;
        }
        try {
            this.theYearInt = Integer.valueOf(visitPlanHeader.ASI_HK_CRM_Year__c);
        } catch (TypeException te) {
            this.hasError = true;
            showPageError(String.format('Unknown Year: {0}', new String[]{
                    Schema.SObjectType.ASI_HK_CRM_Visitation_Plan__c.getLabel(), visitPlanHeader.ASI_HK_CRM_Month__c
            }));
            return;
        }
        this.visitPlanBeginDate = Date.newInstance(theYearInt, vpMonth, 1);
        this.visitPlanEndDate = Date.newInstance(theYearInt, vpMonth, Date.daysInMonth(theYearInt, vpMonth));
        this.isLocked = this.visitPlanHeader.ASI_HK_CRM_Confirmed__c == true? 'true' : 'false';
        this.gradeToRequiredPointMap = initGradeToVisitCountMap();

        this.visitDetailGen = new ASI_CRM_VN_VisitationPlanDetailGenerator();
    }

    public String getSortDirection() {
        return String.isEmpty(sortExpression)? 'ASC' : sortDirection;
    }

    public void setSortDirection(String value) {
        sortDirection = value;
    }

    public void ResetNameSearch() {
        searchAccountName = '';
        searchAddress = '';
        selectedArea = '';
        selectedProvince = '';
        selectedDistrict = '';
        NameSearch();
    }

    public void NameSearch() {
        sortDirection = 'ASC';
        sortExp = 'name';
        ViewData();
        //sortExp = 'ASI_HK_CRM_Grade__c';
    }

    public PageReference ViewData() {
        string sortFullExp = sortExpression + ' ' + sortDirection;
        if (!sortFullExp.contains('name'))
            sortFullExp += ',name';

        this.visitTableRows.clear();
        String parentId = ApexPages.currentPage().getParameters().get('id');

        List<ASI_HK_CRM_Visitation_Plan_Detail__c> visitDetailList2 = [
                SELECT Id, Name, ASI_HK_CRM_Visitation_Plan__c, ASI_HK_CRM_Account__c, ASI_HK_CRM_Visit_Date__c,ASI_CRM_MY_Customer__c,ASI_CRM_MY_Customer__r.Name
                FROM ASI_HK_CRM_Visitation_Plan_Detail__c
                WHERE ASI_HK_CRM_Visitation_Plan__c = :parentId
                AND (ASI_HK_CRM_Visitation_Plan__r.RecordType.DeveloperName = :ASI_VN_CRM_VISITATIONPLAN_RECORDTYPE
                OR ASI_HK_CRM_Visitation_Plan__r.RecordType.DeveloperName = :ASI_VN_CRM_SUBMITTED_VISITATIONPLAN_RECORDTYPE)
        ];

        Map<ID, List<Integer>> acctIdToVisitDaysMap = new Map<ID, List<Integer>>();
        this.dateToVisitCountMap = new Map<Date, Integer>();
        this.dateToOutletsMap = new Map<Date, String>();
        for (ASI_HK_CRM_Visitation_Plan_Detail__c vd : visitDetailList2) {
            // List of visitation date of the account
            List<Integer> visitDays = acctIdToVisitDaysMap.get(vd.ASI_CRM_MY_Customer__c);
            if (visitDays == null) {
                visitDays = new List<Integer>();
                acctIdToVisitDaysMap.put(vd.ASI_CRM_MY_Customer__c, visitDays);
            }
            if (vd.ASI_HK_CRM_Visit_Date__c != null)
                visitDays.add(vd.ASI_HK_CRM_Visit_Date__c.day());
            // Update the numbers of visitation of each date
            Integer visitCount = dateToVisitCountMap.get(vd.ASI_HK_CRM_Visit_Date__c);
            String outletStr = dateToOutletsMap.get(vd.ASI_HK_CRM_Visit_Date__c);
            if (visitCount == null) {
                visitCount = 0;
            }
            if (outletStr == null) {
                outletStr = vd.ASI_CRM_MY_Customer__c + ':' + vd.ASI_CRM_MY_Customer__r.Name;
            } else {
                outletStr = outletStr + ';';
                outletStr += vd.ASI_CRM_MY_Customer__c + ':' + vd.ASI_CRM_MY_Customer__r.Name;
            }
            dateToVisitCountMap.put(vd.ASI_HK_CRM_Visit_Date__c, visitCount + 1);
            dateToOutletsMap.put(vd.ASI_HK_CRM_Visit_Date__c, outletStr);
        }

        ID headerOwnerId = this.visitPlanHeader.OwnerId;
        System.debug('Debug headerOwnerId  :' + headerOwnerId);


        String queryForOutlet = 'SELECT Id, Name, RecordTypeId, RecordType.Name, RecordType.DeveloperName, ASI_CRM_Call_Frequency__c, ASI_CRM_Service_Pack__r.ASI_CRM_CallFrequency__c, ' +
                'ASI_CRM_CN_Address__c,ASI_TH_CRM_OutletType__c,ASI_CRM_Outlet_Sub_Type__c,ASI_CRM_CN_Image__c,ASI_TH_CRM_LeadBrand__c, ASI_CRM_VN_OutletType__c, ASI_CRM_VN_Region__c, ASI_CRM_Area__c, ASI_CRM_VN_Province__c,' +
                '(SELECT ASI_CRM_SG_Service_Pack__r.ASI_CRM_CallFrequency__c From Pros_Segmentations__r)' +
                'FROM ASI_CRM_AccountsAdditionalField__c WHERE ';

        // show confirmed outlet if have detail and no filter
        if (this.visitPlanHeader.Recordtype.DeveloperName == ASI_VN_CRM_SUBMITTED_VISITATIONPLAN_RECORDTYPE &&
                visitDetailList2.size() > 0 &&
                String.isEmpty(searchAccountName) &&
            	String.isEmpty(searchAddress) && 
                String.isEmpty(selectedArea) &&
                String.isEmpty(selectedProvince) &&
                String.isEmpty(selectedDistrict)
                ) {
            Set<Id> acctIds = acctIdToVisitDaysMap.keySet();
            queryForOutlet += 'Id IN :acctIds ';
        } else {
            queryForOutlet += 'ASI_CRM_CN_Inactive_Flag__c = false ' +
                'AND OwnerId = :headerOwnerId ' + (String.isEmpty(searchAccountName)? '' : ' and name like \'%' + searchAccountName + '%\' ') +
                (String.isNotEmpty(searchAddress) ? 'AND ASI_CRM_CN_Address__c LIKE \'%' + searchAddress + '%\' ' : '') + 
                (String.isNotEmpty(selectedArea)? 'AND ASI_CRM_Area__c = :selectedArea ' : '') +
                (String.isNotEmpty(selectedProvince)? 'AND ASI_CRM_VN_Province__c = :selectedProvince ' : '') +
                (String.isNotEmpty(selectedDistrict)? 'AND ASI_CRM_VN_Quan__c = :selectedDistrict ' : '');

            if(this.visitPlanHeader.Recordtype.DeveloperName == ASI_VN_CRM_SUBMITTED_VISITATIONPLAN_RECORDTYPE) {
                Set<Id> acctIds = acctIdToVisitDaysMap.keySet();
                queryForOutlet += 'AND Id IN :acctIds ';
            }
        }
        
//        queryForOutlet += 'ASI_CRM_CN_Inactive_Flag__c = false ' +
//                'AND OwnerId = :headerOwnerId ' + (String.isEmpty(searchAccountName) ? '' : ' and name like \'%' + searchAccountName + '%\' ') +
//                (String.isNotEmpty(selectedArea)? 'AND ASI_CRM_Area__c = :selectedArea ' : '') +
//                (String.isNotEmpty(selectedProvince)? 'AND ASI_CRM_VN_Province__c = :selectedProvince ' : '') +
//                (String.isNotEmpty(selectedDistrict)? 'AND ASI_CRM_VN_Quan__c = :selectedDistrict ' : '');
//
        queryForOutlet += 'AND (RecordType.DeveloperName = :RT_VN_OUTLET OR RecordType.DeveloperName = :RT_VN_OFF_TRADE_OUTLET OR RecordType.DeveloperName = :RT_VN_VALUE_OUTLET OR RecordType.DeveloperName = :RT_VN_VALUE_OFF_TRADE_OUTLET) ' +
                'ORDER BY ' + sortFullExp;

        List<ASI_CRM_AccountsAdditionalField__c> targetSObjList = Database.query(queryForOutlet);

        for (ASI_CRM_AccountsAdditionalField__c targetSObj : targetSObjList) {

            System.debug('targetSObj.id:' + targetSObj.id);
            System.debug('targetSObj:' + targetSObj.Name);
            System.debug('targetSObj.RecordType.DeveloperName:' + targetSObj.RecordType.DeveloperName);
            System.debug('DEF_WORTH_POINT:' + DEF_WORTH_POINT);
            System.debug('acctIdToVisitDaysMap.get(targetSObj.Id):' + acctIdToVisitDaysMap.get(targetSObj.Id));

            this.visitTableRows.add(new ASI_HK_CRM_VisitationPlanEditRow(targetSObj, null,
                    targetSObj.RecordType.DeveloperName, DEF_WORTH_POINT, acctIdToVisitDaysMap.get(targetSObj.Id)));
        }

        for (Date tempDate = this.visitPlanBeginDate; tempDate <= this.visitPlanEndDate; tempDate = tempDate.addDays(1)) {
            Integer visitCount = dateToVisitCountMap.get(tempDate);
            String outletStr = dateToOutletsMap.get(tempDate);
            if (outletStr == null) {
                dateToOutletsMap.put(tempDate, '');
            }
            if (visitCount == null)
                dateToVisitCountMap.put(tempDate, 0);
        }
        // Calculate the overall points
        initOverallPoints();
        system.debug(dateToOutletsMap);
        system.debug(dateToVisitCountMap);
        return null;
    }

    public PageReference initPage() {
        if (hasError) return null;
        // Summarize the visitation details by Account
        Map<ID, List<Integer>> acctIdToVisitDaysMap = new Map<ID, List<Integer>>();
        this.dateToVisitCountMap = new Map<Date, Integer>();
        this.dateToOutletsMap = new Map<Date, String>();
        for (ASI_HK_CRM_Visitation_Plan_Detail__c vd : visitDetailList) {

            // List of visitation date of the account
            List<Integer> visitDays = acctIdToVisitDaysMap.get(vd.ASI_CRM_MY_Customer__c);
            if (visitDays == null) {
                visitDays = new List<Integer>();
                acctIdToVisitDaysMap.put(vd.ASI_CRM_MY_Customer__c, visitDays);
            }
            if (vd.ASI_HK_CRM_Visit_Date__c != null)
                visitDays.add(vd.ASI_HK_CRM_Visit_Date__c.day());
            // Update the numbers of visitation of each date
            Integer visitCount = dateToVisitCountMap.get(vd.ASI_HK_CRM_Visit_Date__c);
            String outletStr = dateToOutletsMap.get(vd.ASI_HK_CRM_Visit_Date__c);
            if (visitCount == null) {
                visitCount = 0;
            }
            if (outletStr == null) {
                outletStr = vd.ASI_CRM_MY_Customer__c + ':' + vd.ASI_CRM_MY_Customer__r.Name;
            } else {
                outletStr = outletStr + ';';
                outletStr += vd.ASI_CRM_MY_Customer__c + ':' + vd.ASI_CRM_MY_Customer__r.Name;
            }
            dateToVisitCountMap.put(vd.ASI_HK_CRM_Visit_Date__c, visitCount + 1);
            dateToOutletsMap.put(vd.ASI_HK_CRM_Visit_Date__c, outletStr);
        }
        system.debug(dateToOutletsMap);
        // Create table row info for each Account
        ID headerOwnerId = this.visitPlanHeader.OwnerId;

        List<ASI_CRM_AccountsAdditionalField__c> customers = [
                SELECT Id, Name, RecordTypeId, RecordType.Name, RecordType.DeveloperName, ASI_CRM_VN_OutletType__c, ASI_CRM_VN_Region__c,ASI_CRM_Area__c,ASI_CRM_VN_Province__c,
                        ASI_CRM_CN_Address__c,ASI_TH_CRM_OutletType__c,ASI_CRM_Outlet_Sub_Type__c,ASI_CRM_CN_Image__c,ASI_TH_CRM_LeadBrand__c, ASI_CRM_Call_Frequency__c , ASI_CRM_Service_Pack__r.ASI_CRM_CallFrequency__c
                FROM ASI_CRM_AccountsAdditionalField__c
                WHERE ASI_CRM_CN_Inactive_Flag__c = FALSE
                AND OwnerId = :headerOwnerId
                AND (RecordType.DeveloperName = :RT_VN_OUTLET OR RecordType.DeveloperName = :RT_VN_OFF_TRADE_OUTLET /*OR RecordType.DeveloperName = :RT_VN_POTENTIAL_OUTLET OR RecordType.DeveloperName = :RT_VN_WHOLE_SALER*/
                 OR RecordType.DeveloperName = :RT_VN_VALUE_OUTLET OR RecordType.DeveloperName = :RT_VN_VALUE_OFF_TRADE_OUTLET)
                ORDER BY Name
        ];
        for (ASI_CRM_AccountsAdditionalField__c customer : customers) {
            // Skip if Visitation Plan is submitted and customer has no visit
            if (this.visitPlanHeader.RecordType.DeveloperName == ASI_VN_CRM_SUBMITTED_VISITATIONPLAN_RECORDTYPE && acctIdToVisitDaysMap.get(customer.Id) == null) {
                continue;
            }

            this.visitTableRows.add(
                    new ASI_HK_CRM_VisitationPlanEditRow(
                            customer,
                            null,
                            customer.RecordType.DeveloperName,
                            DEF_WORTH_POINT,
                            acctIdToVisitDaysMap.get(customer.Id)
                    )
            );

        }

        // Fill in zero visitation count for missing date
        for (Date tempDate = this.visitPlanBeginDate; tempDate <= this.visitPlanEndDate; tempDate = tempDate.addDays(1)) {
            Integer visitCount = dateToVisitCountMap.get(tempDate);
            String outletStr = dateToOutletsMap.get(tempDate);
            if (outletStr == null) {
                dateToOutletsMap.put(tempDate, '');
            }
            if (visitCount == null)
                dateToVisitCountMap.put(tempDate, 0);
        }
        // Calculate the overall points
        system.debug(dateToOutletsMap);
        system.debug(dateToVisitCountMap);
        initOverallPoints();

        return null;
    }

    public PageReference quickSaveChanges() {
        Boolean saveSuccess = implSaveChanges();
        PageReference redirectPage = null;
        if (saveSuccess) {
            redirectPage = Page.ASI_CRM_VN_VisitationPlanEditPage;
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
        List<ASI_HK_CRM_Visitation_Plan_Detail__c> visitDetailList = [
                SELECT Id, ASI_HK_CRM_Visit_Date__c, ASI_HK_CRM_Account__c,ASI_CRM_MY_Customer__c
                FROM ASI_HK_CRM_Visitation_Plan_Detail__c
                WHERE ASI_HK_CRM_Visitation_Plan__c = :visitPlanHeader.Id
                ORDER BY ASI_HK_CRM_Visit_Date__c
        ];
        Map<ID, List<ASI_HK_CRM_Visitation_Plan_Detail__c>> acctIdToVisitDetailMap = new Map<ID, List<ASI_HK_CRM_Visitation_Plan_Detail__c>>();
        for (ASI_HK_CRM_Visitation_Plan_Detail__c vDetail : visitDetailList) {

            List<ASI_HK_CRM_Visitation_Plan_Detail__c> tempVisitDetailList = acctIdToVisitDetailMap.get(vDetail.ASI_CRM_MY_Customer__c);
            if (tempVisitDetailList == null) {
                tempVisitDetailList = new List<ASI_HK_CRM_Visitation_Plan_Detail__c>();
                acctIdToVisitDetailMap.put(vDetail.ASI_CRM_MY_Customer__c, tempVisitDetailList);
            }
            tempVisitDetailList.add(vDetail);
        }
        List<ASI_HK_CRM_Visitation_Plan_Detail__c> deleteVisitDetailList = new List<ASI_HK_CRM_Visitation_Plan_Detail__c>();
        List<ASI_HK_CRM_Visitation_Plan_Detail__c> insertVisitDetailList = new List<ASI_HK_CRM_Visitation_Plan_Detail__c>();
        system.debug('@visitTableRows' + visitTableRows);
        for (ASI_HK_CRM_VisitationPlanEditRow row : visitTableRows) {
            ASI_CRM_AccountsAdditionalField__c acct = row.targetSObj;

            ID acctId = row.targetSObj.Id;
            List<ASI_HK_CRM_Visitation_Plan_Detail__c> vDetailList = acctIdToVisitDetailMap.get(acctId);
            if (vDetailList == null) vDetailList = new List<ASI_HK_CRM_Visitation_Plan_Detail__c>();
            List<String> visitDayStrList = (row.visitDayStr != null && row.visitDayStr.length() > 0)? row.visitDayStr.split(VISIT_DAY_DELIM, 0) : new List<String>();
            List<Integer> visitDayIntList = new List<Integer>();
            for (String visitDayStr : visitDayStrList) visitDayIntList.add(Integer.valueOf(visitDayStr.trim()));
            visitDayIntList.sort();
            Integer i = 0, j = 0;
            Boolean reachEndOfUserInput = false;
            Boolean reachEndOfOriginal = false;

            while (i < visitDayIntList.size() || j < vDetailList.size()) {
                if (!reachEndOfUserInput && i >= visitDayIntList.size()) reachEndOfUserInput = true;
                if (!reachEndOfOriginal && j >= vDetailList.size()) reachEndOfOriginal = true;
                Integer userInputDay = 0;
                Integer originalDay = 0;
                if (!reachEndOfUserInput) userInputDay = visitDayIntList.get(i);
                if (!reachEndOfOriginal) originalDay = vDetailList.get(j).ASI_HK_CRM_Visit_Date__c.day();
                if (!reachEndOfUserInput && (reachEndOfOriginal || userInputDay < originalDay)) {
                    system.debug('@acct' + acct);
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
                system.debug('@insertVisitDetailList' + insertVisitDetailList);
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
        List<RecordType> rtList = [
                SELECT Id, Name, DeveloperName
                FROM RecordType
                WHERE DeveloperName IN (:RT_VN_OUTLET, :RT_VN_OFF_TRADE_OUTLET/*, :RT_VN_POTENTIAL_OUTLET, :RT_VN_WHOLE_SALER */, :RT_VN_VALUE_OUTLET, :RT_VN_VALUE_OFF_TRADE_OUTLET)
        ];
        this.keyToVisitPointMap = new Map<String, ASI_HK_CRM_VisitationPlanPoint>();
        for (RecordType rt : rtList) {
            System.debug('Debug rt.DeveloperName:' + rt.DeveloperName);
            this.keyToVisitPointMap.put(
                    rt.DeveloperName
                    , new ASI_HK_CRM_VisitationPlanPoint(rt.Name, 0, 0, 0)
            );
        }

        Integer totalRequiredPt = 0;
        Integer totalPlannedPt = 0;
        Integer outletNo = 0;
        system.debug('@this.visitTableRows' + this.visitTableRows);
        for (ASI_HK_CRM_VisitationPlanEditRow visitRow : this.visitTableRows) {
            if (visitRow.customType == null) continue;
            ASI_HK_CRM_VisitationPlanPoint pt = keyToVisitPointMap.get(visitRow.customType);
            if (pt == null) continue;
            pt.plannedPt = pt.plannedPt + visitRow.plannedPt;
            if (visitRow.plannedPt > 0) {
                outletNo = outletNo + 1;
                pt.noOutlet = pt.noOutlet + 1;
            }
            totalPlannedPt += visitRow.plannedPt;
            system.debug('@pt.plannedPt' + pt.plannedPt);
            system.debug('@visitRow.plannedPt' + visitRow.plannedPt);
            system.debug('@totalPlannedPt' + totalPlannedPt);
        }
        keyToVisitPointMap.put(POINT_KEY_TOTAL, new ASI_HK_CRM_VisitationPlanPoint(Label.ASI_HK_CRM_VF_VISIT_TotalPoint, totalRequiredPt, totalPlannedPt, outletNo));
        system.debug('@keyToVisitPointMap' + keyToVisitPointMap);
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

    public pageReference confirm() {

        if (visitPlanHeader.OwnerId == UserInfo.getUserId()) {
            //Identify if the currently logged in user is the record owner himself
            //Throw Error
            this.hasError = true;
            showPageError(Label.ASI_VN_CRM_VF_VISIT_ERR_ContactManager);
        } else {
            ASI_CRM_VN_VisitationConfirmProcess visitConfirmProcess = new ASI_CRM_VN_VisitationConfirmProcess(visitPlanHeader.Id);
            this.hasError = !visitConfirmProcess.processConfirmation();
        }
        return this.hasError? null : new PageReference('/' + visitPlanHeader.Id);
    }

    public class ASI_HK_CRM_VisitationPlanEditRow {
        public ASI_CRM_AccountsAdditionalField__c targetSObj { get; set; }
        public ASI_CRM_AccountsAdditionalField__c additionalField { get; set; }
        public String customType { get; private set; }
        public Integer worthPt { get; set; }
        //public Integer requiredPt { get; set; }
        public Integer plannedPt { get; private set; }
        public String visitDayStr { get; set; }

        public ASI_HK_CRM_VisitationPlanEditRow(ASI_CRM_AccountsAdditionalField__c targetSObj, ASI_CRM_AccountsAdditionalField__c additionalField, String customType,
                Integer worthPt, List<Integer> visitDayIntList) {
            this.targetSObj = targetSObj;
            this.additionalField = additionalField;
            this.customType = customType;
            this.worthPt = worthPt;
            this.visitDayStr = intListToSeparatedStr(visitDayIntList, VISIT_DAY_DELIM);
            this.plannedPt = calculatePlannedPoint(visitDayIntList);
        }

        private String intListToSeparatedStr(List<Integer> intList, String delim) {
            if (intList == null || delim == null) return '';
            intList.sort();
            return String.join(intList, delim);
        }

        private Integer calculatePlannedPoint(List<Integer> visitDayIntList) {
            return visitDayIntList == null? 0 : this.worthPt * visitDayIntList.size();
        }
    }

    public class ASI_HK_CRM_VisitationPlanPoint {
        public String label { get; private set; }
        public String type { get; private set; }
        public Integer requiredPt { get; private set; }
        public Integer plannedPt { get; private set; }
        public Integer balancePt { get {return this.requiredPt - this.plannedPt;} private set; }
        public Integer noOutlet { get; set; }

        public ASI_HK_CRM_VisitationPlanPoint(String label, Integer requiredPt, Integer plannedPt, Integer noOutlet) {
            this.label = label;
            this.requiredPt = requiredPt;
            this.plannedPt = plannedPt;
            this.noOutlet = noOutlet;
			/*
            if (this.label == 'Outlet (VN)') {
                this.type = 'ON';
            } else {
                this.type = 'OFF';
            }*/
            // Laputa: Calvin 2018-12-07
			if (this.label.contains('Off-Trade')) {
                this.type = 'OFF';
            } else {
                this.type = 'ON';
            }
            
            if (this.label.contains('Value')) {
                this.type += ' (Value)';
            } else {
                this.type += ' (Premium)';
            }
        }
    }

}