/***************************************************************************************************************************
 * Name:        ASI_CRM_CN_SeasonCalendarPage_Ctrl
 * Description:
 *
 * Version History
 * Date             Developer               Comments
 * *************************************************************************************************************************
 * 2019-07-16       Wilson Chow             Created
 ***************************************************************************************************************************/

global class ASI_CRM_CN_SeasonCalendarPage_Ctrl {

    public static List<String> getRegionPicklist() {
        // Get the object type of the SObject
        Schema.SObjectType seasonObjType = ASI_CRM_Season__c.getSObjectType();

        // Describe the SObject using its object type.
        Schema.DescribeSObjectResult seasonObjDescribe = seasonObjType.getDescribe();

        // Get a map of fields for the SObject
        Map<String, Schema.SObjectField> seasonFieldMap = seasonObjDescribe.fields.getMap();

        List<String> result = new List<String>();
        result.add('All');

        List<Schema.PicklistEntry> values = seasonFieldMap.get('ASI_CRM_Region__c').getDescribe().getPickListValues();

        for (Schema.PicklistEntry option: values) {
            result.add(option.getValue());
        }

        return result;
    }

    public static List<String> getStatusPicklist() {
        // Get the object type of the SObject
        Schema.SObjectType seasonObjType = ASI_CRM_Season__c.getSObjectType();

        // Describe the SObject using its object type.
        Schema.DescribeSObjectResult seasonObjDescribe = seasonObjType.getDescribe();

        // Get a map of fields for the SObject
        Map<String, Schema.SObjectField> seasonFieldMap = seasonObjDescribe.fields.getMap();

        List<String> result = new List<String>();

        List<Schema.PicklistEntry> values = seasonFieldMap.get('ASI_CRM_Status__c').getDescribe().getPickListValues();

        for (Schema.PicklistEntry option: values) {
            result.add(option.getValue());
        }

        return result;
    }

    global class event{
        public string id {set;get;}
        public string seasonId {set;get;}
        public String text {set;get;}
        public String start_date {set;get;}
        public String end_date {set;get;}
        public String details {set;get;}
    
        global event(){

        }
    }
    
    global class events{
        public event[] wholelist {set;get;}        
        
        global events(){
            
            
        }
    }

    private static Date parseStr2Date(String dateStr) {
        if(String.isBlank(dateStr)) {
            return null;
        }
        return Date.valueOf(dateStr);
    }

    private static List<String> parseStr2StrList(String jsonStr) {
        if(String.isBlank(jsonStr)) {
            return null;
        }
        return (List<String>)System.JSON.deserialize(jsonStr, List<String>.class);
    }

    private static List<ASI_CRM_Season__c> getSeasonData(
            Date startDate,
            Date endDate,
            List<String> regionList,
            String status) {

        system.debug('getSeasonData start');

        String queryStr = 'SELECT Id, Name, ASI_CRM_Region__c, ASI_CRM_Status__c, ASI_CRM_Start_Date__c, ASI_CRM_End_Date__c ' +
                'FROM ASI_CRM_Season__c';

        String filter = '';
        String operator = ' AND ';

        if(String.isNotBlank(status)) {
            filter += operator + 'ASI_CRM_Status__c=:status';
        }

        List<String> tmpRegionList = null;
        if(regionList != null && regionList.size() > 0) {
            filter += operator + 'ASI_CRM_Region__c IN :regionList';
        }
        else {
            tmpRegionList = getRegionPicklist();
            filter += operator + 'ASI_CRM_Region__c NOT IN :tmpRegionList';
        }

        if(startDate != null && endDate != null) {
            filter += operator + '((ASI_CRM_Start_Date__c<=:startDate AND ASI_CRM_End_Date__c>=:endDate) ' +
                    'OR (ASI_CRM_Start_Date__c>=:startDate AND ASI_CRM_End_Date__c<=:endDate) ' +
                    'OR (ASI_CRM_Start_Date__c<=:startDate AND ASI_CRM_End_Date__c<=:endDate AND ASI_CRM_End_Date__c>=:startDate) ' +
                    'OR (ASI_CRM_Start_Date__c>=:startDate AND ASI_CRM_End_Date__c>=:endDate AND ASI_CRM_Start_Date__c<=:endDate))';
        }

        if(String.isNotBlank(filter)) {
            system.debug('filter:' + filter);
            queryStr += ' WHERE ' + filter.replaceFirst(operator, '');
        }

        // default sorted by start date in ascending order
        queryStr += ' ORDER BY ASI_CRM_Start_Date__c ASC LIMIT 2000';
        system.debug('queryStr:' + queryStr);

        List<ASI_CRM_Season__c> seasonList = Database.query(queryStr);

        system.debug('getSeasonData end');
        return seasonList;
    }

    @RemoteAction
    global static String getEventData(
            String startDateStr,
            String endDateStr,
            String regionListStr,
            String statusStr) {

        system.debug('getEventData start');
        JSONGenerator gen = JSON.createGenerator(true);
            
        events eventList = new events();
        eventList.wholelist = new event[]{};      

        // default date = current month
        Date startDate = System.today().toStartOfMonth();
        if(String.isNotBlank(startDateStr)) {
            startDate = parseStr2Date(startDateStr);
            system.debug('startDate:' + startDate);
        }

        Date endDate = startDate.addDays(Date.daysInMonth(startDate.year(), startDate.month()) - 1);
        if(String.isNotBlank(endDateStr)) {
            endDate = parseStr2Date(endDateStr);
            system.debug('endDate:' + endDate);
        }

        String status = 'Active';
        if(String.isNotBlank(statusStr)) {
            status = statusStr;
            system.debug('status:' + status);
        }

        List<String> regionList = null;
        if (String.isNotBlank(regionListStr)) {
            system.debug('regionListStr:' + regionListStr);
            regionList = parseStr2StrList(regionListStr);
            system.debug('regionList:' + regionList);
        }

//        Map<String, List<String>> regionDateMap = new Map<String, List<String>>();
        Map<String, Map<String, Id>> dateRegionIdMap = new Map<String, Map<String, Id>>();

        List<ASI_CRM_Season__c> seasonList =
                getSeasonData(startDate, endDate, regionList, status);

        if(seasonList.size() > 0) {
            for (ASI_CRM_Season__c season : seasonList) {

                Date seasonStartDate = season.ASI_CRM_Start_Date__c;
                Date seasonEndDate = season.ASI_CRM_End_Date__c;
                String seasonRegion = season.ASI_CRM_Region__c;
                Id seasonId = season.Id;

                while (seasonStartDate <= seasonEndDate) {
                    String seasonFormattedStartDateStr =
                            DateTime.newInstance(
                                    seasonStartDate,
                                    Time.newInstance(0, 0, 0, 0)).format('MM/dd/yyyy');

                    /*
                    if (!regionDateMap.containsKey(seasonFormattedStartDateStr)) {
                        regionDateMap.put(seasonFormattedStartDateStr, new List<String>());
                    }
                    List<String> regionListPerDate = regionDateMap.get(seasonFormattedStartDateStr);
                    if(!regionListPerDate.contains(seasonRegion)) {
                        regionListPerDate.add(seasonRegion);
                        regionDateMap.put(seasonFormattedStartDateStr, regionListPerDate);
                    }
                    */

                    if(!dateRegionIdMap.containsKey(seasonFormattedStartDateStr)) {
                        dateRegionIdMap.put(seasonFormattedStartDateStr, new Map<String, Id>());
                    }
                    Map<String, Id> regionIdMap = dateRegionIdMap.get(seasonFormattedStartDateStr);
                    regionIdMap.put(seasonRegion, seasonId);
                    dateRegionIdMap.put(seasonFormattedStartDateStr, regionIdMap);

                    seasonStartDate = seasonStartDate.addDays(1);
                }
            }
        }

        /*
        if(regionDateMap.size() > 0) {
            system.debug('construct event list start');
            Integer regionPicklistSize = getRegionPicklistSize();
            List<event> tmpEventList = new List<event>();

            for(String dateKey: regionDateMap.keySet()) {
                List<String> regionListPerDate = regionDateMap.get(dateKey);

                for(String region: regionListPerDate) {
                    event tmpEvent = new event();
                    tmpEvent.start_date = dateKey;
                    tmpEvent.end_date = dateKey;
                    tmpEvent.text = region;
                    tmpEventList.add(tmpEvent);
                }
            }
            */

        if(dateRegionIdMap.size() > 0) {
            system.debug('construct event list start');
            List<event> tmpEventList = new List<event>();

            for(String dateKey: dateRegionIdMap.keySet()) {
                Map<String, Id> regionIdMap = dateRegionIdMap.get(dateKey);

                for(String regionKey: regionIdMap.keySet()) {
                    Id seasonId = regionIdMap.get(regionKey);

                    event tmpEvent = new event();
                    tmpEvent.start_date = dateKey;
                    tmpEvent.end_date = dateKey;
                    tmpEvent.text = regionKey;
                    tmpEvent.seasonId = '' + seasonId;
                    tmpEventList.add(tmpEvent);
                }
            }

            eventList.wholelist = tmpEventList;
            system.debug('tmpEventList:' + tmpEventList);
            system.debug('tmpEventList size:' + tmpEventList.size());
            system.debug('construct event list end');
        }

        gen.writeStartObject();
        gen.writeFieldName('Event');
        gen.writeObject(eventList);                
        gen.writeEndObject();
        system.debug('getEventData end');

        return gen.getAsString();
    }

    @RemoteAction
    global static void saveSeasonData(
            String startDateStr,
            String endDateStr,
            String regionListStr) {

        system.debug('saveSeasonData start');
        Date startDate = null;
        if(String.isNotBlank(startDateStr)) {
            startDate = parseStr2Date(startDateStr);
            system.debug('startDate:' + startDate);
        }

        Date endDate = null;
        if(String.isNotBlank(endDateStr)) {
            endDate = parseStr2Date(endDateStr);
            system.debug('endDate:' + endDate);
        }

        List<String> regionList = null;
        if (String.isNotBlank(regionListStr)) {
            system.debug('regionListStr:' + regionListStr);
            regionList = parseStr2StrList(regionListStr);
            system.debug('regionList:' + regionList);
        }

        JSONException jEx = new JSONException();
        if(startDate == null) {
            system.debug('Missing start date');
            jEx.setMessage('Missing start date');
            throw jEx;
        }
        if(endDate == null) {
            system.debug('Missing end date');
            jEx.setMessage('Missing end date');
            throw jEx;
        }
        if(regionList == null || regionList.size() == 0) {
            system.debug('Missing regions');
            jEx.setMessage('Missing regions');
            throw jEx;
        }

        List<ASI_CRM_Season__c> seasonList = new List<ASI_CRM_Season__c>();
        String status = 'Active';

        List<ASI_CRM_Season__c> overlappedSeasonList =
                getSeasonData(startDate, endDate, regionList, status);
        if(overlappedSeasonList != null && overlappedSeasonList.size() > 0) {
            DmlException olEx = new DmlException();
            olEx.setMessage('Failed to save season. Details: Season will be overlapped from '
                    + startDateStr + ' to ' + endDateStr + ' in region(' + String.join(regionList,', ') + ').');
            throw olEx;
        }

        try{
            for(String region: regionList) {
                ASI_CRM_Season__c season = new ASI_CRM_Season__c();
                season.ASI_CRM_Region__c = region;
                season.ASI_CRM_Status__c = status;
                season.ASI_CRM_Start_Date__c = startDate;
                season.ASI_CRM_End_Date__c = endDate;

                seasonList.add(season);
            }

            if(seasonList.size() > 0) {
                system.debug('seasonList.size():' + seasonList.size());
                insert seasonList;
            }
        }
        /*
        catch(DmlException dEx) {
            system.debug('throw dml exception');
            Integer numOfError = dEx.getNumDml();
            for (Integer i = 0; i < numOfError; i++) {
                sObject errorSObj = seasonList.get(dEx.getDmlIndex(i));
                errorSObj.addError(dEx.getDmlMessage(i));
            }
        }
        */
        catch(Exception e) {
            system.debug('throw exception');
            DmlException dmlEx = new DmlException();
            dmlEx.setMessage('Failed to save season. Details:' + e.getMessage());
            throw dmlEx;
        }

        system.debug('saveSeasonData end');
    }

    // testing purpose
    @RemoteAction
    global static void deleteSeasonData(
            String startDateStr,
            String endDateStr,
            String regionListStr,
            String statusStr) {
        system.debug('deleteSeasonData start');

        Date startDate = null;
        if(String.isNotBlank(startDateStr)) {
            startDate = parseStr2Date(startDateStr);
            system.debug('startDate:' + startDate);
        }

        Date endDate = null;
        if(String.isNotBlank(endDateStr)) {
            endDate = parseStr2Date(endDateStr);
            system.debug('endDate:' + endDate);
        }

        String status = 'Active';
        if(String.isNotBlank(statusStr)) {
            status = statusStr;
            system.debug('status:' + status);
        }

        List<String> regionList = null;
        if (String.isNotBlank(regionListStr)) {
            system.debug('regionListStr:' + regionListStr);
            regionList = parseStr2StrList(regionListStr);
            system.debug('regionList:' + regionList);
        }

        List<ASI_CRM_Season__c> seasonList =
                getSeasonData(startDate, endDate, regionList, status);

        system.debug('seasonList size:' + seasonList.size());
        delete seasonList;

        system.debug('deleteSeasonData end');
    }
}