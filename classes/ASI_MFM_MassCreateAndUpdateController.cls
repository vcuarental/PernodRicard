/*********************************************************************************
 * Name:ASI_MFM_MassCreateAndUpdateController 
 * Description: 
 * Test Class: ASI_MFM_CAP_Plan_Test, ASI_MFM_CN_PO_Test, ASI_MFM_GF_TestClass_DL, ASI_MFM_HK_TestClass_DL, ASI_MFM_MY_Test_Class,
 * 			   ASI_MFM_MY_TestClass_DL, ASI_MFM_RM_TestClass, ASI_MFM_SG_PO_Test, ASI_MFM_TH_PO_Test, ASI_MFM_TH_Test_Class
 *
* Version History
 * Date             Developer               Comments 
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2018-03-02       Wilken Lee              [WL 1.0] Add SG Manual Credit Note lookup to picklist criteria
=== Usage ===
    Allow users creating and editing multiple records in single page
    
=== Steps ===
    - Import the codes (MassCreateAndUpdateController.cls, MassCreateAndUpdate.component)
    - Create Custom Setting named "MassCreateAndUpdateSetting" and Setting Type is List
    - Create fields for MassCreateAndUpdateSetting: DisplayFields__c, FieldsToParam__c
    - Create a VF page including the component in MassCreateAndUpdate.component
    - Set the component attribute according to your preferences (See 
      MassCreateAndUpdate.component for detail)
 
=== Custom Setting Description ===
    MassCreateAndUpdateSetting:
        Name:
            Specify which object and record type this setting belongs to
            Format: Object__c:Record_Type_1
            If record type is not specified, the settings would be applied to all types
                of the object
        DisplayFields__c:
            The columns of fields which are shown in the edit page
            Format: Field1__c, Field2__c&req=T&width=150px, Field3__c&read=A
            Attributes:
                Attribute Name      Values          Description
                req                 T               Whether the field is mandatory
                width               150px/25%       The column width
                read                N/O/A           Set this attribute if need readonly. readonly for (N = new records, O = old records, A = all records)
                skipClone           T               Skip cloning the value for column // TODO: Now only for fast mode
        FieldsToParam__c:
            Show the default value of fields when creating new record
            Specify the mapping of field name (API Name) and URL parameter names
            Format: Field1__c => param1
            In above example, if the url is "https://xxx?param1=DefaultValue", it
                will assign "DefaultValue" to Field1__c when creating new record
*/
public with sharing class ASI_MFM_MassCreateAndUpdateController extends ASI_MFM_AbstractComponentController {

    public static final String ACTION_EDIT = 'edit';
    public static final String ACTION_CLONE = 'clone';
    public static final String ACTION_ADD_NEW = 'add_new';
    public static final String ACTION_REMOVE_NEW = 'remove_new';
    public static final String RTNAME_MASTER = 'General';
    public static final String RTDEVNAME_MASTER = '_General_';
    public static final Integer NUM_OF_HIDDEN_ROW = 15;
    private static final String FIELD_PARAM_REQUIRED = 'req';
    private static final String FIELD_PARAM_COL_WIDTH = 'width';
    private static final String FIELD_PARAM_READ_ONLY = 'read';
    private static final String FIELD_PARAM_COL_KEY = 'ckey';
    private static final String FIELD_PARAM_SKIP_CLONE = 'skipClone';
    private static final String DELIM_SETTING_KEY = ':';
    private static final String DELIM_RT = ',';
    private static final String DELIM_FIELDS = ',';
    private static final String DELIM_FIELD_ELEMENTS = '&';
    private static final String DELIM_FIELD_SETTING = '=';
    private static final String DEF_ORDER_BY = 'Name';

    // Attributes
    public Boolean isFastModeBool { get; set; }
    public String sObjTypeStr { get; set; }
    public String displayFieldsStr { get; set; }
    public String whereStatm { get; set; }
    public String orderByStr { get { if (orderByStr == null || orderByStr.trim().length() == 0) orderByStr = DEF_ORDER_BY; return orderByStr; } set; }
    public String includeRecordTypes { get; set; }
    public String fieldToURLParamStr { get; set; }
    public String pageBlockTitleStr { get {if (pageBlockTitleStr == null) return sObjLabel; return pageBlockTitleStr;} set; }
    public String successLink { get; set; }
    public String cancelLink { get; set; }
    public String mode { get { if (mode == null) mode = MODE_BOTH; return mode; } set { if (value == null) mode = MODE_BOTH; else mode = value.toUpperCase(); } }
    public Boolean isDefaultEditVal { get; set; }
    public Boolean showAllRT { get; set; }
    public Boolean isUseFirstRowForNew { get; set; }
    public String altSObjectTypeName { get; set; }
    // a dummy variable to invoke init() method
    public Boolean dummyVar { get { if (dummyVar != true) {dummyVar = init();} return dummyVar; } set; }
    
    // Data used in VF page
    public String sObjLabel { get; private set; }
    public List<RecordTypeElement> theRecordTypeElementList { get; set; }
    public List<SelectOption> recordTypeOptionList { get; set; }
    public Integer numOfRecordType { get; set; }
    public String selectedRecordType { get; set; }
    public List<PageBlockActionBtn> pageBlockActionBtnList { get; set; }
    
    // Modes
    public String MODE_NEW { get { return 'NEW'; } private set; }
    public String MODE_EDIT { get { return 'EDIT'; } private set; }
    public String MODE_BOTH { get { return 'BOTH'; } private set; }
    // Parameter Names
    public String PARAM_RTID { get { return 'rtid'; } private set;} // record type id
    public String PARAM_TRID { get { return 'rid'; } private set;} // record id
    public String PARAM_NUM_OF_SHOW_ROW { get { return 'showRowNum'; } private set;}
    
    private Schema.SObjectType sObjType;
    private Map<String, String> fieldNameToValueMap;
    private decimal last_plan_balance;
    private boolean negative_pol_balance = false;
    
    public ASI_MFM_MassCreateAndUpdateController() {}

    public ASI_MFM_objectPickListHelper helper1{ get; set; }
    public String lookupToPicklist { get; set; } 
    public List<String> checkPicklist { get; set; }
    public Set<String> checkPicklistSet { get; set; }
    public Map<String,List<selectOption>> allLookPicklist { get; set;} 
    
    //For Sub-brand Allocation
    public List<ASI_MFM_Sub_brand_Allocation__c> theSubBrandAllocationList { get; set; }
    public List<ASI_MFM_Sub_brand__c> subBrandList = new List <ASI_MFM_Sub_brand__c>();
    public Map<id, String> setofSubBrand = new Map<id, String>();
    public List<SelectOption> subBrand_All_Picklist {set; get;}
    public Set<id> setOfsubBrandID {set; get;}
    public List<interimData> results {get; set;}
    public integer index = 0;
    public integer rowSelected_index {set; get;}
    public List <ASI_MFM_Sub_brand_Allocation__c> delItemList = new List <ASI_MFM_Sub_brand_Allocation__c>(); 
    public boolean SBAllocation {set; get;}  
    public ASI_MFM_PO__c objPO {set; get;}
    //For Sub-brand Allocation - END
    
    public Set<String> getcheckPicklistSet(){
        return checkPicklistSet;
    }
    
    //For Sub-brand Allocation
    public Class interimData{
        public String id{ 
            get{
                if(String.isBlank(id)){
                    return null;
                }
                return id;
            } 
            set;
        }
        public integer rowindex {get; set;}
        public ASI_MFM_Sub_brand_Allocation__c ppl {get; set;}
    }
    //For Sub-brand Allocation - END
    
    public Boolean init() {
        //Start of Sub-brand Allocation
        results = new List<interimData>();
        if (sObjTypeStr == 'ASI_MFM_PO_Line_Item__c') {
            objPO = [select RecordType.DeveloperName from ASI_MFM_PO__c where id = :apexpages.currentPage().getParameters().get('id')];
            system.debug(objPO);
            system.debug(objPO.RecordType.DeveloperName);
        }       
        //Execute only when record type is CN
        if(objPO != null && (objPO.RecordType.DeveloperName == 'ASI_MFM_CN_PO' || objPO.RecordType.DeveloperName == 'ASI_MFM_CN_PO_Read_Only')){
            List<String> roleRelatedGroupIds = new List<String>();
            for (Group gp : [SELECT id, RelatedId, Type FROM Group where RelatedId=:UserInfo.getUserRoleId()]){
                roleRelatedGroupIds.add(gp.id);
            }
            
            Set<id> allGroupIDs = new Set<id>();
            for (GroupMember gm : [SELECT Id, group.id, group.name, group.type FROM GroupMember where (UserOrGroupId = :UserInfo.getUserId() AND group.type='Regular') OR (UserOrGroupId IN :roleRelatedGroupIds AND group.type='Regular')]){
                allGroupIDs.add(gm.group.id);
            }                       
            Group objPGp = [SELECT id FROM group WHERE name = 'ASI MFM CN Regional User'];            
            system.debug(allGroupIDs);
            
            if(!allGroupIDs.IsEmpty() && allGroupIDs.contains(objPGp.id)){
                SBAllocation = true;
                subBrand_All_Picklist = new List<SelectOption>();        
                setOfsubBrandID = new Set<id>();
                
                subBrandList = [SELECT id, Name FROM ASI_MFM_Sub_brand__c WHERE recordtype.developername='ASI_FOC_CN_Sub_brand' AND ASI_MFM_Active_for_MFM__c=TRUE ORDER BY ASI_TH_CRM_Brand_Code__c];
                    
                for(ASI_MFM_Sub_brand__c sbItm : subBrandList){
                    setofSubBrand.put(sbItm.id, sbItm.Name);
                    setOfsubBrandID.add(sbItm.id);
                }       
                
                theSubBrandAllocationList = [SELECT ASI_MFM_Sub_brand_percentage__c, ASI_MFM_Sub_brand_Code__c, ASI_MFM_Sub_brand_Code__r.Name, ASI_MFM_Remarks__c FROM ASI_MFM_Sub_brand_Allocation__c WHERE ASI_MFM_PO__c =:apexpages.currentPage().getParameters().get('id') AND ASI_MFM_Sub_brand_Code__c IN:setOfsubBrandID AND RecordType.DeveloperName = 'ASI_MFM_CN_Sub_Brand_Allocation'];
                for(ASI_MFM_Sub_brand_Allocation__c sba : theSubBrandAllocationList){
                    setofSubBrand.put(sba.ASI_MFM_Sub_brand_Code__c, sba.ASI_MFM_Sub_brand_Code__r.Name);
                }       
                
                for(Id key: setofSubBrand.keySet()){
                    subBrand_All_Picklist.add(new SelectOption(key, setofSubBrand.get(key)));
                }     
                subBrand_All_Picklist.sort();
                
                for(ASI_MFM_Sub_brand_Allocation__c itm : theSubBrandAllocationList){
                    interimData sbaObj = new interimData();
                    sbaObj.ppl = itm;
                    sbaObj.rowindex = index;
                    results.add(sbaObj);
                    index++;
                }
            }else{
               SBAllocation = false;
            }
        }
        //End of Sub-brand Allocation
        
        System.debug('abcit' + lookupToPicklist);
        checkPicklist = lookupToPicklist.split(',', 0);
        checkPicklistSet = new Set<String>();
        allLookPickList = new Map<String,List<selectOption>>();
        for(String s: checkPickList){ System.debug('bcd' + s);}
        
        if(checkPicklist != null)
         if(checkPicklist[0] != 'hello')
            {
                ASI_MFM_Plan__c plan;
                ASI_MFM_PO__c  po;
				
				/*[WL 1.0 Begin]*/
				ASI_CRM_Credit_Debit_Note__c cNote;
				if (sObjTypeStr == 'ASI_CRM_Credit_Debit_Note_Line_Item__c') {
					cNote = [select RecordType.DeveloperName from ASI_CRM_Credit_Debit_Note__c where id = :apexpages.currentPage().getParameters().get('id')];
				} 
				system.debug ('sObjTypeStr: ' + sObjTypeStr + ' id: ' + apexpages.currentPage().getParameters().get('id') + ' cNote: ' + cNote);
				/*[WL 1.0 End]*/
				
                if (sObjTypeStr == 'ASI_MFM_Plan_Line_Item__c') {
                    plan = [select RecordType.DeveloperName, ASI_MFM_Prefix__r.ASI_MFM_TR_Rec_Type__c,ASI_MFM_Prefix__r.ASI_MFM_Location__c, ASI_MFM_Prefix__r.ASI_MFM_Default_BU__r.ASI_MFM_BU_Code__c,ASI_MFM_Prefix__r.Name from ASI_MFM_Plan__c where id = :apexpages.currentPage().getParameters().get('id')];
                } 
                if (sObjTypeStr == 'ASI_MFM_PO_Line_Item__c') {
                    po = [select id, ASI_MFM_PO_PP_Category__c, name, ASI_MFM_Plan__r.id,ASI_MFM_Prefix__r.ASI_MFM_TR_Rec_Type__c, RecordType.DeveloperName, ASI_MFM_Prefix__r.ASI_MFM_Location__c, ASI_MFM_Prefix__r.Name, ASI_MFM_Prefix__r.ASI_MFM_Default_BU__r.ASI_MFM_BU_Code__c from ASI_MFM_PO__c where id = :apexpages.currentPage().getParameters().get('id')];
                } 
                
                //Wilken 20161108, Add FOC Item for TW CRM
                ASI_FOC_Free_Goods_Request__c foc;
                if (sObjTypeStr == 'ASI_FOC_Request_Item__c') {
                    foc = [select id, name, RecordType.DeveloperName from ASI_FOC_Free_Goods_Request__c where id = :apexpages.currentPage().getParameters().get('id')];
                } 
                
                system.debug('Has FOC: ' + foc); 
                //ASI_MFM_Plan__c pli = [select id, RecordType.DeveloperName from ASI_MFM_Plan__c where id = :apexpages.currentPage().getParameters().get('id')];

              for(String s: checkPicklist){ 
                 checkPicklistSet.add(s);
				 /*[WL 1.0 Begin]*/
				 System.debug('sObjTypeStr: ' + sObjTypeStr);
				 System.debug('checkPicklist: ' + s);
				 System.debug('whereStatm:' + whereStatm);
				 /*[WL 1.0 End]*/
                 sObjTypeStr = sObjTypeStr.trim();
                 s = s.trim();
                 if (sObjTypeStr == 'ASI_MFM_Plan_Line_Item__c' && s == 'ASI_MFM_A_C_Code__c')
                 {
                     System.debug('cdj0 ' +  apexpages.currentPage().getParameters().get('id'));
                     if (plan != null)
                     {
                         if (plan.RecordType.DeveloperName.contains('ASI_MFM_TW'))
                             helper1 = new ASI_MFM_objectPickListHelper(sObjTypeStr,s,whereStatm);
                         else if (plan.RecordType.DeveloperName.contains('ASI_MFM_JP')){
                             String whereStat = ' recordtype.developername =\'ASI_JP_A_C_Code\'  ';
                             helper1 = new ASI_MFM_objectPickListHelper(sObjTypeStr,s,'',whereStat);
                         }
                         // Added By Alan Wong (Elufa) 24Feb2015
                         // Display A_C code by market
                         else if (plan.RecordType.DeveloperName.contains('ASI_MFM_SG')){
                             String whereStat = ' recordtype.developername =\'ASI_MFM_SG_A_C_Code\'  AND ASI_MFM_Dummy_A_C__c != True  ';
                             whereStat += ' AND ASI_MFM_Market__c = \'' + plan.ASI_MFM_Prefix__r.ASI_MFM_Location__c + '\' ';
                             helper1 = new ASI_MFM_objectPickListHelper(sObjTypeStr,s,'',whereStat);
                         }
                         // Added By Alan Wong (Elufa) 22April2015
                         // Display User A_C code only
                         else if (plan.RecordType.DeveloperName.contains('ASI_MFM_TH')){
                             string AC_Prefix = plan.ASI_MFM_Prefix__r.Name.substring(0,3);
                             String whereStat = ' recordtype.developername =\'ASI_MFM_TH_A_C_Code\'  AND ASI_MFM_Dummy_A_C__c != True AND ASI_MFM_TH_Prefix__c LIKE \'%' + AC_Prefix + '%\' ';
                             helper1 = new ASI_MFM_objectPickListHelper(sObjTypeStr,s,'',whereStat);
                         }
                         else
                             helper1 = new ASI_MFM_objectPickListHelper(sObjTypeStr,s);
                     }
                     else
                        helper1 = new ASI_MFM_objectPickListHelper(sObjTypeStr,s);
                 }
                 else if (sObjTypeStr == 'ASI_MFM_PO_Line_Item__c' && (s == 'ASI_MFM_A_C_Code__c' || s == 'ASI_MFM_Sub_brand_Code__c'))
                 {
                     System.debug('cdj1 ' +  apexpages.currentPage().getParameters().get('id') );
                      if (po!= null)
                     {
                         string whereStat = ''; 
                            
                         if (po.RecordType.DeveloperName.contains('ASI_MFM_CN')){
                             string relatedStr = s.replace('__c', '__r');
                             if (s == 'ASI_MFM_Sub_brand_Code__c')
                             {
                                 whereStat = 'ASI_MFM_Plan__r.id =\'' + po.ASI_MFM_Plan__r.id + '\'';
                                 helper1 = new ASI_MFM_objectPickListHelper('ASI_MFM_Plan_Line_Item__c',whereStat , '',relatedStr ,true);
                             }
                             else
                             {
                                 if(po.ASI_MFM_PO_PP_Category__c == Null){
                                     
                                     whereStat = ' id =\'' + po.ASI_MFM_Plan__r.id + '\'';
                                     helper1 = new ASI_MFM_objectPickListHelper('ASI_MFM_Plan__c',whereStat , '','ASI_MFM_PP_Category__r', 'ASI_MFM_PP_Category_A_C__c' ,relatedStr  ,true);
                                 }else if(po.ASI_MFM_PO_PP_Category__c != Null){
                                     
                                     //20170607 Introv changed to base on PO's PP Category
                                     whereStat = ' ASI_MFM_PP_Category__c =\'' + po.ASI_MFM_PO_PP_Category__c + '\'';
                                     helper1 = new ASI_MFM_objectPickListHelper('ASI_MFM_PP_Category_A_C__c',whereStat , '','ASI_MFM_A_C_Code__r' ,true);
                                     //20170607 End
                                 }
                             }
                         }
                         // Added By Alan Wong (Elufa) 24Feb2015   Display A_C code by market
                         else if (po.RecordType.DeveloperName.contains('ASI_MFM_SG') && s == 'ASI_MFM_A_C_Code__c'){
                             whereStat = ' recordtype.developername =\'ASI_MFM_SG_A_C_Code\'   AND ASI_MFM_Dummy_A_C__c != True  ';
                             whereStat += ' AND ASI_MFM_Market__c = \'' + po.ASI_MFM_Prefix__r.ASI_MFM_Location__c + '\' '; 
                             helper1 = new ASI_MFM_objectPickListHelper(sObjTypeStr,s,'',whereStat);
                         }
                         else if (po.RecordType.DeveloperName.contains('ASI_MFM_PH') && s == 'ASI_MFM_Sub_brand_Code__c'){
                             whereStat = ' recordtype.developername =\'ASI_MFM_PH_Sub_brand\' ';
                             
                             helper1 = new ASI_MFM_objectPickListHelper(sObjTypeStr,s,'',whereStat);
                         }
                         else if (po.RecordType.DeveloperName.contains('ASI_MFM_SG') && s == 'ASI_MFM_Sub_brand_Code__c'){
                             whereStat = ' recordtype.developername =\'ASI_CRM_SG_Sub_brand\' AND ASI_TH_CRM_Active__c = true ';
                             
                             helper1 = new ASI_MFM_objectPickListHelper(sObjTypeStr,s,'',whereStat);
                         }
                         else if (po.RecordType.DeveloperName.contains('ASI_MFM_MY') && s == 'ASI_MFM_Sub_brand_Code__c'){
                             whereStat = ' recordtype.developername =\'ASI_MFM_MY_Sub_brand\'';
                             
                             helper1 = new ASI_MFM_objectPickListHelper(sObjTypeStr,s,'',whereStat);
                         }
                         else if (po.RecordType.DeveloperName.contains('ASI_MFM_TH' ) && s == 'ASI_MFM_A_C_Code__c' ){
                             string AC_Prefix = po.ASI_MFM_Prefix__r.Name.substring(0,3); 
                             whereStat = ' recordtype.developername =\'ASI_MFM_TH_A_C_Code\' AND ASI_MFM_Dummy_A_C__c != True AND ASI_MFM_TH_Prefix__c LIKE \'%' + AC_Prefix + '%\' ';
                             helper1 = new ASI_MFM_objectPickListHelper(sObjTypeStr,s,'',whereStat);
                         }
                         else if (po.RecordType.DeveloperName.contains('ASI_MFM_TW') && s == 'ASI_MFM_Sub_brand_Code__c'){
                             whereStat = ' ASI_TH_CRM_Active__c = true AND ASI_CRM_TW_Company__c = \'PRT\' ';
                             helper1 = new ASI_MFM_objectPickListHelper(sObjTypeStr,s,'',whereStat);
                         }
                         // 2017-08-24  Linus@introv
                         else if (po.RecordType.DeveloperName.contains('ASI_MFM_GF')){
                             if(s == 'ASI_MFM_Sub_brand_code__c'){
                                 whereStat = ' recordtype.developername =\'ASI_MFM_GF_Sub_brand\' AND ASI_MFM_Active_for_MFM__c = true ';                             
                                 helper1 = new ASI_MFM_objectPickListHelper(sObjTypeStr,s,'',whereStat);
                             }else if (s == 'ASI_MFM_AP_Code__c'){
                                 whereStat = ' recordtype.developerName =\'ASI_MFM_GF_AP_Code\' AND ASI_MFM_Inactive__c = false ';
                                 helper1 = new ASI_MFM_objectPickListHelper(sObjTypeStr,s,'',whereStat);
                             }                           
                         }
                         // 2017-08-24  Linus@introv
                         else
                             helper1 = new ASI_MFM_objectPickListHelper(sObjTypeStr,s);    
                     }else
                             helper1 = new ASI_MFM_objectPickListHelper(sObjTypeStr,s);
                          
                 }
                 else if (sObjTypeStr == 'ASI_MFM_Plan_Line_Item__c' && s == 'ASI_MFM_Sub_brand_Code__c')
                 {
                     
                     if (plan != null)
                     {
                         System.debug('cdj0 ' +  apexpages.currentPage().getParameters().get('id'));
                         if (plan.RecordType.DeveloperName.contains('ASI_MFM_CN')){
                            String whereStat = ' recordtype.developername =\'ASI_FOC_CN_Sub_brand\' and ASI_MFM_Active_for_MFM__c = true';
                            //ASI_MFM_Function.getRecordTypeId('ASI_MFM_Sub_brand_Code__c');
                             helper1 = new ASI_MFM_objectPickListHelper(sObjTypeStr,s,'',whereStat);
                         }else if (plan.RecordType.DeveloperName.contains('ASI_MFM_TW')){
                            String whereStat = ' ASI_CRM_TW_Company__c =\'PRT\' AND ASI_TH_CRM_Active__c = true ';
                             helper1 = new ASI_MFM_objectPickListHelper(sObjTypeStr,s,'',whereStat);
                         }
                         else if (plan.RecordType.DeveloperName.contains('ASI_MFM_SG')){
                            String whereStat = ' recordtype.developername =\'ASI_CRM_SG_Sub_brand\' AND ASI_TH_CRM_Active__c = true ';
                             helper1 = new ASI_MFM_objectPickListHelper(sObjTypeStr,s,'',whereStat);
                         }
                         //20170223, Elufa
                         else if (plan.RecordType.DeveloperName.contains('ASI_MFM_MY')){
                            String whereStat = ' recordtype.developername =\'ASI_MFM_MY_Sub_brand\'';
                             helper1 = new ASI_MFM_objectPickListHelper(sObjTypeStr,s,'',whereStat);
                         }
                         //20170223, Elufa
                         else
                             helper1 = new ASI_MFM_objectPickListHelper(sObjTypeStr,s);
                     }
                     else
                        helper1 = new ASI_MFM_objectPickListHelper(sObjTypeStr,s);
                 }
                 else if (sObjTypeStr == 'ASI_MFM_Plan_Line_Item__c' && s == 'ASI_MFM_AP_Code__c')
                 {
                     System.debug('cdj0 ' +  apexpages.currentPage().getParameters().get('id'));
                     if (plan != null)
                     {
                         if (plan.RecordType.DeveloperName.contains('ASI_MFM_JP')){
                            String whereStat = ' recordtype.developername =\'ASI_JP_AP_Code\'  ';
                             helper1 = new ASI_MFM_objectPickListHelper(sObjTypeStr,s,'',whereStat);
                         }
                         // Added by 2018-07-17 Linus@introv
                         else if(plan.RecordType.DeveloperName.contains('ASI_MFM_GF')){             
                             
                             String whereStat = ' recordtype.developerName =\'ASI_MFM_GF_AP_Code\' and ASI_MFM_Inactive__c = false ';
                             helper1 = new ASI_MFM_objectPickListHelper(sObjTypeStr,s,'',whereStat);
                         }
                         // END - Linus
                         else
                             helper1 = new ASI_MFM_objectPickListHelper(sObjTypeStr,s);
                     }
                     else
                        helper1 = new ASI_MFM_objectPickListHelper(sObjTypeStr,s);
                 }else if ((sObjTypeStr == 'ASI_MFM_Plan_Line_Item__c' || sObjTypeStr == 'ASI_MFM_PO_Line_Item__c' ) && s == 'ASI_MFM_Customer_Name__c')
                 {
                    String whereStat = ' recordtype.developername =\'ASI_MFM_MY_Customer\'  ';
                    String GF_whereStat = ' recordtype.developername =\'ASI_GF_Customer\'  ';
                    
                     if (plan != null && plan.RecordType.DeveloperName.contains('ASI_MFM_MY')){
                         helper1 = new ASI_MFM_objectPickListHelper(sObjTypeStr,s,'',whereStat);
                        
                     }
                     else if (po != null && po.RecordType.DeveloperName.contains('ASI_MFM_MY')){
                         helper1 = new ASI_MFM_objectPickListHelper(sObjTypeStr,s,'',whereStat);
                     }
                    else if (plan != null && plan.RecordType.DeveloperName.contains('ASI_MFM_GF')){
                         if(plan.ASI_MFM_Prefix__r.ASI_MFM_TR_Rec_Type__c!=null){
                            //Updated by Wilken 20161229, Separate customer based on Duty Paid, Duty Free, SLM based on ASI_HK_CRM_Type__c
                            /*if(plan.ASI_MFM_Prefix__r.ASI_MFM_TR_Rec_Type__c=='SL'){
                                 GF_whereStat+=' and ASI_HK_CRM_Type__c  =\'SL\'  ';
                            }else{
                                GF_whereStat+=' and ASI_HK_CRM_Type__c =\'GF\'  '; 
                            }*/
                            GF_whereStat+=' and ASI_HK_CRM_Type__c =\'' + plan.ASI_MFM_Prefix__r.ASI_MFM_TR_Rec_Type__c + '\'  '; 
                            
                            system.debug('Gulf Customer SOQL: ' + GF_whereStat);
                            
                            helper1 = new ASI_MFM_objectPickListHelper(sObjTypeStr,s,'',GF_whereStat);
                         }
                         else{
                              helper1 = new ASI_MFM_objectPickListHelper(sObjTypeStr,s,'',GF_whereStat);
                         }
                     }
                    else if (po != null && po.RecordType.DeveloperName.contains('ASI_MFM_GF')){
                        if(po.ASI_MFM_Prefix__r.ASI_MFM_TR_Rec_Type__c!=null){
                            //Updated by Wilken 20161229, Separate customer based on Duty Paid, Duty Free, SLM based on ASI_HK_CRM_Type__c
                            /*if(po.ASI_MFM_Prefix__r.ASI_MFM_TR_Rec_Type__c=='SL'){
                                 GF_whereStat+=' and ASI_HK_CRM_Type__c  =\'SL\'  ';
                            }else{
                                GF_whereStat+=' and ASI_HK_CRM_Type__c =\'GF\'  '; 
                            }*/
                            GF_whereStat+=' and ASI_HK_CRM_Type__c =\'' + po.ASI_MFM_Prefix__r.ASI_MFM_TR_Rec_Type__c + '\'  '; 
                            
                            system.debug('Gulf Customer SOQL: ' + GF_whereStat);
                            
                            helper1 = new ASI_MFM_objectPickListHelper(sObjTypeStr,s,'',GF_whereStat);
                        }
                        else{
                              helper1 = new ASI_MFM_objectPickListHelper(sObjTypeStr,s,'',GF_whereStat);
                        }                        
                    } 
                     //HK MFM Logic
                     else if (plan != null && plan.RecordType.DeveloperName.contains('ASI_MFM_HK')){
                         helper1 = new ASI_MFM_objectPickListHelper(sObjTypeStr,s,'',' recordtype.developername =\'ASI_HK_CRM_Outlet\' AND  ASI_HK_CRM_Location__c = \'' + plan.ASI_MFM_Prefix__r.ASI_MFM_Default_BU__r.ASI_MFM_BU_Code__c + '\'');
                     }
                     else if (po != null && po.RecordType.DeveloperName.contains('ASI_MFM_HK')){
                         helper1 = new ASI_MFM_objectPickListHelper(sObjTypeStr,s,'',' recordtype.developername =\'ASI_HK_CRM_Outlet\' AND  ASI_HK_CRM_Location__c = \'' + po.ASI_MFM_Prefix__r.ASI_MFM_Default_BU__r.ASI_MFM_BU_Code__c + '\'');
                     }
                     // SG MFM Logic
                     else if (plan != null && plan.RecordType.DeveloperName.contains('ASI_MFM_SG')){
                         String whereStats = ' recordtype.developername =\'ASI_MFM_SG_Customer\'  ';
                         if (plan.ASI_MFM_Prefix__r.ASI_MFM_Location__c == 'Singapore'){
                            whereStats+= ' AND ASI_HK_CRM_Location__c = \'SG\' ';
                         }
                         if (plan.ASI_MFM_Prefix__r.ASI_MFM_Location__c == 'Cambodia'){
                            whereStats+= ' AND ASI_HK_CRM_Location__c = \'CA\' ';
                         }
                         if (plan.ASI_MFM_Prefix__r.ASI_MFM_Location__c == 'Myanmar'){
                            whereStats+= ' AND ASI_HK_CRM_Location__c = \'MM\' ';
                         }
                         if (plan.ASI_MFM_Prefix__r.ASI_MFM_Location__c == 'Laos'){
                            whereStats+= ' AND ASI_HK_CRM_Location__c = \'LA\' ';
                         }
                         helper1 = new ASI_MFM_objectPickListHelper(sObjTypeStr,s,'',whereStats);
                         
                         //helper1 = new ASI_MFM_objectPickListHelper(sObjTypeStr,s,'',' recordtype.developername =\'ASI_MFM_SG_Customer\' ');   //helper1 = new ASI_MFM_objectPickListHelper(sObjTypeStr,s,'',' recordtype.developername =\'ASI_CRM_SG_Outlet\'  ');
                     }
                     else if (po != null && po.RecordType.DeveloperName.contains('ASI_MFM_SG')){
                         if (po.ASI_MFM_Prefix__r.ASI_MFM_Location__c == 'Singapore'){
                            helper1 = new ASI_MFM_objectPickListHelper(sObjTypeStr,s,'',' recordtype.developername =\'ASI_MFM_SG_Customer\'  AND ASI_HK_CRM_Location__c = \'SG\' ');    //helper1 = new ASI_MFM_objectPickListHelper(sObjTypeStr,s,'',' recordtype.developername =\'ASI_CRM_SG_Outlet\'  ');
                         }else if (po.ASI_MFM_Prefix__r.ASI_MFM_Location__c == 'Cambodia'){
                            helper1 = new ASI_MFM_objectPickListHelper(sObjTypeStr,s,'',' recordtype.developername =\'ASI_MFM_SG_Customer\'  AND ASI_HK_CRM_Location__c = \'CA\' ');
                         }else if (po.ASI_MFM_Prefix__r.ASI_MFM_Location__c == 'Myanmar'){
                            helper1 = new ASI_MFM_objectPickListHelper(sObjTypeStr,s,'',' recordtype.developername =\'ASI_MFM_SG_Customer\'  AND ASI_HK_CRM_Location__c = \'MM\' ');
                         }else if (po.ASI_MFM_Prefix__r.ASI_MFM_Location__c == 'Laos'){
                            helper1 = new ASI_MFM_objectPickListHelper(sObjTypeStr,s,'',' recordtype.developername =\'ASI_MFM_SG_Customer\'  AND ASI_HK_CRM_Location__c = \'LA\' ');
                         }
                     } 
                     //Thailand MFM logic 16/02/2015
                     else if (plan != null && plan.RecordType.DeveloperName.contains('ASI_MFM_TH')){
                         //helper1 = new ASI_MFM_objectPickListHelper(sObjTypeStr,s,'',' recordtype.developername =\'ASI_TH_CRM_Outlet\'  ');
                         helper1 = new ASI_MFM_objectPickListHelper(sObjTypeStr,s,'',' recordtype.developername in (\'ASI_TH_CRM_Outlet\', \'ASI_MFM_TH_Customer \' )  ');
                         //helper1 = new ASI_MFM_objectPickListHelper(sObjTypeStr,s,'',' recordtype.developername in (\'ASI_TH_CRM_Modern_Trade\', \'ASI_TH_CRM_Outlet \' , \'ASI_TH_CRM_Potential_Outlet\' , \'ASI_TH_CRM_Wholesaler \')  ');
                     }
                     else if (po != null && po.RecordType.DeveloperName.contains('ASI_MFM_TH')){
                         //helper1 = new ASI_MFM_objectPickListHelper(sObjTypeStr,s,'',' recordtype.developername =\'ASI_TH_CRM_Outlet\'  ');
                         helper1 = new ASI_MFM_objectPickListHelper(sObjTypeStr,s,'',' recordtype.developername in (\'ASI_TH_CRM_Outlet\', \'ASI_MFM_TH_Customer \' )  ');
                     }
                     else
                        helper1 = new ASI_MFM_objectPickListHelper(sObjTypeStr,s);
                 }
                 // Added by Alan Wong(Elufa) 20150504 Inavtive sub-brand allocation
                 else if ((sObjTypeStr == 'ASI_MFM_Plan_Line_Item__c' || sObjTypeStr == 'ASI_MFM_PO_Line_Item__c' ) && s == 'ASI_MFM_Sub_brand_Allocation_Type__c')
                 {
                     System.debug('cdj0 ' +  apexpages.currentPage().getParameters().get('id'));
                     if (plan != null)
                     {
                         if (plan.RecordType.DeveloperName.contains('ASI_MFM_GF')){
                             String whereStat = ' recordtype.developername =\'ASI_MFM_Gulf_Brand_Allocation\' AND ASI_MFM_Inactive__c = false';
                             helper1 = new ASI_MFM_objectPickListHelper(sObjTypeStr,s,'',whereStat);
                             System.debug('cdj1 ' +  whereStat);
                         }
                         else
                             helper1 = new ASI_MFM_objectPickListHelper(sObjTypeStr,s);
                     }
                     else if (po != null)
                     {
                         if (po.RecordType.DeveloperName.contains('ASI_MFM_GF')){
                             String whereStat = ' recordtype.developername =\'ASI_MFM_Gulf_Brand_Allocation\' AND ASI_MFM_Inactive__c = false';
                             helper1 = new ASI_MFM_objectPickListHelper(sObjTypeStr,s,'',whereStat);
                             System.debug('cdj1 ' +  whereStat);
                         }
                         else
                             helper1 = new ASI_MFM_objectPickListHelper(sObjTypeStr,s);
                     }
                     else
                        helper1 = new ASI_MFM_objectPickListHelper(sObjTypeStr,s);
                 }
                 //Added by Wilken 20161108, TW CRM uses FOC Object Manage All with SKU picklist
                 /*else if ((sObjTypeStr == 'ASI_FOC_Request_Item__c') && s == 'ASI_FOC_SKU__c')
                 {
                    if (foc.RecordType.DeveloperName.contains('ASI_CRM_TW_FOC')){
                         String whereStat = ' recordtype.developername =\'ASI_MFM_TW_SKU_Code\' and ASI_HK_CRM_Active__c = TRUE AND ASI_HK_CRM_IsPOSProduct__c = FALSE ';
                         helper1 = new ASI_MFM_objectPickListHelper(sObjTypeStr,s,'',whereStat);
                    }
                    else if(foc.RecordType.DeveloperName.contains('ASI_CRM_TW_POSM')){
                         String whereStat = ' recordtype.developername =\'ASI_MFM_TW_SKU_Code\' and ASI_HK_CRM_Active__c = TRUE AND ASI_HK_CRM_IsPOSProduct__c = TRUE ';
                         helper1 = new ASI_MFM_objectPickListHelper(sObjTypeStr,s,'',whereStat);
                    }
                 }*/
				  /*[WL 1.0 Begin]*/
				 else if (sObjTypeStr == 'ASI_CRM_Credit_Debit_Note_Line_Item__c' && (s == 'ASI_CRM_A_C_Code__c' || s == 'ASI_CRM_Sub_brand__c')){
					system.debug('In Credit Note Line Item A/C Code or Sub-brand objectToPicklist function');
					if (cNote != null){

						if (cNote.RecordType.DeveloperName.contains('ASI_CRM_SG')){
							String whereStat = ' recordtype.developername like \'ASI_CRM_SG%\'';
							helper1 = new ASI_MFM_objectPickListHelper(sObjTypeStr,s,'',whereStat);
							system.debug('whereStat: ' + whereStat + ' sObjTypeStr: ' + sObjTypeStr + ' s:' + s);
						}
					}
				}
				/*[WL 1.0 End]*/ 
                 else 
                     helper1 = new ASI_MFM_objectPickListHelper(sObjTypeStr,s);
                 allLookPickList.put(s,helper1.pickList);
              }
          }



        // Initialize basic components
        if (pageController != null)
            this.pageBlockActionBtnList = ((ASI_MFM_MassCreateAndUpdateAbstract)pageController).mcau_initPageBlockActionButtonList();
        if (this.pageBlockActionBtnList == null) this.pageBlockActionBtnList = new List<PageBlockActionBtn>();
        
        // Handle SF object information
        sObjType = Schema.getGlobalDescribe().get(sObjTypeStr);
        sObjLabel = sObjType.getDescribe().getLabel();
        
        // Handle record types
        List<RecordType> recordTypeList = this.getRecordTypeList();
        if (recordTypeList.size() == 0) { // Record type is not enabled for this sobject type
            recordTypeList.add(new RecordType(Name = RTNAME_MASTER, DeveloperName = RTDEVNAME_MASTER));
        }
        this.numOfRecordType = recordTypeList.size();
        this.selectedRecordType = recordTypeList.get(0).DeveloperName;
        
        // Handle display fields
        Map<String, Schema.SObjectField> sObjFieldMap = sObjType.getDescribe().fields.getMap();
        List<DisplayCol> commonDisplayColList= getDisplayColListByFieldStr(displayFieldsStr, sObjFieldMap);
        
        // Handle default field values
        Map<String, String> fieldToValueMap = new Map<String, String>();
        if (fieldToURLParamStr != null) fieldToValueMap = getDefaultFieldValueMapFromStr(fieldToURLParamStr);
        
        recordTypeOptionList = new List<SelectOption>();
        Map<String, ASI_MFM_MassCreateAndUpdateSetting__c> allSettingMap = ASI_MFM_MassCreateAndUpdateSetting__c.getAll();
        if (mode == MODE_EDIT) isDefaultEditVal = true;
        
        theRecordTypeElementList = new List<RecordTypeElement>();
        // Handle record types one by one
        for (RecordType tempRT : recordTypeList) {
            Boolean hasRecordType = (tempRT.DeveloperName != RTDEVNAME_MASTER);
            ID rtId = hasRecordType ? tempRT.Id : null;
            recordTypeOptionList.add(new SelectOption(tempRT.DeveloperName, tempRT.Name));
            ASI_MFM_MassCreateAndUpdateSetting__c rtSetting = getSettingByRecordType(allSettingMap, tempRT.DeveloperName);
            // Get the display fields from settings if no common display fields defined
            List<DisplayCol> displayColList = commonDisplayColList;
            if (commonDisplayColList == null || commonDisplayColList.size() == 0) {
                displayColList = getDisplayColListFromSetting(rtSetting, sObjFieldMap);
            }
            
            // Get default field values from settings if no common default values defined
            if (fieldToValueMap.size() == 0 && fieldToURLParamStr != null)
                fieldToValueMap = getDefaultFieldValueMapFromStr(rtSetting.ASI_MFM_FieldsToParam__c);
            
            // Check other required fields
            Boolean needRecordTypeIdField = hasRecordType;
            if (hasRecordType) {
                for (DisplayCol dc : displayColList) {
                    for (DisplayField df : dc.displayFieldList) {
                        if (df.name.toUpperCase() == 'RECORDTYPEID')
                            needRecordTypeIdField = false;
                    }
                }
            }
            // Generate the query string
            List<sObject> existingSObjList = new List<sObject>();
            if (mode == MODE_BOTH || mode == MODE_EDIT) {
                String displayFieldCommaStr = getCommaStringFromDisplayColList(displayColList);
                if (needRecordTypeIdField) displayFieldCommaStr += ', RecordTypeId';
                String queryStr = 'SELECT ' + displayFieldCommaStr + ' FROM ' + sObjTypeStr;
                String wholeWhereStatm = '';
                if (whereStatm != null && whereStatm.trim().length() > 0) wholeWhereStatm += ' (' + whereStatm + ')';
                if (hasRecordType) wholeWhereStatm += (wholeWhereStatm.length() == 0 ? '' : ' AND') + ' (RecordTypeId = :rtId)';
                if (wholeWhereStatm.trim().length() > 0) queryStr += ' WHERE ' + wholeWhereStatm;
                if (orderByStr != null && orderByStr.trim().length() > 0) queryStr += ' ORDER BY ' + orderByStr;
                
                // Query the results
                system.debug('rtId: '+rtId);
                System.debug('queryString: ' + queryStr);
                existingSObjList = Database.query(queryStr);
                system.debug('existingSObjList: '+ existingSObjList);
            }
            theRecordTypeElementList.add(new RecordTypeElement(sObjType, tempRT, existingSObjList, displayColList, fieldToValueMap, isDefaultEditVal, isUseFirstRowForNew, isFastModeBool));
        }
        return true;
    }
    
    /**
     * Methods used by other classes
     */
    
    public void clearAll() {
        for (RecordTypeElement rtEle : theRecordTypeElementList) {
            rtEle.deleteAll();
        }
    }
    
    /**
     * Page Actions
     */
     
    
    public PageReference commitAll() {
        //For sub-brand allocation
        if(objPO != null && (objPO.RecordType.DeveloperName == 'ASI_MFM_CN_PO' || objPO.RecordType.DeveloperName == 'ASI_MFM_CN_PO_Read_Only')){
            Decimal decSBPercentage = 0;
            Set<id> setExistSubBrandID = new Set<id>();
            //Set<id> setAllocateSubBrandID = new Set<id>();
            Set<id> setSBId = new Set<Id>();
            Map<id, ASI_MFM_Sub_brand__c> mapSB = new Map<id, ASI_MFM_Sub_brand__c>();
            List<ASI_MFM_Sub_brand_Allocation__c> saveItemList = new List<ASI_MFM_Sub_brand_Allocation__c>();
            
            for(interimData r : results){
                setSBId.add(r.ppl.ASI_MFM_Sub_brand_Code__c);
            }
            List<ASI_MFM_Sub_brand__c> listSB = [SELECT id, name FROM ASI_MFM_Sub_brand__c WHERE id IN: setSBId];
            for(ASI_MFM_Sub_brand__c sb : listSB){
                mapSB.put(sb.id, sb);
            }            
            
            for(interimData r : results){
                ASI_MFM_Sub_brand_Allocation__c ppl = new ASI_MFM_Sub_brand_Allocation__c();
                ppl = r.ppl;
                ppl.name = mapSB.get(r.ppl.ASI_MFM_Sub_brand_Code__c).name;
                saveItemList.add(ppl);
            }           
            for(interimData r: results){
                if(r.ppl != null){
                    /*if(r.ppl.ASI_MFM_Sub_brand_Code__c != null)
                        setAllocateSubBrandID.add(r.ppl.ASI_MFM_Sub_brand_Code__c);*/
                    
                    if(r.ppl.ASI_MFM_Sub_brand_percentage__c == null)
                        r.ppl.ASI_MFM_Sub_brand_percentage__c = 0;
                    
                    decSBPercentage += r.ppl.ASI_MFM_Sub_brand_percentage__c;               
                }
            }
            if(decSBPercentage != 0 && decSBPercentage != 100){
                apexpages.addMessage(new apexpages.message(apexpages.severity.error, 'Total allocation percentage should be either 0% or 100%.')); 
                return null;
            }
            
            /*for(RecordTypeElement itm : theRecordTypeElementList){
                for(TableRow itm2 : itm.myDisplayRecordList){       
                    if(itm2.mySObj != null && itm2.mySObj.get('ASI_MFM_Sub_brand_Code__c') != null){
                        setExistSubBrandID.add((ID)itm2.mySObj.get('ASI_MFM_Sub_brand_Code__c'));
                    }
                }
            }           
            for(id key : setAllocateSubBrandID){
                if(!setExistSubBrandID.contains(key)){
                    apexpages.addMessage(new apexpages.message(apexpages.severity.error, 'You must select the sub-brand code that is contained in PO line items.')); 
                    return null;
                }
            }*/

            try{
                upsert saveItemList;
                
                if(delItemList != null && delItemList.size() > 0){
                    delete delItemList;
                    delItemList.clear();
                }
            }catch(DmlException dmle){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,dmle.getMessage()));
                return null;
            }catch(Exception e){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,e.getMessage()));
                return null;
            } 
        }
        //For sub-brand allocation - End

        List<sObject> insertList = new List<sObject>();
        List<sObject> updateList = new List<sObject>();
        List<sObject> deleteList = new List<sObject>();
        for (RecordTypeElement rtEle : theRecordTypeElementList) {
            for (TableRow tr : rtEle.myRecordList) {
                System.debug('Debug Log : ' + tr);
                if (!tr.isBlankAndHidden) {
                    if (tr.isDelete) {
                        if (tr.mySObj.Id != null)
                            deleteList.add(tr.mySObj);
                    } else if (tr.isNew) {
                        if (tr.mySObj.getsObjectType() == asi_mfm_po_line_item__c.sObjectType) {
                            tr.mySObj = asi_mfm_POLineItem.setAmount((asi_mfm_po_line_item__c)tr.mySObj);
                        }
                        insertList.add(tr.mySObj.clone(false, true)); 
                    } else if (tr.isEdit) {
                        updateList.add(tr.mySObj);
                    }
                }
            }
        }
        System.Savepoint sp = database.setSavepoint();
        
        //CAPEX Logic: Added By Conrad Pantua: check Payment Line Amount Sum = Payment Amount Header before database commit
   /*     if (sObjTypeStr == 'ASI_MFM_Payment_Line_Item__c') {
            // Added by Conrad (LAPUTA) Handle CAPEX Payment
            Set<ID> CapRecTypeID = new Set<ID>();
            for(RecordType rec : Global_RecordTypeCache.getRtList('ASI_MFM_Payment__c')){
                if(rec.DeveloperName.contains('ASI_MFM_CAP_Payment')){
                    CapRecTypeID.add(rec.id);
                }
            }
            
            List<ASI_MFM_Payment__c> pyList = [select ASI_MFM_Status__c, ASI_MFM_OCR__c, ASI_MFM_Payment_Amount__c, ASI_MFM_Is_Direct_Payment__c 
                                        from ASI_MFM_Payment__c 
                                        where id = :apexpages.currentPage().getParameters().get('id')
                                        AND recordtypeID IN : CapRecTypeID];
            if(pyList.size() > 0)
            {
                ASI_MFM_Payment__c py = pyList.get(0);
                Decimal paymentAmount = 0;
                
                List<ASI_MFM_Payment_Line_Item__c> deletePylList = deleteList.size() > 0 ? (List<ASI_MFM_Payment_Line_Item__c>)deleteList
                                                                    : new List<ASI_MFM_Payment_Line_Item__c>(); 
                                                                    
                List<ASI_MFM_Payment_Line_Item__c> updatePylList = updateList.size() > 0 ? (List<ASI_MFM_Payment_Line_Item__c>)updateList
                                                                    : new List<ASI_MFM_Payment_Line_Item__c>();
                                                                    
                List<ASI_MFM_Payment_Line_Item__c> InsertPylList = insertList.size() > 0 ? (List<ASI_MFM_Payment_Line_Item__c>)insertList
                                                                    : new List<ASI_MFM_Payment_Line_Item__c>();
                
                Set<ID> paymentLineExisting = new Set<ID>();
                
                for (ASI_MFM_Payment_Line_Item__c paymentLine : updatePylList)
                {
                    paymentLineExisting.add(paymentLine.id);
                }
                
                Map<ID, ASI_MFM_Payment_Line_Item__c> paymentLineMap = new Map<ID, ASI_MFM_Payment_Line_Item__c>();
                
                
                
                for (ASI_MFM_Payment_Line_Item__c paymentLine : deletePylList)
                {
                    if (paymentLine.ASI_MFM_Payment_Amount__c != null)
                        paymentAmount -= paymentLine.ASI_MFM_Payment_Amount__c;
                }
                for (ASI_MFM_Payment_Line_Item__c paymentLine : updatePylList)
                {
                    if (paymentLine.ASI_MFM_Payment_Amount__c != null)
                        paymentAmount += paymentLine.ASI_MFM_Payment_Amount__c;
                }
                for (ASI_MFM_Payment_Line_Item__c paymentLine : InsertPylList)
                {
                    if (paymentLine.ASI_MFM_Payment_Amount__c != null)
                        paymentAmount += paymentLine.ASI_MFM_Payment_Amount__c;
                }
            }
        }*/
        
        
        if (deleteList.size() > 0) {
            try {
                database.delete(deleteList);
            } catch (DmlException dmle) {
                Integer numOfError = dmle.getNumDml();
                for (Integer i = 0; i < numOfError; i++) {
                    sObject errorSObj = deleteList.get(dmle.getDmlIndex(i));
                    errorSObj.addError(formatMsg(dmle.getDmlMessage(i)));
                }
                database.rollback(sp);
                return null;
            }
        }
        if (updateList.size() > 0) {
            try { 
                database.update(updateList);
            } catch (DmlException dmle) {
                Integer numOfError = dmle.getNumDml();
                for (Integer i = 0; i < numOfError; i++) {
                    sObject errorSObj = updateList.get(dmle.getDmlIndex(i));
                    errorSObj.addError(formatMsg(dmle.getDmlMessage(i)));                  
                }
                database.rollback(sp);
                return null;
            }
        }
        if (insertList.size() > 0) {
            try {  
                database.insert(insertList);
            } catch (DmlException dmle) {
                Integer numOfError = dmle.getNumDml();
                for (Integer i = 0; i < numOfError; i++) {
                    sObject errorSObj = insertList.get(dmle.getDmlIndex(i));
                    errorSObj.addError(formatMsg(dmle.getDmlMessage(i)));
                }
                database.rollback(sp);
                return null;
            }
        }        
