public with sharing class EUR_CRM_ProsSegmentationFactory {

  public Interface IProsSegmentationInterface{
    Boolean hasVolumeCard();
  }
  
  public virtual class ProsSementationFactoryBase{}
  
  public class EUR_PRT_PROS_Segmentation extends ProsSementationFactoryBase implements IProsSegmentationInterface{
    public Boolean hasVolumeCard(){
      return true;
    }
  }
}