/*
    *Created By: Bryan Trinidad
    *Created Date: June 19,2014
    *   
    *       Updated By:             Date:               Description:        
    *       Bryan Trinidad          July 24, 2014       Change Request: Retrieving objectives based on country dropdown list
    *
    * Updated regarding evolutions LCS-159
*/
public class PRH_Objective_Controller {

    /*variables*/
    public List<PRH_Objectives__c> objectiveList {get;set;}
    public Boolean rendered {get;set;}
    public Boolean saveAndCancelRendered {get;set;}
    public Boolean updateObjectivesRendered {get;set;}
    public Boolean withList {get;set;}
    public List<ObjectiveWrapperClass> objectiveWrapList {get;set;}
    public Integer outletCount {get;set;}
    public String dateModified {get;set;}
    public String objectiveLabel {get;set;}    
    public String selectedCountry {get;set;}

    Set<PRH_Objectives__c> objectiveSet;
    Set<PRH_Brand_Criteria__c> brandCriteriaSet;
    Map<Id,Integer> brandsWithPresenceMap;
    Map<Integer,PRH_Objectives__c> orderBySequenceMap;
    List<PRH_Brand_Criteria__c> brandCriteriaList;
    //User currentUser;

    /*constructor*/ 
    public PRH_Objective_Controller() {

        //currentUser = [SELECT Id,Country FROM User WHERE Id=:UserInfo.getUserId()];
       
    }//end constructor

