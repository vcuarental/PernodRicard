public with sharing class LAT_BR_TransferAccountsAndUDC {    
    public Account accOldLookup {get;set;}
    public Account accNewLookup {get;set;}
    public LAT_Account__c udcNewLookup {get;set;}
    public Lat_Opportunity__c dummyOpp {get;set;}

    public List<Account> listOfAccount {get;set;}
    public List<AccountInner> listInnerAccount {get;set;}
    public Boolean selectAll {get; set;}
    
    public Boolean transferContacts {get; set;}
    public Boolean transferOpps {get; set;}
    public Boolean mantainVendorCode {get; set;}
    public Boolean useNewVendorCode {get; set;}
    public Boolean sendToJDE {get; set;}
    
    public string shareOption {get;set;}
    public String vendorCode {get;set;}
    private String sortDirection = 'ASC';
    private String sortExp = 'Name';

    public String sortExpression {
        get{ return sortExp;  }
        set {
            if (value == sortExp) {
                sortDirection = (sortDirection == 'ASC')? 'DESC' : 'ASC';
            }  else {
                sortDirection = 'ASC';
            }
            sortExp = value;
        }
    }
      
    public LAT_BR_TransferAccountsAndUDC() {
        List<LAT_Account__c> lstLATAccount = null;

        System.debug('LAT_BR_TransferAccountsAndUDC[] ->');

        listOfAccount = new List<Account>();
        listInnerAccount = new List<AccountInner>();
        accOldLookup = new Account();
        accNewLookup = new Account();
        dummyOpp = new Lat_Opportunity__c();
        selectAll = false;
        mantainVendorCode = false; 
        useNewVendorCode = false;
		sendToJDE = true;

        lstLATAccount = [SELECT ID, LAT_UDCZonaVendedor__c FROM LAT_Account__c WHERE Recordtype.Developername = 'LAT_BR_LAC_Standard' AND LAT_UDCZonaVendedor__c = null LIMIT 1]; 
        if(!lstLATAccount.IsEmpty()) {
            udcNewLookup = lstLATAccount[0];
        }

        System.debug('LAT_BR_TransferAccountsAndUDC[] <-');
    }

    
    public PageReference getAccountsPerUser() {
        PageReference objPageReference = null;
        List<Account> lstAccounts = null;
        AccountInner objAccountInner = null; 
        String strSortExpression = null;
        String strSOQL = null;

        System.debug('LAT_BR_TransferAccountsAndUDC.getAccountsPerUser[] ->');

        if(accOldLookup != NULL && String.isNotBlank(accOldLookup.OwnerId)){
            listInnerAccount = new List<AccountInner>();
            strSortExpression = sortExpression  + ' ' + sortDirection;

            strSOQL = 'SELECT Id, Name, Corporate_Name__c, CNPJ__c, Sub_Channel_Rating__r.Name, OwnerId, Client_code_AN8__c, Owner.C_digo_JDE__c, LAT_Account__r.LAT_JDEZone__c '; 
            strSOQL += 'FROM Account ';
            strSOQL += 'WHERE OwnerId = \'' + accOldLookup.OwnerId + '\' ';
            strSOQL += String.format('ORDER BY {0} ', new String [] { strSortExpression });
            strSOQL += 'LIMIT 1000 ';

            System.debug('LAT_BR_TransferAccountsAndUDC.getAccountsPerUser[strSOQL : ' + strSOQL + ']');

            lstAccounts = Database.query(strSOQL);
            
            System.debug('LAT_BR_TransferAccountsAndUDC.getAccountsPerUser[strSOQL : ' + lstAccounts + ']'); 
    
            for(Account objAccount : lstAccounts){
                objAccountInner = new AccountInner();
                objAccountInner.isSelected = false;
                objAccountInner.razSocial = objAccount.Name;
                objAccountInner.accId = objAccount.Id;
                objAccountInner.ownerId = objAccount.OwnerId;
                objAccountInner.an8 = objAccount.Client_code_AN8__c;
                objAccountInner.nameFantasia = objAccount.Corporate_Name__c;
                objAccountInner.jdeZoneCode = objAccount.LAT_Account__r.LAT_JDEZone__c;
                objAccountInner.cuit = objAccount.CNPJ__c;
                objAccountInner.codigoSubcanal = objAccount.Sub_Channel_Rating__r.Name;

                listInnerAccount.add(objAccountInner);

                vendorCode =  objAccount.Owner.C_digo_JDE__c;
            }
        }
        System.debug('LAT_BR_TransferAccountsAndUDC.getAccountsPerUser[listInnerAccount : ' + listInnerAccount + ']');
        
        if( listInnerAccount.isEmpty() ){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'No records for the user selected'));
        }

        System.debug('LAT_BR_TransferAccountsAndUDC.getAccountsPerUser[] <-');

        return objPageReference;
    }

    public PageReference transferAccounts(){
        Pagereference objPageReference = null;
        Set<Id> setAccountsToUpdate = null;
        List<AccountInner> lstAccountSelected = null;
        List<User> lstNewOwner = null;
        List<UDC__c> lstUDCVendedorList = null;                    
        List<UDC__c> lstUDCNewVendedorList = null;
        List<LAT_Account__c> lstLATAccount = null;
        String strNewVendorCode = null;        

        System.debug('LAT_BR_TransferAccountsAndUDC.transferAccounts[] ->');

        try {
            if(!listInnerAccount.isEmpty()) {
                if(String.isNotBlank(accNewLookup.OwnerId)) {
                    setAccountsToUpdate = retrieveSelectedAccounts();

                    System.debug('LAT_BR_TransferAccountsAndUDC.transferAccounts[accountsToUpdate : ' + setAccountsToUpdate + ']');

                    if(!setAccountsToUpdate.isEmpty()) {
                        vendorCode = String.isBlank(vendorCode)?'NOT_FOUND':vendorCode;
                        lstNewOwner = [SELECT C_digo_JDE__c FROM User WHERE Id =: accNewLookup.ownerid];
                        strNewVendorCode = (lstNewOwner.isEmpty() || String.isBlank(lstNewOwner[0].C_digo_JDE__c)) ? 'NOT_FOUND' : lstNewOwner[0].C_digo_JDE__c;
                        
                        lstUDCVendedorList = [SELECT Id FROM UDC__c WHERE Recordtype.Developername = 'BRA_Standard' AND CodProd__c = '01' AND CodUs__c = '02' AND CodDefUsuario__c = :vendorCode LIMIT 1];                    
                        lstUDCNewVendedorList = [SELECT Id FROM UDC__c WHERE Recordtype.Developername = 'BRA_Standard' AND CodProd__c = '01' AND CodUs__c = '02' AND CodDefUsuario__c = :strNewVendorCode LIMIT 1];
                        if(!lstUDCNewVendedorList.IsEmpty()) { 

                            lstLATAccount = [SELECT Id, LAT_UDCZonaVendedor__c, LAT_IsAdmin__c 
                                            FROM LAT_Account__c 
                                            WHERE LAT_Accountid__c IN :setAccountsToUpdate];

                            System.debug('LAT_BR_TransferAccountsAndUDC.transferAccounts[lstLATAccount : ' + lstLATAccount + ']');

                            for(LAT_Account__c objLATAccount :lstLATAccount){
                                if(mantainVendorCode){
                                    if(String.isBlank(objLATAccount.LAT_UDCZonaVendedor__c) && !lstUDCVendedorList.IsEmpty()) {
                                        objLATAccount.LAT_UDCZonaVendedor__c = lstUDCVendedorList[0].Id;
                                    }
                                } else if(useNewVendorCode) {
                                    if(!lstUDCNewVendedorList.IsEmpty()) {
                                        objLATAccount.LAT_UDCZonaVendedor__c = lstUDCNewVendedorList[0].Id;
                                    }
                                }

                                objLATAccount.LAT_IsAdmin__c = true;
                            }

                            System.debug('LAT_BR_TransferAccountsAndUDC.transferAccounts[lstLATAccount : ' + lstLATAccount + ']');
                            update lstLATAccount;
        
                            Database.executeBatch(new LAT_AR_TransferAccounts_Batch(setAccountsToUpdate, accNewLookup.ownerid, sendToJDE), 10);
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, Label.LAT_MX_VFP_13_001));
        
                            System.debug('LAT_BR_TransferAccountsAndUDC.transferAccounts[transferOpps : ' + transferOpps + ']');
                            System.debug('LAT_BR_TransferAccountsAndUDC.transferAccounts[transferContacts : ' + transferContacts + ']');
                            if(transferOpps){
                                transferAccountOpportunities(setAccountsToUpdate);
                            }
            
                            if(transferContacts){
                                transferAccountContacts(setAccountsToUpdate);
                            }
                        } else {
                            System.debug('LAT_BR_TransferAccountsAndUDC.transferAccounts[El nuevo dueño no tiene una Zona/Vendedor válida. Por favor Revise.]');
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'El nuevo dueño no tiene una Zona/Vendedor válida. Por favor Revise.'));
                        }
                    } else {
                        System.debug('LAT_BR_TransferAccountsAndUDC.transferAccounts[' + Label.LAT_VFP9_Account_Transfer + ']');
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,Label.LAT_VFP9_Account_Transfer));
                    }
                } else {
                    System.debug('LAT_BR_TransferAccountsAndUDC.transferAccounts[' + Label.LAT_VFP09_New_Owner_Selection + ']');
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.LAT_VFP09_New_Owner_Selection));
                }
            }
        } catch(Exception Ex) {
            System.debug('LAT_BR_TransferAccountsAndUDC.transferAccounts[' + Ex.getMessage() + ']');
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Ex.getMessage()));
        }

        System.debug('LAT_BR_TransferAccountsAndUDC.transferAccounts[] <-');

        return objPageReference;
    }
    
    public PageReference assignUDCs() {
        Pagereference objPageReference = null;
        List<LAT_Account__c> lstLATAccount = null;
        Set<Id> setAccountsToUpdate = null;

        System.debug('LAT_BR_TransferAccountsAndUDC.assignUDCs[] ->');

        try {
            System.debug('LAT_BR_TransferAccountsAndUDC.assignUDCs[listInnerAccount : ' + listInnerAccount + ']');
            System.debug('LAT_BR_TransferAccountsAndUDC.assignUDCs[udcNewLookup.LAT_UDCZonaVendedor__c : ' + udcNewLookup.LAT_UDCZonaVendedor__c + ']');
            if(!listInnerAccount.isEmpty()) {
                if(String.isNotBlank(udcNewLookup.LAT_UDCZonaVendedor__c)) {
                    setAccountsToUpdate = retrieveSelectedAccounts();

                    if(!setAccountsToUpdate.IsEmpty()) {
                        lstLATAccount = [SELECT Id, LAT_UDCZonaVendedor__c, LAT_IsAdmin__c, LAT_Accountid__r.OwnerId 
                                         FROM LAT_Account__c 
                                         WHERE LAT_Accountid__c IN :setAccountsToUpdate];

                        for(LAT_Account__c objLATAccount : lstLATAccount){                        
                            objLATAccount.LAT_UDCZonaVendedor__c = udcNewLookup.LAT_UDCZonaVendedor__c;
                            objLATAccount.LAT_IsAdmin__c = true;
                        }

                        System.debug('LAT_BR_TransferAccountsAndUDC.assignUDCs[lstLATAccount : ' + lstLATAccount + ']');

                        update lstLATAccount;

                        for(LAT_Account__c objLATAccount : lstLATAccount){                        
                            objLATAccount.LAT_IsAdmin__c = false;
                        }
                        update lstLATAccount;

                        Database.executeBatch(new LAT_AR_TransferAccounts_Batch(setAccountsToUpdate, lstLATAccount[0].LAT_Accountid__r.Ownerid, sendToJDE), 10);

                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, Label.LAT_MX_VFP_13_001));
                    } else {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,Label.LAT_VFP9_Account_Transfer));
                    }
                } else {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Debe seleccionar una UDC a asignar a las cuentas.'));
                }
            }
        } catch(Exception Ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Ex.getMessage()));
        }

        System.debug('LAT_BR_TransferAccountsAndUDC.assignUDCs[] <-');

        return objPageReference;
    }
    

    public PageReference shareAccounts(){
        Pagereference objPageReference = null;
        List<LAT_Opportunity__C> lstOpportunities = null;
        Set<Id> setAccountsToUpdate = null;

        System.debug('LAT_BR_TransferAccountsAndUDC.shareAccounts[] ->');

        try {
            if(!listInnerAccount.isEmpty()) {
                if(String.isNotBlank(accNewLookup.OwnerId)) {
                    setAccountsToUpdate = retrieveSelectedAccounts();

                    System.debug('LAT_BR_TransferAccountsAndUDC.shareAccounts[setAccountsToUpdate : ' + setAccountsToUpdate + ']');

                    if(!setAccountsToUpdate.isEmpty()) {
                        shareAccounts(setAccountsToUpdate, accNewLookup.OwnerId, shareOption );

                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, Label.LAT_MX_VFP_13_001));

                        if(transferOpps) { 
                            lstOpportunities = retrieveOpportunities(setAccountsToUpdate);

                            shareOpportunities(lstOpportunities, accNewLookup.ownerid, shareOption);
                        }
                    } else {
                        System.debug('LAT_BR_TransferAccountsAndUDC.transferAccounts[' + Label.LAT_VFP9_Account_Transfer + ']');
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,Label.LAT_VFP9_Account_Transfer));
                    }
                } else {
                    System.debug('LAT_BR_TransferAccountsAndUDC.transferAccounts[' + Label.LAT_VFP09_New_Owner_Selection + ']');
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.LAT_VFP09_New_Owner_Selection));
                }
            } 
        } catch(Exception Ex) {
            System.debug('LAT_BR_TransferAccountsAndUDC.shareAccounts[' + Ex.getMessage() + ']');
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Ex.getMessage()));
        }

        System.debug('LAT_BR_TransferAccountsAndUDC.shareAccounts[] <-');

        return objPageReference;
    }

    private Set<Id> retrieveSelectedAccounts() {
        Set<Id> setAccountsToUpdate = null;

        System.debug('LAT_BR_TransferAccountsAndUDC.retrieveSelectedAccounts[] ->');

        setAccountsToUpdate = new Set <Id>();

        for(AccountInner objAccountInner : listInnerAccount){
            if(objAccountInner.isSelected) {
                setAccountsToUpdate.add(objAccountInner.accId);
            }
        }

        System.debug('LAT_BR_TransferAccountsAndUDC.retrieveSelectedAccounts[' + setAccountsToUpdate + '] <-');
        
        return setAccountsToUpdate;
    }

    private List<LAT_Opportunity__c> retrieveOpportunities(Set<Id> setAccountsToUpdate) {
        List<LAT_Opportunity__C> lstOpportunities = null;
        String strSOQL = null;
        String strDateFrom = null;
        String strDateTO = null;
        
        System.debug('LAT_BR_TransferAccountsAndUDC.retrieveOpportunities[] ->');

        strSOQL = 'SELECT Id, Ownerid FROM LAT_Opportunity__C WHERE LAT_Account__c IN :setAccountsToUpdate';

        if(dummyOpp.LAT_DTDelivery__c != null && dummyOpp.LAT_MX_PurchaseOrderUntil__c != null) {
            strDateFrom = DateTime.newInstance(dummyOpp.LAT_DTDelivery__c.year(),dummyOpp.LAT_DTDelivery__c.month(),dummyOpp.LAT_DTDelivery__c.day()).format('yyyy-MM-dd\'T\'HH:mm:ss.SSSXXX');
            strDateTO = DateTime.newInstance(dummyOpp.LAT_MX_PurchaseOrderUntil__c.year(),dummyOpp.LAT_MX_PurchaseOrderUntil__c.month(),dummyOpp.LAT_MX_PurchaseOrderUntil__c.day()).format('yyyy-MM-dd\'T\'HH:mm:ss.SSSXXX');
            strSOQL += ' AND CreatedDate >= ' + strDateFrom + ' AND CreatedDate <= ' + strDateTO;
        }
        
        System.debug('LAT_BR_TransferAccountsAndUDC.retrieveOpportunities[strSOQL : ' + strSOQL + ']');

        lstOpportunities = Database.query(strSOQL);

        System.debug('LAT_BR_TransferAccountsAndUDC.retrieveOpportunities[strSOQL : ' + strSOQL + ']');
        return lstOpportunities;
    }

    private void transferAccountOpportunities(Set<Id> setAccountsToUpdate) {
        List<LAT_Opportunity__C> lstOpportunities = null;
        
        System.debug('LAT_BR_TransferAccountsAndUDC.transferAccountOpportunities[] ->');

        lstOpportunities = retrieveOpportunities(setAccountsToUpdate);

        System.debug('LAT_BR_TransferAccountsAndUDC.transferAccountOpportunities[lstOpportunities : ' + lstOpportunities + ']');

        if(!lstOpportunities.IsEmpty()) {
            for(LAT_Opportunity__c objOpportunity : lstOpportunities){
                objOpportunity.Ownerid = accNewLookup.Ownerid;
            }

            update lstOpportunities;
        }
        System.debug('LAT_BR_TransferAccountsAndUDC.transferAccountOpportunities[] <-');
    }

    private void transferAccountContacts(Set<Id> setAccountsToUpdate) {
        List<Contact> lstContacts = null;

        System.debug('LAT_BR_TransferAccountsAndUDC.transferAccountContacts[] ->');

        lstContacts = [SELECT Id, Ownerid FROM Contact WHERE Accountid IN :setAccountsToUpdate];
        
        for(Contact objContact : lstContacts){
            objContact.Ownerid = accNewLookup.Ownerid;
        }

        update lstContacts;

        System.debug('LAT_BR_TransferAccountsAndUDC.transferAccountContacts[] <-');
    }

    private void shareAccounts(Set<Id> setAccountsToUpdate, Id strOwnerId, String strShareOption ) {        
        List<AccountShare> lstAccountShare = null;
        AccountShare objShare = null;

        System.debug('LAT_BR_TransferAccountsAndUDC.shareAccounts[ setAccountsToUpdate : ' +  setAccountsToUpdate + ' - strOwnerId : ' + strOwnerId + ' - strShareOption : ' + strShareOption + '] ->');

        lstAccountShare = new List<AccountShare>();
        for(Id objAccountId : setAccountsToUpdate) {
            objShare = new AccountShare();
            objShare.AccountId = objAccountId;
            objShare.UserOrGroupId = strOwnerId;
            objShare.AccountAccessLevel = strShareOption;
            objShare.OpportunityAccessLevel = strShareOption;
            objShare.RowCause = Schema.AccountShare.RowCause.Manual;  
            
            lstAccountShare.add(objShare);
        }
        
        Database.insert(lstAccountShare);

        System.debug('LAT_BR_TransferAccountsAndUDC.shareAccounts[] <-');
    }

    private void shareOpportunities(List<LAT_Opportunity__c> lstOpportunitiesToUpdate, Id strOwnerId, String strShareOption ) {        
        List<LAT_Opportunity__share> lstOpportunityShare = null;
        LAT_Opportunity__share objShare = null;

        System.debug('LAT_BR_TransferAccountsAndUDC.shareAccounts[ lstOpportunitiesToUpdate : ' +  lstOpportunitiesToUpdate + ' - strOwnerId : ' + strOwnerId + ' - strShareOption : ' + strShareOption + '] ->');

        lstOpportunityShare = new List<LAT_Opportunity__share>();
        for(LAT_Opportunity__c objOpportunityId : lstOpportunitiesToUpdate) {
            objShare = new LAT_Opportunity__share();
            objShare.ParentId = objOpportunityId.Id;
            objShare.UserOrGroupId = strOwnerId;
            objShare.AccessLevel = strShareOption;
            objShare.RowCause = Schema.LAT_Opportunity__share.RowCause.Manual;  
                        
            lstOpportunityShare.add(objShare);
        }
        
        Database.insert(lstOpportunityShare);

        System.debug('LAT_BR_TransferAccountsAndUDC.shareAccounts[] <-');
    }

    public List<SelectOption> getShareOptions() {
        List<SelectOption> lstOptions = new List<SelectOption>(); 

        lstOptions = new List<SelectOption>(); 

        lstOptions.add(new SelectOption('Read','Ler')); 
        lstOptions.add(new SelectOption('Edit','Editar')); 

        return lstOptions; 
    }

    public String getSortDirection(){
        String strSortDirection = null;
        
        if (String.IsBlank(sortExpression)) {
            strSortDirection = 'ASC';
        } else {
            strSortDirection =  sortDirection;
        }

        return strSortDirection;
    }

    public void setSortDirection(String strValue) {  
        sortDirection = strValue;
    }

    public class AccountInner {
        public Boolean isSelected {get;set;}
        public String razSocial {get;set;}
        public String nameFantasia {get;set;}
        public String accId {get;set;}
        public String ownerId {get;set;}
        public String an8 {get;set;}
        public String description {get;set;}
        public String phone {get;set;}
        public String address {get;set;}
        public String jdeZoneCode {get;set;}        
        public String cuit {get;set;}
        public String codigoSubcanal {get;set;}
    }
}