// Custom change starts
         if (sObjTypeStr == 'ASI_MFM_Plan_Line_Item__c') {
//Modified by Alan on 20150315
             ASI_MFM_Plan__c plan = [select id,ASI_MFM_Single_Approval__c , RecordType.DeveloperName,ASI_MFM_Plan_Amount__c,ASI_MFM_Total_PO_Amount__c from ASI_MFM_Plan__c where id = :apexpages.currentPage().getParameters().get('id')];
             
             if (plan.RecordType.DeveloperName.contains('ASI_MFM_SG')){
                 plan.ASI_MFM_Single_Approval__c = false;
                 update plan;
             }
             if(plan.ASI_MFM_Total_PO_Amount__c>plan.ASI_MFM_Plan_Amount__c){ //block PO Amt > Plan Amt
                 if (plan.RecordType.DeveloperName.contains('ASI_MFM_SG')){
                     apexpages.addMessage(new apexpages.message(apexpages.severity.error, 'PO Amt > Plan Amt !!'));
                     database.rollback(sp);
                     return null;
                 }
             }
         }
        if (sObjTypeStr == 'ASI_MFM_PO_Line_Item__c') {
            //Modified by Wilken on 20130924, HK MFM need hard error to block PO Amt > Plan Amt
            //Original SOQL
            ASI_MFM_PO__c po = [select id,ASI_MFM_Plan__c,ASI_MFM_Plan__r.ASI_MFM_Plan_Balance__c, RecordType.DeveloperName,ASI_MFM_PO_Amount__c,ASI_MFM_Is_Direct_Payment__c,ASI_MFM_Status__c from ASI_MFM_PO__c where id = :apexpages.currentPage().getParameters().get('id')];
            //Add By Elufa 20151215
            if(po.RecordType.DeveloperName.contains('ASI_MFM_GF') && po.ASI_MFM_Status__c== 'Final' && po.ASI_MFM_Is_Direct_Payment__c==false){
                decimal OriginalAmount=0;
                list<ASI_MFM_PO_Line_Item__c> plist=[select id,ASI_MFM_Original_Amount__c from ASI_MFM_PO_Line_Item__c where ASI_MFM_PO__c=:po.id];
                for(ASI_MFM_PO_Line_Item__c pl: plist){
                    if(pl.ASI_MFM_Original_Amount__c!=null){
                        OriginalAmount=OriginalAmount+pl.ASI_MFM_Original_Amount__c;
                    }
                }
                if(OriginalAmount<po.ASI_MFM_PO_Amount__c){
                    apexpages.addMessage(new apexpages.message(apexpages.severity.error, 'PO amount cannot be increased after approval.'));                 
                    database.rollback(sp);
                    return null;   
                }
                            
            }// GF MFM Logic end-- 
            
            // Set “Reference” as mandatory field for GF MFM, By Elufa 20160401
            // 20160926 Wilken: Remove Reference field in Gulf MFM
            /*if(po.RecordType.DeveloperName.contains('ASI_MFM_GF')){
               List<ASI_MFM_PO_Line_Item__c> PoLineList=[select id,name,ASI_MFM_Reference__c from ASI_MFM_PO_Line_Item__c where  ASI_MFM_PO__c=: po.id];
                boolean Ispass=true;
                String Msg='';
                for(ASI_MFM_PO_Line_Item__c pol:PoLineList){
                    if(pol.ASI_MFM_Reference__c==null){
                        Ispass=false;
                        Msg='Please input Reference.';
                    }
                }
                
                if(!Ispass){
                    apexpages.addMessage(new apexpages.message(apexpages.severity.error, Msg));                 
                    database.rollback(sp);
                    return null; 
                }
            }*/
            
            // SG MFM Logic:  prevent PO's sub brand differing from Plan's sub brand"     
            /*if(po.RecordType.DeveloperName.contains('ASI_MFM_SG')){          // Removed - Modified by 2017-07-19  Linus@Introv
                set<id> PlanSBSet= new set<id> ();
                boolean Ispass=true;
                 String Msg='';
                List<ASI_MFM_Plan_Line_Item__c> PlanLineList=[select id,ASI_MFM_Sub_brand_Code__c from ASI_MFM_Plan_Line_Item__c where ASI_MFM_Plan__c =: po.ASI_MFM_Plan__c and ASI_MFM_Sub_brand_Code__c !=null];
                for(ASI_MFM_Plan_Line_Item__c pl:PlanLineList){
                    PlanSBSet.add(pl.ASI_MFM_Sub_brand_Code__c);
                }
                List<ASI_MFM_PO_Line_Item__c> POLineList=[select id,name,ASI_MFM_Sub_brand_Code__c,ASI_MFM_Sub_brand_Code__r.name from ASI_MFM_PO_Line_Item__c where  ASI_MFM_PO__c=: po.id];
                for(ASI_MFM_PO_Line_Item__c pol:POLineList){
                    if(!PlanSBSet.contains(pol.ASI_MFM_Sub_brand_Code__c)){
                        Ispass=false;
                        Msg='Sub Brand Code :   '+pol.ASI_MFM_Sub_brand_Code__r.name +'    does not exist in Plan Lines. ';
                    }
                }
                
                if(!Ispass && !ASI_MFM_ByPass_Setting.ByPassClass('ASI_MFM_POManagAllClass','SG')){
                    apexpages.addMessage(new apexpages.message(apexpages.severity.error, Msg));                 
                    database.rollback(sp);
                    return null; 
                }
            }*/
            
            if(po.RecordType.DeveloperName.contains('ASI_MFM_MY')){
               List<ASI_MFM_PO_Line_Item__c> PoLineList=[select id,name,ASI_MFM_A_C_Code__c from ASI_MFM_PO_Line_Item__c where  ASI_MFM_PO__c=: po.id];
                boolean Ispass=true;
                String Msg='';
                for(ASI_MFM_PO_Line_Item__c pol:PoLineList){
                    if(pol.ASI_MFM_A_C_Code__c==null){
                        Ispass=false;
                        Msg='Please input A/C Code';
                    }
                }
                
                if(!Ispass){
                    apexpages.addMessage(new apexpages.message(apexpages.severity.error, Msg));                 
                    database.rollback(sp);
                    return null; 
                }
            }// End Of MY Logic
            
            if (po.ASI_MFM_Plan__r.ASI_MFM_Plan_Balance__c < 0 && po.ASI_MFM_Plan__r.ASI_MFM_Plan_Balance__c != last_plan_balance) {
                System.debug('PO Record Type Name: ' + po.RecordType.DeveloperName);
                if (po.RecordType.DeveloperName.contains('ASI_MFM_HK')){
                    apexpages.addMessage(new apexpages.message(apexpages.severity.error, 'Total PO amount exceeds the available plan balance.'));                 
                    database.rollback(sp);
                    return null;                
                }
                else if (po.RecordType.DeveloperName.contains('ASI_MFM_MY')){
                    apexpages.addMessage(new apexpages.message(apexpages.severity.error, 'Total PO amount exceeds the available plan balance.'));                 
                    database.rollback(sp);
                    return null;                
                }
                // Added by Alan Wong (Elufa) 6Feb2015
                else if (po.RecordType.DeveloperName.contains('ASI_MFM_SG') || po.RecordType.DeveloperName.contains('ASI_MFM_TH')){
                    apexpages.addMessage(new apexpages.message(apexpages.severity.error, 'Total PO amount exceeds the available plan balance.'));                 
                    database.rollback(sp);
                    return null;                
                }
                else {
                    if (last_plan_balance == null) {
                        apexpages.addMessage(new apexpages.message(apexpages.severity.warning, 
                            'Total PO amount exceeds the available plan balance. Click "Save All" button again if want to proceed. Click "Cancel" button if do not want to proceed.'));                 
                    }
                    else {
                        apexpages.addMessage(new apexpages.message(apexpages.severity.warning, 
                            'Total PO amount still exceeds the available plan balance after you made changes. Click "Save All" button again if want to proceed. Click "Cancel" button if do not want to proceed.'));                    
                    }
                    last_plan_balance = po.ASI_MFM_Plan__r.ASI_MFM_Plan_Balance__c;
                    database.rollback(sp);
                    return null;                
                }
            }
        }        
        else if (sObjTypeStr == 'ASI_MFM_Payment_Line_Item__c') {
            //Added by Michael Yip (Introv) Handle CN payment checking
            Set<id> SCNRecTypeID = new Set<id>();
            // Added by Conrad (LAPUTA) Handle CAPEX Payment
            Set<ID> CapRecTypeID = new Set<ID>();
            Set<ID> PrepaymentRecTypeID = new Set<ID>();
            Set<ID> MYRecTypeID = new Set<ID>();
            for(RecordType rec : Global_RecordTypeCache.getRtList('ASI_MFM_Payment_Line_Item__c')){
                if(rec.DeveloperName.contains('CN_Payment')){
                    SCNRecTypeID.add(rec.id);
                }
                if(rec.DeveloperName.contains('ASI_MFM_CAP_Payment')){
                    CapRecTypeID.add(rec.id);
                }
                if(rec.DeveloperName.contains('ASI_MFM_MY_Payment')){
                    MYRecTypeID.add(rec.id);
                }
                if(rec.DeveloperName.contains('ASI_MFM_SG_Payment') || rec.DeveloperName.contains('ASI_MFM_TH_Payment') ){
                    PrepaymentRecTypeID.add(rec.id);
                }
            }

            ASI_MFM_Payment__c py = [select name,ASI_MFM_G_L_Date__c,ASI_MFM_POSM_Deposit__c, ASI_MFM_POSM_Balance__c, ASI_MFM_Status__c, ASI_MFM_OCR__c, ASI_MFM_Payment_Amount__c,RecordType.DeveloperName , ASI_MFM_Is_Direct_Payment__c, (select  recordtypeid, ASI_MFM_PO_Line_Item__r.name,ASI_MFM_PO_Line_Item__r.ASI_MFM_POSM_Deposit__c, ASI_MFM_PO_Line_Item__r.ASI_MFM_Remaining_Balance__c,ASI_MFM_POSM_Balance__c,ASI_MFM_Complete_POL__c ,ASI_MFM_G_L_Date__c,ASI_MFM_Payment_Amount__c,ASI_MFM_PO_Line_Remaining_Amount__c, ASI_MFM_Payee__c, ASI_MFM_Invoice_Number__c, ASI_MFM_Invoice_Date__c, ASI_MFM_Payment__r.ASI_MFM_POSM_Deposit__c from Payment_Line_Items__r) from ASI_MFM_Payment__c where id = :apexpages.currentPage().getParameters().get('id')];
            if (!negative_pol_balance) {
                string pol_list = '';
                boolean negativePOLCAPEX = false;
                boolean depositwithoutbalance = false;
                boolean balancewithoutcomplete = false;
                boolean fullpaydeposit = false;
                boolean diffinvoicedate = false;
                Map<id, map<string, date>> InvoiceDate_Map = new Map<id, map<string, date>>();
                
                //For MY Checking ,One Invoice Number should have One G/L Date
                boolean diffGLDate = false;
                Map<id, map<string, date>> GLDate_Map = new Map<id, map<string, date>>();
                
                Decimal paymentAmount = 0;
                for (ASI_MFM_Payment_Line_Item__c pyl:py.Payment_Line_Items__r) {
                    //Capex Logic
                    boolean capexSkipChecking = false;
                    if(CapRecTypeID.contains(pyl.recordtypeid))
                    {
                        // Only skip warning if SSC Finance is doing the changes
                        if(py.ASI_MFM_Status__c == 'Final'){
                            capexSkipChecking = true;
                        }
                    } 
                    //End of Capex Logic
                    if (pyl.ASI_MFM_PO_Line_Item__r.ASI_MFM_Remaining_Balance__c < 0 && !SCNRecTypeID.contains(pyl.recordtypeid) && !capexSkipChecking) {
                        negative_pol_balance = true;
                        if (!pol_list.contains(pyl.ASI_MFM_PO_Line_Item__r.name)) {
                            if (pol_list.length() > 0) {
                                pol_list += ', ';
                            }
                            pol_list += pyl.ASI_MFM_PO_Line_Item__r.name;
                        }
                    }
                    // For CAPEX, block user if total Payment amount greater than PO amount
                    if (pyl.ASI_MFM_PO_Line_Item__r.ASI_MFM_Remaining_Balance__c < 0 && CapRecTypeID.contains(pyl.recordtypeid) && !capexSkipChecking) {                        
                        negativePOLCAPEX = true;
                        if (!pol_list.contains(pyl.ASI_MFM_PO_Line_Item__r.name)) {
                            if (pol_list.length() > 0) {
                                pol_list += ', ';
                            }
                            pol_list += pyl.ASI_MFM_PO_Line_Item__r.name;
                        }
                    }
                    if (PrepaymentRecTypeID.contains(pyl.recordtypeid) && pyl.ASI_MFM_PO_Line_Item__r.ASI_MFM_Remaining_Balance__c < 0 ) {
                        negative_pol_balance = true;
                        if (!pol_list.contains(pyl.ASI_MFM_PO_Line_Item__r.name)) {
                            if (pol_list.length() > 0) {
                                pol_list += ', ';
                            }
                            pol_list += pyl.ASI_MFM_PO_Line_Item__r.name;
                        }
                    }
                    // Added by Alan Wong (Elufa) 20150510 check POSM Status
                    if (PrepaymentRecTypeID.contains(pyl.recordtypeid) && pyl.ASI_MFM_PO_Line_Item__r.ASI_MFM_POSM_Deposit__c == true && pyl.ASI_MFM_POSM_Balance__c == false && (pyl.ASI_MFM_Complete_POL__c == true || (pyl.ASI_MFM_PO_Line_Remaining_Amount__c - pyl.ASI_MFM_Payment_Amount__c) == 0)) {
                        depositwithoutbalance = true;
                        if (!pol_list.contains(pyl.ASI_MFM_PO_Line_Item__r.name)) {
                            if (pol_list.length() > 0) {
                                pol_list += ', ';
                            }
                            pol_list += pyl.ASI_MFM_PO_Line_Item__r.name;
                        }
                    }
                    if (PrepaymentRecTypeID.contains(pyl.recordtypeid) && pyl.ASI_MFM_Payment__r.ASI_MFM_POSM_Deposit__c == true && (pyl.ASI_MFM_PO_Line_Remaining_Amount__c - pyl.ASI_MFM_Payment_Amount__c) == 0) {
                        fullpaydeposit = true;
                        if (!pol_list.contains(pyl.ASI_MFM_PO_Line_Item__r.name)) {
                            if (pol_list.length() > 0) {
                                pol_list += ', ';
                            }
                            pol_list += pyl.ASI_MFM_PO_Line_Item__r.name;
                        }
                    }
                    if (PrepaymentRecTypeID.contains(pyl.recordtypeid) && pyl.ASI_MFM_PO_Line_Item__r.ASI_MFM_POSM_Deposit__c == true && pyl.ASI_MFM_POSM_Balance__c == true && (pyl.ASI_MFM_Complete_POL__c == false && (pyl.ASI_MFM_PO_Line_Remaining_Amount__c - pyl.ASI_MFM_Payment_Amount__c) > 0)) {
                        balancewithoutcomplete = true;
                        if (!pol_list.contains(pyl.ASI_MFM_PO_Line_Item__r.name)) {
                            if (pol_list.length() > 0) {
                                pol_list += ', ';
                            }
                            pol_list += pyl.ASI_MFM_PO_Line_Item__r.name;
                        }
                    }
                    
                    //One Invoice No. can only have one Invoice Date
                    if (PrepaymentRecTypeID.contains(pyl.recordtypeid) || MYRecTypeID.contains(pyl.recordtypeid)) {
                        if(!InvoiceDate_Map.containsKey(pyl.ASI_MFM_Payee__c)){
                            map<string, date> newmap= new map<string, date>();
                            newmap.put(pyl.ASI_MFM_Invoice_Number__c,pyl.ASI_MFM_Invoice_Date__c);
                            InvoiceDate_Map.put(pyl.ASI_MFM_Payee__c, newmap);
                        }else {
                            if (InvoiceDate_Map.get(pyl.ASI_MFM_Payee__c).containsKey(pyl.ASI_MFM_Invoice_Number__c)){
                                if(InvoiceDate_Map.get(pyl.ASI_MFM_Payee__c).get(pyl.ASI_MFM_Invoice_Number__c) != pyl.ASI_MFM_Invoice_Date__c){
                                    diffinvoicedate = true;                
                                    if (!pol_list.contains(pyl.ASI_MFM_PO_Line_Item__r.name)) {
                                        if (pol_list.length() > 0) {
                                            pol_list += ', ';
                                        }
                                        pol_list += pyl.ASI_MFM_PO_Line_Item__r.name;
                                    }
                                }
                            }
                        }                        
                    } 
                    //

                    
                    //One Invoice No. can only have one GL Date
                        if (MYRecTypeID.contains(pyl.recordtypeid)) {
                        if(!GLDate_Map.containsKey(pyl.ASI_MFM_Payee__c)){
                            map<string, date> newmap= new map<string, date>();
                            newmap.put(pyl.ASI_MFM_Invoice_Number__c,pyl.ASI_MFM_G_L_Date__c);
                            GLDate_Map.put(pyl.ASI_MFM_Payee__c, newmap);
                        }else {
                            if (GLDate_Map.get(pyl.ASI_MFM_Payee__c).containsKey(pyl.ASI_MFM_Invoice_Number__c)){
                                if(GLDate_Map.get(pyl.ASI_MFM_Payee__c).get(pyl.ASI_MFM_Invoice_Number__c) != pyl.ASI_MFM_G_L_Date__c){
                                    diffGLDate = true;                
                                    if (!pol_list.contains(pyl.ASI_MFM_PO_Line_Item__r.name)) {
                                        if (pol_list.length() > 0) {
                                            pol_list += ', ';
                                        }
                                        pol_list += pyl.ASI_MFM_PO_Line_Item__r.name;
                                    }
                                }
                            }
                        }                        
                    } 
                    
                }
                
                if (negativePOLCAPEX) {
                    apexpages.addMessage(new apexpages.message(apexpages.severity.FATAL, 'The total Payment Amount is greater than Amount in PO line item ' + pol_list + '. Please check'));                 
                    database.rollback(sp);
                    return null; 
                } 
                if (fullpaydeposit) {
                    apexpages.addMessage(new apexpages.message(apexpages.severity.FATAL, 'You cannot full pay a POSM deposit PO Line: ' + pol_list));                 
                    database.rollback(sp);
                    return null; 
                }
                if (depositwithoutbalance) {
                    apexpages.addMessage(new apexpages.message(apexpages.severity.FATAL, 'You cannot complete POSM deposit PO Lines: ' + pol_list + ' without checking "POSM: Balance" checkbox. Please check the Payment header.'));                 
                    database.rollback(sp);
                    return null; 
                }
                
                if (balancewithoutcomplete) {
                    apexpages.addMessage(new apexpages.message(apexpages.severity.FATAL, 'Please tick "Complete POL" checkbox for partial POSM Balance. PO Lines: ' + pol_list));                 
                    database.rollback(sp);
                    return null; 
                }
                
                if (diffinvoicedate) {
                    apexpages.addMessage(new apexpages.message(apexpages.severity.FATAL, 'One Invoice No. can only have one Invoice Date'));                 
                    database.rollback(sp);
                    return null; 
                }
                
                 if (diffGLDate) {
                    apexpages.addMessage(new apexpages.message(apexpages.severity.FATAL, 'One Invoice Number can only have one G/L Date'));                 
                    database.rollback(sp);
                    return null; 
                }
                
                
                if (negative_pol_balance) {
                    // Add by Alan Wong (Elufa) 4 March 2015
                    // PY Line balance checking
                    if (py.RecordType.DeveloperName.contains('ASI_MFM_SG') || py.RecordType.DeveloperName.contains('ASI_MFM_TH') || py.RecordType.DeveloperName.contains('ASI_MFM_MY')) {
                        apexpages.addMessage(new apexpages.message(apexpages.severity.FATAL, 'The total Payment Amount is greater than Amount in PO line item ' + pol_list + '. Please check'));                 
                        database.rollback(sp);
                        return null;
                    } // End Logic
                    else
                    { 
                        
                        apexpages.addMessage(new apexpages.message(apexpages.severity.warning, 
                            'The remaining balance of PO line item ' + pol_list + ' is less than the payment amount. Click "Save All" button again if want to proceed. Click "Cancel" button if do not want to proceed.'));                 
                        database.rollback(sp);
                        return null;
                    }
                }                          
            }
        }
