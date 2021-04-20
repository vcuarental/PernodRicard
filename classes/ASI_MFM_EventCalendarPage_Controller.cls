global class ASI_MFM_EventCalendarPage_Controller {    
    
    String[] brands = new String[]{};
    String[] subBrands = new String[]{};
    
    String[] channels = new String[]{};
    
    String[] divisions = new String[]{};    
    String[] eventTypes = new String[]{};
    String[] regions = new String[]{}; 
    
            
    public PageReference test() {
        return null;
    }
    
    public string getReportID(){
        return (String)ASI_MFM_Event_Report__c.getInstance().ASI_MFM_Event_Outlet_Listing_Calendar_ID__c;
    }
     
    public List<SelectOption> getBrandItems() {
        List<SelectOption> options = new List<SelectOption>();
        
        Map<String, String> distinctBrandList = new Map<String, String>();
        
        for(ASI_MFM_Event_Sub_Brand__c eventSubBrand :[SELECT ASI_MFM_Sub_brand__r.ASI_MFM_Brand__r.ASI_MFM_Brand_Description__c FROM ASI_MFM_Event_Sub_Brand__c])
        {
            distinctBrandList.put(eventSubBrand.ASI_MFM_Sub_brand__r.ASI_MFM_Brand__r.ASI_MFM_Brand_Description__c, 
            eventSubBrand.ASI_MFM_Sub_brand__r.ASI_MFM_Brand__r.ASI_MFM_Brand_Description__c);
        }
        
        options.add(new SelectOption('All', 'All'));
        for (String brand : distinctBrandList.values())
        {                   
            if (brand != null)
                options.add(new SelectOption(brand, brand));
        }                      
        return options;
    }
    public List<SelectOption> getSubBrandItems() {
        List<SelectOption> options = new List<SelectOption>();
        
        Map<String, String> distinctSubBrandList = new Map<String, String>();
        
        for(ASI_MFM_Event_Sub_Brand__c eventSubBrand :[SELECT ASI_MFM_Sub_brand__r.ASI_MFM_Sub_brand_Description__c FROM ASI_MFM_Event_Sub_Brand__c])
        {
            distinctSubBrandList.put(eventSubBrand.ASI_MFM_Sub_brand__r.ASI_MFM_Sub_brand_Description__c, 
            eventSubBrand.ASI_MFM_Sub_brand__r.ASI_MFM_Sub_brand_Description__c);
        }
        
        options.add(new SelectOption('All', 'All'));
        for (String subBrand : distinctSubBrandList.values())
        {                   
            if (subBrand != null)
                options.add(new SelectOption(subBrand, subBrand));
        }                      
        return options;
    }
    
    public List<SelectOption> getChannelItems() {
        List<SelectOption> options = new List<SelectOption>();
        
        Map<String, String> distinctChannelList = new Map<String, String>();
        
        for(ASI_MFM_Event_Sub_Channel__c eventSubChannel :[SELECT ASI_MFM_Sub_Channel__r.ASI_MFM_Channel__c FROM ASI_MFM_Event_Sub_Channel__c])
        {
            distinctChannelList.put(eventSubChannel.ASI_MFM_Sub_Channel__r.ASI_MFM_Channel__c, 
            eventSubChannel.ASI_MFM_Sub_Channel__r.ASI_MFM_Channel__c);
        }
        
        options.add(new SelectOption('All', 'All'));
        for (String channel : distinctChannelList.values())
        {                   
            if (channel != null)
                options.add(new SelectOption(channel, channel));
        }                      
        return options;
    }
     
     public List<SelectOption> getDivisionItems() {
        List<SelectOption> options = new List<SelectOption>();
        
        Map<String, String> distinctDivisionList = new Map<String, String>();
        
        for(ASI_MFM_Event_Outlet__c eventOutlet :[SELECT ASI_MFM_Outlet__r.ASI_HK_CRM_Location__c FROM ASI_MFM_Event_Outlet__c])
        {
            distinctDivisionList.put(eventOutlet.ASI_MFM_Outlet__r.ASI_HK_CRM_Location__c, 
            eventOutlet.ASI_MFM_Outlet__r.ASI_HK_CRM_Location__c);
        }
        
        options.add(new SelectOption('All', 'All'));
        for (String divisionvalue : distinctDivisionList.values())
        {                   
            if (divisionvalue != null)
                options.add(new SelectOption(divisionvalue, divisionvalue));
        }                      
        return options;
    }
     
    public List<SelectOption> getEventTypeItems() {
        List<SelectOption> options = new List<SelectOption>();
        
        Map<String, String> distinctEventTypeList = new Map<String, String>();
        
        for(ASI_MFM_Event_Outlet__c eventOutlet :[SELECT ASI_MFM_Event__r.ASI_MFM_Event_Type__c FROM ASI_MFM_Event_Outlet__c])
        {
            distinctEventTypeList.put(eventOutlet.ASI_MFM_Event__r.ASI_MFM_Event_Type__c, eventOutlet.ASI_MFM_Event__r.ASI_MFM_Event_Type__c);
        }
        
        options.add(new SelectOption('All', 'All'));
        for (String eventType : distinctEventTypeList.values())
        {                   
            if (eventType != null)
                options.add(new SelectOption(eventType, eventType));
        }                      
        return options;
    }
     
    public List<SelectOption> getRegionItems() {
        List<SelectOption> options = new List<SelectOption>();
        
        Map<String, String> distinctRegionsList = new Map<String, String>();
        
        for(ASI_MFM_Event_Outlet__c eventOutlet :[SELECT  ASI_MFM_Outlet__r.ASI_KOR_Addr_Region__c FROM ASI_MFM_Event_Outlet__c])
        {
            distinctRegionsList.put(eventOutlet.ASI_MFM_Outlet__r.ASI_KOR_Addr_Region__c, eventOutlet.ASI_MFM_Outlet__r.ASI_KOR_Addr_Region__c);
        }
        
        options.add(new SelectOption('All', 'All'));
        for (String region : distinctRegionsList.values())
        {                   
            if (region != null)
                options.add(new SelectOption(region, region));
        }                      
        return options;
    }                
      
    public String[] getBrands() {
        return brands;
    }
    public String[] getSubBrands() {
        return subBrands;
    }    
    public String[] getChannels() {
        return channels;
    }
    public String[] getDivisions() {
        return regions;
    }   
    public String[] getRegions() {
        return regions;
    }
    public String[] getEventTypes() {
        return eventTypes;
    }           
    
    public void setBrands(String[] brands) {
        this.brands = brands;
    }
    public void setSubBrands(String[] subBrands) {
        this.subBrands = subBrands;
    }     
    public void setChannels(String[] channels) {
        this.channels = channels;
    }     
    public void setDivisions(String[] divisions) {
        this.divisions = divisions;
    }    
    public void setregions(String[] regions) {
        this.regions = regions;
    }
    public void seteventTypes(String[] eventTypes) {
        this.eventTypes = eventTypes;
    }           
    
    global class event{ 
        public string id{set;get;}  
        public String text {set;get;}
        public String start_date {set;get;}
        public String end_date {set;get;}        
        public String details {set;get;} 
        public String eventOutletId {set;get;}                             
    
        global event(){
                        
        }
    }
    
    global class events{
        public event[] wholelist {set;get;}        
        
        global events(){
            
            
        }
    }       
    
    global static void checkEventDateExist(List<event> listEvents, event tempEvent){
        Boolean needToAdd = true;
        for(event e : listEvents){
            if (e.start_date == tempEvent.start_date) {
                needToAdd = false;
                e.details += tempEvent.details;
                
                if (e.eventOutletId == '') e.eventOutletId = tempEvent.eventOutletId;
                else e.eventOutletId += ',' + tempEvent.eventOutletId;
            }
        }
        
        if (needToAdd) listEvents.add(tempEvent);
    }
    
    @RemoteAction
    global static String getEventData(String selectedBrand, String selectedSubBrand, String selectedChannel, 
    String selectedDivision, String selectedEventType, String selectedRegion, String currentSelectFromDateTimeString) {
        JSONGenerator gen = JSON.createGenerator(true);
            
        events eventList = new events();
        eventList.wholelist = new event[]{};      
        
        String[] stringDate = currentSelectFromDateTimeString.split('-');
        Integer d =  Integer.valueOf(stringDate[2]);
        Integer m = Integer.valueOf(stringDate[1]);
        Integer y = Integer.valueOf(stringDate[0]);
    
        Date currentSelectFromDate = date.newInstance(y,m,d);       
        Date currentSelectToDate = currentSelectFromDate.addMonths(1);
        
        String soalString = 'SELECT id, ASI_MFM_Beginning_Date__c, ASI_MFM_End_Date__c, ASI_MFM_Event__r.Name, ASI_MFM_Outlet__c FROM ASI_MFM_Event_Outlet__c '+ 
            'WHERE (ASI_MFM_Beginning_Date__c >= :currentSelectFromDate AND ASI_MFM_Beginning_Date__c < :currentSelectToDate) ' + 
            'OR (ASI_MFM_End_Date__c >= :currentSelectFromDate AND ASI_MFM_End_Date__c < :currentSelectToDate) ' + 
            'OR (ASI_MFM_End_Date__c > :currentSelectToDate AND ASI_MFM_Beginning_Date__c < :currentSelectFromDate) ';              
        
        String whereClauseOperator = 'AND ';
        
        if (selectedBrand != 'All') {           
            soalString += whereClauseOperator + 'ASI_MFM_Event__c in(SELECT ASI_MFM_Event__c FROM ASI_MFM_Event_Sub_Brand__c WHERE ASI_MFM_Sub_brand__r.ASI_MFM_Brand__r.ASI_MFM_Brand_Description__c = :selectedBrand) ';
            whereClauseOperator = 'AND ';
        }
        
        if (selectedSubBrand != 'All') {            
            soalString += whereClauseOperator + 'ASI_MFM_Event__c in(SELECT ASI_MFM_Event__c FROM ASI_MFM_Event_Sub_Brand__c WHERE ASI_MFM_Sub_brand__r.ASI_MFM_Sub_brand_Description__c = :selectedSubBrand) ';
            whereClauseOperator = 'AND ';
        }
        
        if (selectedChannel != 'All') {         
            soalString += whereClauseOperator + 'ASI_MFM_Event__c in(SELECT ASI_MFM_Event__c FROM ASI_MFM_Event_Sub_Channel__c WHERE ASI_MFM_Sub_Channel__r.ASI_MFM_Channel__c = :selectedChannel) ';
            whereClauseOperator = 'AND ';
        }
        
        if (selectedDivision != 'All') {            
            soalString += whereClauseOperator + 'ASI_MFM_Outlet__r.ASI_HK_CRM_Location__c = :selectedDivision ';
            whereClauseOperator = 'AND ';
        }   
        
        if (selectedEventType != 'All') {           
            soalString += whereClauseOperator + 'ASI_MFM_Event__r.ASI_MFM_Event_Type__c = :selectedEventType ';
            whereClauseOperator = 'AND ';
        }   
        
        if (selectedRegion != 'All') {          
            soalString += whereClauseOperator + 'ASI_MFM_Outlet__r.ASI_KOR_Addr_Region__c = :selectedRegion ';
            whereClauseOperator = 'AND ';
        }    
        
        List<ASI_MFM_Event_Outlet__c> eventOutlets = Database.query(soalString);
        for(ASI_MFM_Event_Outlet__c eventOutlet : eventOutlets){
            
            date eventStartDate =  eventOutlet.ASI_MFM_Beginning_Date__c;
            date eventEndDate =  eventOutlet.ASI_MFM_End_Date__c.addDays(1);
            date startDate =  eventOutlet.ASI_MFM_Beginning_Date__c;
            date endDate =  startDate.addDays(1);
            
            do {                                
                event tempEvent = new event();
                tempEvent.start_date = startDate.month() + '/' +
                startDate.day() + '/' + 
                startDate.year();
                            
                tempEvent.end_date = endDate.month() + '/' +
                endDate.day() + '/' +
                endDate.year();
                
                tempEvent.details = '<br/>' + eventOutlet.ASI_MFM_Event__r.Name;
                tempEvent.eventOutletId = eventOutlet.id;
                
                checkEventDateExist(eventList.wholelist, tempEvent);    
                
                startDate = startDate.addDays(1);
                endDate = endDate.addDays(1);    
            }while (endDate <= eventEndDate);                                                       
        }
        gen.writeStartObject();
        gen.writeFieldName('Event');
        gen.writeObject(eventList);                
        gen.writeEndObject();
                       
        return gen.getAsString();
    }
    
}