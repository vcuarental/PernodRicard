public with sharing class MMPJ_XRM_Segmentation_Controller {
	private final Campaign myCampaign;
    private Map<String,critereClass> criteres;
    public List<SelectOption> criteresOptions{get;set;} 
    public Map<String,critereClass> criteresOptionsMap{get;set;}
    //public List<SelectOptionClass> criteresOptions{get;set;}
    private List<operateurClass> operateurs;
    public List<SelectOption> operateursOptions{get;set;}
    public List<searchCriteriaClass> searchCriterias {get;set;}
    public Integer searchCriteriasDeleted{get;set;}
    public Integer searchCriteriasModified{get;set;}
    public List<contactClass> contacts{get;set;}
    private List<ContactClass> allContactsList {get;set;} 
    private Map<Id,CampaignMember> campaignMembers; 
    public Set<Id> ContactIdList{get;set;} 
    public Boolean isFirstLoad{get;set;}
    public Integer firstIndex{get;set;}
    public Integer lastIndex{get;set;}
    public Boolean globalCheck{get;set;}
    public Boolean displayFinishMessage{get;set;}
    public Boolean querySubAccount{get;set;}
    public Boolean queryTopAccount{get;set;}
    public String orderField{get;set;}
    public Boolean orderAsc{get;set;}
    public String searchFilters{get;set;}
    private static final Integer PAGESIZE = 200;
    static final String TEXT_TYPE = 'Text';
    static final String DATE_TYPE = 'Date';
    static final String PICKLIST_TYPE = 'PickList';
    static final String PICKLIST_EXT_TYPE = 'PickListExtend';
    static final String PICKLIST_FROM_LABEL_TYPE = 'PickListFromLabel';
    static final String USER_TYPE = 'User';
    static final String RECORDTYPE_TYPE = 'RecordType';
    static final String NUMBER_TYPE = 'Number';
    static final String CHECKBOX_TYPE = 'CheckBox';
    static final String SOCIETE_TYPE = 'MMPJ_Ext_Vign_Societe__c';
    private Boolean isCampaignContext;
    public Boolean SegmentationFromCampaign{get;set;}
    public String context{get;set;}
    public String labelFilters { get; set; }
    public String labelBackToCampaign { get; set; }
    public String labelAddFilter { get; set; }
    public String labelResetFilters { get; set; }
    public String labeExportCampaignMembers { get; set; }
    public String labelSearch { get; set; }
    public String labelDelete { get; set; }
    public String labelFilter { get; set; }
    public String labelOperator { get; set; }
    public String labelValue { get; set; }
    public String labelResults { get; set; } 
    public String labelFirstName { get; set; }
    public String labelName { get; set; }
    public String labelCompany { get; set; }
    public String labelPrevious { get; set; }
    public String labelNext { get; set; }
    public String labelIncludeLinkedCompanies { get; set; }
    public String labelIncludeTopCompanies { get; set; }
    public String labelCheckAllContacts { get; set; }
    public String labelUncheckAllContacts { get; set; }
    public String labelExportContacts { get; set; }
    public String labelUpdateTarget { get; set; } 
    public String labelDisplayCampaignMember { get; set; }
    public Boolean shouldBeDisplayedForMypjCampaign;


    public MMPJ_XRM_Segmentation_Controller(ApexPages.StandardController stdController) {
        orderAsc = true;
        querySubAccount = false;
        queryTopAccount = false;
        displayFinishMessage = false;
        this.myCampaign = (Campaign)stdController.getRecord();
        SegmentationFromCampaign = (this.myCampaign.Id != null) ? true : false;
        isFirstLoad = true;
        initCriteres(this.myCampaign);
        initOperateurs();
        initSearchCriterias();
        if(SegmentationFromCampaign)
            initCampaignMembers();
        searchCriteriasDeleted = null;
        globalCheck = false;
        isCampaignContext = false;
        
    }

    private void initCampaignMembers()
    {

        campaignMembers = new Map<Id,CampaignMember>();
        for(CampaignMember member:[select Id,ContactId, MMPJ_XRM_Societe__r.Id, MMPJ_XRM_Societe__r.Name from CampaignMember where CampaignId=:myCampaign.Id])
            campaignMembers.put(member.ContactId,member);
    }

    private void initCriteres(Campaign campaign) {
        criteres = new Map<String,critereClass>();

        String mypjRecordTypeId = Schema.SobjectType.Campaign.getRecordTypeInfosByDeveloperName().get( 'MYPJ_Campaign' )?.getRecordTypeId();

        // Boolean 
        shouldBeDisplayedForMypjCampaign = (mypjRecordTypeId != null ? mypjRecordTypeId.equals( campaign.RecordTypeId ) : false);

        /* */
        labelFilters = (!shouldBeDisplayedForMypjCampaign ? 'Critères de recherche' : 'Filters');
        labelBackToCampaign = (!shouldBeDisplayedForMypjCampaign ? 'Retour à la campagne' : 'Back to campaign');
        labelAddFilter = (!shouldBeDisplayedForMypjCampaign ? 'Ajouter un critère' : 'Add a filter');
        labelResetFilters = (!shouldBeDisplayedForMypjCampaign ? 'Réinitialiser' : 'Reset filters');
        labeExportCampaignMembers = (!shouldBeDisplayedForMypjCampaign ? 'Export Invités' : 'Export Campaign Members');
        labelSearch = (!shouldBeDisplayedForMypjCampaign ? 'Rechercher' : 'Search');
        labelDelete = (!shouldBeDisplayedForMypjCampaign ? 'Supprimer' : 'Delete');
        labelFilter = (!shouldBeDisplayedForMypjCampaign ? 'Critère' : 'Filter');
        labelOperator = (!shouldBeDisplayedForMypjCampaign ? 'Opérateur' : 'Operator'); 
        labelValue = (!shouldBeDisplayedForMypjCampaign ? 'Valeur' : 'Value');	
        labelResults = (!shouldBeDisplayedForMypjCampaign ? 'Résultats de recherche' : 'Results'); 
        labelFirstName = (!shouldBeDisplayedForMypjCampaign ? 'Prénom' : 'First name');
        labelName = (!shouldBeDisplayedForMypjCampaign ? 'Nom' : 'Last name'); 
        labelCompany = (!shouldBeDisplayedForMypjCampaign ? 'Société(s)' : 'Company');
        labelPrevious = (!shouldBeDisplayedForMypjCampaign ? 'Précédent': 'Previous');
        labelNext = (!shouldBeDisplayedForMypjCampaign ? 'Suivant' : 'Next'); 
        labelIncludeLinkedCompanies = (!shouldBeDisplayedForMypjCampaign ? 'Inclure les société liées' : 'Include all linked companies'); 
        labelIncludeTopCompanies = (!shouldBeDisplayedForMypjCampaign ? 'Inclure aux unions' : 'Include top companies'); 
        labelCheckAllContacts = (!shouldBeDisplayedForMypjCampaign ? 'Cocher tous les contacts' : 'Check all contacts'); 
        labelUncheckAllContacts = (!shouldBeDisplayedForMypjCampaign ? 'Décocher tous les contacts' : 'Uncheck all contacts'); 
        labelExportContacts = (!shouldBeDisplayedForMypjCampaign ? 'Exporter les contacts' : 'Export contacts'); 
        labelUpdateTarget = (!shouldBeDisplayedForMypjCampaign ? 'Mettre à jour la cible' : 'Update the target'); 
        labelDisplayCampaignMember = (!shouldBeDisplayedForMypjCampaign ? 'Voir les membres de campagne' : 'Display campaign members'); 
        /* */

        if ( ! shouldBeDisplayedForMypjCampaign ) {
            criteres.put('001',new critereClass('001','Societe : Raison Sociale','MMPJ_Ext_Vign_Societe__c','Name', TEXT_TYPE));
            criteres.put('002',new critereClass('002','Societe : Ville / Commune','MMPJ_Ext_Vign_Societe__c','MMPJ_Ext_Vign_Ville__c', TEXT_TYPE));
            criteres.put('003',new critereClass('003','Societe : Type d\'enregistrement','MMPJ_Ext_Vign_Societe__c','RecordType.Name', RECORDTYPE_TYPE));
            criteres.put('004',new critereClass('004','Societe : Statut','MMPJ_Ext_Vign_Societe__c','MMPJ_Ext_Vign_Statut__c', PICKLIST_TYPE));
            criteres.put('005',new critereClass('005','Societe : Code Postal','MMPJ_Ext_Vign_Societe__c','MMPJ_Ext_Vign_Code_Postal__c', TEXT_TYPE));
            //criteres.put('006',new critereClass('006','Societe : Tiers déblocage','MMPJ_Ext_Vign_Societe__c','MMPJ_XRM_Tiers_Deblocage__c', CHECKBOX_TYPE));
            criteres.put('008',new critereClass('008','Societe : Segmentation','MMPJ_Ext_Vign_Societe__c','MMPJ_Ext_Vign_Societe_Segmentation__c', PICKLIST_TYPE));
            criteres.put('009',new critereClass('009','Societe : Propriétaire du compte','MMPJ_Ext_Vign_Societe__c','OwnerId', USER_TYPE));
            criteres.put('010',new critereClass('010','Societe : Superficie exploitée (ha)','MMPJ_Ext_Vign_Societe__c','MMPJ_XRM_Superficie_exploitee__c', NUMBER_TYPE));
            criteres.put('011',new critereClass('011','Societe : Alias Propriétaire du compte','MMPJ_Ext_Vign_Societe__c','Owner.Alias', TEXT_TYPE));
        }
        
        if ( ! shouldBeDisplayedForMypjCampaign ) {
            criteres.put('101',new critereClass('101','Contact : Martell Fonction','MMPJ_Ext_Vign_Societe_Contact__c','MMPJ_Ext_Vign_Fonction__c', PICKLIST_TYPE));
            criteres.put('102',new critereClass('102','Contact : MPJ - Titre','MMPJ_Ext_Vign_Societe_Contact__c','MMPJ_XRM_Titre__c', PICKLIST_TYPE));
        }
        criteres.put('103',new critereClass('103',(!shouldBeDisplayedForMypjCampaign ? 'Contact : Contact Principal' : 'Contact : Primary Contact'),'MMPJ_Ext_Vign_Societe_Contact__c','MMPJ_Ext_Vign_Contact_Principal__c', CHECKBOX_TYPE));
        
        criteres.put('201',new critereClass('201',(!shouldBeDisplayedForMypjCampaign ? 'Contact : Civilité' : 'Contact : Salutation'),'Contact','Salutation', PICKLIST_FROM_LABEL_TYPE));
        criteres.put('202',new critereClass('202',(!shouldBeDisplayedForMypjCampaign ? 'Contact : Nom' : 'Contact : Name'),'Contact','LastName', TEXT_TYPE));
        if ( shouldBeDisplayedForMypjCampaign ) {
            criteres.put('212',new critereClass('212','Contact : Name (Kana)','Contact','MYPJ_Last_Name_in_Kana__c', TEXT_TYPE));
        }
        criteres.put('203',new critereClass('203',(!shouldBeDisplayedForMypjCampaign ? 'Contact : Prénom' : 'Contact : First name'),'Contact','FirstName', TEXT_TYPE));
        if ( shouldBeDisplayedForMypjCampaign ) {
            criteres.put('213',new critereClass('213','Contact : First name (Kana)','Contact','MYPJ_First_Name_Kana__c', TEXT_TYPE));
            criteres.put('210',new critereClass('210','Contact : E-mail','Contact','Email', TEXT_TYPE));
            criteres.put('211',new critereClass('211','Contact : Mobile','Contact','MYPJ_Mobile_Phone__c', TEXT_TYPE));
            criteres.put('214',new critereClass('214','Contact : Gender','Contact','MYPJ_Gender__c', PICKLIST_TYPE));
            criteres.put('215',new critereClass('215','Contact : Prefecture','Contact','MYPJ_Prefecture__c', TEXT_TYPE));
            criteres.put('216',new critereClass('216','Contact : City','Contact','MailingCity', TEXT_TYPE));
            // 217 Age gvp__Age_Calculated__c?
            criteres.put('218',new critereClass('218','Contact : Profession','Contact','MYPJ_Profession__c', PICKLIST_TYPE));
            // Profession vs Profession Type?
            criteres.put('219',new critereClass('219','Contact : Company','Contact','MYPJ_Company_Name__c', TEXT_TYPE));
            // 222 Registration ???
            // criteres.put('221',new critereClass('220','Contact : Total events participation','Contact','MYPJ_Total_events_participation__c', NUMBER_TYPE));
            // criteres.put('220',new critereClass('221','Contact : Segment','Contact','MYPJ_Segment__c', PICKLIST_TYPE));
        }
        criteres.put('204',new critereClass('204',(!shouldBeDisplayedForMypjCampaign ? 'Contact : Date de naissance' : 'Contact : Birthdate'),'Contact','MMPJ_Ext_Vign_Contacts_Date_de_naissance__c', DATE_TYPE));
        criteres.put('205',new critereClass('205',(!shouldBeDisplayedForMypjCampaign ? 'Contact : Arts et Culture' : 'Contact : Arts and Culture'),'Contact','MMPJ_Ext_Vign_Arts_et_Culture__c', PICKLIST_TYPE));
        criteres.put('206',new critereClass('206','Contact : Sports','Contact','MMPJ_Ext_Vign_Sports__c', PICKLIST_TYPE));
        criteres.put('207',new critereClass('207',(!shouldBeDisplayedForMypjCampaign ? 'Contact : Loisirs' : 'Contact : Hobbies'),'Contact','MMPJ_Ext_Vign_Loisirs__c', PICKLIST_TYPE));
        criteres.put('208',new critereClass('208',(!shouldBeDisplayedForMypjCampaign ? 'Contact : Autres' : 'Contact : Others'),'Contact','MMPJ_Ext_Vign_Autres__c', PICKLIST_TYPE));
        criteres.put('209',new critereClass('209','Contact : Blacklist','Contact','MMPJ_Ext_Vign_Blacklist__c', CHECKBOX_TYPE));

        if ( ! shouldBeDisplayedForMypjCampaign ) {
            criteres.put('301',new critereClass('301','Contrat : Cru','MMPJ_Ext_Vign_Contrat__c','MMPJ_Ext_Vign_Cru__c',PICKLIST_TYPE));
            criteres.put('302',new critereClass('302','Contrat : Surface Contrat (ha)','MMPJ_Ext_Vign_Contrat__c','MMPJ_Ext_Vign_Surface_Contrat_ha__c', NUMBER_TYPE));
            criteres.put('303',new critereClass('303','Contrat : Type d\'enregistrement','MMPJ_Ext_Vign_Contrat__c','RecordType.Name', RECORDTYPE_TYPE));
            criteres.put('304',new critereClass('304','Contrat : Date de début du contrat','MMPJ_Ext_Vign_Contrat__c','MMPJ_Ext_Vign_Date_de_debut_du_contrat__c', DATE_TYPE));
            criteres.put('305',new critereClass('305','Contrat : Date de fin du contrat','MMPJ_Ext_Vign_Contrat__c','MMPJ_Ext_Vign_Date_de_fin_du_contrat__c', DATE_TYPE));
            criteres.put('306',new critereClass('306','Contrat : Type de contrat','MMPJ_Ext_Vign_Contrat__c','MMPJ_Ext_Vign_Type_de_contrat__c', PICKLIST_TYPE));
        }

        criteres.put('401',new critereClass('401',(!shouldBeDisplayedForMypjCampaign ? 'Campagne : Propriétaire de la campagne' : 'Campaign : Owner of the campaign'),'Campaign','OwnerId', USER_TYPE));
        criteres.put('402',new critereClass('402',(!shouldBeDisplayedForMypjCampaign ? 'Campagne : Nom de la campagne' : 'Campaign : Name'),'Campaign','Name', TEXT_TYPE));
        criteres.put('403',new critereClass('403',(!shouldBeDisplayedForMypjCampaign ? 'Campagne : Date de début' : 'Campaign : Start date'),'Campaign','StartDate', DATE_TYPE));
        criteres.put('404',new critereClass('404',(!shouldBeDisplayedForMypjCampaign ? 'Campagne : Date de fin' : 'Campaign : End date'),'Campaign','EndDate', DATE_TYPE));
        criteres.put('405',new critereClass('405',(!shouldBeDisplayedForMypjCampaign ? 'Campagne : Type' : 'Campaign : Type'),'Campaign','Type', PICKLIST_FROM_LABEL_TYPE));
        criteres.put('406',new critereClass('406',(!shouldBeDisplayedForMypjCampaign ? 'Campagne : Sous Type' : 'Campaign : Sub type'),'Campaign','MMPJ_XRM_Sous_type__c', PICKLIST_TYPE));
        if ( shouldBeDisplayedForMypjCampaign ) {
            // code ???                criteres.put('408',new critereClass('408','Campagne : Code','Campaign','???', CHECKBOX_TYPE));
            criteres.put('409',new critereClass('409','Campaign : Price','Campaign','MYPJ_Price__c', NUMBER_TYPE));
            criteres.put('410',new critereClass('410','Campaign : Ambassador','Campaign','MYPJ_Ambassador__c.FullName', TEXT_TYPE));
            criteres.put('411',new critereClass('411','Campaign : Memo','Campaign','MYPJ_Memo__c', TEXT_TYPE));
        }
        criteres.put('407',new critereClass('407',(!shouldBeDisplayedForMypjCampaign ? 'Campagne : Alias Propriétaire de la campagne' : 'Campaign : Alias of the Campaign Owner'),'Campaign','Owner.Alias', TEXT_TYPE));

        criteres.put('501',new critereClass('501',(!shouldBeDisplayedForMypjCampaign ? 'Membre : Status'  : 'Member : Status'),'CampaignMember','Status', PICKLIST_FROM_LABEL_TYPE));
        criteres.put('502',new critereClass('502',(!shouldBeDisplayedForMypjCampaign ? 'Membre : Participation' : 'Member : Participation'),'CampaignMember','MMPJ_Ext_Vign_Participation__c', PICKLIST_TYPE));
        criteres.put('503',new critereClass('503',(!shouldBeDisplayedForMypjCampaign ? 'Membre : Présence': 'Member : Attendance'),'CampaignMember','MMPJ_Ext_Vign_Presence__c', PICKLIST_TYPE));
        //possibilité de filtrer avec la société se trouvant sur le campaign member
        criteres.put('504',new critereClass('504',(!shouldBeDisplayedForMypjCampaign ? 'Membre : Societé' : 'Member : Company'),'CampaignMember','MMPJ_XRM_Societe__c', SOCIETE_TYPE, campaign));
        

        criteresOptions = new List<SelectOption>();
        criteresOptionsMap = new Map<String,critereClass>();
        criteresOptions.add(new SelectOption('', ''));
        for(String num:criteres.keySet())
        {
            criteresOptions.add(new SelectOption( num, criteres.get(num).libelle));
            criteresOptionsMap.put(num,criteres.get(num));
        }

        /*criteresOptions = new List<SelectOptionClass>();
        criteresOptions.add(new SelectOptionClass('', ''));
        for(String num:criteres.keySet())
            criteresOptions.add(new SelectOptionClass( num, criteres.get(num).libelle));*/

    }

    private void initOperateurs() {
        operateurs = new List<operateurClass>();
        operateurs.add(new operateurClass('Equal', (!shouldBeDisplayedForMypjCampaign ? 'égale à' : 'equals to')));
        operateurs.add(new operateurClass('NotEqual', (!shouldBeDisplayedForMypjCampaign ? 'différent de' : 'not equals to')));
        operateurs.add(new operateurClass('StartWith', (!shouldBeDisplayedForMypjCampaign ? 'commence par' : 'begins with')));
        operateurs.add(new operateurClass('Contain', (!shouldBeDisplayedForMypjCampaign ? 'contient' : 'contains')));
        operateurs.add(new operateurClass('NotContain', (!shouldBeDisplayedForMypjCampaign ? 'ne contient pas' : 'does not contain')));
        operateurs.add(new operateurClass('Inferior', (!shouldBeDisplayedForMypjCampaign ? 'inférieur à' : 'less than')));
        operateurs.add(new operateurClass('Superior', (!shouldBeDisplayedForMypjCampaign ? 'supérieur à' : 'greater than')));
        operateurs.add(new operateurClass('Include', (!shouldBeDisplayedForMypjCampaign ? 'inclus' : 'includes')));
        operateurs.add(new operateurClass('Exclude', (!shouldBeDisplayedForMypjCampaign ? 'exclus' : 'excludes')));

        operateursOptions = new List<SelectOption>();
        operateursOptions.add(new SelectOption('', ''));
        for(operateurClass op:operateurs)
            operateursOptions.add(new SelectOption(op.operateur, op.libelle));
    }

    private void initSearchCriterias()
    {
        searchCriterias = new List<searchCriteriaClass>();
        for(Integer i=0;i<3;i++)
            searchCriterias.add(new searchCriteriaClass(i));
    }

    public void addSearchCriterias()
    {
        searchCriterias.add(new searchCriteriaClass(searchCriterias.size()));
    }

    public void removeSearchCriterias()
    {
        if(searchCriteriasDeleted != null)
            searchCriterias.remove(searchCriteriasDeleted);
        for(Integer i=0; i < searchCriterias.size() ; i++)
            searchCriterias[i].numero = i;
    }

    public void lookForSearchInput()
    {
        System.debug('##### searchCriteriasModified = ' + searchCriteriasModified);
        if(searchCriteriasModified != null)
        {
            searchCriterias[searchCriteriasModified].searchText = '';
            /*if(searchCriterias[searchCriteriasModified].selectedOperateur == '')
                searchCriterias[searchCriteriasModified].selectedOperateur = 'Equal';*/
        }

    }

    public void checkAll()
    {
        displayFinishMessage = false;
        globalCheck = !globalCheck;
        for(contactClass cc:allContactsList)
            cc.isSelected = globalCheck;
    }

    public void reorder()
    {
        initContactList(ContactIdList,isCampaignContext);
        orderAsc = !orderAsc;
    }

    public void reload()
    {
        /*PageReference page = ApexPages.currentPage();
        page.setRedirect(true);
        return page;*/
        displayFinishMessage = false;
        globalCheck = false;
        initSearchCriterias();
        querySubAccount = false;
        queryTopAccount = false;
    }

    public static String getLabelValues(String labelName ){
        Component.Apex.OutputText output = new Component.Apex.OutputText();
        output.expressions.value = '{!$Label.' + labelName + '}';
        return String.valueOf(output.value);
    }

    public void search()
    {
        displayFinishMessage = false;
        search(false);
    }

    private void search(Boolean excludeInserted)
    {
        orderAsc = true;
        orderField = 'LastName';
        isCampaignContext = false;
        initCampaignMembers();
        isFirstLoad = false;
        Integer totalCriterias = 0;
        
        Boolean    queryCompteParams = false;
        //String queryCompte = 'select MMPJ_Ext_Vign_Contact__c from MMPJ_Ext_Vign_Societe_Contact__c where (MMPJ_Ext_Vign_Societe__r.MMPJ_Ext_Vign_Societe_Segmentation__c = \'Cognac\' OR MMPJ_Ext_Vign_Societe__r.MMPJ_Ext_Vign_Societe_Segmentation__c = \'Champagne\')';
        String     queryCompte       = 'select Id, Name from MMPJ_Ext_Vign_Societe__c where (MMPJ_Ext_Vign_Societe_Segmentation__c = \'Cognac\' OR MMPJ_Ext_Vign_Societe_Segmentation__c = \'Champagne\') ';
        Set < Id > queryCompteMatchs = new Set < Id >();

        Boolean    queryContactParams = false;
        String     queryContact       = 'SELECT Id FROM Contact';
        Set < Id > queryContactMatchs = new Set < Id >();

        Boolean    queryContratParams = false;
        String     queryContrat       = 'select MMPJ_Ext_Vign_Livreur__c from MMPJ_Ext_Vign_Contrat__c where (MMPJ_Ext_Vign_Contrat_Segmentation__c = \'Cognac\' OR MMPJ_Ext_Vign_Contrat_Segmentation__c = \'Champagne\')';
        Set < Id > queryContratMatchs = new Set < Id >();

        Boolean    querySocieteContactParams = false;
        String     querySocieteContact       = 'select MMPJ_Ext_Vign_Contact__c from MMPJ_Ext_Vign_Societe_Contact__c where (MMPJ_Ext_Vign_Societe__r.MMPJ_Ext_Vign_Societe_Segmentation__c = \'Cognac\' OR MMPJ_Ext_Vign_Societe__r.MMPJ_Ext_Vign_Societe_Segmentation__c = \'Champagne\')';
        Set < Id > querySocieteContactMatchs = new Set < Id >();

        Boolean    queryCampaignParams = false;
        String     queryCampaign       = 'SELECT Id FROM Campaign';
        Set < Id > queryCampaignMatchs = new Set < Id >();

        Boolean    queryCampaignmemberParams = false;
        String     queryCampaignMember       = 'SELECT ContactId, MMPJ_XRM_Societe__c FROM CampaignMember';
        Set < Id > queryCampaignmemberMatchs = new Set < Id >();
        
        String mypjContactRecordTypeId        = Schema.SobjectType.Contact.getRecordTypeInfosByDeveloperName().get( 'MYPJ_Contact' ).getRecordTypeId();
        String mypjCampaignRecordTypeId       = Schema.SobjectType.Campaign.getRecordTypeInfosByDeveloperName().get( 'MYPJ_Campaign' ).getRecordTypeId();
        String mypjCampaignMemberRecordTypeId = Schema.SobjectType.CampaignMember.getRecordTypeInfosByDeveloperName().get( 'MYPJ' ).getRecordTypeId();
        
        if ( mypjCampaignRecordTypeId.equals( myCampaign.RecordTypeId ) ) {
            queryContact        += ' WHERE RecordTypeId = \'' + mypjContactRecordTypeId + '\'';
            queryCampaign       += ' WHERE RecordTypeId = \'' + mypjCampaignRecordTypeId + '\'';
            queryCampaignMember += ' WHERE RecordTypeId = \'' + mypjCampaignMemberRecordTypeId + '\'';
        } else {
            queryContact        += ' WHERE (MMPJ_Ext_Vign_Contact_Segmentation__c = \'Cognac\' OR MMPJ_Ext_Vign_Contact_Segmentation__c = \'Champagne\')';
            queryCampaign       += ' WHERE RecordType.DeveloperName = \'MMPJ_Ext_Vign_Campaign\'';
            queryCampaignMember += ' WHERE Campaign.RecordType.DeveloperName = \'MMPJ_Ext_Vign_Campaign\'';
        }

        for(searchCriteriaClass c:searchCriterias)
        {
            if(String.isNotBlank(c.selectedCritere) && String.isNotBlank(c.selectedOperateur))
            {
                if(c.selectedCritere.left(1) == '0')
                {
                    queryCompteParams = true;
                    queryCompte += ' AND ' + makeWhere(criteres.get(c.selectedCritere).champ,c);
                }
                else if(c.selectedCritere.left(1) == '2')
                {
                    queryContactParams = true;
                    queryContact += ' AND ' + makeWhere(criteres.get(c.selectedCritere).champ,c);
                }
                else if(c.selectedCritere.left(1) == '3')
                {
                    queryContratParams = true;
                    queryContrat += ' AND ' + makeWhere(criteres.get(c.selectedCritere).champ,c);
                } else if(c.selectedCritere.left(1) == '1')
                {
                    querySocieteContactParams = true;
                    querySocieteContact += ' AND ' + makeWhere(criteres.get(c.selectedCritere).champ,c);
                } else if(c.selectedCritere.left(1) == '4')
                {
                    queryCampaignParams = true;
                    queryCampaign += ' AND ' + makeWhere(criteres.get(c.selectedCritere).champ,c);
                } else if(c.selectedCritere.left(1) == '5')
                {
                    queryCampaignMemberParams = true;
                    queryCampaignMember += ' AND ' + makeWhere(criteres.get(c.selectedCritere).champ,c);
                } 
            }
        }

        if(queryCompteParams)
        {
            System.debug('##### QueryCompte = ' + queryCompte);
            Set<Id> societes = new Set<Id>();

            for(MMPJ_Ext_Vign_Societe__c soc:Database.query(queryCompte))
            {
                System.debug('## societe trouvée : ' + soc.Id);
                societes.add(soc.Id);
            }
            if(querySubAccount)
            {
                for(MMPJ_XRM_RelationSociete__c rel:[select MMPJ_XRM_Societe_liee__c,MMPJ_XRM_Livreur__c from MMPJ_XRM_RelationSociete__c where MMPJ_XRM_Livreur__c IN:societes or MMPJ_XRM_Societe_liee__c IN:societes])
                {
                    System.Debug('## MMPJ_XRM_Societe_liee__c : ' + rel.MMPJ_XRM_Societe_liee__c + ' / MMPJ_XRM_Livreur__c : ' +  rel.MMPJ_XRM_Livreur__c);
                    if(!societes.contains(rel.MMPJ_XRM_Societe_liee__c))
                        societes.add(rel.MMPJ_XRM_Societe_liee__c);
                    if(!societes.contains(rel.MMPJ_XRM_Livreur__c))
                        societes.add(rel.MMPJ_XRM_Livreur__c);
                }
            }

            if(queryTopAccount)
            {
                //Query all Hierarchy
                //query via MMPJ_XRM_Societe_Chapeau__c. 
                Set<Id> societesParents = new Set<Id>();
                societesParents.addAll(queryTopAccounts(societes,true));
                Set<Id> societesEnfants = new Set<Id>();
                societesEnfants.addAll(queryTopAccounts(societes,false));
                societes.addAll(societesParents);
                societes.addAll(societesEnfants);
            }

            String theQuery = 'select MMPJ_Ext_Vign_Contact__c from MMPJ_Ext_Vign_Societe_Contact__c where (MMPJ_Ext_Vign_Societe__r.MMPJ_Ext_Vign_Societe_Segmentation__c = \'Cognac\' OR MMPJ_Ext_Vign_Societe__r.MMPJ_Ext_Vign_Societe_Segmentation__c = \'Champagne\') AND MMPJ_Ext_Vign_Societe__c IN:societes order by MMPJ_Ext_Vign_Societe__r.Name ';

            for(MMPJ_Ext_Vign_Societe_Contact__c sc:Database.query(theQuery))
                queryCompteMatchs.add(sc.MMPJ_Ext_Vign_Contact__c);
        }

        if(querySocieteContactParams)
        {
            System.debug('##### querySocieteContact = ' + querySocieteContact);
            for(MMPJ_Ext_Vign_Societe_Contact__c sc:Database.query(querySocieteContact))
                querySocieteContactMatchs.add(sc.MMPJ_Ext_Vign_Contact__c);
        }

        if(queryContactParams)
        {
            System.debug('##### queryContact = ' + queryContact);
            for(Contact con:Database.query(queryContact))
                queryContactMatchs.add(con.Id);
        }

        if(queryCampaignMemberParams)
        {
            System.debug('##### queryCampaignMember = ' + queryCampaignMember);
            for(CampaignMember cm:Database.query(queryCampaignMember))
                queryCampaignMemberMatchs.add(cm.ContactId);
        }

        if(queryContratParams)
        {
            System.debug('##### queryContrat = ' + queryContrat);
            Set<Id> societes = new Set<Id>();
            for(MMPJ_Ext_Vign_Contrat__c contrat:Database.query(queryContrat))
                societes.add(contrat.MMPJ_Ext_Vign_Livreur__c);

            String theQuery = 'select MMPJ_Ext_Vign_Contact__c from MMPJ_Ext_Vign_Societe_Contact__c where (MMPJ_Ext_Vign_Societe__r.MMPJ_Ext_Vign_Societe_Segmentation__c = \'Cognac\' OR MMPJ_Ext_Vign_Societe__r.MMPJ_Ext_Vign_Societe_Segmentation__c = \'Champagne\') AND MMPJ_Ext_Vign_Societe__c IN:societes';
            
            for(MMPJ_Ext_Vign_Societe_Contact__c sc:Database.query(theQuery))
                queryContratMatchs.add(sc.MMPJ_Ext_Vign_Contact__c);
        }

        if(queryCampaignParams)
        {

            System.debug('##### queryCampaign = ' + queryCampaign);
            List<Campaign> campagnes = Database.query(queryCampaign);
            String theQuery = 'select ContactId from CampaignMember where Campaign.RecordType.DeveloperName = \'MMPJ_Ext_Vign_Campaign\' AND CampaignId IN:campagnes';
            
            for(CampaignMember sc:Database.query(theQuery))
                queryCampaignMatchs.add(sc.ContactId);
        }

        Set<Id> finalContactIdList = new Set<Id>();

        Set<Id> allContacts = new Set<Id>();
        if(queryCompteParams)
            allContacts.addAll(queryCompteMatchs);
        if(queryContactParams)
            allContacts.addAll(queryContactMatchs);
        if(queryContratParams)
            allContacts.addAll(queryContratMatchs);
        if(querySocieteContactParams)
            allContacts.addAll(querySocieteContactMatchs);
        if(queryCampaignParams)
            allContacts.addAll(queryCampaignMatchs);
        if(queryCampaignMemberParams)
            allContacts.addAll(queryCampaignMemberMatchs);

        for(Id conId:allContacts)
        {
            if(
                (!queryCompteParams ||(queryCompteParams && queryCompteMatchs.contains(conId)))
                &&
                 (!queryContactParams ||(queryContactParams && queryContactMatchs.contains(conId)))
                 &&
                  (!queryContratParams ||(queryContratParams && queryContratMatchs.contains(conId)))
                  &&
                  (!querySocieteContactParams ||(querySocieteContactParams && querySocieteContactMatchs.contains(conId)))
                  &&
                  (!queryCampaignParams ||(queryCampaignParams && queryCampaignMatchs.contains(conId)))
                  &&
                  (!queryCampaignMemberParams ||(queryCampaignMemberParams && queryCampaignMemberMatchs.contains(conId)))
                  &&
                  (!excludeInserted || (excludeInserted && !campaignMembers.containsKey(conId)))
                )
            {
                finalContactIdList.add(conId);
            }
        }

        initContactList(finalContactIdList,false);
        orderAsc = !orderAsc;

        searchFilters = makeFiltersToString();
        System.debug('### filters : ' + searchFilters);

    }

    private Set<ID> queryTopAccounts(Set<Id> accountsIds, Boolean queryParents)
    {
        Set<Id> accountsLocalIds = new Set<Id>();
        if(queryParents)
        {
            for(MMPJ_Ext_Vign_Societe__c soc:[select MMPJ_XRM_Societe_Chapeau__c from MMPJ_Ext_Vign_Societe__c where Id IN : accountsIds])
                accountsLocalIds.add(soc.MMPJ_XRM_Societe_Chapeau__c);
        } else {
             for(MMPJ_Ext_Vign_Societe__c soc:[select Id from MMPJ_Ext_Vign_Societe__c where MMPJ_XRM_Societe_Chapeau__c IN : accountsIds])
                accountsLocalIds.add(soc.Id);
        }

        if(accountsLocalIds.size() > 0)
            accountsLocalIds.addAll(queryTopAccounts(accountsLocalIds,queryParents));

        return accountsLocalIds;
    }

    private void initContactList(Set<Id> contactsId, Boolean isAllTrue)
    {
        contacts = new List<contactClass>();
        allContactsList = new List<contactClass>();
        ContactIdList = contactsId;
        String queryContacts = 'select Id,FirstName, LastName, (select MMPJ_Ext_Vign_Societe__c, MMPJ_Ext_Vign_Contact_Principal__c, MMPJ_Ext_Vign_Fonction__c, MMPJ_Ext_Vign_Societe__r.Name from SocietesContacts__r ORDER BY MMPJ_Ext_Vign_Societe__r.Name) from Contact where Id IN:contactsId';
        queryContacts += ' order by';
        queryContacts += (String.isBlank(orderField)) ? ' LastName' : (' ' + orderField);
        queryContacts += (orderAsc) ? ' ASC' : ' DESC';
        queryContacts += ' LIMIT 10000';
        for(Contact con:DataBase.query(queryContacts))
        {
            Boolean isSelected;
            String societePrincipale;
            if(isAllTrue)
                isSelected = true;
            else
                isSelected = campaignMembers.containsKey(con.Id) ? true : false;
                
            Set<selectOption> lesSocietes = new Set<selectOption>();
            List<SelectOption> listofCompaniesToReturn = new List<SelectOption>(); 
            
            for(MMPJ_Ext_Vign_Societe_Contact__c so: con.SocietesContacts__r)
            {
            //modified by Amadou
            //désormais les sociétés ne sont plus affichées en concaténant leurs noms 
            //elles sont affichées désormais dans une picklist que l'utilisateur peut modifier à sa guise
            //lorsque le contact est contact principale dans une société, 
            //la société par défaut sera cette dernière, et les autres sociétés auxquelles il appartient 
            //s'afficheront dans une picklist par ordre alphabétique. 
            //si le contact n'est contact principale dans aucune société, 
            //on affichera la liste des sociétés par ordre alphabétique
                
                if(so.MMPJ_Ext_Vign_Contact_Principal__c || con.SocietesContacts__r.size() == 1)
                {
                    societePrincipale = so.MMPJ_Ext_Vign_Societe__r.Id;
                }else {
                    lesSocietes.add(new SelectOption('','Select an option')); 
                }
               

            lesSocietes.add(new selectOption(so.MMPJ_Ext_Vign_Societe__r.Id, so.MMPJ_Ext_Vign_Societe__r.Name));
                 
            }
             listofCompaniesToReturn = new List<selectOption>(lesSocietes);
                 if(campaignMembers.containsKey(con.Id)){
                     societePrincipale = campaignMembers.get(con.Id).MMPJ_XRM_Societe__r.Id; 
                } 
                System.debug('societePrincipale' + societePrincipale); 
            //contacts.add(new contactClass(isSelected,con));
            allContactsList.add(new contactClass(isSelected,con.Id,con.FirstName,con.LastName,societePrincipale,listofCompaniesToReturn));
           
        }

        if(allContactsList.size() <= PAGESIZE)
        {
            contacts.addAll(allContactsList);
            lastIndex = allContactsList.size();
            firstIndex = 0;
        } else {
            for(Integer i=0;i<PAGESIZE;i++)
            {
                lastIndex = PAGESIZE;
                firstIndex = 0;
                contacts.add(allContactsList[i]);
            }
        }
    }

    public void next()
    {
        displayFinishMessage = false;
        contacts.clear();
        Integer lastIdx = (lastIndex + PAGESIZE <= allContactsList.size()) ? lastIndex + PAGESIZE : allContactsList.size();
        for(Integer i= lastIndex; i < lastIdx ; i++)
        {
            contacts.add(allContactsList[i]);
        }
        firstIndex = lastIndex;
        lastIndex = lastIdx;

    }

    public void previous()
    {
        displayFinishMessage = false;
        contacts.clear();
        for(Integer i= firstIndex - PAGESIZE; i < firstIndex ; i++)
        {
            contacts.add(allContactsList[i]);
        }
        lastIndex = firstIndex;
        firstIndex -= PAGESIZE;
        
    }

    public Boolean gethasPrevious()
    {
        return (firstIndex == 0 || allContactsList == null) ? false : true;
    }

    public Boolean gethasnext()
    {
        return (allContactsList == null || (allContactsList != null && allContactsList.size() == lastIndex)) ? false : true;
    }

    public Integer getTotalContacts()
    {
        return (allContactsList == null) ? 0 : allContactsList.size();
    }

    private String makeWhere(String fieldQuery, SearchCriteriaClass searchCriteria)
    {
        String queryWhere = '';
        String operatorQuery = searchCriteria.selectedOperateur;
        String inputType = criteresOptionsMap.get(searchCriteria.selectedCritere).inputType;
        String valueQuery = searchCriteria.searchText;

        if(inputType==DATE_TYPE && String.isNotEmpty(valueQuery))
        {
            List<String> theDates = valueQuery.split('/');
            valueQuery = theDates[2] + '-' + theDates[1] + '-' + theDates[0];
        }

        if(inputType == NUMBER_TYPE && valueQuery.contains(','))
            valueQuery = valueQuery.replace(',', '.');

        /* Gestion du cas oes multipicklist où l'utilisateur met contain au lieu de include */
        if(inputType == PICKLIST_TYPE && operatorQuery == 'Contain')
            operatorQuery = 'Include';
        else if(inputType == PICKLIST_TYPE && operatorQuery == 'NotContain')
            operatorQuery = 'Exclude';

        if(operatorQuery == 'Equal')
            queryWhere = fieldQuery + ((inputType == USER_TYPE || inputType == SOCIETE_TYPE || inputType == TEXT_TYPE || inputType == PICKLIST_TYPE || inputType == RECORDTYPE_TYPE || inputType == PICKLIST_FROM_LABEL_TYPE) ? ('= \'' + valueQuery + '\'') : ('= ' + valueQuery + ''));
        else if(operatorQuery == 'NotEqual')
            queryWhere = fieldQuery + ((inputType == USER_TYPE ||  inputType == SOCIETE_TYPE || inputType == TEXT_TYPE || inputType == PICKLIST_TYPE || inputType == RECORDTYPE_TYPE || inputType == PICKLIST_FROM_LABEL_TYPE) ? ('!= \'' + valueQuery + '\'') : ('!= ' + valueQuery + ''));
        else if(operatorQuery == 'StartWith')
            queryWhere = fieldQuery + ' LIKE \'' + valueQuery + '%\'';
        else if(operatorQuery == 'Contain')
            queryWhere = fieldQuery + ' LIKE \'%' + valueQuery + '%\'';
        else if(operatorQuery == 'NotContain')
            queryWhere = fieldQuery + ' NOT LIKE \'%' + valueQuery + '%\'';
        else if(operatorQuery == 'Inferior')
            queryWhere = fieldQuery + ((inputType == USER_TYPE || inputType == SOCIETE_TYPE || inputType == TEXT_TYPE || inputType == PICKLIST_TYPE || inputType == RECORDTYPE_TYPE || inputType == PICKLIST_FROM_LABEL_TYPE) ? ('< \'' + valueQuery + '\'') : ('< ' + valueQuery + ''));
        else if(operatorQuery == 'Superior')
            queryWhere = fieldQuery + ((inputType == USER_TYPE || inputType == SOCIETE_TYPE || inputType == TEXT_TYPE || inputType == PICKLIST_TYPE || inputType == RECORDTYPE_TYPE || inputType == PICKLIST_FROM_LABEL_TYPE) ? ('> \'' + valueQuery + '\'') : ('> ' + valueQuery + ''));
        else if(operatorQuery == 'Include')
            queryWhere = fieldQuery + ' includes(\'' + valueQuery + '\')';
        else if(operatorQuery == 'Exclude')
            queryWhere = fieldQuery + ' excludes(\'' + valueQuery + '\')';

        /*if(operatorQuery == 'Equal')
            queryWhere = fieldQuery + '= \'' + valueQuery + '\'';
        else if(operatorQuery == 'NotEqual')
            queryWhere = fieldQuery + '!= \'' + valueQuery + '\'';
        else if(operatorQuery == 'StartWith')
            queryWhere = fieldQuery + ' LIKE \'' + valueQuery + '%\'';
        else if(operatorQuery == 'Contain')
            queryWhere = fieldQuery + ' LIKE \'%' + valueQuery + '%\'';
        else if(operatorQuery == 'NotContain')
            queryWhere = fieldQuery + ' NOT LIKE \'%' + valueQuery + '%\'';
        else if(operatorQuery == 'Inferior')
            queryWhere = fieldQuery + '< \'' + valueQuery + '\'';
        else if(operatorQuery == 'Superior')
            queryWhere = fieldQuery + '> \'' + valueQuery + '\'';*/

        return queryWhere;
    }

    public void addToCampaign()
    {
        List<CampaignMember> membersInside = new List<CampaignMember>();
        List<CampaignMember> membersToDelete = new List<CampaignMember>();
        List<CampaignMember> membersToUpdate = new List<CampaignMember>();
        String errorlabel = System.Label.MMPJ_XRM_ERROR_Societe;
        if(allContactsList != null)
        {
            for(ContactClass con:allContactsList)
            {     
                    if(con.isSelected && !campaignMembers.containsKey(con.contactId) ){
                         membersInside.add(new CampaignMember(ContactId=con.contactId,CampaignId=myCampaign.Id, Status='Sent', MMPJ_XRM_Societe__c = con.societe));
                    }
                    else if( ! con.isSelected && campaignMembers.containsKey(con.contactId)){
                         membersToDelete.add(new CampaignMember(Id=campaignMembers.get(con.contactId).Id));
                    }
                    else if(con.isSelected && campaignMembers.containsKey(con.contactId)){
                        CampaignMember cm = campaignMembers.get(con.contactId); 
                        cm.MMPJ_XRM_Societe__c = con.societe; 
                        membersToUpdate.add(cm);
                    }
                    //lorsqu'on essaie d'insérer un campaign member sans société, on génère une erreur 
                    if(con.isSelected && con.societe == null || con.societe == '' || con.societe == 'Select an option'){
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,
                                                     con.firstName +' '+ con.lastName + ' ' + errorlabel));
                    }
                        
            }
            //on ne peut ajouter aux campagnes que des contacts ayant une société
            //car chaque contact est invité désormais au nom d'une société 
            List<CampaignMember> membersToInsert = new List<CampaignMember>();
            
            if(! membersInside.isEmpty()){
                for(CampaignMember cpm : membersInside ){
                    if(cpm.MMPJ_XRM_Societe__c != null){
                        membersToInsert.add(cpm); 
                    }
                }
            }
            
            if(! membersToDelete.isEmpty()||! membersToInsert.isEmpty() || ! membersToUpdate.isEmpty()){
                
            
                if(! membersToDelete.isEmpty()){
                    delete membersToDelete;
                }

                if(! membersToInsert.isEmpty()){
                    insert membersToInsert;
                }
                if(! membersToUpdate.isEmpty()){
                    update membersToUpdate;
                }

          
                initCampaignMembers();

                Set<Id> contactsId = new Set<Id>();
                if(isCampaignContext)
                {
                    for(CampaignMember cm:[select ContactId from CampaignMember where CampaignId=:myCampaign.Id]){
                        contactsId.add(cm.ContactId);
                    }
                    initContactList(contactsId,true);
                } else {
                    search(true);
                }
            
                displayFinishMessage = true;
                
            
            }
        }      
    }

    public void seeCampaignMembers()
    {
        displayFinishMessage = false;
        isCampaignContext = true;
        Set<Id> contactsId = new Set<Id>();
        for(CampaignMember cm:[select ContactId from CampaignMember where CampaignId=:myCampaign.Id])
            contactsId.add(cm.ContactId);
        initContactList(contactsId,true);
        /*contacts = new List<contactClass>();
        for(CampaignMember cm:[select ContactId, Contact.FirstName, Contact.LastName from CampaignMember where CampaignId=:myCampaign.Id])
            contacts.add(new contactClass(true, new Contact(Id=cm.ContactId,FirstName=cm.Contact.FirstName, LastName=cm.Contact.LastName)));*/
    }

    /*public String getRecordName() {
        return 'Hello ' + (String)mysObject.get('name') + ' (' + (Id)mysObject.get('Id') + ')';
    }*/

    public String getContextString()
    {
        return (isCampaignContext) ? 'membre(s)' : 'contact(s)';
    }

    /*public PageReference exportExcelCampaign()
    {
        PageReference page = new PageReference('/apex/MMPJ_XRM_Export_Excel_Campaign?Id=' + myCampaign.Id);
        page.setRedirect(true);
        return page;
    }

    public PageReference exportExcel()
    {
        String urlParameters = '';
        //Pattern search+numero=numero|selectedCritere| selectedOperateur|searchText
        //ex : ?search1=1|monchamp|Equals|Toto
        for(searchCriteriaClass c:searchCriterias)
        {
            if(String.isNotBlank(c.selectedCritere) && String.isNotBlank(c.selectedOperateur))
            {
                String param = c.numero + '|' + c.selectedCritere + '|' + c.selectedOperateur + '|' + c.searchText;
                
                urlParameters += '&search' + c.numero + '=' + EncodingUtil.urlEncode(param, 'UTF-8');
            }
        }


        urlParameters = urlParameters.removeStart('&');
        System.debug('#### urlParameters encoded : ' + urlParameters);
        PageReference page = new PageReference('/apex/MMPJ_XRM_Export_Excel?' + urlParameters);
        page.setRedirect(true);
        return page;
    }*/

    public void doNothing()
    {

    }

    public String makeFiltersToString()
    {
        String urlParameters = '';
        //Pattern search+numero=numero|selectedCritere| selectedOperateur|searchText
        //ex : ?search1=1|monchamp|Equals|Toto
        for(searchCriteriaClass c:searchCriterias)
        {
            if(String.isNotBlank(c.selectedCritere) && String.isNotBlank(c.selectedOperateur))
            {
                String param = c.numero + '|' + c.selectedCritere + '|' + c.selectedOperateur + '|' + c.searchText;
                
                urlParameters += '&search' + c.numero + '=' + EncodingUtil.urlEncode(param, 'UTF-8');
            }
        }

        urlParameters = urlParameters.removeStart('&');

        urlParameters += '&querySubAccount=' + querySubAccount;
        urlParameters += '&queryTopAccount=' + queryTopAccount;
        
        return urlParameters;
    }


    class critereClass {
        public String numero {get;set;}
        public String libelle {get;set;}
        public String objet {get;set;}
        public String champ {get;set;}
        public String inputType{get;set;}
        public List<SelectOption> options{get;set;}
        public Boolean isMultiPickList{get;set;}
        //public List<SelectOptionClass> options{get;set;}
        public critereClass (String numero, String libelle,String objet,String champ, String inputType)
        {
           this(numero, libelle,objet,champ, inputType, null);
        }

        public critereClass (String numero, String libelle,String objet,String champ, String inputType, Campaign Campaign)
        {
            this.numero = numero;
            this.libelle = libelle;
            this.objet = objet;
            this.champ = champ;
            this.options = new List<SelectOption>();
            this.isMultiPickList = false;
            //this.options = new List<SelectOptionClass>();
            this.inputType = inputType;    
            if(inputType == PICKLIST_TYPE)
            {

                Schema.SObjectType t = Schema.getGlobalDescribe().get(objet);
                Schema.DescribeSObjectResult r = t.getDescribe();
                Schema.DescribeFieldResult fieldResult = r.fields.getMap().get(champ).getDescribe();

                if(fieldResult.getType() == Schema.DisplayType.MultiPicklist)
                    this.isMultiPickList = true;

                List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
                options.add(new SelectOption('', ''));
                //options.add(new SelectOptionClass('', ''));
               for( Schema.PicklistEntry f : ple)
               {
                    //options.add(new SelectOptionClass(f.getValue(), f.getLabel()));
                    options.add(new SelectOption(f.getValue(), f.getLabel()));
               }
                
            } else if(inputType == RECORDTYPE_TYPE)
            {
               options.add(new SelectOption('', ''));
               //options.add(new SelectOptionClass('', ''));
               for(RecordType rt : [select Name from RecordType where SObjectType=:objet])
               {
                  options.add(new SelectOption(rt.Name, rt.Name));
                  //options.add(new SelectOptionClass(rt.Name, rt.Name));
               }
            } else if(inputType == PICKLIST_EXT_TYPE)
            {
                /*for(User usr:[select Name from User where isActive=true and Contactid=null])
                {
                    options.add(new SelectOption(usr.Name, usr.Name));
                }*/
                /*String theQuery = 'select ' + champ + ' from ' + objet + '';
                System.debug('query=' + theQuery);
                options.add(new SelectOption('', ''));*/
                /*for(SObject obj : DataBase.Query(theQuery))
               {
                  System.debug('hop');
                  options.add(new SelectOption((String)obj.get(champ), (String)obj.get(champ)));
               }*/
            }  else if(inputType == USER_TYPE)
            {
                options.add(new SelectOption('', ''));
                Set<id> permisionsUnique = new Set<Id>();
                for(PermissionSetAssignment p :[SELECT AssigneeId,Assignee.Name FROM PermissionSetAssignment WHERE PermissionSet.Name like 'MMPJ_Ext%' or  PermissionSet.Name like 'MMPJ_X%'])
                {
                    if(!permisionsUnique.contains(p.AssigneeId))
                    {
                        permisionsUnique.add(p.AssigneeId);
                        options.add(new SelectOption(p.AssigneeId,p.Assignee.Name));
                    }
                }
            }//lorsqu'on filtre sur 'Membre : Societé' le champ valeur nous affiche la liste des sociétés présentent dans la campagne sur laquelle nous sommes
            else if( inputType == SOCIETE_TYPE)
            {
                options.add(new SelectOption('', ''));
                Set<id> societesUniques = new Set<Id>();
                for(CampaignMember cm :[SELECT id, MMPJ_XRM_Societe__r.Name, MMPJ_XRM_Societe__c FROM CampaignMember WHERE CampaignId = :Campaign.Id AND MMPJ_XRM_Societe__c != null])
                {
                    if(!societesUniques.contains(cm.MMPJ_XRM_Societe__c))
                    {
                        societesUniques.add(cm.MMPJ_XRM_Societe__c);
                        options.add(new SelectOption(cm.MMPJ_XRM_Societe__c,cm.MMPJ_XRM_Societe__r.Name));
                    }
                }
            }else if(inputType == PICKLIST_FROM_LABEL_TYPE)
            {
               List<String> picklistValues = getLabelValues('MMPJ_XRM_Segmentation_' + objet + '_' + champ).split(';');
               options.add(new SelectOption('', ''));
               for(String p:picklistValues)
                    options.add(new SelectOption(p, p));
            }
        }
    }

    class operateurClass{ 
        public String libelle{get;set;}
        public String operateur{get;set;}
        public operateurClass(String operateur,String libelle)
        {
            this.libelle = libelle;
            this.operateur = operateur;
        }
    }

    public class searchCriteriaClass {
        public Integer numero {get;set;}
        public String selectedCritere{get;set;}
        public String selectedOperateur{get;set;}
        public String searchText{get;set;}
        public searchCriteriaClass(Integer numero)
        {
            this.numero = numero;
            this.selectedCritere = '';
            this.selectedOperateur = '';
            this.searchText = '';
        }
    }

    class contactClass {
        public Boolean isSelected {get;set;}
        public Contact ctc {get;set;}
        public Id contactId {get;set;}
        public String firstName {get;set;}
        public String lastName {get;set;}
        public String societe {get;set;}
        public List<selectOption> listDesSocietes {get;set;}
        public contactClass(Boolean isSelected,Contact ctc)
        {
            this.isSelected = isSelected;
            this.ctc = ctc;
        }

        public contactClass(Boolean isSelected,Id contactId,String firstName,String lastName,String societe, List<selectOption> societes)
        {
            this.isSelected = isSelected;
            this.contactId = contactId;
            this.firstName = firstName;
            this.lastName = lastName;
            this.listDesSocietes = societes;
            this.societe = societe;
            
        }
    }
    /*
    class SelectOptionClass {
        public String value {get;set;}
        public String label {get;set;}
        public SelectOptionClass(String value, String label)
        {
            this.value = value;
            this.label = label;
        }
    }
    */
}