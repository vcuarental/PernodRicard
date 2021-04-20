public with sharing class LAT_MX_Account_OnTrade_Controller {

    public LAT_Account__c   accFields {get;set;}
    public Account          acc {get;set;}
    public User             loggedInUser {get;set;}
    public List<SelectableRFC> listaRFCActuales {get; set;}
    public List<LAT_MX_RFC__c>  listaDeRFCNuevos {get; set;}
    public List<LAT_MX_RFC__c>  listaDeRFCViejos {get; set;}
    public String           parentID{get; set;}
    public String           rfcSelec{get; set;}
    public String           rsSelec{get; set;}
    public boolean          isInsert{get;set;}
    public String toDeleteId {get;set;}
    public Boolean disabled {get;set;}
    private Boolean isKAMUser;


    public LAT_MX_Account_OnTrade_Controller(ApexPages.StandardController stdController) {
        this.acc = (Account) stdController.getRecord();
        this.accFields = this.getLATAccount(this.acc.Id);
        this.isInsert = (this.acc.Id == null);
        this.acc.RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'LAT_MX_ACC_OnTrade');
        this.loggedInUser = this.getUserData();
        this.listaRFCActuales = new List<SelectableRFC>();
        this.listaDeRFCViejos = new List<LAT_MX_RFC__c>();
        this.listaDeRFCNuevos = new List<LAT_MX_RFC__c>();
        loadRFC();
        rfcSelec = '';
        rsSelec = '';

        disabled = false;

        if (accFields.LAT_ID_Status__c == 'Inactivo') {
            disabled = true;
            ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.severity.WARNING, 'Este centro de consumo no puede ser modificado, solo puede ser activado');
            ApexPages.addMessage(errorMsg);
        }

    }

    private User getUserData() {
        return [SELECT Name, Id, ManagerId, Manager.Name, ProfileId, Profile.Name
                    FROM User
                    WHERE Id =: UserInfo.getUserId()];
    }

    private LAT_Account__c getLATAccount(String accId) {
        List<LAT_Account__c>  listAccLat = [SELECT Id,LAT_MX_AnualContract__c,LAT_plaza__c,LAT_MX_Direccion__c,LAT_MX_InicioConvenio__c,LAT_MX_FinConvenio__c,LAT_MX_Third_Supply_Option__c,LAT_MX_Fourth_Supply_Option__c,LAT_ScoreType__c,LAT_Branding__c,LAT_CalidadBateo__c,
                                            LAT_CubaLibre__c,LAT_DJInternacional__c,LAT_PrecioBacardi__c,LAT_PrecioMinPlatoFuerte__c,
                                            LAT_PromocionesPrecioPaquete__c,LAT_RestriccionesAcceso__c,LAT_SKUChampagne__c,LAT_SKUWhiskies__c,LAT_Somelier__c,LAT_VisibilidadTailorMade__c,LAT_Calificacion__c,
                                            LAT_Coctel__c, LAT_Entrada__c, LAT_PlatoFuerte__c, LAT_Postre__c,LAT_Accountid__c,LAT_Activaciones__c, LAT_Capacitacion__c, LAT_Convenio_prm__c, LAT_Convenio1__c, LAT_Convenio2__c, LAT_Convenio3__c,
                                            LAT_Incentivos__c,LAT_MX_MejorDia__c,LAT_ID_Status__c,LAT_MX_PostalCode__c,LAT_TipoComida__c,LAT_Nombre_Comercial__c,LAT_TipoCentro__c,LAT_Capacidad__c, LAT_Fecha_Apertura__c,
                                            LAT_MX_Neighbourhood__c, LAT_MX_AttendingKAM__c, LAT_MX_HasRecognizedChef__c,
                                             LAT_MX_City__c, LAT_MX_County__c,LAT_MX_SecondSupplyOption__c,LAT_MX_FirstSupplyOption__c, LAT_MX_Periodicity__c, LAT_Accountid__r.Owner.Name
                                            FROM LAT_Account__c
                                            WHERE LAT_Accountid__c =: accId];

        if (!listAccLat.isEmpty()){
            return listAccLat.get(0);
        } else {
            return new LAT_Account__c();
        }
    }



    public PageReference Save() {
        Savepoint sp = Database.setSavepoint();
            try {

                this.loadAccountManager();

                // Needed because AN8 validation prevents null inserts
                if (this.acc.Client_code_AN8__c == null || this.acc.Client_code_AN8__c == '') {
                    this.acc.Client_code_AN8__c = ' ';
                }
                this.acc.SaveDuplicatedFiscalID_AR__c = true;
                system.debug('system.debug' + this.acc);
                
                // Validates if insert reset the Id (if in another save attep this fail the Id is populated even if the insert fail)
                if (this.isInsert) {
                    this.acc.id = null;
                }
                upsert this.acc;

                // Load New account Plaza && Region
                this.loadPlazaRegion();
                // Load New Account Id into related Objects
                LAT_Account__c la =  this.getLATAccount(this.acc.Id);
                this.accFields.id = la.id;

                update accFields;

                creatRFC();
                insertRFCAccount(accFields.id);

                // Redirect to view page
                PageReference pag = new PageReference('/apex/LAT_MX_Account_OnTrade_Profile');
                pag.getParameters().put('id', acc.id);
                return pag;

            } catch( Exception e ){
                Database.rollback(sp);
                // Validates if insert reset the Id (if in another save attep this fail the Id is populated even if the insert fail)
                if (this.isInsert) {
                    this.acc.id = null;
                }
                ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.severity.ERROR, e.getMessage());
                System.debug('LAT_MX_Account_OnTrade_Controller Catch: ' + e.getMessage() + '/n/n' + e);
                ApexPages.addMessage(errorMsg);
                return null;
            }
    }


