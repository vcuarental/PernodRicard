public interface ASI_eForm_MassCreateAndUpdateExtAbstract extends ASI_eForm_MassCreateAndUpdateAbstract {
    void mcau_triggerActionAfterCommitAll(ASI_eForm_MassCreateAndUpdateController controller);
    boolean mcau_triggerActionBeforeCommitAll(ASI_eForm_MassCreateAndUpdateController controller);
}