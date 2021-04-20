public with sharing class LAT_AR_VFC_13_TransferAccsOppsConts {
    
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
            //if the column is clicked on then switch between Ascending and Descending modes
            if (value == sortExp)
                sortDirection = (sortDirection == 'ASC')? 'DESC' : 'ASC';
            else
                sortDirection = 'ASC';
            sortExp = value;
        }
    }

    
        
    public LAT_AR_VFC_13_TransferAccsOppsConts() {
        listOfAccount = new List<Account>();
        listInnerAccount = new List<AccountInner>();
        accOldLookup = new Account();
        accNewLookup = new Account();
        List<LAT_Account__c> latAccs = [SELECT ID, LAT_JDEZoneUDC__c FROM LAT_Account__c WHERE Recordtype.Developername = 'LAT_AR_LAC_Standard' AND LAT_JDEZoneUDC__c = null LIMIT 1]; 
        udcNewLookup = latAccs[0];
        dummyOpp = new Lat_Opportunity__c();
        selectAll = mantainVendorCode = useNewVendorCode = sendToJDE = false;
    }

    
    public PageReference getAccountsPerUser(){

        if(accOldLookup.OwnerId != null){

            listInnerAccount = new List<AccountInner>();

            AccountInner accInn;
            string sortFullExp = sortExpression  + ' ' + sortDirection;
            system.debug('user old: ' + accOldLookup.OwnerId);
            List<Account> accs= Database.query('Select Id, Name, Corporate_Name__c, CNPJ__c, Sub_Channel_Rating__r.Name,OwnerId, Client_code_AN8__c, Owner.C_digo_JDE__c, LAT_Account__r.LAT_JDEZone__c From Account Where OwnerId =\''+accOldLookup.OwnerId +'\' order by ' + sortFullExp + ' limit 1000');
    
            for(Account acc : accs){

                accInn = new AccountInner();
                accInn.isSelected = false;
                accInn.razSocial = acc.Name;
                accInn.accId = acc.Id;
                accInn.ownerId = acc.OwnerId;
                accInn.an8 = acc.Client_code_AN8__c;
                accInn.nameFantasia = acc.Corporate_Name__c;
                accInn.jdeZoneCode = acc.LAT_Account__r.LAT_JDEZone__c;
                accInn.cuit = acc.CNPJ__c;
                accInn.codigoSubcanal = acc.Sub_Channel_Rating__r.Name;
                listInnerAccount.add(accInn);

                vendorCode =  acc.Owner.C_digo_JDE__c;
            }

        }

        if( listInnerAccount.isEmpty() ){

            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'No records for the user selected'));

            return null;
        }

        return null;
    }

    public PageReference transferAccounts(){

        if(!listInnerAccount.isEmpty()){

            Boolean found = false;
            for(AccountInner ai : listInnerAccount){
                if(ai.isSelected){
                    found = true;
                    break;
                }
            }
            if(!found){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,Label.LAT_VFP9_Account_Transfer));
                return null;
            }else if(accNewLookup.OwnerId == null){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.LAT_VFP09_New_Owner_Selection));
                return null;
            }

            try{

                Set <Id> accountsToUpdate = new Set <Id>();
                List<AccountInner> accountSelected = new LisT<AccountInner>();

                for(AccountInner accInn : listInnerAccount){

                    if(accInn.isSelected){

                        //accountSelected.add(accInn);
                        accountsToUpdate.add(accInn.accId);
                        //accounts.add(accInn.accId);
                    }
                }

                if(!accountsToUpdate.isEmpty()){
                    vendorCode = vendorCode == null ? 'NOT_FOUND' : vendorCode;
                    List<User> newOwner = [SELECT C_digo_JDE__c FROM User WHERE Id =:accNewLookup.ownerid];
                    String newVendorCode = newOwner[0] == null ? 'NOT_FOUND' : newOwner[0].C_digo_JDE__c;
                    

                    List<UDC__c> udcVendedorList = [SELECT Id FROM UDC__c WHERE Recordtype.Developername = 'Standard_AR' AND CodProd__c = '01' AND CodUs__c = '02' AND CodDefUsuario__c = :vendorCode LIMIT 1];
                    
                    List<UDC__c> udcNewVendedorList = [SELECT Id FROM UDC__c WHERE Recordtype.Developername = 'Standard_AR' AND CodProd__c = '01' AND CodUs__c = '02' AND CodDefUsuario__c = :newVendorCode LIMIT 1];
                    if(udcNewVendedorList.size() == 0) {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'El nuevo dueño no tiene una Zona/Vendedor válida. Por favor Revise.'));
                        return null;
                    }
                    List<LAT_Account__c> lataccountList = [Select Id, LAT_JDEZoneUDC__c, LAT_IsAdmin__c from LAT_Account__c where LAT_Accountid__c in :accountsToUpdate];
                    for(LAT_Account__c lat_acc :lataccountList){
                        if(mantainVendorCode){
                            if(lat_acc.LAT_JDEZoneUDC__c == null && udcVendedorList[0] != null) {
                                lat_acc.LAT_JDEZoneUDC__c = udcVendedorList[0].Id;
                            }
                        }
                        if(useNewVendorCode){
                            if(udcNewVendedorList[0] != null) {
                                lat_acc.LAT_JDEZoneUDC__c = udcNewVendedorList[0].Id;
                            }
                        }
                        lat_acc.LAT_IsAdmin__c = true;
                    }

                    update lataccountList;

                    Database.executeBatch(new LAT_AR_TransferAccounts_Batch(accountsToUpdate, accNewLookup.ownerid, sendToJDE), 10);

                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, Label.LAT_MX_VFP_13_001));
                }

                if(transferOpps){

                    String query = 'Select Id, Ownerid From LAT_Opportunity__C Where LAT_Account__c in :accountsToUpdate';

                    if(dummyOpp.LAT_DTDelivery__c != null && dummyOpp.LAT_MX_PurchaseOrderUntil__c != null){
                        String oppFrom = DateTime.newInstance(dummyOpp.LAT_DTDelivery__c.year(),dummyOpp.LAT_DTDelivery__c.month(),dummyOpp.LAT_DTDelivery__c.day()).format('yyyy-MM-dd\'T\'HH:mm:ss.SSSXXX');
                        String oppTo = DateTime.newInstance(dummyOpp.LAT_MX_PurchaseOrderUntil__c.year(),dummyOpp.LAT_MX_PurchaseOrderUntil__c.month(),dummyOpp.LAT_MX_PurchaseOrderUntil__c.day()).format('yyyy-MM-dd\'T\'HH:mm:ss.SSSXXX');

                        query += ' and CreatedDate >= ' + oppFrom + ' and CreatedDate <= ' + oppTo;
                    }

                    //buscar opps y transferir
                    List<LAT_Opportunity__C> listaOpp = Database.query(query);
                    for(LAT_Opportunity__C opp :listaOpp){
                        opp.ownerid = accNewLookup.ownerid;
                        //lat is admin = true;
                    }

                    update listaOpp;
                }

                if(transferContacts){

                    //buscar contacts y transferir
                    List<Contact> listaCont = [Select Id, Ownerid From Contact Where accountid in :accountsToUpdate];
                    for(Contact con :listaCont){
                        con.ownerid = accNewLookup.ownerid;
                    }

                    update listaCont;
                }
                    
            }catch(Exception e){

                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
            }
       
        }
        return null;
    }
    
    public PageReference assignUDCs(){

        if(!listInnerAccount.isEmpty()){

            Boolean found = false;
            for(AccountInner ai : listInnerAccount){
                if(ai.isSelected){
                    found = true;
                    break;
                }
            }
            if(!found){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,Label.LAT_VFP9_Account_Transfer));
                return null;
            }else if(udcNewLookup.LAT_JDEZoneUDC__c == null){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Debe seleccionar una UDC a asignar a las cuentas.'));
                return null;
            }

            try{

                Set <Id> accountsToUpdate = new Set <Id>();
                List<AccountInner> accountSelected = new LisT<AccountInner>();

                for(AccountInner accInn : listInnerAccount){

                    if(accInn.isSelected){

                        //accountSelected.add(accInn);
                        accountsToUpdate.add(accInn.accId);
                        //accounts.add(accInn.accId);
                    }
                }

                if(!accountsToUpdate.isEmpty()){
                    

                
                    
                    List<LAT_Account__c> lataccountList = [Select Id, LAT_JDEZoneUDC__c, LAT_IsAdmin__c, LAT_Accountid__r.OwnerId from LAT_Account__c where LAT_Accountid__c in :accountsToUpdate];
                    for(LAT_Account__c lat_acc :lataccountList){
                        
                        lat_acc.LAT_JDEZoneUDC__c = udcNewLookup.LAT_JDEZoneUDC__c;
                        lat_acc.LAT_IsAdmin__c = true;
                    }

                    update lataccountList;

                    Database.executeBatch(new LAT_AR_TransferAccounts_Batch(accountsToUpdate, lataccountList[0].LAT_Accountid__r.ownerid, sendToJDE), 10);

                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, Label.LAT_MX_VFP_13_001));
                }

                    
            }catch(Exception e){

                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
            }
       
        }
        return null;
    }
    

    public PageReference shareAccounts(){

        if(!listInnerAccount.isEmpty()){

            Boolean found = false;
            for(AccountInner ai : listInnerAccount){
                if(ai.isSelected){
                    found = true;
                    break;
                }
            }
            if(!found){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,Label.LAT_VFP9_Account_Transfer));
                return null;
            }else if(accNewLookup.OwnerId == null){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.LAT_VFP09_New_Owner_Selection));
                return null;
            }

            try{

                Set <Id> accountsToUpdate = new Set <Id>();
                List<AccountInner> accountSelected = new LisT<AccountInner>();

                for(AccountInner accInn : listInnerAccount){

                    if(accInn.isSelected){

                        accountsToUpdate.add(accInn.accId);
                    }
                }

                if(!accountsToUpdate.isEmpty()){

                    List<AccountShare> listinsert = new List<AccountShare>();

                    for(Id accId :accountsToUpdate){
                        AccountShare jobShr = new AccountShare();
                        jobShr.accountid = accId;
                        jobShr.UserOrGroupId = accNewLookup.ownerid;
                        jobShr.AccountAccessLevel = shareOption;
                        jobShr.OpportunityAccessLevel = shareOption;
                        jobShr.RowCause = Schema.AccountShare.RowCause.Manual;  
                        
                        listinsert.add(jobShr);
                    }
                    
                    insert listinsert;
                }

                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, Label.LAT_MX_VFP_13_001));


                if(transferOpps){

                    String query = 'Select Id, Ownerid From LAT_Opportunity__C Where LAT_Account__c in :accountsToUpdate';

                    if(dummyOpp.LAT_DTDelivery__c != null && dummyOpp.LAT_MX_PurchaseOrderUntil__c != null){
                        String oppFrom = String.valueOf(dummyOpp.LAT_DTDelivery__c);
                        String oppTo = String.valueOf(dummyOpp.LAT_MX_PurchaseOrderUntil__c);

                        query += ' and CreatedDate >= ' + oppFrom + ' and CreatedDate <= ' + oppTo;
                    }

                    //buscar opps y transferir
                    List<LAT_Opportunity__C> listaOpp = Database.query(query);
                    
                    list<LAT_Opportunity__share> listinsert = new list<LAT_Opportunity__share>();

                    for(LAT_Opportunity__C opp :listaOpp){
                       LAT_Opportunity__share jobShr  = new LAT_Opportunity__share();
                        jobShr.ParentId = opp.id;
                        jobShr.UserOrGroupId = accNewLookup.ownerid;
                        jobShr.AccessLevel = shareOption;
                        jobShr.RowCause = Schema.LAT_Opportunity__share.RowCause.Manual;  
                           
                        listinsert.add(jobShr);
                    }
                    
                    insert listinsert;
                }

                return null;

            }catch(Exception e){

                system.debug('errrrrorrrr: ' + e.getMessage());

                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
            }

        }

        return null;       
    }

    public List<SelectOption> getShareOptions() {
        List<SelectOption> options = new List<SelectOption>(); 
        options.add(new SelectOption('Read','Read')); 
        options.add(new SelectOption('Edit','Edit')); 
        return options; 
    }

    public String getSortDirection(){
        //if not column is selected 
        if (sortExpression == null || sortExpression == '')
            return 'ASC';
        else
            return sortDirection;
    }

    public void setSortDirection(String value){  
        sortDirection = value;
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