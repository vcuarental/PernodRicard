public with sharing class ASI_CRM_SG_PromotionYearGroup implements Comparable {
      public String groupName { get; private set; }
      public String height { get; private set; }
      public Integer heightInt { get; set { heightInt = value; height = '' + heightInt + 'px'; } }
      
      public ASI_CRM_SG_PromotionYearGroup(String groupName) {
          system.debug('@groupName'+groupName);
          this.groupName = groupName;
      }
      
      public Integer compareTo(Object objectToCompareTo) {
          return groupName.compareTo(((ASI_CRM_SG_PromotionYearGroup)objectToCompareTo).groupName);
      }
  }