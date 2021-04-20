public without sharing class EUR_CRM_EventOverviewCtrl {
	public final Event      cEvent;
    public final sObject    objWhat        {get; set;}
    public final String     objWhatName    {get; set;}
    public final Boolean    isShowRLs      {get; set;}
    public final Boolean    isObjWhat      {get; set;}
    private Map<String, String> MAPRELATEDLIST = new Map<String, String>{
        'EUR_CRM_Account__c' => 'sales_orders__r,combinedattachments'
    };
    private Set<String>     allowedProfiles = new Set<String>{
        'eur za telesales agent'
    };

    // The extension constructor initializes the private member
    // variable mysObject by using the getRecord method from the standard
    // controller.
    public EUR_CRM_EventOverviewCtrl(ApexPages.StandardController stdCtrl) {        
        List<Event> events = [SELECT Id, WhatId FROM Event WHERE Id=:stdCtrl.getId()];
        this.cEvent = events!=null && !events.isEmpty()? events[0]: new Event();
        this.isObjWhat = String.isNotBlank(cEvent.WhatId);

        if(isObjWhat){
            this.objWhat = cEvent.WhatId.getsObjectType().newSObject(cEvent.WhatId);
            this.objWhatName = cEvent.WhatId.getsObjectType().getDescribe().getName();

            Profile p = [SELECT Id, Name FROM Profile WHERE Id = :UserInfo.getProfileId() LIMIT 1][0];
            isShowRLs = p != null && String.isNotBlank(p.Name) && allowedProfiles.contains(p.Name.toLowerCase());
        }
        if(events==null || events.isEmpty()){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'Event cannot be found.'));
        }
    }

    public Component.Apex.OutputPanel getEUAccountRelatedLists() {
        Component.Apex.OutputPanel dynOutPanel= new Component.Apex.OutputPanel();
        for(String id: populateRelLists()) {
           Component.Apex.RelatedList dynRelList = new Component.Apex.RelatedList();
           dynRelList.list = id;
           dynRelList.Subject = cEvent.WhatId;
           dynOutPanel.childComponents.add(dynRelList);
        }

        return dynOutPanel;
    }

    public List<String> populateRelLists() {
        List<String> lstRLs = new List<String>();
        List<String> lstAllowedRLs = MAPRELATEDLIST.containsKey(objWhatName)? MAPRELATEDLIST.get(objWhatName).split(','): new List<String>();
        Set<String>  setAllowedRLs = new Set<String>(lstAllowedRLs);
        if(String.isBlank(cEvent.WhatId)){return lstRLs;}
        Schema.DescribeSObjectResult scDsor = cEvent.WhatId.getsobjecttype().getDescribe();
        List<Schema.ChildRelationship> shCRls = scDsor.getChildRelationships();
        Map<String, Schema.ChildRelationship> mapSchemaRLs = new Map<String, Schema.ChildRelationship>();
        for(Schema.ChildRelationship shCRl: shCRls){
            String relName = shCRl.getRelationshipName();
            if(String.isNotBlank(relName)){
                mapSchemaRLs.put(relName.toLowerCase(), shCRl);
            }
        }

        for(String rlName: lstAllowedRLs){
            if(mapSchemaRLs.containsKey(rlName)){
                lstRLs.add(mapSchemaRLs.get(rlName).getRelationshipName());
            }
        }
        return lstRLs;
    }

}