// Custom change ends
        return new PageReference(successLink);
    }
    
    /*
     * Methods for non-fast mode only
     * Start {
     */
    public PageReference triggerPageBlockAction() {
        PageReference redirectPage = null;
        String pbBtnId = ApexPages.currentPage().getParameters().get('PARAM_PB_BTN_ID');
        if (pageController != null) redirectPage = ((ASI_MFM_MassCreateAndUpdateAbstract)pageController).mcau_triggerPageBlockAction(this, pbBtnId);
        return redirectPage;
    }
    
    public PageReference addNewRow() {
        String rtid = ApexPages.currentPage().getParameters().get(PARAM_RTID);
        RecordTypeElement curRTEle = getRTElementByRTDevName(rtid);
        TableRow tr = curRTEle.createNewSObject();
        if (pageController != null) ((ASI_MFM_MassCreateAndUpdateAbstract)pageController).mcau_triggerActionForSObject(this, ACTION_ADD_NEW, tr.mySObj);
        return null;
    }
    public void addNewRowByInfo(String rtDevName, sObject sObj) {
        System.debug('sb8:' + rtDevName);
        RecordTypeElement curRTEle = getRTElementByRTDevName(rtDevName);
        TableRow tr = null;
        System.debug('sb9:' + getRTElementByRTDevName(rtDevName));
        if (curRTEle != null) {
            tr = curRTEle.createNewSObject(sObj);
            System.debug('sc0:');
        }
        if (tr != null && pageController != null){
            ((ASI_MFM_MassCreateAndUpdateAbstract)pageController).mcau_triggerActionForSObject(this, ACTION_ADD_NEW, tr.mySObj);
            System.debug('sc1:');
        }
    }
    
    public PageReference cloneRow() {
        Map<String, String> urlParamMap = ApexPages.currentPage().getParameters();
        String rtid = urlParamMap.get(PARAM_RTID);
        String trid = urlParamMap.get(PARAM_TRID);
        RecordTypeElement curRTEle = getRTElementByRTDevName(rtid);
        TableRow tr = curRTEle.cloneNewSObjectByTableRowId(trid);
        if (pageController != null) ((ASI_MFM_MassCreateAndUpdateAbstract)pageController).mcau_triggerActionForSObject(this, ACTION_CLONE, tr.mySObj);
        return null;
    }
    
    public PageReference enableForEdit() {
        Map<String, String> urlParamMap = ApexPages.currentPage().getParameters();
        String rtid = urlParamMap.get(PARAM_RTID);
        String trid = urlParamMap.get(PARAM_TRID);
        RecordTypeElement curRTEle = getRTElementByRTDevName(rtid);
        TableRow tr = curRTEle.enableForEditByTableRowId(trid);
        if (pageController != null) ((ASI_MFM_MassCreateAndUpdateAbstract)pageController).mcau_triggerActionForSObject(this, ACTION_EDIT, tr.mySObj);
        return null;
    }
    
    public PageReference removeNew() {
        Map<String, String> urlParamMap = ApexPages.currentPage().getParameters();
        String rtid = urlParamMap.get(PARAM_RTID);
        String trid = urlParamMap.get(PARAM_TRID);
        TableRow tr = deleteRow(rtid, trid);
        if (pageController != null) ((ASI_MFM_MassCreateAndUpdateAbstract)pageController).mcau_triggerActionForSObject(this, ACTION_REMOVE_NEW, tr.mySObj);
        return null;
    }
    
    public PageReference deleteOld() {
        Map<String, String> urlParamMap = ApexPages.currentPage().getParameters();
        String rtid = urlParamMap.get(PARAM_RTID);
        String trid = urlParamMap.get(PARAM_TRID);
        TableRow tr = deleteRow(rtid, trid);
        if (pageController != null) ((ASI_MFM_MassCreateAndUpdateAbstract)pageController).mcau_triggerActionForSObject(this, ACTION_REMOVE_NEW, tr.mySObj);
        return null;
    }
    
    public TableRow deleteRow(String rtid, String trid) {
        RecordTypeElement curRTEle = getRTElementByRTDevName(rtid);
        TableRow tr = curRTEle.removeByTableRowId(trid);
        return tr;
    }
    
    /*
     * Methods for non-fast mode only
     * } End
     */
    
    /*
     * Methods for fast mode only
     * Start {
     */
    
    public PageReference addMoreBlankRows() {
        String rtid = ApexPages.currentPage().getParameters().get(PARAM_RTID);
        String numOfShowRowStr = ApexPages.currentPage().getParameters().get(PARAM_NUM_OF_SHOW_ROW);
        Integer numOfShowRow = numOfShowRowStr != null ? Integer.valueOf(numOfShowRowStr) : 1;
        RecordTypeElement curRTEle = getRTElementByRTDevName(rtid);
        for (Integer i = 0; i < NUM_OF_HIDDEN_ROW; i++) {
            TableRow tr = curRTEle.createNewSObject();
            tr.isBlankAndHidden = true;
        }
        return null;
    }
    
    /*
     * Methods for fast mode only
     * } End
     */
     
    public void refresh() {
    }
    
    private RecordTypeElement getRTElementByRTDevName(String rtId) {
        for (RecordTypeElement rtEle : theRecordTypeElementList) {
            if (rtEle.myRecordType.DeveloperName == rtId)
                return rtEle;
        }
        return null;
    }
    
    /**
     * Methods used by init()
     */
    
    private List<RecordType> getRecordTypeList() {
        List<RecordType> allRecordTypeList = database.query('SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType = :sObjTypeStr AND IsActive = true ORDER BY Name');
        List<RecordType> recordTypeList = new List<RecordType>();
        system.debug('includeRecordTypes: '+includeRecordTypes);
        // include only part of record types if needed
        if (includeRecordTypes != null) {
            Set<String> recordTypeStringSet = new Set<String>(strToStrList(includeRecordTypes, DELIM_RT));
            for (RecordType tempRT : allRecordTypeList) {
                if (recordTypeStringSet.contains(tempRT.DeveloperName))
                    recordTypeList.add(tempRT);
            }
        } else {
            recordTypeList = allRecordTypeList;
        }
        return recordTypeList;
    }
    
    private ASI_MFM_MassCreateAndUpdateSetting__c getSettingByRecordType(Map<String, ASI_MFM_MassCreateAndUpdateSetting__c> allSettingMap, String recordTypeDevName) {
        String settingKey = (recordTypeDevName == RTDEVNAME_MASTER) ? sObjTypeStr : sObjTypeStr + DELIM_SETTING_KEY + recordTypeDevName;
        ASI_MFM_MassCreateAndUpdateSetting__c rtSetting = allSettingMap.get(settingKey);
        if (rtSetting == null) {
            settingKey = (recordTypeDevName == RTDEVNAME_MASTER) ? altSObjectTypeName : altSObjectTypeName + DELIM_SETTING_KEY + recordTypeDevName;
            rtSetting = allSettingMap.get(settingKey);
        }
        return rtSetting;
    }
    
    private List<DisplayCol> getDisplayColListByFieldStr(String fieldsStr, Map<String, Schema.SObjectField> sObjFieldMap) {
        //Add by Abel
        List<DisplayCol> result = new List<DisplayCol>();  
        Set<String> nowPickListSet = getCheckPicklistSet();  //Add by Abel
        boolean fieldIsPicklist = false;  //Add by Abel
        if (fieldsStr != null && fieldsStr.trim().length() > 0) {
            List<String> fieldList = fieldsStr.split(DELIM_FIELDS, 0);
            DisplayCol curDC = null;
            for (String fieldStr : fieldList) { // Field1__c&req=t&key=value, Field2__c
                List<String> fieldEleList = fieldStr.trim().split(DELIM_FIELD_ELEMENTS, 0);
                String fieldDevName = fieldEleList.get(0).trim();
                Schema.SObjectField sObjField = sObjFieldMap.get(fieldDevName);
                if (sObjField != null) { // if field exists
                    // Create display field
                    //Add by Abel
                    fieldIsPicklist = CheckPicklistSet.contains(fieldDevName);  //Add by Abel
                        System.debug('bcd 7' + fieldDevName);  //Add by Abel
                        System.debug('bcd 7' + fieldIsPicklist);  //Add by Abel
                        
                    
                    DisplayField df = new DisplayField(sObjField.getDescribe().getLabel(), fieldDevName, fieldIsPicklist);  //Add by Abel
                    String colKey = null;
                    String colLabel = null;
                    String colWidth = null;
                    if (fieldEleList.size() > 1) {
                        for (Integer i = 1; i < fieldEleList.size(); i++) { // req=t&key=value
                            List<String> keyAndValue = fieldEleList.get(i).split(DELIM_FIELD_SETTING, 2);
                            if (keyAndValue.size() == 2) {
                                String key = keyAndValue.get(0).trim().toLowerCase();
                                String value = keyAndValue.get(1).trim();
                                if (FIELD_PARAM_COL_KEY == key) {
                                    colKey = value;
                                    colLabel = value;
                                } else if (FIELD_PARAM_COL_WIDTH == key) {
                                    // TODO: get the maximum value
                                    colWidth = value;
                                }
                                assignDisplayFieldProperty(df, key, value);
                            }
                        }
                        if (colLabel == null) {
                            colLabel = df.label;
                            df.label = null;
                        }
                    }
                    if (curDC == null || colKey == null || curDC.colKey != colKey) {
                        curDC = new DisplayCol(colKey, colLabel);
                        result.add(curDC);
                        curDC.colWidth = colWidth;
                    }
                    curDC.addDisplayField(df);
                    system.debug('Field label: ' + df.label);
                    system.debug('Field name: ' + df.name);
                    system.debug('Is required: ' + df.isrequired);
                } else {
                    System.debug('Unknown field: ' + fieldDevName);
                }
            }
        }
        if (result.size() == 0) {
            DisplayCol dc = new DisplayCol(null, null);
            result.add(dc);
            dc.addDisplayField(new DisplayField('Name', 'Name'));
        }
        return result;
    }
    
    private void assignDisplayFieldProperty(DisplayField df, String key, String value) {
        if (FIELD_PARAM_REQUIRED == key) {
            if (value.toLowerCase() == 't' || value.toLowerCase() == 'true')
                df.isRequired = true;
        } else if (FIELD_PARAM_COL_WIDTH == key) {
            df.width = value;
        } else if (FIELD_PARAM_READ_ONLY == key) {
            df.readonlyMode = value.toLowerCase();
        } else if (FIELD_PARAM_COL_KEY == key) {
            df.colKey = value;
        } else if (FIELD_PARAM_SKIP_CLONE == key) {
            df.skipClone = value != null && value.toLowerCase() == 't' || value.toLowerCase() == 'true';
        }
    }
    
    private List<DisplayCol> getDisplayColListFromSetting(ASI_MFM_MassCreateAndUpdateSetting__c rtSetting, Map<String, Schema.SObjectField> sObjFieldMap) {
        if (rtSetting == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'List of display fields is not specified for the object: ' + sObjTypeStr + '. Please edit Custom Setting MassCreateAndUpdateSetting'));
            return null;
        }
        String settingDF = rtSetting.ASI_MFM_DisplayFields__c;
        if (settingDF == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Empty displayField' + sObjTypeStr + '. Please edit Custom Setting MassCreateAndUpdateSetting'));
            return null;
        }
        return getDisplayColListByFieldStr(settingDF, sObjFieldMap);
    }
    
    private String getCommaStringFromDisplayColList(List<DisplayCol> dcList) {
        String result = '';
        for (DisplayCol dc : dcList) {
            List<DisplayField> dfList = dc.displayFieldList;
            for (DisplayField df : dfList) {
                result += ', ' + df.name;
            }
        }
        if (result.length() > 2)
            return result.substring(2);
        return '';
    }
    
    private Map<String, String> getDefaultFieldValueMapFromStr(String fieldToParamStr) {
        Map<String, String> fieldNameToValueMap = new Map<String, String>();
        if (fieldToParamStr != null && fieldToParamStr.trim().length() > 0) {
            Map<String, String> urlParamMap = ApexPages.currentPage().getParameters();
            Map<String, String> fieldToParamMap = strToStrMap(fieldToParamStr);
            Set<String> fieldNameSet = fieldToParamMap.keySet();
            for (String fieldName : fieldNameSet) {
                String paramName = fieldToParamMap.get(fieldName);
                fieldNameToValueMap.put(fieldName, urlParamMap.get(paramName));
            }
        }
        return fieldNameToValueMap;
    }
    
    /**
     * Other Utils
     */
    
    private List<String> strToStrList(String inputStr) { return this.strToStrList(inputStr, ','); }
    private List<String> strToStrList(String inputStr, String delim) {
        List<String> result = new List<String>();
        if (inputStr != null && delim != null) {
            List<String> inputStrList = inputStr.split(delim, 0);
            for (String ele : inputStrList) {
                result.add(ele.trim());
            }
        }
        return result;
    }
    
    private String strListToStr(List<String> inputStrList) { return this.strListToStr(inputStrList, ','); }
    private String strListToStr(List<String> inputStrList, String delim) {
        String result = '';
        if (inputStrList != null && delim != null) {
            for (String ele : inputStrList) {
                result += delim + ele;
            }
        }
        if (result.length() >= delim.length()) {
            return result.substringAfter(delim);
        }
        return '';
    }
    
    private Map<String, String> strToStrMap(String mapStr) {
        Map<String, String> result = new Map<String, String>();
        if (mapStr.trim().length() > 0) {
            List<String> mapList = strToStrList(mapStr, ',');
            for (String ms : mapList) {
                List<String> keyAndValue = ms.split('=>', 2);
                if (keyAndValue.size() != 2)
                    ApexPages.addMessage(new  ApexPages.Message(ApexPages.Severity.WARNING, 'Incorrect Map String: ' + mapStr + '. Please check the Custom Setting MassCreateAndUpdateSetting'));
                else
                    result.put(keyAndValue.get(0).trim(), keyAndValue.get(1).trim());
            }
        }
        return result;
    }
    
    //sub-brand allocation
    public void sba_addRow(){    
        if(results != null && results.size() > 0){
            interimData sbaObj = new interimData();
            sbaObj.ppl = new ASI_MFM_Sub_brand_Allocation__c();
            sbaObj.rowindex = index;
            sbaObj.ppl.ASI_MFM_PO__c = apexpages.currentPage().getParameters().get('id');
            sbaObj.ppl.recordtypeID = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand_Allocation__cASI_MFM_CN_Sub_Brand_Allocation');            
            results.add(0,sbaObj);
            index++;
        }else{
            results = new List<interimData>();
            interimData sbaObj = new interimData();
            sbaObj.ppl = new ASI_MFM_Sub_brand_Allocation__c();
            sbaObj.rowindex = index;
            sbaObj.ppl.ASI_MFM_PO__c = apexpages.currentPage().getParameters().get('id');
            sbaObj.ppl.recordtypeID = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand_Allocation__cASI_MFM_CN_Sub_Brand_Allocation');
            results.add(sbaObj);
            index++; 
        }
    }
    public void sba_cloneRow(){
        interimData selected_itm;
        List<interimData> cloneList = new List<interimData>();
        
         for(interimData rpl : results){
            if(rpl.rowindex == rowSelected_index){
                selected_itm = new interimData();
                selected_itm.rowindex = index;
                selected_itm.ppl = new ASI_MFM_Sub_brand_Allocation__c();
                selected_itm.ppl.ASI_MFM_PO__c = apexpages.currentPage().getParameters().get('id');
                selected_itm.ppl.ASI_MFM_Sub_brand_Code__c = rpl.ppl.ASI_MFM_Sub_brand_Code__c;
                selected_itm.ppl.ASI_MFM_Sub_brand_percentage__c = rpl.ppl.ASI_MFM_Sub_brand_percentage__c;
                selected_itm.ppl.recordtypeID = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand_Allocation__cASI_MFM_CN_Sub_Brand_Allocation');
                
                cloneList.add(selected_itm);
                index++;
            }
         }
         results.addall(cloneList);
    }
    public void sba_deleteRow(){
        interimData selected_rpl;
        integer i = 0;
        integer c = 0;
        List <integer> temp_index = new List <integer>();
        
        for(interimData r : results){  
            if(r.rowindex == rowSelected_index){
                temp_index.add(i);
                if(r.ppl.id != null)
                    delItemList.add(r.ppl);
            }
            i++;
        }       
        for(integer n : temp_index){
            if(n!=0){
                if(c>0) n=n-c;
                results.remove(n);
                c++;
            }else{
                results.remove(0);
                c++;
            }
        }
    }
    //End of sub-brand allocation
    
    public class RecordTypeElement {
        public RecordType myRecordType { get; set; }
        public List<TableRow> myRecordList { get; set; }
        public List<TableRow> myDisplayRecordList {
            get {
                if (myRecordList == null) return null;
                List<TableRow> tempList = new List<TableRow>();
                for (TableRow tr : myRecordList)
                    if (tr.isDelete != true)
                        tempList.add(tr);
                return tempList;
            }
            set;
        }
        public List<DisplayCol> myDisplayColList { get; set; }
        public Set<String> myDisplayFieldSet;
        private Schema.SObjectType sObjType;
        private Map<String, String> fieldNameToValueMap;
        private Boolean hasRecordType;
        public Integer tableRowNextId;
        private Boolean isCreateBeforeFirstRow;
        private Boolean isFastMode;
        
        public RecordTypeElement(Schema.SObjectType sObjType, RecordType recordType, List<sObject> sObjList, List<DisplayCol> displayColList
            , Map<String, String> fieldNameToValueMap, Boolean isAllEdit, Boolean isCreateBeforeFirstRow, Boolean isFastMode) {
            this.myRecordType = recordType;
            this.myDisplayColList = displayColList;
            this.sObjType = sObjType;
            this.fieldNameToValueMap = fieldNameToValueMap;
            this.hasRecordType = (myRecordType.DeveloperName != RTDEVNAME_MASTER);
            this.tableRowNextId = 1;
            this.isCreateBeforeFirstRow = isCreateBeforeFirstRow;
            this.isFastMode = isFastMode;
            this.myRecordList = new List<TableRow>();
            
            for (sObject tempSObj : sObjList) {
                TableRow tr = new TableRow(this, tempSObj, false);
                if (isAllEdit) tr.isEdit = true;
                this.myRecordList.add(tr);
            }
            if (isFastMode) {
                for (Integer i = 0; i < NUM_OF_HIDDEN_ROW; i++) {
                    TableRow tr = createNewSObject(isCreateBeforeFirstRow);
                    tr.isBlankAndHidden = true;
                }
            }
            // Assign display fields developer name to set for later search
            Schema.DescribeSObjectResult sObjTypeDescribe = sObjType.getDescribe();
            Map<String, Schema.SObjectField> sObjFieldMap = sObjTypeDescribe.fields.getMap();
            this.myDisplayFieldSet = new Set<String>();
            for (DisplayCol dc : displayColList) {
                List<DisplayField> displayFieldList = dc.displayFieldList;
                for (DisplayField df : displayFieldList) {
                    this.myDisplayFieldSet.add(df.name);
                }
            }
        }
        
        public TableRow enableForEditByTableRowId(String trId) {
            TableRow tr = getTableRowById(trId);
            if (tr != null)
                tr.isEdit = true;
            return tr;
        }
        
        public TableRow removeByTableRowId(String trId) {
            Integer size = myRecordList.size();
            for (Integer i = 0; i < size; i++) {
                TableRow tr = myRecordList.get(i);
                if (tr.id != null && tr.id == trid) {
                    if (tr.isNew) {
                        return myRecordList.remove(i);
                    } else {
                        tr.isDelete = true;
                        return tr;
                    }
                }
            }
            return null;
        }
        
        public TableRow createNewSObject() { return createNewSObject(this.isCreateBeforeFirstRow); }
        public TableRow createNewSObject(Boolean beforeFirstRow) { return createNewSObject(!beforeFirstRow ? this.myRecordList.size() : 0, this.sObjType.newSObject()); }
        public TableRow createNewSObject(sObject newSObj) { return createNewSObject(!this.isCreateBeforeFirstRow ? this.myRecordList.size() : 0, newSObj); }
        public TableRow createNewSObject(Integer index, sObject newSObj) {
            system.debug('sd0: enter');
            if (hasRecordType)
                newSObj.put('RecordTypeId', myRecordType.Id);
            Set<String> fieldNameSet = fieldNameToValueMap.keySet();
            system.debug('sd1:' + myRecordType.Id);
// Custom change starts
            Map<String, Schema.SObjectField> field_map = newSObj.getSObjectType().getDescribe().fields.getMap();
            for (String fieldName : fieldNameSet) {
                system.debug('sd2:' + fieldNameToValueMap.get(fieldName));
                if (fieldNameToValueMap.get(fieldName) != null) {
                    if (field_map.get(fieldName).getDescribe().getType().name() == 'Date') {
                        newSObj.put(fieldName, date.parse(fieldNameToValueMap.get(fieldName)));
                    }
                    else {
                         system.debug('sd3:' + fieldName);
                        system.debug('sd4:' + fieldNameToValueMap.get(fieldName));
                        newSObj.put(fieldName, fieldNameToValueMap.get(fieldName));
                    }
                }
            }
// Custom change ends
            return addNewTableRow(index, newSObj);
        }
        
        public TableRow cloneNewSObjectByTableRowId(String trId) {
            TableRow tr = getTableRowById(trId);
            if (tr != null)
                return cloneNewSObject(tr.mySObj);
            return null;
        }
        public TableRow cloneNewSObject(sObject sObj) { return cloneNewSObject(sObj, this.isCreateBeforeFirstRow); }
        public TableRow cloneNewSObject(sObject sObj, Boolean beforeFirstRow) { return cloneNewSObject(sObj, !beforeFirstRow ? this.myRecordList.size() : 0); }
        public TableRow cloneNewSObject(sObject sObj, Integer index) {
            sObject newSObj = sObj.clone(false, true, false, false);
            if (hasRecordType)
                newSObj.put('RecordTypeId', myRecordType.Id);
            Set<String> fieldNameSet = fieldNameToValueMap.keySet();
            for (String fieldName : fieldNameSet) {
                if (!myDisplayFieldSet.contains(fieldName))
                    newSObj.put(fieldName, fieldNameToValueMap.get(fieldName));
            }
            return addNewTableRow(index, newSObj);
        }
        
        public void deleteAll() {
            List<TableRow> newTRList = new List<TableRow>();
            Integer size = myRecordList.size();
            for (Integer i = 0; i < size; i++) {
                TableRow tr = myRecordList.get(i);
                if (!tr.isNew) {
                    tr.isDelete = true;
                    newTRList.add(tr);
                }
            }
            myRecordList = newTRList;
        }
        
        private TableRow addNewTableRow(Integer index, SObject newSObj) {
            TableRow tr = new TableRow(this, newSObj, true);
            if (this.myRecordList.size() == 0 || index >= this.myRecordList.size())
                this.myRecordList.add(tr);
            else
                this.myRecordList.add(index, tr);
            return tr;
        }
    
        private TableRow getTableRowBySObjId(ID sObjId) {
            for (TableRow tr : myRecordList) {
                if (tr.mySObj.Id != null && tr.mySObj.Id == sObjId)
                    return tr;
            }
            return null;
        }
        private TableRow getTableRowById(String trid) {
            for (TableRow tr : myRecordList) {
                if (tr.id != null && tr.id == trid)
                    return tr;
            }
            return null;
        }
    }
    
    public class TableRow {
        public String id { get; private set; }
        public sObject mySObj { get; set; }
        public Boolean isNew { get; set; }
        public Boolean isEdit { get; set; }
        public Boolean isDelete { get; set; }
        public Boolean isBlankAndHidden { get; set; }
        private RecordTypeElement rtEle;
        
        public TableRow(RecordTypeElement rtEle, sObject mySObj, Boolean isNew) {
            this.id = String.valueOf(rtEle.tableRowNextId++);
            this.mySObj = mySObj;
            this.isNew = isNew;
            this.isEdit = isNew;
            this.isDelete = false;
            this.isBlankAndHidden = false;
        }
    }
    
    public class DisplayCol {
        public String colKey { get; set; }
        public String colLabel { get; set; }
        public List<DisplayField> displayFieldList { get; set; }
        public String colWidth { get; set; }
        
        public DisplayCol(String colKey, String colLabel) {
            this.colKey = colKey;
            this.colLabel = colLabel;
            this.displayFieldList = new List<DisplayField>();
        }
        
        public void addDisplayField(DisplayField displayField) {
            this.displayFieldList.add(displayField);
        }
    }
    
    public class DisplayField {
        public String label { get; set; }
        public String name { get; set; }
        public Boolean isRequired { get; set; }
        public String readonlyMode { get; set; }
        public String width { get; set; }
        public String colKey { get; set; }
        public Boolean skipClone { get; set; }
        public Boolean isPickList { get; set; }  //Add by Abel
        
        public DisplayField(String label, String name) {
            this.label = label;
            this.name = name;
            this.isRequired = false;
            this.readonlyMode = null;
            this.width = 'auto';
        }

//Add by Abel        
        public DisplayField(String label, String name, Boolean isPickList) {
            this.label = label;
            this.name = name;
            this.isRequired = false;
            this.readonlyMode = null;
            this.width = 'auto';
            this.isPickList = isPickList;
        }        
        
    }
    
    public with sharing class PageBlockActionBtn {
        public String id { get; set; }
        public String label { get; set; }
        
        public PageBlockActionBtn(String id, String label) {
            this.id = id;
            this.label = label;
        }
    }
    
// Custom change starts
    private string formatMsg(string msg) {
        if (msg.contains('duplicate value found: ASI_MFM_Sys_Deduplication_Key__c')) {
            msg = 'Duplicated Plan Line Items are detected. Please Adjust';
        }
        return msg;
    }
// Custom change ends    
}