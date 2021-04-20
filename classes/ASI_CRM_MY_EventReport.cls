public with sharing class ASI_CRM_MY_EventReport {
    
    public List<EventReport> eventList { get; set; }
    public String name { get; set; }
    public String activity {get; set;}
    public Date startdate { get; set; }
    public Date enddate { get; set; }
    
    public String branch  { get; set; }
    public String keysearch { get; set; }
    
    public ASI_CRM_EVENTCapture__c searchRec{ get; set; }
    
    public String zipFileName {get; set;}
    
    public List<SelectOption> getActivitys() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('Activity','All'));
        options.add(new SelectOption('PRM Activity','PRM Activity'));
        options.add(new SelectOption('Competitor Activity','Competitor Activity'));
        
        return options;
    }
    
    public List<SelectOption> getBranchlist() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','All'));
        options.add(new SelectOption('PRM EAST MSIA','PRM EAST MSIA'));
        options.add(new SelectOption('PRM IPOH','PRM IPOH'));
        options.add(new SelectOption('PRM JOHOR BARU','PRM JOHOR BARU'));
        options.add(new SelectOption('PRM KUALA LUMPUR','PRM KUALA LUMPUR'));
        options.add(new SelectOption('PRM KUANTAN','PRM KUANTAN'));
        options.add(new SelectOption('PRM MALACCA','PRM MALACCA'));
        options.add(new SelectOption('PRM PENANG','PRM PENANG'));
        return options;
    }
    
    public ASI_CRM_MY_EventReport(ApexPages.StandardSetController controller) {
        //ApexPages.currentPage().getParameters().get('id')
        eventList = new List<EventReport> ();
        
        searchRec = new ASI_CRM_EVENTCapture__c();
        name = ApexPages.currentPage().getParameters().get('name');
        activity = ApexPages.currentPage().getParameters().get('activity');
        String ispdf = ApexPages.currentPage().getParameters().get('pdf');
        if(ispdf == 'true') {
            String dateTo = ApexPages.currentPage().getParameters().get('start');
            String dateFrom = ApexPages.currentPage().getParameters().get('end');
            keysearch = ApexPages.currentPage().getParameters().get('key');
            branch = ApexPages.currentPage().getParameters().get('branch');
            loadEvents(true, dateTo, dateFrom);
        }
        
        DateTime d = datetime.now();
        zipFileName = d.year() + '' + d.month() + '' + d.day() + '' + d.hour() + '' + d.minute() + '.zip';
        //var fn  = d.getFullYear() +''+ d.getMonth() +''+ d.getDate()+''+ d.getHours()+''+ d.getMinutes()+'.zip';
    }
    
    public PageReference searchEvents() {
        return loadEvents(false); 
    }
    
    private PageReference loadEvents(boolean isExcel) {
       return loadEvents(isExcel, '', '');
    }
    private PageReference loadEvents(boolean isExcel, String datefrom, String dateto) {
        
        system.debug('startDate='+startdate);
        system.debug('endDate='+enddate);
        system.debug('isExcel='+isExcel);
        
        String sqlQuery = 'SELECT Id, Name, ASI_CRM_MY_PRMorCompetitor__c, ASI_CRM_MY_ActivationStartDate__c, '+
            ' Owner.Name, LastModifiedDate, ASI_CRM_MY_Remarks__c, ASI_CRM_MY_ActivationEndDate__c, '+
            ' ASI_CRM_MY_Outlet__r.Name, ASI_CRM_MY_Subbrand__r.Name, ASI_CRM_MY_Outlet__r.ASI_CRM_MY_BranchOpt__c, '+
            ' ASI_CRM_MY_TypeActivation__c '+
            ' FROM ASI_CRM_EVENTCapture__c WHERE IsDeleted=false';
        
        String sqlCond = '  ';
        if( name.trim()!='' ) {
            sqlCond += ' AND Name LIKE \'%'+name.trim() +'%\'';
        } 
        if( activity.trim()=='PRM Activity' || activity.trim()=='Competitor Activity' ) {
            sqlCond += ' AND ASI_CRM_MY_PRMorCompetitor__c =  \''+activity.trim() +'\'';
        } 

        if (startdate != null ) {
            sqlCond += ' AND ASI_CRM_MY_ActivationStartDate__c >= '+ string.valueOf(startdate).replace(' 00:00:00','');
        }
        
        if (enddate != null ) {
            sqlCond += ' AND ASI_CRM_MY_ActivationEndDate__c <= '+ string.valueOf(enddate).replace(' 00:00:00','');
        }
        
        //CR20180803
        // ‘promotion mechanic’ ,
        if(branch!=null && branch.trim()!='') {
            sqlCond += ' AND ASI_CRM_MY_Outlet__r.ASI_CRM_MY_BranchOpt__c = \''+ branch +'\' ';
        }
        if(keysearch!=null && keysearch.trim()!='') {
            //on sub brand, event name, remarks, promotion mechanics
            sqlCond += ' AND (Name LIKE \'%'+keysearch.trim() +'%\' OR '+
                ' ASI_CRM_MY_PromotionMechanics__c LIKE \'%'+keysearch.trim() +'%\' OR '+
                ' ASI_CRM_MY_Remarks__c LIKE \'%'+keysearch.trim() +'%\' OR '+
                ' ASI_CRM_MY_BrandOther__c LIKE \'%'+keysearch.trim() +'%\' OR '+
                ' ASI_CRM_MY_Subbrand__r.Name LIKE \'%'+keysearch.trim() +'%\' OR '+
                ' ASI_CRM_MY_Outlet__r.Name LIKE \'%'+keysearch.trim() +'%\' OR '+
                ' ASI_CRM_MY_Outlet__r.ASI_CRM_MY_BranchOpt__c LIKE \'%'+keysearch.trim() +'%\' OR '+
                ' Owner.Name LIKE \'%'+keysearch.trim() +'%\' OR '+
                ' ASI_CRM_MY_TypeActivation__c LIKE \'%'+keysearch.trim() +'%\' '+
                ')';
        }
        
        sqlQuery = sqlQuery + sqlCond;
        
        List<ASI_CRM_EVENTCapture__c> eventActList = Database.query(sqlQuery);
        
        List<Attachment> eventAttlist = loadAttachment(sqlCond);
        
        eventList = new List<EventReport> ();
        
        for(ASI_CRM_EVENTCapture__c event : eventActList) {
            String lastDate = event.LastModifiedDate.format('yyyy-MM-dd HH:mm');
            
            String tmpOutlet = event.ASI_CRM_MY_Outlet__r.Name;
            //if(tmpOutlet.containsIgnoreCase('Dummy Cold Call')) {
            if(event.ASI_CRM_MY_Remarks__c!=null) {
                if(isExcel==false)
                    tmpOutlet += '<br/>' + event.ASI_CRM_MY_Remarks__c;
            } else {
                event.ASI_CRM_MY_Remarks__c = '';
            }
            
            String imagepre = (String.valueOf(event.ID));
            
            
            EventReport aReport = new EventReport (imagepre.substring(12),//event.ID,
                                                   event.Name,
                                                   event.ASI_CRM_MY_PRMorCompetitor__c,
                                                   event.ASI_CRM_MY_ActivationStartDate__c,
                                                   event.ASI_CRM_MY_ActivationEndDate__c,
                                                   tmpOutlet,
                                                   event.ASI_CRM_MY_Outlet__r.ASI_CRM_MY_BranchOpt__c,
                                                   event.ASI_CRM_MY_Subbrand__r.Name,
                                                   event.ASI_CRM_MY_TypeActivation__c,
                                                   event.Owner.Name,
                                                   lastDate,
                                                   event.ASI_CRM_MY_Remarks__c
                                                  );
            
            List<Attachment> tmpAtt = new List<Attachment>();
            List<String> tmpAttId = new List<String>();
            
            for(Attachment att : eventAttlist) {
                if(att.ParentId == event.Id){
                    tmpAtt.add(att);
                    tmpAttId.add(att.Id);
                }
            }
            
            aReport.EventAttachment = tmpAtt;
            aReport.EventAttachmentId = tmpAttId;
            
            eventList.add(aReport);
        }
        
        
        return null;
    }
    
    //export to pdf
    public PageReference getEventsReport() {
        PageReference pdf = Page.ASI_CRM_MY_EventReportPdf;
        
        pdf.getParameters().put('name', name);
        pdf.getParameters().put('activity', activity);
        pdf.getParameters().put('key', keysearch);
       	pdf.getParameters().put('start', String.valueOf(startDate));
       	pdf.getParameters().put('end',String.valueOf( endDate));
        pdf.getParameters().put('branch', branch);
        pdf.getParameters().put('pdf', 'true');
        pdf.setRedirect(true);
        
        //loadEvents(true);
        return pdf;
    }
    
    //export to excel
    public PageReference getEventsExcel() {
        PageReference pdf = Page.ASI_CRM_MY_EventReportExcel;
        
        pdf.getParameters().put('name', name);
        pdf.getParameters().put('activity', activity);
        //pdf.getParameters().put('start', startDate);
        //pdf.getParameters().put('end', endDate);
        pdf.getParameters().put('pdf', 'true');
        pdf.setRedirect(false);
        
        loadEvents(true);
        return pdf;
    }
    
    public List<Attachment> loadAttachment(String sqlCond) {
        String sqlQuery = 'SELECT Id, Name, ParentId, Body FROM Attachment WHERE IsDeleted=false '+
            ' AND ParentId IN (SELECT Id FROM ASI_CRM_EVENTCapture__c WHERE IsDeleted=false '+sqlCond+')';
        
        
        List<Attachment>  eventAttlist = Database.query(sqlQuery);
        
        return eventAttlist;
    }
    
    @RemoteAction
    public static List<Attachment> getAttachments() {
        
        String sqlQuery = 'SELECT Id, Name, ParentId, Body FROM Attachment WHERE IsDeleted=false '+
            ' AND ParentId IN (SELECT Id FROM ASI_CRM_EVENTCapture__c WHERE IsDeleted=false)';
        
        
        List<Attachment>  eventAttlist = Database.query(sqlQuery);
        
        
        
        return eventAttlist;
    }
    
    //download zip file with images
    @RemoteAction
    public static Map<String, String> getXMLFiles(String inname, String inactivity, String inkeys, String inbranch, String indatefrom, String indateto) {
        
        // Setup map to contain all results from this method. Will contain the generated XML files and a list of Opportunities that were used in the process.
        Map<String, String> resultsData = new Map<String, String>();
        
        String sqlQuery = 'SELECT Id, Name, ParentId, Body FROM Attachment WHERE IsDeleted=false '+
            ' AND ParentId IN (SELECT Id FROM ASI_CRM_EVENTCapture__c WHERE IsDeleted=false ';
        
        
        String sqlCond = '  ';
        if( inname.trim()!='' ) {
            sqlCond += ' AND Name LIKE \'%'+inname.trim() +'%\'';
        } 
        if( inactivity.trim()=='PRM Activity' || inactivity.trim()=='Competitor Activity' ) {
            sqlCond += ' AND ASI_CRM_MY_PRMorCompetitor__c =  \''+inactivity.trim() +'\'';
        } 
        
        if (indatefrom != null && indatefrom != '') {
            sqlCond += ' AND ASI_CRM_MY_ActivationStartDate__c >= '+ indatefrom;
        }
        //16/08/2018
        if (indateto != null && indateto != '') {
            sqlCond += ' AND ASI_CRM_MY_ActivationEndDate__c <= '+ indateto;
        }
        
        //CR20180803
        // ‘promotion mechanic’ ,
        if(inbranch!=null && inbranch.trim()!='') {
            sqlCond += ' AND ASI_CRM_MY_Outlet__r.ASI_CRM_MY_BranchOpt__c = \''+ inbranch +'\' ';
        }
        if(inkeys!=null && inkeys.trim()!='') {
            //on sub brand, event name, remarks, promotion mechanics
            sqlCond += ' AND (Name LIKE \'%'+inkeys.trim() +'%\' OR '+
                ' ASI_CRM_MY_PromotionMechanics__c LIKE \'%'+inkeys.trim() +'%\' OR '+
                ' ASI_CRM_MY_Remarks__c LIKE \'%'+inkeys.trim() +'%\' OR '+
                ' ASI_CRM_MY_BrandOther__c LIKE \'%'+inkeys.trim() +'%\' OR '+
                ' ASI_CRM_MY_Subbrand__r.Name LIKE \'%'+inkeys.trim() +'%\' OR '+
                ' ASI_CRM_MY_Subbrand__r.Name LIKE \'%'+inkeys.trim() +'%\' OR '+
                ' ASI_CRM_MY_Outlet__r.Name LIKE \'%'+inkeys.trim() +'%\' OR '+
                ' ASI_CRM_MY_Outlet__r.ASI_CRM_MY_BranchOpt__c LIKE \'%'+inkeys.trim() +'%\' OR '+
                ' Owner.Name LIKE \'%'+inkeys.trim() +'%\' OR '+
                ' ASI_CRM_MY_TypeActivation__c LIKE \'%'+inkeys.trim() +'%\' '+
                ')';
        }
        
        sqlQuery = sqlQuery + sqlCond + ')';                                             
        
        
        List<Attachment>  eventAttlist = Database.query(sqlQuery);
        
        for(Attachment att : eventAttlist) {
            String imagepre = String.valueOf(att.parentId);
            
            String filename =    imagepre.substring(12) +'_'+att.Name;
            
            resultsData.put(filename, EncodingUtil.base64Encode(att.Body));
        }
        
        return resultsData;
    }
    
    public class EventReport {
        String ID;
        String Name;
        String Activity;
        Date StartDate;
        Date EndDate;
        String Outlet;
        String Branch;
        String Subbrand;
        String TypeActivation;
        String Salesman;
        String LastModified;
        String Remarks;
        List<Attachment> EventAttachment;
        List<String> EventAttachmentId;
        
        EventReport(String id, String name, String activity, Date startDate,
                    Date endDate, String outlet, string branch, String subbrand, String typeActivation,
                    String salesman, String lastmodified, String remarks) {
                        this.ID = id ;
                        this.Name = name;
                        this.Activity = activity;
                        this.StartDate = (startDate);
                        this.EndDate = (endDate);
                        this.Outlet = outlet;
                        this.Branch = branch;
                        this.Subbrand = subbrand;
                        this.TypeActivation = typeActivation;
                        this.Salesman = salesman;
                        this.LastModified = lastmodified;
                        this.Remarks = remarks;
                        this.EventAttachment = new List<Attachment>();
                        this.EventAttachmentId = new List<String>();
                    }
        
        public String getId() {return ID;}
        public String getName() { return Name;}
        public String getActivity() {return Activity;}
        public Date getStartDate() {return StartDate;}
        public Date getEndDate() {return EndDate;}
        public String getOutlet() {return Outlet;}
        public String getBranch() {return Branch;}
        public String getSubbrand() {return Subbrand;}
        public String getTypeActivation() {return TypeActivation;}
        public String getSalesman() {return Salesman;}
        public String getLastModified() {return LastModified;}
        public String getRemarks() {return Remarks;}
        
        public List<Attachment> getEventAttachment() {
            return EventAttachment;
        }
        public void setEventAttachment(List<Attachment> eventAtt) {
            this.EventAttachment = eventAtt;
        }
        
        public List<String> getEventAttachmentId() {
            return EventAttachmentId;
        }
        public void setEventAttachmentId(List<String> eventAttachmentId) {
            this.EventAttachmentId = eventAttachmentId;
        }
    }
    
}