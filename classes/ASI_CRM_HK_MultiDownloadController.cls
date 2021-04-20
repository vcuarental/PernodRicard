public class ASI_CRM_HK_MultiDownloadController {
    public Id PAFID {set;get;}
    public ASI_HK_CRM_Pre_Approval_Form__c PAF {get;set;}
    public string AttLink {get; set;}
    public List<interOj> CusList{get;set;}
    public ASI_CRM_HK_MultiDownloadController() {}
    public List<String> ids{get;set;}
    public integer count{get;set;}
    public string scriptvar{get;set;}
    
    public class interOj {
        public ASI_CRM_HK_Pre_Approval_Form_Customer__c cus {get; set;}
        public Boolean checked {get;set;}
    }
    
    public ASI_CRM_HK_MultiDownloadController(ApexPages.StandardController controller) {
        List<string> fields = new List<string>();
        fields.add('Name');
        fields.add('ASI_CRM_HK_Is_Channel_PAF__c');
        fields.add('ASI_HK_CRM_PAF_Customer__c');
        fields.add('ASI_HK_CRM_PAF_Customer__r.Name');
        fields.add('ASI_CRM_Short_Term_Promotion__c');
        if(!Test.isRunningTest())
        	controller.addFields(fields);
        this.PAF = (ASI_HK_CRM_Pre_Approval_Form__c)controller.getRecord();
        System.debug('-----PAF id:'+this.PAF.id);
        CusList = new List<interOj>();
        List<ASI_CRM_HK_Pre_Approval_Form_Customer__c> Customers = [SELECT id, ASI_CRM_HK_Customer__c, ASI_CRM_HK_Customer__r.Name, ASI_CRM_PA_DA__c FROM ASI_CRM_HK_Pre_Approval_Form_Customer__c WHERE ASI_CRM_HK_Pre_Approval_Form__c =: this.PAF.id ];
        for (ASI_CRM_HK_Pre_Approval_Form_Customer__c Customer : Customers) {
            interOj tmp = new interOj();
            tmp.cus = Customer;
            tmp.checked = true;
            CusList.add(tmp);
        }
        System.debug('-----Customer:'+Customers.size());
        Download();
    }
    
    public boolean Download() {
        system.debug('PAF::::' + this.PAF);
        List<ASI_CRM_HK_Pre_Approval_Form_Customer__c> PAFCList = new List<ASI_CRM_HK_Pre_Approval_Form_Customer__c>();
        List<id> customerList = new List<id>();
        Set<id> custSet = new Set<Id>();
        
        if (this.PAF!=null){
            //if (!this.PAF.ASI_CRM_Short_Term_Promotion__c)
            //	customerList.add(this.PAF.ASI_HK_CRM_PAF_Customer__c);
            system.debug(this.PAF.ASI_HK_CRM_PAF_Customer__r.Name);
            if(!Test.isRunningTest()
               && this.PAF.ASI_HK_CRM_PAF_Customer__r.Name.contains('OUTLET_') && this.PAF.ASI_CRM_Short_Term_Promotion__c) {
                PAFCList = [SELECT id, ASI_CRM_HK_Customer__c
                            , ASI_CRM_HK_Customer__r.parentId
                            FROM ASI_CRM_HK_Pre_Approval_Form_Customer__c 
                            WHERE ASI_CRM_HK_Pre_Approval_Form__c = :this.PAF.id];
            }else{
                customerList.add(this.PAF.ASI_HK_CRM_PAF_Customer__c);
            }
            //system.debug('--------------PAFCList  '+ PAFCList.size);
        }
        AttLink = '';
        //id oldID = null;
        /*
        if (PAFCList.size() > 0){
            for (ASI_CRM_HK_Pre_Approval_Form_Customer__c PACF : PAFCList){
                if ( PACF.ASI_CRM_HK_Customer__r.parentId == null){
                	customerList.add(PACF.ASI_CRM_HK_Customer__c);
                    //custSet.add(PACF.ASI_CRM_HK_Customer__c);
                } 
                else {
                    if (!custSet.contains(PACF.ASI_CRM_HK_Customer__r.parentId)){
                        customerList.add(PACF.ASI_CRM_HK_Customer__r.parentId);
                        custSet.add(PACF.ASI_CRM_HK_Customer__r.parentId);
                    }
                }
            }
        }*/
        for(Id customerID : customerList){
            AttLink += customerID + ',';
        }/*
        system.debug('CustList================'+AttLink);
        string str = AttLink;
        ids = str.split(',');
        for(String tmp:ids){
            system.debug('CustList================'+tmp);
                
            }*/
        return true;
    }
    
    public void multiDownloadBtn(){
        List<id> customerList = new List<id>();
        Set<id> custSet = new Set<Id>();
        if(!Test.isRunningTest()
           && this.PAF.ASI_HK_CRM_PAF_Customer__r.Name.contains('OUTLET_') && this.PAF.ASI_CRM_Short_Term_Promotion__c) {
            Map<id, Boolean> downloadMap= new Map<id, Boolean>();
            for (interOj tmp: CusList){
                downloadMap.put(tmp.cus.ASI_CRM_HK_Customer__c, tmp.checked);
            }
            system.debug('PAFID::::'+this.PAF.id);
            List<ASI_CRM_HK_Pre_Approval_Form_Customer__c> tmpDLList = [Select ASI_CRM_HK_Customer__c, ASI_CRM_HK_Download_Flag__c 
                                                                        ,ASI_CRM_PA_DA__c, ASI_CRM_HK_Customer__r.parentId
                                                                     from ASI_CRM_HK_Pre_Approval_Form_Customer__c
                                                                     where ASI_CRM_HK_Pre_Approval_Form__c =: this.PAF.id];
            AttLink = '';
            for (ASI_CRM_HK_Pre_Approval_Form_Customer__c cusUpdate: tmpDLList){
                if (downloadMap.containsKey(cusUpdate.ASI_CRM_HK_Customer__c)
                   && cusUpdate.ASI_CRM_HK_Download_Flag__c != downloadMap.get(cusUpdate.ASI_CRM_HK_Customer__c)){
                    cusUpdate.ASI_CRM_HK_Download_Flag__c = downloadMap.get(cusUpdate.ASI_CRM_HK_Customer__c);
                    update cusUpdate;
                }
                //if (!cusUpdate.ASI_CRM_HK_Download_Flag__c && cusUpdate.ASI_CRM_PA_DA__c == 'PA'){
                
                if (cusUpdate.ASI_CRM_HK_Download_Flag__c){
                    if ( cusUpdate.ASI_CRM_HK_Customer__r.parentId == null){
                        customerList.add(cusUpdate.ASI_CRM_HK_Customer__c);
                    } 
                    else {
                        if (!custSet.contains(cusUpdate.ASI_CRM_HK_Customer__r.parentId)){
                            customerList.add(cusUpdate.ASI_CRM_HK_Customer__r.parentId);
                            custSet.add(cusUpdate.ASI_CRM_HK_Customer__r.parentId);
                        }
                    }
                    
                    //string removeCust = cusUpdate.ASI_CRM_HK_Customer__c+',';
                    //system.debug('AttLink================'+AttLink);
                    //system.debug('removeCust================'+removeCust);
                    //AttLink.remove(removeCust);
                    //AttLink = AttLink.replace(removeCust, '');
                    
                }
            }
            for(Id customerID : customerList){
            	AttLink += customerID + ',';
        	}
            if (AttLink == '')
            	ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please select customer(s)'));
            system.debug('AttLink================'+AttLink);
        }
        
        //return true;
        
    }
    public pagereference multiDownload(){
        if (PAF.ASI_CRM_Short_Term_Promotion__c){
			return null;
        } 
        scriptvar='<script> Downlaod(); </script>';
        //PageReference pageRef = new PageReference('/apex/ASI_CRM_HK_PDFDownloadPage?id='+ this.PAF.Id+'&cid='+ this.PAF.ASI_HK_CRM_PAF_Customer__c);
        PageReference pageRef = new PageReference('/' + this.PAF.id);
        pageRef.setRedirect(true);
        system.debug('/apex/ASI_CRM_HK_PDFDownloadPage?id='+ this.PAF.Id+'&cid='+this.PAF.ASI_HK_CRM_PAF_Customer__c);
        return pageRef;
    }
    
    public pagereference Cancel() {
        PageReference redirect = new PageReference('/' + this.PAF.id); 
        return redirect;
    }
    
}