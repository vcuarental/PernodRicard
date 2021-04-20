public with sharing class LAT_MX_Account_OnTrade_Prof_Control {
    public LAT_Account__c accFields {get;set;}
    public LAT_Account__c accPadre {get;set;}
    public Account acc {get;set;}
    public String accId;
    private Boolean enableDeleting {get; set;}
    public String toDeleteId {get;set;}
    public String currentUserProfileName {get;set;} 
    public Boolean userCanDelete {get;set;} 


    public LAT_MX_Account_OnTrade_Prof_Control(ApexPages.StandardController stdController) {
        accId= ApexPages.currentPage().getParameters().get('id');
        toDeleteId = '';
        this.enableDeleting = true;
        getAcc();

        List<Profile> prof = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];
        this.currentUserProfileName = prof[0].Name;
        this.userCanDelete = userHasDeleteEnabledProfile();
    }

    public void getAcc(){
        List<Account> listAcc = [SELECT Id, Name, LAT_MX_CreditAndCollectionsExecutive__r.Email, LAT_MX_PriorityBrand_1__c,
                                    LAT_Account__c, LAT_MX_PriorityBrand_2__c, LAT_MX_PriorityBrand_3__c, 
                                    Client_code_AN8__c, ParentID, CreatedBy.name, LastModifiedBy.name, Return_JDE_Integration__c,
                                    Status__c, LAT_MX_Group__c, Parent.Name, LAT_MX_CreditAndCollectionsExecutive__c, ownerId,
                                    Description, Corporate_Name__c, Owner.ManagerId, LAT_MX_MissingDocuments__c,
                                    AddressLine1_AR__c, Phone, Website, Email_NFE__c, LAT_MX_PostalCode__c,
                                    LAT_MX_Neighbourhood__c, LAT_MX_City__c, LAT_MX_County__c, 
                                    Contact_Schedule__c, Segmentation_Type_on_trade__c,
                                    Channel_Type__c, type, Sub_Channel__c, LAT_MX_AverageTicket__c,
                                    Begin_Time__c, LAT_MX_GiveBonus__c, CNPJ__c, Frequency_of_Visits__c
                                    FROM Account
                                    WHERE id =: this.accId LIMIT 1];
        List<LAT_Account__c>  listAccLat = [SELECT Id, LAT_MX_AnualContract__c, LAT_MX_MejorDia__c, LAT_MX_InicioConvenio__c, 
                                            LAT_MX_Direccion__c, LAT_MX_FinConvenio__c, LAT_ID_Status__c, LAT_MX_Third_Supply_Option__c, 
                                            LAT_MX_Fourth_Supply_Option__c, LAT_Activaciones__c, LAT_Capacitacion__c, LAT_Convenio_prm__c,
                                            LAT_Convenio1__c, LAT_Convenio2__c, LAT_Convenio3__c, LAT_Incentivos__c, LAT_ScoreType__c,
                                            LAT_Coctel__c, LAT_Entrada__c, LAT_MX_AttendingKAM__c, LAT_PlatoFuerte__c, LAT_Postre__c,
                                            LAT_Branding__c, LAT_CalidadBateo__c, LAT_CubaLibre__c, LAT_DJInternacional__c, LAT_PrecioBacardi__c,
                                            LAT_PrecioMinPlatoFuerte__c, LAT_PromocionesPrecioPaquete__c, LAT_RestriccionesAcceso__c,
                                            LAT_SKUChampagne__c,LAT_SKUWhiskies__c, LAT_Somelier__c, LAT_VisibilidadTailorMade__c, LAT_Calificacion__c, 
                                            LAT_Plaza_Formula__c, LAT_Region_Formula__c, LAT_plaza__c,LAT_region__c, LAT_MX_PostalCode__c,
                                            LAT_TipoComida__c,LAT_Nombre_Comercial__c,LAT_TipoCentro__c, LAT_Capacidad__c,LAT_Fecha_Apertura__c,
                                            LAT_MX_Neighbourhood__c, LAT_MX_City__c, LAT_MX_County__c, LAT_MX_SecondSupplyOption__c, 
                                            LAT_MX_FirstSupplyOption__c, LAT_MX_Periodicity__c, LAT_MX_CuadranteClientes__c, LAT_MX_HasRecognizedChef__c,
                                            (SELECT id, Name, LAT_MX_RFC__r.Name, LAT_MX_RFC__r.LAT_RFC__c from LAT_MX_RFC_Accounts__r)
                                            FROM LAT_Account__c
                                            WHERE LAT_Accountid__c =: this.accId LIMIT 1];

        for(Account c: listAcc){
            this.acc=c;           
        }
        for(LAT_Account__c af: listAccLat){
            this.accFields=af;
        }
        if(this.acc.ParentId != null){
            List<LAT_Account__c>  listACCpadre = [SELECT Id,LAT_MX_AnualContract__c,LAT_MX_InicioConvenio__c,LAT_MX_FinConvenio__c,LAT_Activaciones__c, LAT_Capacitacion__c, LAT_Convenio_prm__c,LAT_Convenio1__c,LAT_Convenio2__c,LAT_Convenio3__c
                                                                                        ,LAT_Incentivos__c
                                                                                        FROM LAT_Account__c
                                                                                        WHERE LAT_Accountid__c =: this.acc.ParentId LIMIT 1];
            for(LAT_Account__c a : listACCpadre) {
                this.accPadre = a;
            }
        }else{
           this.accPadre = accFields;
        }
    }

    public PageReference doEdit() {
        String accATM= ApexPages.currentPage().getParameters().get('id');
        PageReference newocp = new PageReference('/apex/LAT_MX_Account_OnTrade_Create?id=' + accATM);
        newocp.setRedirect(true);
        return newocp;
    }

    public PageReference doDelete() {
        toDeleteId = ApexPages.currentPage().getParameters().get('toDelete');
        system.debug('------>' + toDeleteId);

        if (toDeleteId != null && toDeleteId != '') {
            List<LAT_MX_RFC_Account__c> rfcAcc = [SELECT id FROM LAT_MX_RFC_Account__c WHERE id =: toDeleteId];
            if (!rfcAcc.isEmpty()) delete rfcAcc;
        }
        String accATM= ApexPages.currentPage().getParameters().get('id');
        PageReference pageRef = new PageReference('/apex/LAT_MX_Account_OnTrade_Profile?id=' + accATM);
        pageRef.setRedirect(true);
        return pageRef;
    }

    public PageReference doInactivar() {
        Savepoint sp = Database.setSavepoint();
        try {
            if(acc.status__c == 'Inactive Account'){
                acc.status__c = 'Modification requested in CRM';
                acc.Reason_for_Inactivation__c = '';
                update acc;
    
                LAT_ACCOUNT__c latAcc = [Select id from LAT_ACCOUNT__c where id =: acc.LAT_Account__c];
                latAcc.LAT_ID_Status__c = 'Inactivo'; 
                update latAcc;
    
                List<LAT_MX_RFC_Account__c> listAccountRFCs = [SELECT id FROM LAT_MX_RFC_Account__c WHERE LAT_ACCOUNT__c = :latAcc.id]; 
                if (listAccountRFCs.size() > 0){
                    delete listAccountRFCs;
                }
            } else {
                String statusPrev = acc.status__c; 
                acc.status__c = 'Pending Inactivation Approval';
                acc.Regional_Manager__c = acc.Owner.ManagerId;
                update acc;
                LAT_ACCOUNT__c latAcc = [Select id from LAT_ACCOUNT__c where id =: acc.LAT_Account__c];
                latAcc.LAT_Status_Before_Approval__c = statusPrev; 
                update latAcc;
            }
            // Redirect to view page
            String accATM= ApexPages.currentPage().getParameters().get('id');
            PageReference pageRef = new PageReference('/apex/LAT_MX_Account_OnTrade_Profile?id=' + accATM);
            pageRef.setRedirect(true);
            return pageRef;
        } catch( Exception e ){
            Database.rollback(sp);
            ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.severity.ERROR, e.getMessage());
            System.debug('LAT_MX_Account_OnTrade_Controller Catch: ' + e.getMessage() + '/n/n' + e);
            ApexPages.addMessage(errorMsg);
            return null;
        }
    }

    public PageReference deleteAccount() {
        try {
            delete acc;
            return new pagereference('/home/home.jsp');
        } catch (dmlException e) {
            system.debug('Error en LAT_MX_Account_OnTrade_Prof_Control.deleteAccount  ' + e.getMessage());
            if (!ApexPages.hasMessages()){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, e.getdmlMessage(0)));
            }
            return null;
        }  
   }

   public Boolean userHasDeleteEnabledProfile() {
        Boolean ret = false;
        LAT_GeneralConfig__c gcP = [SELECT Name, Id, LAT_Value__c FROM LAT_GeneralConfig__c where name = 'MX_PROFILES_DELETE_ON_TRADE_ACCOUNTS'];
        LAT_GeneralConfig__c gcU = [SELECT Name, Id, LAT_Value__c FROM LAT_GeneralConfig__c where name = 'MX_USERS_DELETE_ON_TRADE_ACCOUNTS'];

        if (gcP != null) {
            if (gcP.LAT_Value__c.contains(currentUserProfileName)) {
                ret = true;
            } else if (gcU != null) {
                if (gcU.LAT_Value__c.contains(UserInfo.getUserId())) {
                    ret = true;
                }
            }
        }

        return ret;
   }

}