//Carga todos los RFCs de la cuenta actual, del padre  y llena listaRFCActuales
    public void loadRFC() {
      List<SelectableRFC> listSelec = new List<SelectableRFC>();

      if (this.accFields != null && String.isNotBlank(this.accFields.id)) {
          final List <LAT_MX_RFC_Account__c> listRFC = [SELECT id, LAT_MX_RFC__c, LAT_MX_RFC__r.name, LAT_MX_RFC__r.LAT_RFC__c FROM LAT_MX_RFC_Account__c WHERE LAT_ACCOUNT__c =: this.accFields.id];

          if (listRFC != null && !listRFC.isEmpty()) {
              for (LAT_MX_RFC_Account__c rfcAc : listRFC){
                  listSelec.add(new SelectableRFC(rfcAc.LAT_MX_RFC__r.name, rfcAc.LAT_MX_RFC__r.LAT_RFC__c, true));
              }
          }
      }

     if (String.isNotBlank(this.parentID)) {
          final List <LAT_Account__c> idAccPadreList = [SELECT id FROM LAT_Account__c WHERE LAT_Accountid__c =: this.parentID];

          final LAT_Account__c idAccPadre = (!idAccPadreList.isEmpty()) ? idAccPadreList.get(0) : null;
          if(idAccPadre != null){
              final List<LAT_MX_RFC_Account__c> listRFCPadre = [SELECT id, LAT_MX_RFC__c, LAT_MX_RFC__r.name, LAT_MX_RFC__r.LAT_RFC__c  from LAT_MX_RFC_Account__c WHERE LAT_ACCOUNT__c =: idAccPadre.id];

              if (listRFCPadre != null && !listRFCPadre.isEmpty()) {
                  for (LAT_MX_RFC_Account__c rfcAc : listRFCPadre) {
                      listSelec.add(new SelectableRFC(rfcAc.LAT_MX_RFC__r.name, rfcAc.LAT_MX_RFC__r.LAT_RFC__c,false));
                  }
              }
          }
      }
      this.listaRFCActuales = listSelec;
    }

 //Inserta insertRFCAccount de la cuenta
    public void insertRFCAccount (String accID) {
        List<LAT_MX_RFC_Account__c> newRFCAccount = new List<LAT_MX_RFC_Account__c>();
        if(accId != null && accID != ''){
            List<LAT_MX_RFC_Account__C> oldRFC = [SELECT id FROM LAT_MX_RFC_Account__C where LAT_ACCOUNT__c =: accID];
            if(oldRFC != null && oldRFC.size()>0)
                delete oldRFC;

            if(listaDeRFCNuevos != null && listaDeRFCNuevos.size()>0){
                for(LAT_MX_RFC__c r : listaDeRFCNuevos){
                    LAT_MX_RFC_Account__c rAcc = new LAT_MX_RFC_Account__c();
                    rAcc.LAT_ACCOUNT__c = accID;
                    rAcc.LAT_MX_RFC__c = r.id;
                    newRFCAccount.add(rAcc);
                }
            }
            if(listaDeRFCViejos != null && listaDeRFCViejos.size()>0){
                for(LAT_MX_RFC__c r : listaDeRFCViejos){
                    LAT_MX_RFC_Account__c rAcc = new LAT_MX_RFC_Account__c();
                    rAcc.LAT_ACCOUNT__c = accID;
                    rAcc.LAT_MX_RFC__c = r.id;
                    newRFCAccount.add(rAcc);
                }
            }

        }
        if(newRFCAccount != null && newRFCAccount.size()>0)
            insert newRFCAccount;
    }

//Crea registro de RFC
    public void creatRFC() {
        Set<String> allRFCName = new Set<String>();
        List<String> allRFCold = new List<String>();
        if(listaRFCActuales != null && listaRFCActuales.size()>0){
            List<LAT_MX_RFC__c> allRFC = [SELECT LAT_RFC__c from LAT_MX_RFC__c];
            if(allRFC != null && allRFC.size()>0){
                for(LAT_MX_RFC__c r : allRFC){
                    allRFCName.add(r.LAT_RFC__c);
                }
            }
            for(SelectableRFC r: listaRFCActuales){
                if(!allRFCName.contains(r.rfc) && r.selected){
                    LAT_MX_RFC__c rfc = new LAT_MX_RFC__c();
                    rfc.name = r.razonSocial;
                    rfc.LAT_RFC__c = r.rfc;
                    listaDeRFCNuevos.add(rfc);
                }
                if(allRFCName.contains(r.rfc) && r.selected){
                    allRFCold.add(r.rfc);
                }
            }
        }
        if(listaDeRFCNuevos != null && listaDeRFCNuevos.size()>0){
            insert listaDeRFCNuevos;
        }
        if(allRFCold != null && allRFCold.size()>0)
            listaDeRFCViejos = [SELECT id from LAT_MX_RFC__C where LAT_RFC__c IN : allRFCold];
    }