    //method for rerendering objective table base on the selected country
    public void rerenderObjectives() {
        try {
            updateObjectivesRendered = false;
            withList = true;
            rendered = true;
            saveAndCancelRendered = false;
            
            objectiveSet = new Set<PRH_Objectives__c>();
            brandCriteriaSet = new Set<PRH_Brand_Criteria__c>();
            brandsWithPresenceMap = new Map<Id,Integer>();
            orderBySequenceMap = new Map<Integer,PRH_Objectives__c>();
            brandCriteriaList = new List<PRH_Brand_Criteria__c>();
            objectiveWrapList = new List<ObjectiveWrapperClass>();
            dateModified = '';

            //count of iconic account per country
            outletCount = retrieveOutletCount(selectedCountry);
            objectiveList = retrieveObjectives(selectedCountry);
            objectiveLabel = retrieveFiscalYrLabel();

            system.debug('==> rerenderObjectives : objectiveList.size() = ' + objectiveList.size() + ', country = ' + selectedCountry);

            // ApexPages.Message msg1 = new ApexPages.Message(ApexPages.Severity.INFO,'country '+selectedCountry+' '+objectiveList.size());
            // ApexPages.addMessage(msg1);
            //get current presence count if there are no stored objectives
            if (objectiveList.isEmpty()) {
                //system.debug('!START IF!');
                brandCriteriaList = retrieveBrands(selectedCountry);
                system.debug('==> rerenderObjectives, brandCriteriaList : ' + brandCriteriaList);

                if (selectedCountry != '--none--') {                   
                    //retrieve iconic brands if there are no brand criteria for the selected country
                    if (brandCriteriaList.isEmpty()) {
                        List<PRH_Brand_Luxury_Brand__c> iconicBrandsList = retrieveIconicBrands();

                        for (PRH_Brand_Luxury_Brand__c brand : iconicBrandsList) {
                            PRH_Objectives__c newObjective = new PRH_Objectives__c();
                            newObjective.PRH_Iconic_Brand__c = brand.Id;
                            newObjective.PRH_Country__c = selectedCountry;
                            newObjective.PRH_Presence__c = 0;
                            newObjective.PRH_Objective__c = 0;
                            objectiveList.add(newObjective);
                        }

                        for (PRH_Objectives__c obj:objectiveList) {
                            ObjectiveWrapperClass objWrap = new ObjectiveWrapperClass(obj,false);
                            objectiveWrapList.add(objWrap);
                        }

                        /*rendered = false;
                        withList = false;                        
                        ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.INFO,'No brand criteria records.');
                        ApexPages.addMessage(msg);*/
                    } else {
                        brandCriteriaSet.addAll(brandCriteriaList);
                        brandsWithPresenceMap = presenceCountInBrand(brandCriteriaSet,selectedCountry);              

                        for (PRH_Brand_Criteria__c brand:brandCriteriaSet) {
                            PRH_Objectives__c newObjective = new PRH_Objectives__c();
                            newObjective.PRH_Iconic_Brand__c = brand.PRH_Brand__c;
                            newObjective.PRH_Country__c = selectedCountry;//brand.PRH_Account__r.PRH_Account_Country__c;
                            newObjective.PRH_Presence__c = (brandsWithPresenceMap.get(brand.PRH_Brand__c) == null) ? 0 : brandsWithPresenceMap.get(brand.PRH_Brand__c);
                            newObjective.PRH_Objective__c = 0;
                            objectiveSet.add(newObjective);
                            //orderBySequenceMap.put((Integer)brand.PRH_Brand__r.PRH_SYS_Sequence__c,newObjective);
                        	String sequence = ((String)brand.PRH_Brand__r.PRH_Sequence__c).SubString(4,8);
                        	system.debug('==> rerenderObjectives, sequence=' + sequence );
                        	orderBySequenceMap.put((Integer)Integer.ValueOf(sequence), newObjective);
                        }

                        objectiveList.addAll(orderBySequenceMap.values());
                        
                        for (PRH_Objectives__c obj:objectiveList) {
                            ObjectiveWrapperClass objWrap = new ObjectiveWrapperClass(obj,false);
                            objectiveWrapList.add(objWrap);
                        }
                    }
                //render nothing if chosen country is equal to none
                } else {
                    withList = false;
                    rendered = false;
                    //ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.INFO,'No specified country for the current user.');
                    //ApexPages.addMessage(msg);
                }
            //get current stored objectives
            } else {
                //system.debug('!START ELSE!');
                dateModified = objectiveList[0].PRH_Last_Modified_Date__c;

                for (PRH_Objectives__c obj:objectiveList) {
                    ObjectiveWrapperClass objWrap = new ObjectiveWrapperClass(obj,false);
                    objectiveWrapList.add(objWrap);
                }
                //ApexPages.Message msg1 = new ApexPages.Message(ApexPages.Severity.INFO,''+objectiveList);
                //ApexPages.addMessage(msg1);          
            } 
        } catch(Exception e) {
            System.Debug('==> rerenderObjectives, error:'+ e.getMessage());
            System.Debug('==> rerenderObjectives, error:'+ e.getLineNumber());
            System.Debug('==> rerenderObjectives, error:'+ e.getStackTraceString());

            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.WARNING,''+e);
            ApexPages.addMessage(msg);
        }
    }//end rerenderObjectives()

    //enabling update objectives button after rerendering objectives table
    public void enabledUpdateObjectives() {
        
        updateObjectivesRendered = true;

    }//end enabledUpdateObjectives();

    //retrieve picklist values for objective country field
    public List<SelectOption> getCountryPicklistValues() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('--none--','--none--'));

        Schema.DescribeFieldResult fieldResult = PRH_Luxury_Accounts__c.PRH_Account_Country__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            
        for( Schema.PicklistEntry f : ple)
        {
            options.add(new SelectOption(f.getLabel(), f.getValue()));
        }
     
        return options;
    } //end retrieveCountryPicklistValues()

    /* method for retrieving objectives based on current user's country */
    public List<PRH_Objectives__c> retrieveObjectives(String country) {      
       return [SELECT Id,PRH_Iconic_Brand__c,PRH_Country__c,PRH_Presence__c,PRH_Objective__c,
                            PRH_Iconic_Brand__r.PRH_Sequence__c,PRH_Last_Modified_Date__c
                            FROM PRH_Objectives__c WHERE PRH_Country__c=:country
                            ORDER BY PRH_Iconic_Brand__r.PRH_Sequence__c ASC];
    } //end retrieveObjectives()

    /* method for retrieving brands based on current user's country */
    public List<PRH_Brand_Criteria__c> retrieveBrands(String country) {
        // LCS-159
        return [SELECT Id, PRH_Brand__c, PRH_Brand__r.Name, PRH_Brand__r.PRH_Active__c, PRH_Collect__r.PRH_Iconic_Account__r.PRH_Account_Country__c,
                    PRH_Collect__r.PRH_Iconic_Account__r.PRH_Suppress_and_archive__c, PRH_Account__r.Name, PRH_Brand__r.PRH_Sequence__c
                    FROM PRH_Brand_Criteria__c
                    WHERE PRH_Collect__r.PRH_Iconic_Account__r.PRH_Account_Country__c=:country
                    AND PRH_Collect__r.PRH_Active__c = true
                    AND PRH_Collect__r.PRH_Iconic_Account__c != null
                    AND PRH_Brand__r.PRH_Active__c = true
                    AND PRH_Brand__c != null
                    AND PRH_Collect__r.PRH_Iconic_Account__r.PRH_Suppress_and_archive__c=false
                    ORDER BY PRH_Brand__r.PRH_Sequence__c ASC];
        /*
        return [SELECT Id, PRH_Brand__c, PRH_Brand__r.Name, PRH_Brand__r.PRH_Active__c, PRH_Account__r.PRH_Account_Country__c,
                    PRH_Account__r.Name, PRH_Brand__r.PRH_Sequence__c
                    FROM PRH_Brand_Criteria__c
                    WHERE PRH_Account__r.PRH_Account_Country__c=:country
                    AND PRH_Account__c != null
                    AND PRH_Brand__c != null
                    AND PRH_Account__r.PRH_Suppress_and_archive__c=false
                    ORDER BY PRH_Brand__r.PRH_Sequence__c ASC];
        */
    } //end retrieveBrands()

    /* method for retrieving iconic brands, used when there are no brand criteria for the selected country */
    public List<PRH_Brand_Luxury_Brand__c> retrieveIconicBrands() {    
        return [SELECT Id 
                FROM PRH_Brand_Luxury_Brand__c 
                WHERE PRH_Competitor_Brand__c=false
                ORDER BY PRH_Sequence__c ASC];
    } //end retrieveIconicBrands();

    //method for getting fiscal year(july 1 to june 30) that will fillout objective column name
    public String retrieveFiscalYrLabel() { 
        Datetime dt = System.now();
        String objColumnLabel = '';
        String julyOnwardsMonth = 'Objective FY '+String.valueOf(dt.year()).substring(2,4)
                    +'/'+String.valueOf(dt.year()+1).substring(2,4);
        String belowJulyMonth = 'Objective FY '+String.valueOf(dt.year()-1).substring(2,4)+'/'
                    +String.valueOf(dt.year()).substring(2,4);

        objColumnLabel = (dt.month()>=7) ? julyOnwardsMonth : belowJulyMonth;

        return objColumnLabel;
    } //end retrieveFiscalYrLabel()

    /* count of iconic account per country */
    public Integer retrieveOutletCount(String country) {
        return [SELECT count() FROM
                PRH_Luxury_Accounts__c WHERE
                PRH_Account_Country__c=:country and PRH_Suppress_and_Archive__c = false];
    } //end retrieveOutletCount()

    /* method for counting all brand criterias with presence per country */
    public Map<Id,Integer> presenceCountInBrand(Set<PRH_Brand_Criteria__c> brandList,String country) {

        List<Id> iconicBrandIds = new List<Id>();
        Map<Id,Integer> brandsWithPresenceMap = new Map<Id,Integer>();
        
        system.debug('presenceCountInBrand, brandList.size() = '+brandList.size());

        if (!brandList.isEmpty()) {
            for (PRH_Brand_Criteria__c brand:brandList) {
                iconicBrandIds.add(brand.PRH_Brand__c);
            }

            // LCS-159
            List<AggregateResult> brandsWithPresence = [SELECT PRH_Brand__c,count(Id) FROM PRH_Brand_Criteria__c
                                                                WHERE PRH_Brand__c IN:iconicBrandIds
                                                                AND PRH_Collect__r.PRH_Active__c = true
                                                                AND PRH_Collect__r.PRH_Iconic_Account__r.PRH_Account_Country__c=:country
                                                                AND PRH_Brand__r.PRH_Active__c = true
                                                                AND PRH_Collect__r.PRH_Iconic_Account__r.PRH_Suppress_and_archive__c=:false
                                                                AND PRH_Presence__c = true GROUP BY PRH_Brand__c];
            
            /*List<AggregateResult> brandsWithPresence = [SELECT PRH_Brand__c,count(Id) FROM PRH_Brand_Criteria__c
                                                                WHERE PRH_Brand__c IN:iconicBrandIds
                                                                AND PRH_Account__r.PRH_Account_Country__c=:country
                                                                AND PRH_Account__r.PRH_Suppress_and_archive__c=:false
                                                                AND PRH_Presence__c = true GROUP BY PRH_Brand__c];*/
            
            system.debug('presenceCountInBrand, brandsWithPresence = '+brandsWithPresence);

            for (AggregateResult ar:brandsWithPresence) {
                brandsWithPresenceMap.put((Id) ar.get('PRH_Brand__c'),(Integer) ar.get('expr0'));
                system.debug('presenceCountInBrand, ar = '+ar);
            }
        }

        return brandsWithPresenceMap;
    } //end presenceCountInBrand()

    /* method for getting the current count of presence based on the current user's country */
    public void renderUpdate() {
        saveAndCancelRendered = true;

        Set<String> usersPermission = PRH_Competitor_Brand_Controller.setPermissionMethod(UserInfo.getUserId());
        Set<String> permissionSetup = new Set<String>();

        //for disabling objective fields depending on user's permissions
        for (String p : usersPermission) {
            
            if (p == 'PRH_Iconic_Platform_Pernod') {
                permissionSetup.add('PRH_Luxury_Account_Pernod');
            }

            if (p == 'PRH_Iconic_Platform_Ricard') {
                permissionSetup.add('PRH_Luxury_Account_Ricard');
            }
        }

        rendered = false;
        objectiveSet = new Set<PRH_Objectives__c>();
        brandCriteriaSet = new Set<PRH_Brand_Criteria__c>();
        brandsWithPresenceMap = new Map<Id,Integer>();
        orderBySequenceMap = new Map<Integer,PRH_Objectives__c>();

        brandCriteriaList = retrieveBrands(selectedCountry);
                    
        brandCriteriaSet.addAll(brandCriteriaList);

        brandsWithPresenceMap = presenceCountInBrand(brandCriteriaSet,selectedCountry);

        List<Id> getBrandList = new List<Id>();

        for (ObjectiveWrapperClass objectWrap: objectiveWrapList) {           
            //get all brands for permission to edit objective field processing
            getBrandList.add(objectWrap.objectiveObj.PRH_Iconic_Brand__c);
            
            objectWrap.objectiveObj.PRH_Presence__c = 
            (brandsWithPresenceMap.get(objectWrap.objectiveObj.PRH_Iconic_Brand__c) == null) ? 0 : brandsWithPresenceMap.get(objectWrap.objectiveObj.PRH_Iconic_Brand__c);
        }

        //permission processing
        List<PRH_Brand_Luxury_Brand__c> brandRecordTypesList = [SELECT Id, RecordType.DeveloperName 
                                                                FROM PRH_Brand_Luxury_Brand__c
                                                                WHERE Id IN:getBrandList];
        Map<Id,String> brandRecordTypesMap = new Map<Id,String>();

        for (PRH_Brand_Luxury_Brand__c b:brandRecordTypesList) {
            brandRecordTypesMap.put(b.Id,b.RecordType.DeveloperName);
        }

        List<ObjectiveWrapperClass> newObjectiveWrapList = new List<ObjectiveWrapperClass>();

        for (ObjectiveWrapperClass objectWrap: objectiveWrapList) {
            Boolean permitted = true;

            //do not process if user is an administrator
            if (!usersPermission.contains('PRH_Iconic_Platform_PR_Holding_Admin')) {
                if (brandRecordTypesMap.containsKey(objectWrap.objectiveObj.PRH_Iconic_Brand__c)) {
                    permitted = permissionSetup.contains(brandRecordTypesMap.get(objectWrap.objectiveObj.PRH_Iconic_Brand__c));
                }
            }

            newObjectiveWrapList.add(new ObjectiveWrapperClass(objectWrap.objectiveObj,permitted));
        }

        objectiveWrapList.clear();
        objectiveWrapList = newObjectiveWrapList.clone();

    } //end renderUpdate()

    /* redirect to page of objectives */
    public PageReference doCancel() {
        PageReference pageRef = Page.PRH_Objective_NewEdit_Page;
        String tabname = ApexPages.currentPage().getParameters().get('sfdc.tabName');
        pageRef.getParameters().put('sfdc.tabName',tabname);
        pageRef.setRedirect(true);

        return pageRef;
    } //end doCancel()

    /* saving objectives */
    public void saveObjects() {       
        try {
            List<PRH_Objectives__c> upsertObjectivesList = new List<PRH_Objectives__c>();
            outletCount = retrieveOutletCount(selectedCountry);

            for (ObjectiveWrapperClass objectWrap: objectiveWrapList) {
                PRH_Objectives__c obj = new PRH_Objectives__c();
                obj.Id = objectWrap.objectiveObj.Id;
                obj.PRH_Iconic_Brand__c = objectWrap.objectiveObj.PRH_Iconic_Brand__c;
                obj.PRH_Country__c = objectWrap.objectiveObj.PRH_Country__c;
                obj.PRH_Presence__c = objectWrap.objectiveObj.PRH_Presence__c;
                obj.PRH_Objective__c = objectWrap.objectiveObj.PRH_Objective__c;
                obj.PRH_Number_of_Outlets__c = outletCount;
                obj.PRH_Last_Modified_Date__c = System.now().format('MMMMM dd, yyyy');
                upsertObjectivesList.add(obj);
            }

            upsert upsertObjectivesList;
            dateModified = upsertObjectivesList[0].PRH_Last_Modified_Date__c;
            rendered = true;
            saveAndCancelRendered = false;

            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.INFO,'Objectives successfully updated.');
            ApexPages.addMessage(msg);
        } catch(Exception e) {
            System.Debug('### error:'+ e.getMessage());
            System.Debug('### error:'+ e.getLineNumber());
            System.Debug('### error:'+ e.getStackTraceString());

            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.WARNING,''+e);
            ApexPages.addMessage(msg);
        }
        
    } //end saveObjects()

    /* wrapper class */
    public class ObjectiveWrapperClass {
        public PRH_Objectives__c objectiveObj {get;set;}
        public Boolean isPermitted {get;set;}
        /* wrapper class constructor */
        public ObjectiveWrapperClass(PRH_Objectives__c objParam,Boolean isPermittedParam) {

            objectiveObj = new PRH_Objectives__c(); 
            objectiveObj.Id = objParam.Id;
            objectiveObj.PRH_Country__c = objParam.PRH_Country__c;
            objectiveObj.PRH_Iconic_Brand__c = objParam.PRH_Iconic_Brand__c;
            objectiveObj.PRH_Presence__c = objParam.PRH_Presence__c;
            objectiveObj.PRH_Objective__c = objParam.PRH_Objective__c;
            isPermitted = isPermittedParam;
        } //end constructors wrapper class
   }//end wrapper class

}//end class