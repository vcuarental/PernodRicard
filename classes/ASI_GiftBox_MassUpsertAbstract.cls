public interface ASI_GiftBox_MassUpsertAbstract extends ASI_GiftBox_PageInterface { 
    List<ASI_GiftBox_MassUpsertController.PageBlockActionBtn> mcau_initPageBlockActionButtonList(); 
    PageReference mcau_triggerPageBlockAction(Object controller, String actionKey);
    void mcau_triggerActionForSObject(ASI_GiftBox_MassUpsertController controller, String actionKey, sObject sObj);
}