//Create RFC para la lista que se muestra.
    public void addRFCList() {
        if(listaRFCActuales != null && listaRFCActuales.size() >0){
            Set<String> checkContainsList = new Set<String>();
            for(SelectableRFC  itemsInList: listaRFCActuales){
                checkContainsList.add(itemsInList.rfc);
            }
            if(!checkContainsList.contains(this.rfcSelec))
                if(this.rfcSelec != 'XAXX010101000' && this.rfcSelec != 'XEXX010101000')
                    listaRFCActuales.add(new SelectableRFC(this.rsSelec, this.rfcSelec ,true));
        }else{
            if(this.rfcSelec != 'XAXX010101000' && this.rfcSelec != 'XEXX010101000')
                listaRFCActuales.add(new SelectableRFC(this.rsSelec, this.rfcSelec, true));
        }
    }


    public class SelectableRFC {

        public Boolean selected {get; set;}
        public String  razonSocial {get; set;}
        public String  rfc {get; set;}

        public SelectableRFC(String razonParam, String rfcParam, Boolean selectedParam){
            razonSocial = razonParam;
            rfc = rfcParam;
            selected = selectedParam;
        }
    }

// Right now we are only looking at specific users, profile or roles checking can be added later
    public void loadAccountManager() {
        String parentIdacc = '';
        
        List<User> ListU= [SELECT ManagerId from User where id =: acc.ownerID LIMIT 1];
        if(ListU != null && ListU.size()>0){
            for(User u : ListU){
                parentIdacc = u.ManagerId;
            }
        }
        this.acc.LAT_MX_CreditAndCollectionsExecutive__c = parentIdacc;

        if (isKAMUser()) {
            this.acc.LAT_MX_CreditAndCollectionsExecutive__c = acc.ownerID;
        }
        
    }

    //Busca la plaza y region para el owner y manager de la cuenta
    public void loadPlazaRegion() {
        List<LAT_MX_Plaza__c> plaList = [SELECT id, name from LAT_MX_Plaza__c where lat_mx_ejecutivo__c =:acc.ownerID];
        if(plaList != null && plaList.size() > 0) {
            accFields.LAT_MX_plaza__c = plaList.get(0).id;
        }   

        List<User> uList = [SELECT managerId From User where id =: this.acc.ownerID];
        String mangerIdUser = '';
        if(uList!=null && uList.size()>0 && !isKAMUser()){
            mangerIdUser = uList.get(0).ManagerId;    
        } else {
            mangerIdUser = acc.OwnerId;
        }
        System.debug('%%%%%%% managerIdUser :'+mangerIdUser);
        List<LAT_MX_Region__c> regList = [SELECT id, name from LAT_MX_Region__c where lat_mx_kam__c =:mangerIdUser];
        if(regList != null && regList.size()>0){
            accFields.LAT_MX_region__c = regList.get(0).id;
        }
            
        
    }
    public void loadConvenio (String padreID) {

        List<LAT_Account__c> accLAT = [SELECT LAT_Convenio_prm__c from LAT_Account__c where LAT_Accountid__c =: padreID ];
        LAT_Account__C accPadreLAT = new LAT_Account__C();
        if(accLAT != null && accLAT.size() > 0 ) {
            accPadreLAT = accLAT.get(0);
        }
        accFields.LAT_Convenio_prm__c = accPadreLAT.LAT_Convenio_prm__c;
    }


    public void doDelete() {
        List<SelectableRFC> newListRFCTodos = new List<SelectableRFC>();
        List<LAT_MX_RFC__c> newListRFCNuevo = new List<LAT_MX_RFC__c>();

        if (toDeleteId != null && toDeleteId != '') {
            for(SelectableRFC l : listaRFCActuales){
                if(l.rfc != toDeleteId)
                    newListRFCTodos.add(l);
            }
        }
        for(LAT_MX_RFC__c r : listaDeRFCNuevos){
            if(r.LAT_RFC__c != toDeleteId)
                newListRFCNuevo.add(r);
        }
       listaRFCActuales =  newListRFCTodos;
       listaDeRFCNuevos = newListRFCNuevo;
    }

    private boolean isKAMUser(){

        final String users = LAT_GeneralConfig__c.getInstance('MX_ON_TRADE_NO_KAM_USERS').LAT_Value__c;
        this.isKAMUser = false;
        User u = [SELECT Name FROM User WHERE Id = :acc.OwnerId];
        if (users.contains(u.Name)) {
        
            this.isKAMUser = true;
        }
        System.debug('%%%%% retorno --> ' + this.isKAMUser);
        return this.isKAMUser; 
        
    }
}